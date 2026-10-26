-- Helper for CrossModuleChain: the middle link, valid by itself.
module ChainMiddleHelper (countTwice) where

import ChainInnerHelper (count)
import qualified PlutusTx.Prelude as P

countTwice :: [Integer] -> Integer
countTwice xs = count xs P.+ count xs
