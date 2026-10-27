{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
-- EXPECT: ok
-- The compiler primitives are valid whatever their Haskell body: the
-- builtins, fix, the lazy boolean operators and the opaque conversions.
module TrustedBuiltins where

import PlutusTx
import PlutusTx.Function (fix)
import qualified PlutusTx.Builtins as B
import qualified PlutusTx.Builtins.Internal as BI
import qualified PlutusTx.Prelude as P

sumTo :: Integer -> Integer
sumTo = fix (\rec n -> if n P.<= 0 P.&& P.True then 0 else BI.addInteger n (rec (n P.- 1)))

greeting :: P.BuiltinString
greeting = B.appendString "hello " "world"

code :: CompiledCode (Integer -> Integer)
code = $$(PlutusTx.compile [|| \n -> sumTo n P.+ B.lengthOfByteString (B.encodeUtf8 greeting) ||])
