-- In plinthc, -O0 does not imply -fignore-interface-pragmas.
{-# OPTIONS_GHC -O0 #-}

-- Note [No INLINABLE pragmas]
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Plinth code can use functions of other modules and packages without
-- INLINABLE pragmas: GHC adds INLINABLE to every binding that has no
-- inline pragma of its own, so it keeps the unfoldings that the Plinth
-- compiler needs in the interface files (see Note [Default INLINABLE
-- pragmas] in ghc:GHC.Tc.Module).
--
-- In plinthc, -O0 does not imply -fomit-interface-pragmas and
-- -fignore-interface-pragmas (see Note [Keep interface pragmas] in
-- ghc:GHC.Driver.Session), so -O0 does not remove the unfoldings.
--
-- This test uses the helpers of NoPragmas and NoPragmasO0 (library
-- plinth-validators). NoPragmasO0 and this module use -O0. Without the
-- unfoldings, the splice below fails to compile. The test also
-- evaluates the script, to check that the definitions are correct.
--
-- NoPragmasDep is in another package (plinth-test-dep). That package
-- does not set the GHC flags of a Plinth project (-fno-strictness,
-- etc.), as a library that was not written for Plinth.
--
-- GHC also does this for the boot libraries. The test uses foldTree and
-- unfoldTree of containers (Data.Tree): containers has no INLINABLE
-- pragma on unfoldTree and its helper unfoldForest, and unfoldForest uses
-- map of base, which has a NOINLINE [0] pragma. The test does not compile
-- containers: it uses the containers package of plinthc.
module Main (main) where

import Data.Tree (foldTree, unfoldTree)
import PlutusCore.Version (plcVersion110)
import PlutusTx
import PlutusTx.Eval (evaluatesWithoutError)
import PlutusTx.Foldable qualified as F
import PlutusTx.Prelude qualified as P
import System.Exit (exitFailure)

import NoPragmas
import NoPragmasDep
import NoPragmasO0

-- The script fails if the condition is false. It uses 'traceError' on
-- purpose: GHC must not know that the builtin 'error' is bottom, otherwise
-- the unfolding of 'traceError' contains (case error of {}), which Plinth
-- cannot compile. PlutusTx.Builtins.Internal hides this with an explicit
-- -fomit-interface-pragmas (see Note [Keep interface pragmas] in
-- ghc:GHC.Driver.Session).
script :: CompiledCode (Integer -> P.BuiltinUnit)
script =
  $$( PlutusTx.compile
        [||
        \expected ->
          P.check
            ( if P.not (isEven 7)
                P.&& sumTo 4 P.== 10
                P.&& productTo 4 P.== 24
                P.&& totalWeight [Red, Blue, Green] P.== 111
                P.&& power 2 5 P.== 32
                P.&& countDown 3 P.== 3
                -- The children of n > 0 are (n - 1) and (n - 2). The sum
                -- of the tree is 3 + (2 + (1 + 0 + -1) + 0) + (1 + 0 + -1).
                P.&& foldTree
                  (\x xs -> x P.+ F.sum xs)
                  ( unfoldTree
                      (\n -> (n, if n P.<= 0 then [] else [n P.- 1, n P.- 2]))
                      (3 :: Integer)
                  )
                  P.== 5
                P.&& applyN 3 (P.+ 2) (sumAreas [Square 3, Rect 2 5]) P.== expected
                then True
                else P.traceError "no-pragmas: wrong result"
            )
        ||]
    )

-- The script has Plutus Core 1.1.0, the version for the default target
-- protocol version (11): the parameter is lifted at the same version.
run :: Integer -> Bool
run expected =
  evaluatesWithoutError (script `unsafeApplyCode` liftCode plcVersion110 expected)

main :: IO ()
main
  -- The negative case makes sure that the check is not vacuous.
  | run 25 && not (run 24) = putStrLn "no-pragmas: OK"
  | otherwise = putStrLn "no-pragmas: FAILED" >> exitFailure
