{-# LANGUAGE NoImplicitPrelude #-}
-- On-chain function with patterns on Integer literals, used by the
-- integer-patterns test-suite from another package component.
-- See Note [Integer literal patterns] in integer-patterns/Main.hs.
module IntegerPatterns (classify) where

import PlutusTx.Prelude

classify :: Integer -> Integer
classify 42 = 1
classify (-3) = 2
-- Above 2^64: GHC represents this literal with the IP constructor.
classify 18446744073709551621 = 3
classify 0 = 4
classify _ = 5
