module Control.Logger.Console
( console
) where

import Control.Logger (Logger(Logger))
import Control.Monad.Eff.Class (liftEff, class MonadEff)
import Control.Monad.Eff.Console (CONSOLE, log)

-- | Logger that logs records to the console.
console :: forall m e r
         . (MonadEff (console :: CONSOLE | e) m)
        => (r -> String)
        -> Logger m r
console show = Logger \r -> liftEff (log (show r))
