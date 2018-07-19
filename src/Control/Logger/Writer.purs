module Control.Logger.Writer
( writer
) where

import Prelude (class Monoid)
import Control.Logger (Logger(Logger))
import Control.Monad.Writer.Class (class MonadWriter, tell)

-- | Logger that writes records to the writer.
writer :: forall m r
        . MonadWriter r m
       => Monoid r
       => Logger m r
writer = Logger tell
