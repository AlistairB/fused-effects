{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses #-}
module Control.Effect.Lift
( Lift(..)
) where

import Control.Effect.Class

newtype Lift sig m k = Lift { unLift :: sig (m k) }

instance (Functor f, Functor m) => Effect f (Lift m)
