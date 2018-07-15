module Control.Logger.Console
( console
) where

import Control.Logger (Logger(Logger))
import Effect.Class (liftEffect, class MonadEffect)
import Effect.Console (log)

-- | Logger that logs records to the console.
console :: forall m r
         . MonadEffect  m
        => (r -> String)
        -> Logger m r
console show = Logger \r -> liftEffect (log (show r))
