{-# LANGUAGE TemplateHaskell #-}
-- EXPECT: ok
-- A derived Show instance for host-side tests does not make the type
-- invalid: only a use of show on chain would.
module DerivingShowOk where

import PlutusTx
import qualified PlutusTx.Prelude as P

data Pair = Pair Integer Integer
  deriving (Show)

addPair :: Pair -> Integer
addPair (Pair a b) = a P.+ b

code :: CompiledCode (Pair -> Integer)
code = $$(PlutusTx.compile [|| addPair ||])
