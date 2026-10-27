{-# LANGUAGE TemplateHaskell #-}
-- Unsupported construct two same-module helpers away: the error must
-- show the chain outer -> inner -> GHC.List.length and point at the
-- offending expression in inner.
module SameModuleChain where

import PlutusTx
import qualified PlutusTx.Prelude as P

inner :: [Integer] -> Integer
inner xs = fromIntegral (length xs)

outer :: [Integer] -> Integer
outer xs = inner xs P.+ 1

code :: CompiledCode ([Integer] -> Integer)
code = $$(PlutusTx.compile [|| outer ||])
