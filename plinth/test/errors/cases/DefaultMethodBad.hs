{-# LANGUAGE TemplateHaskell #-}
-- A class default method that is not valid Plinth, taken by an
-- instance: the chain goes through the default method.
module DefaultMethodBad where

import MeasureHelper
import PlutusTx

code :: CompiledCode (Unit -> Integer)
code = $$(PlutusTx.compile [|| measure ||])
