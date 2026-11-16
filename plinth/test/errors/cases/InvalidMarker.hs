-- Misused compiler marker: 'plinthc' is not applied to the code to
-- compile (PLINTH-00006).
module InvalidMarker where

import PlutusTx
import PlutusTx.Plugin.Utils (plinthc)

code :: Integer -> CompiledCode Integer
code = plinthc
