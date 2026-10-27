{-# LANGUAGE TemplateHaskell #-}
-- A derived Show instance used on chain: show is a method of the
-- Haskell Show class, whatever the instance.
module DerivingShowUsed where

import PlutusTx
import PlutusTx.Builtins (BuiltinString)
import PlutusTx.Builtins.HasOpaque (stringToBuiltinString)

data Pair = Pair Integer Integer
  deriving (Show)

describe :: Pair -> BuiltinString
describe p = stringToBuiltinString (show p)

code :: CompiledCode (Pair -> BuiltinString)
code = $$(PlutusTx.compile [|| describe ||])
