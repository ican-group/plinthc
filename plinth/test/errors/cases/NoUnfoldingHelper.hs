{-# LANGUAGE NoImplicitPrelude #-}
-- Helper for the NoUnfolding and DeepChain cases: NOINLINE stops
-- plinthc from exposing the unfolding of this function. Its body is
-- valid Plinth, so the missing unfolding is the only problem.
module NoUnfoldingHelper (opaque) where

import PlutusTx.Prelude

opaque :: Integer -> Integer
opaque x = x + 1
{-# NOINLINE opaque #-}
