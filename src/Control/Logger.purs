module Control.Logger
( Logger(Logger)
, log
, cfilter
) where

import Data.Functor.Contravariant (class Contravariant)
import Data.Monoid (class Monoid)
import Prelude

-- | A logger receives records and potentially performs some effects.
newtype Logger m r = Logger (r -> m Unit)

instance contravariantLogger :: Contravariant (Logger m) where
  cmap f (Logger l) = Logger \r -> l (f r)

instance semigroupLogger :: (Apply m) => Semigroup (Logger m r) where
  append (Logger a) (Logger b) = Logger \r -> a r *> b r

instance monoidLogger :: (Applicative m) => Monoid (Logger m r) where
  mempty = Logger \_ -> pure unit

-- | Log a record to the logger.
log :: forall m r. Logger m r -> r -> m Unit
log (Logger l) = l

-- | Transform the logger such that it ignores records for which the predicate
-- | returns false.
cfilter :: forall m r. (Applicative m) => (r -> Boolean) -> Logger m r -> Logger m r
cfilter f (Logger l) = Logger \r -> when (f r) (l r)
