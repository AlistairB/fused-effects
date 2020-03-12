{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE RankNTypes #-}
module Control.Effect.Lift.Internal
( Lift(..)
) where

import Control.Algebra.Internal (Handler)

-- | @since 1.0.0.0
data Lift sig m k
  = forall a . LiftWith
    (forall ctx . Functor ctx => Handler ctx m sig -> ctx () -> sig (ctx a))
    (a -> m k)
