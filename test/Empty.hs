{-# LANGUAGE RankNTypes, ScopedTypeVariables, TypeApplications #-}
module Empty
( tests
, gen
, test
) where

import qualified Control.Carrier.Empty.Maybe as EmptyC
import Control.Effect.Empty
import Gen
import Test.Tasty
import Test.Tasty.Hedgehog

tests :: TestTree
tests = testGroup "Empty"
  [ testGroup "EmptyC" $ test (m gen) a b EmptyC.runEmpty
  , testGroup "Maybe"  $ test (m gen) a b pure
  ]


gen
  :: Has Empty sig m
  => (forall a . Gen a -> Gen (m a))
  -> Gen a
  -> Gen (m a)
gen _ _ = label "empty" empty


test
  :: forall a b m sig
  .  (Has Empty sig m, Arg a, Eq b, Show a, Show b, Vary a)
  => (forall a . Gen a -> Gen (m a))
  -> Gen a
  -> Gen b
  -> (forall a . m a -> PureC (Maybe a))
  -> [TestTree]
test m _ b runEmpty =
  [ testProperty "empty annihilates >>=" . forall (fn @a (m b) :. Nil) $
    \ k -> runEmpty (empty >>= k) === runEmpty empty
  ]