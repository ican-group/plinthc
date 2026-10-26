{-# LANGUAGE TemplateHaskell #-}
-- Mutually recursive data types from another module.
module MutualDataImported where

import MutualDataHelper
import PlutusTx

code :: CompiledCode (Integer -> Tree)
code = $$(PlutusTx.compile [|| leaf ||])
