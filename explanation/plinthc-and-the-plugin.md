---
title: "Difference between plinthc and the plugin"
permalink: /explanation/plinthc-and-the-plugin/
---
plinthc is GHC with the Plinth compiler built in (see
[plinthc]({% link explanation/standalone-compiler.md %})). Because the compiler
is ours, we can change GHC for Plinth. This page describes what a Plinth
developer sees that is different from a stock GHC with the `plutus-tx-plugin`
package:

1. Plinth code can use the definitions of all modules and packages without
   `INLINEABLE` pragmas, not only the definitions of the modules compiled with
   the plugin.
2. Each Plinth compilation error points at a location in the Haskell source.
3. Some smaller differences: the setup and the script hashes (see
   [Other differences](#other-differences)).

The page also tells how the tests check the first two differences. The changes are in
all releases since 9.6.170.1 and 9.12.170.1. The last location fallback (the
start of the module, see below) and the tests below are in all releases since
9.6.170.2 and 9.12.170.2. GHC adds the `INLINEABLE` pragmas (also in the boot
libraries) since 9.6.172.2 and 9.12.172.2. Before, the built-in plugin added
them, and of the boot libraries only `base`, `ghc-prim` and `ghc-bignum` (and
`ghc-internal` for GHC 9.12) had all their unfoldings.

## No `INLINEABLE` pragmas

### With the plugin

To compile a function to Plutus Core, the compiler needs its GHC Core
definition (its *unfolding*). For a function of another module, GHC writes
the unfolding to the interface file only when it decides to. An `INLINEABLE`
pragma makes GHC keep it.

Since Plutus 1.62, the plugin (`-fplugin Plinth.Plugin`) adds `INLINEABLE` to
each definition that has no inline pragma of its own. But it does this only in
the modules that it compiles. Thus you still need `INLINEABLE` pragmas, or the
plugin, in:

- a helper package that does not load the plugin, for example a library that
  was not written for Plinth;
- a module compiled with `-O0` in an `OPTIONS_GHC` pragma. The plugin unsets
  `-fomit-interface-pragmas` for the session, but `-O0` in the module sets it
  again, and GHC then drops the unfoldings of the module.

Most definitions of `base` are not available either, because stock GHC keeps
only some of their unfoldings.

For example, this module is in a package that does not load the plugin:

```haskell
module Helpers where

import PlutusTx.Prelude

sumTo :: Integer -> Integer
sumTo n = if n <= 0 then 0 else n + sumTo (n - 1)
```

When Plinth code in another package uses `sumTo`, the compilation fails with
"Reference to a name which is not a local, a builtin, or an external
INLINABLE function". `sumTo` is recursive, so GHC does not keep its unfolding
on its own. The fix is `{-# INLINEABLE sumTo #-}` in `Helpers`.

### With plinthc

GHC itself adds the `INLINEABLE` pragmas, in each module that it compiles, also
when it builds its own boot libraries. The `Helpers` module above compiles without
the pragma (this `sumTo` is one of the functions of the
[no-pragmas test](#how-the-tests-check-this)). In plinthc, `-O0` does not set
`-fomit-interface-pragmas`, so a module with `-O0` keeps its unfoldings.

This is true for:

- definitions in other modules of the same package;
- definitions in other packages, also packages that do not set the GHC flags
  of a Plinth project and do not load the plugin;
- functions, recursive and mutually recursive functions, data types, classes
  and instances;
- modules compiled at all optimisation levels (`-O0`, `-O1` and `-O2`),
  unless a module sets `-fomit-interface-pragmas`;
- the boot libraries that come with plinthc, for example `base` and
  `containers` (but not the `ghc` library, the GHC API). Plinth can compile a
  function of these libraries if the function uses only features that Plinth
  supports: for example, `foldTree` from `Data.Tree`, but not the functions
  that use machine `Int`, primitive arrays or the FFI.

GHC also changes a `NOINLINE` pragma with a phase (for example
`NOINLINE [1] f`, which `base` uses for list fusion) to `INLINEABLE` with the
same phase. Thus `map`, `filter`, `++` and similar functions are available.

How it works:
[Unfoldings and `INLINEABLE`]({% link explanation/plinth-language.md %}#unfoldings-and-inlineable).

### The limit

A `NOINLINE` or `OPAQUE` pragma hides the definition. If on-chain code uses
such a function, the compiler gives the name of the function and the fix
(error `PLINTH-00005`, see
[Functions without unfoldings]({% link explanation/differences-from-haskell.md %}#functions-without-unfoldings)).

## Errors with a source location

### With the plugin

The plugin reports a Plinth compilation error as a GHC exception, not as a
GHC diagnostic. GHC prints it without a location in the error header and
without an error code:

```
<no location info>: error:
    Plinth Compilation Error:
    Context: ...
    Error: Unsupported feature: ...
```

The `Context:` lines can name a location, and the message can show a source
line. But editors, IDEs and build tools use the header to find the error, so
they cannot put it in a file.

Also, the plugin knows a location only for some expressions: the methods of
the `Eq` and `Ord` classes of `base`, `IO` actions, and, with the option
`preserve-source-locations`, variables and literals. For other errors, the
message often has no location at all.

### With plinthc

Each Plinth compilation error is a GHC diagnostic. It has a file, a line and
a column, an error code from `PLINTH-00001` to `PLINTH-00007`, and the source
line with a caret. Editors and build tools read it as they read other GHC
errors.

When the error is in a function of another module, the error points at that
module, not at the `compile` splice that uses the function:

```
CrossModuleHelper.hs:8:29: error: [PLINTH-00004]
    Plinth Compilation Error:
    Context: Compiling code at CrossModuleHelper.hs:8:29-33:
             GHC.Internal.Err.error
    Error: Unsupported feature: GHC.Internal.Err.error, use PlutusTx.Prelude.error or PlutusTx.Prelude.traceError
  |
8 | checked n = if n P.< 0 then error "negative" else n
  |                             ^^^^^
```

The meaning of each error code:
[How the compiler reports an unsupported feature]({% link explanation/differences-from-haskell.md %}#how-the-compiler-reports-an-unsupported-feature).

### Which location

The compiler gives the most precise location that it has, in this order:

1. The expression that causes the error. This is the location for the known
   unsupported constructs (the `Eq`, `Ord`, `Show` and `Enum` classes of
   `base`, `error`, `undefined`, `IO`, range syntax), and for code in other
   definitions and modules. The plugin marks only `Eq`, `Ord` and `IO`;
   plinthc adds the others, each with the replacement to use.
2. The definition (function or data type) that the compiler could not
   compile. Only plinthc gives this location: it records the location of
   each top-level definition that it compiles.
3. The `$$(compile ...)` splice, for code that you write directly in the
   quote.
4. The start of the module, only in plinthc. plinthc uses this location only
   when it has no other location, so no error is without a location.

The option `-fplugin-opt Plinth.Plugin:preserve-source-locations` makes more
errors point at the expression (level 1). The plugin has the same option. It
is off by default, because it makes the compilation slower.

### Known limits

- An error in code that you write directly in a `[|| ... ||]` quote points at
  the full splice, not at the expression in the quote. GHC can also inline a
  small function of the same module into the splice. To get a more precise
  location, put the code in a function of another module.
- The `Context:` lines show GHC Core, not your Haskell source.

## How the tests check this

Two test suites in the plinthc repository check the two changes. The script
`plinthc-test.sh` runs them, with the test suites of the Plinth compiler.
The links below are to release 9.12.172.2.

| Test suite | What it checks |
|------------|----------------|
| [`plinth/test/no-pragmas`][no-pragmas] | A script that uses functions, a class and its instances, and recursive and mutually recursive functions from two other modules, from [another package][no-pragmas-dep], and from the `Data.Tree` module of the `containers` boot library. No module has an `INLINEABLE` pragma. Two modules use `-O0`, the others `-O1`. The other package does not set the GHC flags of a Plinth project. The test compiles the script, runs it, and checks the result. It also checks that a wrong input makes the script fail. |
| [`plinth/test/errors`][errors] | 28 programs. Each one uses a construct that Plinth does not support. Each program compiles with and without `preserve-source-locations` (56 compilations). The test compares the full compiler output with an expected file. A second check fails if an error has no source location. Two programs have the error in an imported module. The [README][errors-readme] gives the location of each error. |

The CI of the plinthc repository runs `plinthc-test.sh` on Linux (x86-64 and
AArch64, glibc and musl), macOS and Windows, for the GHC 9.6 and GHC 9.12
compilers. The release job runs only after all the test jobs pass, so each
release passed these tests on each platform. To run the tests yourself, see
[Test and benchmark]({% link how-to/build.md %}#test-and-benchmark).

[no-pragmas]: https://github.com/ican-group/plinthc/blob/v9.12.172.2/plinth/test/no-pragmas/Main.hs
[no-pragmas-dep]: https://github.com/ican-group/plinthc/blob/v9.12.172.2/plinth/test/no-pragmas-dep/src/NoPragmasDep.hs
[errors]: https://github.com/ican-group/plinthc/tree/v9.12.172.2/plinth/test/errors
[errors-readme]: https://github.com/ican-group/plinthc/blob/v9.12.172.2/plinth/test/errors/README.md

## Other differences

- **Setup.** With plinthc, a project needs no `-fplugin` flag and no
  `plutus-tx-plugin` dependency: it names plinthc as its compiler. It takes
  `plutus-tx` and `plutus-core` from the `ghc-plinth-plutus` commit of its
  plinthc release, not from CHaP (see
  [Use plinthc in a project]({% link how-to/use.md %})).
- **Script hashes.** plinthc and the plugin can compile the same source to a
  different script, thus to a different hash and address (see
  [Script hashes when you move from the plugin]({% link explanation/standalone-compiler.md %}#script-hashes-when-you-move-from-the-plugin)).

## Further reading

- [The Plinth contract language]({% link explanation/plinth-language.md %})
- [Differences from Haskell]({% link explanation/differences-from-haskell.md %})
- [plinthc]({% link explanation/standalone-compiler.md %})
