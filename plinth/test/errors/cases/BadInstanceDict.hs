{-# LANGUAGE TemplateHaskell #-}
-- A class method is fine, but the instance passed at the use site is
-- not: the chain goes through the instance dictionary.
module BadInstanceDict where

import PlutusTx
import SizeClassHelper

code :: CompiledCode (Bag -> Integer)
code = $$(PlutusTx.compile [|| size ||])
