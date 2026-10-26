{-# LANGUAGE TemplateHaskell #-}
-- EXPECT: ok
-- The same invalid default method, overridden by the instance: the
-- instance is valid.
module DefaultMethodOverridden where

import MeasureHelper
import PlutusTx

code :: CompiledCode (Dot -> Integer)
code = $$(PlutusTx.compile [|| measure ||])
