{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fplinth-report-cost #-}
-- plinth-test: expect-success
-- -fplinth-report-cost: the size of a script with arguments, and the
-- execution units and fee of a script without arguments. A PlutusV3 script
-- must return unit: sumTo gives an error message.
module ReportCost where

import PlutusTx
import qualified PlutusTx.Prelude as P

addOne :: CompiledCode (Integer -> Integer)
addOne = $$(compile [|| \i -> i P.+ 1 ||])

sumDown :: Integer -> Integer
sumDown n = if n P.== 0 then 0 else n P.+ sumDown (n P.- 1)

sumTo :: CompiledCode Integer
sumTo = $$(compile [|| sumDown 100 ||])

checkSum :: CompiledCode P.BuiltinUnit
checkSum = $$(compile [|| P.check (sumDown 100 P.== 5050) ||])
