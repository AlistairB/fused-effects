module Control.Effect.NonDet.Spec where

import Control.Effect
import Test.Hspec
import Test.Hspec.QuickCheck

spec :: Spec
spec = do
  describe "empty" $ do
    it "produces no values" $
      run (runNonDet empty) `shouldBe` ([] :: String)

  describe "<|>" $ do
    it "produces each branch’s result nondeterministically" $
      run (runNonDet (pure 'a' <|> pure 'b')) `shouldBe` "ab"

  describe "interactions" $ do
    it "collects results of effects run before it" $
      run (runNonDet (runState 'a' (pure 'z' <|> put 'b' *> get <|> get))) `shouldBe` [('a', 'z'), ('b', 'b'), ('a', 'a')]

    it "collapses results of effects run after it" $
      run (runState 'a' (runNonDet (pure 'z' <|> put 'b' *> get <|> get))) `shouldBe` ('b', "zbb")

    it "collects results from higher-order effects run before it" $
      run (runNonDet (runError ((pure 'z' <|> throwError 'a') `catchError` pure))) `shouldBe` [Right 'z', Right 'a' :: Either Char Char]

    it "collapses results of higher-order effects run after it" $
      run (runError (runNonDet ((pure 'z' <|> throwError 'a') `catchError` pure))) `shouldBe` (Right "a" :: Either Char String)
