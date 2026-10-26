-- Helper for MutualDataImported: mutually recursive data types.
module MutualDataHelper (Tree (..), Forest (..), leaf) where

data Tree = Node Integer Forest
data Forest = Nil | Cons Tree Forest

leaf :: Integer -> Tree
leaf i = Node i Nil
