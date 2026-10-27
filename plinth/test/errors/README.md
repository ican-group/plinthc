# Plinth error-message golden tests

This directory holds golden tests for the compile-time error messages
of the Plinth compiler (plinthc). Each file in `cases/` uses one
Haskell construct that Plinth does not support. The runner compiles
each case, expects the compilation to fail, and compares the compiler
output with the golden file in `golden/`.

The suite runs in two modes:

- `gate` (default): the Plinth check of the type checker rejects the
  code with a `[PLINTH-00008]` error that shows the chain of
  definitions from the splice to the unsupported feature. Goldens in
  `golden/`.
- `nogate` (`-fno-plinth-gate`, what `defer-errors` selects): the
  plugin's Core to PIR compile rejects the code. Goldens in
  `golden/nogate/`. This path stays as the fallback, so its messages
  are pinned too.

`MODES="gate"` runs one mode. A case whose first lines contain
`-- EXPECT: ok` must compile without any diagnostic: these cases pin
down what the check must accept (a derived `Show` instance that is
not used on chain, a polymorphic function instantiated at a valid
instance, the compiler primitives, ...).

The plutus-tx-plugin test-suites only test the `defer-errors` path,
which drops source locations and source snippets. These tests capture
the real user-facing output, so changes to error reporting show up as
golden diffs here.

## Usage

```
# run (after plinthc-build.sh and the plinth/test build):
./run-error-tests.sh

# update the golden files:
ACCEPT=1 ./run-error-tests.sh

# use a different compiler:
GHC=/path/to/plinthc ./run-error-tests.sh
```

`plinthc-test.sh` runs this suite automatically.

All cases compile with `preserve-source-locations` enabled, because
the goal of this suite is to track how much source-location
information each error carries.

## Cases

Every error carries a source location in its GHC header
("File.hs:l:c: error: [PLINTH-000NN]"). The Location column tells how
precise it is in gate mode: "expression" points at the offending
expression, "definition" at the binding that uses the unsupported
feature, and "splice" at the whole `$$(PlutusTx.compile ...)`
expression (the feature is used by the splice argument itself, or by
an imported binding). "chain" means the message lists the definitions
between the splice and the feature. The `nogate` goldens keep the
locations of the plugin path, which are often less precise.

| Case                    | Construct                                | Location          |
|-------------------------|------------------------------------------|-------------------|
| BadInstanceDict         | instance method over Int, selected       | splice, chain     |
| CrossModuleChain        | three modules, Int through fromIntegral  | splice, chain     |
| DeepChain               | NOINLINE import inside nested functions  | expression, chain |
| DefaultMethodBad        | default method over Int, not overridden  | splice, chain     |
| DefaultMethodOverridden | default method over Int, overridden      | EXPECT ok         |
| DerivingShowOk          | derived Show not used on chain           | EXPECT ok         |
| DerivingShowUsed        | derived Show used on chain               | expression, chain |
| EnumMethod              | Prelude Enum method                      | splice            |
| EnumRange               | range syntax / enumFromTo                | splice            |
| EnumRangeUnbounded      | range syntax / enumFrom                  | splice            |
| Existential             | existential data type                    | definition, chain |
| GadtExtension           | GADT constructor                         | definition, chain |
| HaskellEq               | Prelude Eq method                        | splice            |
| HaskellOrd              | Prelude Ord method                       | splice            |
| HaskellShow             | Prelude Show method                      | splice            |
| IntegerPatternMatch     | pattern match on Integer literal         | expression, chain |
| IOAction                | IO action                                | splice            |
| IrreducibleTypeFamily   | irreducible type family application      | definition, chain |
| LibraryChain            | Data.Map from containers (Int inside)    | definition, chain |
| LitChar                 | Char literal                             | splice            |
| LitDouble               | Double literal                           | splice            |
| LitString               | String literal ([Char])                  | splice            |
| MachineInt              | Int                                      | splice            |
| MachineWord             | Word64                                   | splice            |
| MutualData              | mutually recursive data types            | definition, chain |
| MutualDataImported      | mutually recursive data types, imported  | splice, chain     |
| NoUnfolding             | imported NOINLINE function               | splice, chain     |
| PolyKindsExtension      | PolyKinds extension, not used on chain   | EXPECT ok-gate    |
| PolyOkInstBad           | polymorphic helper at an invalid instance | splice, chain    |
| PolyOkInstOk            | polymorphic helper at a valid instance   | EXPECT ok         |
| PreludeError            | Prelude.error                            | splice            |
| PreludeUndefined        | Prelude.undefined                        | splice            |
| RecordSelectorBad       | selector of a record with a String field | definition, chain |
| RecordSelectorOk        | selector of a valid record               | EXPECT ok         |
| RecursiveNewtype        | recursive newtype                        | definition, chain |
| SameModuleChain         | two same-module functions, Int inside    | expression, chain |
| ToBuiltinUsed           | toBuiltin in compiled code               | splice            |
| TrustedBuiltins         | builtins, fix, &&, toOpaque, mkNilOpaque | EXPECT ok         |
| TypeByteString          | ByteString type                          | splice            |
| TypeText                | Text type                                | splice            |
| UntaggedImport          | import from a module built without the check | splice, chain |

Files named `*Helper.hs` are companion modules of the multi-module
cases.

## How the gate works

The Plinth check (GHC.Plinth.Check in the compiler) runs at the end
of the type checker on every module. It gives each top-level binding
a status (Ok, or Bad with the direct culprit: an imported binding, a
type, or a language feature), stores it in the interface file, and
rejects each `$$(PlutusTx.compile ...)` splice whose argument reaches
a Bad binding. The message follows the culprits from the splice to
the feature, with the definition site of each binding of the home
unit and the unit name of the others. Several paths to the same
feature give one message.

The location is the deepest offending expression in the module being
compiled: the expression itself for a same-module binding, the splice
when the problem is in the splice argument or in an import.

## How the location machinery of the plugin path works (nogate)

- injectAnchors (plutus-tx-plugin:PlutusTx.Plugin.Common) wraps
  variables (bare or under a wrapper, e.g. class methods) and
  literals in `anchor @loc` when `preserve-source-locations` is on.
- injectUnsupportedMarkers (plutus-tx-plugin:PlutusTx.Plugin.Unsupported)
  always wraps known-unsupported expressions in `unsupported @msg
  @loc`: methods of the base Eq, Ord, Show and Enum classes, range
  syntax, Prelude.error / errorWithoutStackTrace / undefined, and
  expressions with IO types. Each entry carries a "use X instead"
  suggestion.
- Every compiled definition gets a fall-back context frame with the
  binder's location: the marked expression itself
  (withDefinitionContext in plutus-tx-plugin:PlutusTx.Plugin.Common)
  and every function whose body or unfolding the compiler enters
  (hoistExpr in plutus-tx-plugin:PlutusTx.Compiler.Expr). Datatype
  definitions carry the source span of their type constructor and
  data constructors in the PIR annotations.
- runPluginM throws a located GHC diagnostic (PlinthDiagnostic, with
  a [PLINTH-000NN] error code per error class) at the innermost span
  in the error context, so GHC prints the "File.hs:l:c: error:"
  header and the source snippet with the caret. When the gate is on,
  such a failure is reported as [PLINTH-00009], an internal error:
  the check accepted the code.
- The Core shown in "Context:" frames is rendered with the GHC
  suppression flags (no occurrence info, coercions, uniques, ticks)
  and with the anchor/unsupported markers stripped.

## Known reporting gaps (as pinned by the goldens)

The goldens document the current behavior, including its defects.
When you fix one of these, update the golden files.

1. Code written inside `[|| ... ||]` quotes keeps only the
   splice-point location through typed TH, so a problem in the splice
   argument itself points at the whole splice. The gate locates a
   problem in a same-module helper at its definition, whatever GHC
   inlines later.

2. The gate reports every unsupported feature a splice reaches, so a
   splice can get several messages for one cause (`show x` on chain:
   the Show class and the String result type).

3. Context frames of the plugin path (nogate) show GHC Core
   (suppressed, but still Core: dictionary methods like
   `$fShowInteger_$cshow`, `IS`/`IP` constructors), which does not
   resemble the user's source code.

4. The markers of the plugin path are injected into every module that
   plinthc compiles, including off-chain code, where the OPAQUE
   identity wrappers can block GHC optimizations. With the gate they
   are only needed under `defer-errors`.

## Notes on the runner

The runner normalizes the output before the comparison: it strips
ANSI escapes, GHC uniques (`x_a5GN` -> `x`), `[N of M]` progress
lines, and CR characters. Files named `*Helper.hs` in `cases/` are
companion modules for multi-module cases, not test cases. The modules
in `cases/prebuilt/` are compiled first with `-fno-plinth-status`,
to stand for a library built without the Plinth check (the
`UntaggedImport` case); the runner adds their output directory to the
search path.
