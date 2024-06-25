{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE TypeApplications #-}

module GHC.Wasm.Web.ReadableStream (
  fromReadableStream,
  module GHC.Wasm.Web.Generated.ReadableStream,
) where

import Control.Monad ((<=<))
import Control.Monad.Trans.Class (lift)
import Data.Word (Word8)
import GHC.Wasm.Object.Builtins
import GHC.Wasm.Web.Generated.ReadableStream
import GHC.Wasm.Web.Generated.ReadableStreamDefaultReader
import GHC.Wasm.Web.Generated.ReadableStreamReadResult
import qualified Streaming.ByteString as Q

fromReadableStream :: ReadableStream -> Q.ByteStream IO ()
fromReadableStream =
  fromReadResult
    <=< lift
      . ( await
            <=< js_fun_read__Promise_ReadableStreamReadResult
              . unsafeCast @_ @(ReadableStreamDefaultReaderClass)
            <=< flip
              js_fun_getReader_nullable_ReadableStreamGetReaderOptions_ReadableStreamReader
              (toNullable Nothing)
        )

fromReadResult :: ReadableStreamReadResult -> Q.ByteStream IO ()
fromReadResult = Q.reread \resl -> do
  done <- getDictField "done" resl
  value <-
    fmap (toByteString . unsafeCast @_ @(JSByteArrayClass Word8)) . fromNullable
      <$> getDictField "value" resl
  if maybe True fromJSPrim $ fromNullable done
    then pure Nothing
    else pure value
