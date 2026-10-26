---
title: "Compiler flags"
permalink: /reference/compiler-flags/
---
The Plinth compiler accepts every GHC flag, plus the flags below. They can be
given on the command line, in the `ghc-options` of a cabal file, or per module
in an `{-# OPTIONS_GHC ... #-}` pragma. A pragma comes after the command line,
so it wins.

## The Plinth check

| Flag                   | Default              | Effect                                                                                                    |
|------------------------|----------------------|-----------------------------------------------------------------------------------------------------------|
| `-fplinth-status`      | on                   | Compute the Plinth status of every top-level binding and store it in the interface file.                  |
| `-fno-plinth-status`   |                      | Turn the computation off. Bindings of the module then have no status and are rejected when used on chain. |
| `-fplinth-gate`        | on                   | Check every Plinth splice of the module at type-checking time and reject invalid code with `PLINTH-00008`.|
| `-fno-plinth-gate`     |                      | Leave the check of the splices to the Core to PIR compile (the fallback path).                            |
| `-fplinth-gate-warn`   | off                  | Report what the check would reject as warnings instead of errors. For sweeps over existing code.          |
| `-ddump-plinth-status` | off                  | Dump the status of every binding of the module and the verdict of every splice.                           |

Two plugin options also turn the check off for a module:
`-fplugin-opt Plinth.Plugin:defer-errors`, so that the error is deferred to
run time as the option promises, and `-fplugin-opt Plinth.Plugin:no-plinth-gate`,
for code that only the Core to PIR compile accepts. Both are ignored by a
stock GHC, so they are the portable way to write it in a module.

See [Differences from Haskell]({% link explanation/differences-from-haskell.md %})
for what the check accepts and how it reports a rejection.
