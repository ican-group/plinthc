{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fplinth-report-cost -fplinth-target-protocol-version=12 #-}
-- plinth-test: expect-success
-- No pinned cost model for PV 12: the size only.
module ReportCostNoModel where

import PlutusTx
import qualified PlutusTx.Prelude as P

two :: CompiledCode Integer
two = $$(compile [|| 1 P.+ 1 ||])
