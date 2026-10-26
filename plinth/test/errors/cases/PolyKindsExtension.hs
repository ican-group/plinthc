{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE PolyKinds #-}
-- EXPECT: ok-gate
-- The PolyKinds language extension: the Plinth check accepts the code
-- (identity is not poly-kinded); the plugin alone rejects the extension.
module PolyKindsExtension where

import PlutusTx

identity :: Integer -> Integer
identity x = x

code :: CompiledCode (Integer -> Integer)
code = $$(PlutusTx.compile [|| identity ||])
