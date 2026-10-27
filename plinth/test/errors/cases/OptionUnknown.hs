{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fplinth-report-costs #-}
-- An unknown Plinth option: the error gives the flag and a suggestion.
module OptionUnknown where

import PlutusTx
import qualified PlutusTx.Prelude as P

addOne :: CompiledCode (Integer -> Integer)
addOne = $$(compile [|| \i -> i P.+ 1 ||])
