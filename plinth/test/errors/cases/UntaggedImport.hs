{-# LANGUAGE TemplateHaskell #-}
-- An import from a module compiled without the Plinth check carries no
-- status, so it cannot be trusted.
module UntaggedImport where

import PlutusTx
import UntaggedHelper (untagged)

code :: CompiledCode (Integer -> Integer)
code = $$(PlutusTx.compile [|| untagged ||])
