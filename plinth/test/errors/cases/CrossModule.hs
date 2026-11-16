{-# LANGUAGE TemplateHaskell #-}
-- Unsupported construct in a function of another module: the error
-- must point at the offending code in CrossModuleHelper.hs, not at the
-- splice of this module.
module CrossModule where

import CrossModuleHelper (checked)
import PlutusTx
import qualified PlutusTx.Prelude as P

twice :: Integer -> Integer
twice i = checked i P.+ checked i

code :: CompiledCode (Integer -> Integer)
code = $$(PlutusTx.compile [|| twice ||])
