{-# LANGUAGE TemplateHaskell #-}
-- Unsupported construct three modules away: the error must show the
-- chain CrossModuleChain -> ChainMiddleHelper -> ChainInnerHelper ->
-- GHC.Types.Int.
module CrossModuleChain where

import ChainMiddleHelper (countTwice)
import PlutusTx

code :: CompiledCode ([Integer] -> Integer)
code = $$(PlutusTx.compile [|| countTwice ||])
