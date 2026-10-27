-- Helper for PolyOkInstBad and PolyOkInstOk: a polymorphic function
-- over a user class is valid at its definition; the instances decide.
module SizeClassHelper (Size (..), Bag (..), twiceSize) where

import qualified PlutusTx.Prelude as P

class Size a where
  size :: a -> Integer

newtype Bag = Bag [Integer]

instance Size Bag where
  size (Bag xs) = fromIntegral (length xs)

instance Size Integer where
  size x = x

twiceSize :: Size a => a -> Integer
twiceSize x = size x P.+ size x
