module Control.Logger
( Logger(Logger)
, log
, cfilter
) where

import Data.Divide (class Divide)
import Data.Divisible (class Divisible)
import Data.Functor.Contravariant (class Contravariant)
import Data.Monoid (class Monoid)
import Data.Tuple (Tuple(..))
import Prelude

-- | A logger receives records and potentially performs some effects.
newtype Logger m r = Logger (r -> m Unit)

instance contravariantLogger :: Contravariant (Logger m) where
  cmap f (Logger l) = Logger \r -> l (f r)

instance divideLogger :: (Apply m) => Divide (Logger m) where
  divide f (Logger a) (Logger b) =
    Logger \r -> case f r of Tuple r1 r2 -> a r1 *> b r2

instance divisibleLogger :: (Applicative m) => Divisible (Logger m) where
  conquer = Logger \_ -> pure unit

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
