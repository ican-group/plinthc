-- Note [Integer literal patterns]
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- A pattern on an Integer literal desugars to a call to integerEq, which
-- Plinth compiles to the builtin equalsInteger. GHC must not inline
-- integerEq into the stable unfolding first, otherwise the unfolding has a
-- case on the constructors of Integer (IS, IP, IN), which Plinth cannot
-- compile (error PLINTH-00004). See Note [Plinth: integerEq in stable
-- unfoldings] in ghc-bignum:GHC.Num.Integer.
--
-- This test compiles 'classify' from another module (IntegerPatterns, in
-- library plinth-validators) and 'classifyHere' from this module, and
-- evaluates both on each literal, on the values next to them, and on the
-- default case.
module Main (main) where

import PlutusTx
import PlutusTx.Eval (evaluatesWithoutError)
import PlutusTx.Prelude qualified as P
import System.Exit (exitFailure)

import IntegerPatterns (classify)

classifyHere :: Integer -> Integer
classifyHere 7 = 10
classifyHere (-7) = 20
classifyHere _ = 30

-- The script fails if a result is not the expected one.
script :: CompiledCode (Integer -> Integer -> Integer -> Integer -> P.BuiltinUnit)
script =
  $$( PlutusTx.compile
        [||
        \n expected m expectedHere ->
          P.check
            ( if classify n P.== expected P.&& classifyHere m P.== expectedHere
                then True
                else P.traceError "integer-patterns: wrong result"
            )
        ||]
    )

run :: Integer -> Integer -> Integer -> Integer -> Bool
run n expected m expectedHere =
  evaluatesWithoutError
    ( script
        `unsafeApplyCode` liftCodeDef n
        `unsafeApplyCode` liftCodeDef expected
        `unsafeApplyCode` liftCodeDef m
        `unsafeApplyCode` liftCodeDef expectedHere
    )

main :: IO ()
main
  | and
      [ run 42 1 7 10
      , run (-3) 2 (-7) 20
      , run 18446744073709551621 3 0 30
      , run 18446744073709551620 5 8 30
      , run 0 4 6 30
      , run 41 5 (-8) 30
      , run 3 5 7 10
      , -- The negative case makes sure that the check is not vacuous.
        not (run 42 5 7 10)
      ] =
      putStrLn "integer-patterns: OK"
  | otherwise = putStrLn "integer-patterns: FAILED" >> exitFailure
