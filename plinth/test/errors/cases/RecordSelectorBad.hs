{-# LANGUAGE TemplateHaskell #-}
-- A record with a String field: the selector of the valid field is
-- still a function over the invalid type.
module RecordSelectorBad where

import PlutusTx

data Account = Account { name :: String, balance :: Integer }

code :: CompiledCode (Account -> Integer)
code = $$(PlutusTx.compile [|| balance ||])
