{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses, PolyKinds, TypeOperators, UndecidableInstances #-}
module Control.Effect.NonDet
( NonDet(..)
, Alternative(..)
, runNonDet
, AltC(..)
) where

import Control.Applicative (Alternative(..), liftA2)
import Control.Effect.Carrier
import Control.Effect.Internal
import Control.Effect.NonDet.Internal
import Control.Effect.Sum
import Control.Monad (join)

-- | Run a 'NonDet' effect, collecting all branches’ results into an 'Alternative' functor.
--
--   Using '[]' as the 'Alternative' functor will produce all results, while 'Maybe' will return only the first.
--
--   prop> run (runNonDet (pure a)) == [a]
--   prop> run (runNonDet (pure a)) == Just a
runNonDet :: (Alternative f, Monad f, Traversable f, Carrier sig m, Effect sig, Applicative m) => Eff (AltC f m) a -> m (f a)
runNonDet = runAltC . interpret

newtype AltC f m a = AltC { runAltC :: m (f a) }

instance (Alternative f, Monad f, Traversable f, Carrier sig m, Effect sig, Applicative m) => Carrier (NonDet :+: sig) (AltC f m) where
  handleReturn a = AltC (handleReturn (pure a))
  alg = algND \/ (AltC . alg . handle (pure ()) (fmap join . traverse runAltC))
    where algND Empty      = AltC (handleReturn empty)
          algND (Choose k) = AltC (liftA2 (<|>) (runAltC (k True)) (runAltC (k False)))


-- $setup
-- >>> :seti -XFlexibleContexts
-- >>> import Test.QuickCheck
-- >>> import Control.Effect.Void
