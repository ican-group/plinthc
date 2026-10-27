{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fplugin-opt Plinth.Plugin:conservative-optimisation #-}
-- plinth-test: expect-success
-- The long form of a Plinth option still works, with a deprecation
-- warning that gives the short form.
module OptionDeprecated where

import PlutusTx
import qualified PlutusTx.Prelude as P

addOne :: CompiledCode (Integer -> Integer)
addOne = $$(compile [|| \i -> i P.+ 1 ||])
