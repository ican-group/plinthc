{-# LANGUAGE TemplateHaskell #-}
-- twiceSize is valid Plinth; instantiating it at Bag passes the
-- Size Bag dictionary, which uses length over Int.
module PolyOkInstBad where

import PlutusTx
import SizeClassHelper

code :: CompiledCode (Bag -> Integer)
code = $$(PlutusTx.compile [|| twiceSize ||])
