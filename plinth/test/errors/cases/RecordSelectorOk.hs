{-# LANGUAGE TemplateHaskell #-}
-- EXPECT: ok
-- Record selectors are ordinary bindings with a status.
module RecordSelectorOk where

import PlutusTx
import qualified PlutusTx.Prelude as P

data Account = Account { owner :: Integer, balance :: Integer }

total :: Account -> Integer
total a = owner a P.+ balance a

code :: CompiledCode (Account -> Integer)
code = $$(PlutusTx.compile [|| total ||])
