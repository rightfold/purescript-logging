module Control.Logger
( Logger(Logger)
) where

import Data.Functor.Contravariant (cmap, class Contravariant)
import Data.Monoid (mempty, class Monoid)
import Prelude

newtype Logger m r = Logger (r -> m Unit)

instance contravariantLogger :: Contravariant (Logger m) where
  cmap f (Logger l) = Logger \r -> l (f r)

instance semigroupLogger :: (Apply m) => Semigroup (Logger m r) where
  append (Logger a) (Logger b) = Logger \r -> a r *> b r

instance monoidLogger :: (Applicative m) => Monoid (Logger m r) where
  mempty = Logger \_ -> pure unit
