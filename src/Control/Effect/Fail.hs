{-# LANGUAGE DeriveFunctor, FlexibleInstances, MultiParamTypeClasses, TypeOperators, UndecidableInstances #-}
module Control.Effect.Fail
( Fail(..)
, MonadFail(..)
, runFail
, FailC(..)
) where

import Control.Applicative (liftA2)
import Control.Effect.Carrier
import Control.Effect.Fail.Internal
import Control.Effect.Internal
import Control.Effect.Sum
import Control.Monad.Fail

-- | Run a 'Fail' effect, returning failure messages in 'Left' and successful computations’ results in 'Right'.
--
--   prop> run (runFail (pure a)) == Right a
runFail :: (Carrier sig m, Effect sig) => Eff (FailC m) a -> m (Either String a)
runFail = runFailC . interpret

newtype FailC m a = FailC { runFailC :: m (Either String a) }
  deriving (Functor)

instance Applicative m => Applicative (FailC m) where
  pure a = FailC (pure (Right a))
  FailC f <*> FailC a = FailC (liftA2 (<*>) f a)

instance Monad m => Monad (FailC m) where
  FailC a >>= f = FailC (a >>= either (pure . Left) (runFailC . f))

instance Monad m => MonadFail (FailC m) where
  fail s = FailC (pure (Left s))

instance (Carrier sig m, Effect sig) => Carrier (Fail :+: sig) (FailC m) where
  ret a = FailC (ret (Right a))
  eff = FailC . handleSum (eff . handleEither runFailC) (\ (Fail s) -> ret (Left s))


-- $setup
-- >>> :seti -XFlexibleContexts
-- >>> import Test.QuickCheck
-- >>> import Control.Effect.Void
