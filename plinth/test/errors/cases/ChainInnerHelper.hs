-- Helper for CrossModuleChain: the innermost link, which uses a base
-- function over Int.
module ChainInnerHelper (count) where

count :: [Integer] -> Integer
count xs = fromIntegral (length xs)
