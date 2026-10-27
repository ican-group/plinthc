{-# LANGUAGE MagicHash #-}
{-# LANGUAGE TemplateHaskell #-}
-- Unsupported construct: pattern match on the constructors of Integer.
-- (A pattern on an Integer literal is supported: see the
-- integer-patterns test-suite.)
module IntegerConstructorMatch where

import GHC.Num (Integer (IS))
import PlutusTx

isSmall :: Integer -> Bool
isSmall (IS _) = True
isSmall _ = False

code :: CompiledCode (Integer -> Bool)
code = $$(PlutusTx.compile [|| isSmall ||])
