{-# LANGUAGE ImpredicativeTypes #-}
{-# LANGUAGE LinearTypes #-}

module Language.WASM.JSVal.JSON (toJSVal, fromJSVal) where

import Control.Monad ((<=<))
import Data.Aeson.Micro (
  FromJSON,
  ToJSON (..),
 )
import Data.Aeson.Micro qualified as J
import Data.ByteString.Lazy qualified as LBS
import GHC.Wasm.Prim
import Language.WASM.ByteString qualified as WBS

-- | NOTE: This converts a value with @JSON.parse@ so all reference to JSVal is lost.
toJSVal :: (ToJSON a) => a -> IO JSVal
toJSVal = js_parse_json <=< WBS.fromByteString . LBS.toStrict . J.encode

foreign import javascript unsafe "JSON.parse($1)"
  js_parse_json :: JSString -> IO JSVal

foreign import javascript unsafe "JSON.stringify($1)"
  js_stringify_json :: JSVal -> IO JSString

-- | NOTE: This converts a value with @JSON.stringify@ so all reference to JSVal is lost and may be expensive when the object is large.
fromJSVal :: (FromJSON a) => JSVal -> IO (Maybe a)
fromJSVal =
  fmap (J.decode . LBS.fromStrict) . WBS.toByteString
    <=< js_stringify_json