{-# LANGUAGE NoImplicitPrelude #-}

-- | Helpers of the no-pragmas test that live in another package.
-- See Note [No INLINABLE pragmas] in no-pragmas/Main.hs.
module NoPragmasDep
  ( Colour (..)
  , Weight (..)
  , totalWeight
  , power
  , countDown
  ) where

import PlutusTx.Prelude

data Colour = Red | Green | Blue

class Weight a where
  weight :: a -> Integer

instance Weight Colour where
  weight Red = 1
  weight Green = 10
  weight Blue = 100

-- A function with a class constraint, used at a type of this package.
totalWeight :: Weight a => [a] -> Integer
totalWeight [] = 0
totalWeight (x : xs) = weight x + totalWeight xs

-- A recursive function with an accumulator: GHC gives it a worker and a
-- wrapper at -O1.
power :: Integer -> Integer -> Integer
power b = go 1
  where
    go acc e = if e <= 0 then acc else go (acc * b) (e - 1)

-- Mutual recursion.
countDown :: Integer -> Integer
countDown n = if n <= 0 then 0 else countUp (n - 1)

countUp :: Integer -> Integer
countUp n = 1 + countDown n
