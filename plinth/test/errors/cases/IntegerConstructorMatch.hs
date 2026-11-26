{-# LANGUAGE MagicHash #-}
{-# LANGUAGE TemplateHaskell #-}
-- Unsupported construct: pattern match on the constructors of Integer.
-- (With GHC 9.6, a pattern on an Integer literal compiles: it desugars
-- to integerEq, which GHC does not inline and Plinth compiles to the
-- builtin equalsInteger.)
module IntegerConstructorMatch where

import GHC.Num (Integer (IS))
import PlutusTx

isSmall :: Integer -> Bool
isSmall (IS _) = True
isSmall _ = False

code :: CompiledCode (Integer -> Bool)
code = $$(PlutusTx.compile [|| isSmall ||])
