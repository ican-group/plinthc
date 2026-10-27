{-# LANGUAGE TemplateHaskell #-}
-- EXPECT: ok
-- twiceSize is valid Plinth; instantiating it at Integer passes a
-- valid dictionary, even though the same class has an invalid instance.
module PolyOkInstOk where

import PlutusTx
import SizeClassHelper

code :: CompiledCode (Integer -> Integer)
code = $$(PlutusTx.compile [|| twiceSize :: Integer -> Integer ||])
