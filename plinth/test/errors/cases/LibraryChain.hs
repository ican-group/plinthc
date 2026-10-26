{-# LANGUAGE TemplateHaskell #-}
-- A function from a library that plinthc built (containers): the chain
-- goes into the library's own source.
module LibraryChain where

import qualified Data.Map as Map
import PlutusTx

single :: Integer -> Map.Map Integer Integer
single k = Map.insert k k Map.empty

code :: CompiledCode (Integer -> Map.Map Integer Integer)
code = $$(PlutusTx.compile [|| single ||])
