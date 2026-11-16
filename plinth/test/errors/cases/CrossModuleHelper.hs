-- Helper for the CrossModule case: a function of another module that
-- uses a construct that Plinth does not support. It has no pragma.
module CrossModuleHelper (checked) where

import qualified PlutusTx.Prelude as P

checked :: Integer -> Integer
checked n = if n P.< 0 then error "negative" else n
