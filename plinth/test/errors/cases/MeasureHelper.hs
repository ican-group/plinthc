-- Helper for DefaultMethodBad and DefaultMethodOverridden: a class with
-- a default method that is not valid Plinth, and two instances.
module MeasureHelper (Measure (..), Unit (..), Dot (..)) where

class Measure a where
  measure :: a -> Integer
  measure _ = fromIntegral (length "default")

data Unit = Unit

-- Takes the default.
instance Measure Unit

data Dot = Dot

-- Overrides it.
instance Measure Dot where
  measure _ = 1
