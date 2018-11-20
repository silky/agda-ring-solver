{-# OPTIONS --without-K #-}

module Positional.Binary where

open import Data.List as List using (List; []; _∷_; foldr)
open import Data.Nat as ℕ using (ℕ; zero; suc; Ordering; less; equal; greater) renaming (compare to ℕ-compare)
open import Data.Product
open import Function
open import Relation.Binary.PropositionalEquality

-- Each element in the list is the distance to the next 1.
--
-- 0  = []
-- 52 = 001011 = [2,1,0]
-- 4  = 001    = [2]
-- 5  = 101    = [0,1]
-- 10 = 0101   = [1,1]
Bin : Set
Bin = List ℕ

incr′ : ℕ → Bin → Bin
incr″ : ℕ → ℕ → Bin → Bin

incr′ i [] = i ∷ []
incr′ i (x ∷ xs) = incr″ i x xs

incr″ i zero xs = incr′ (suc i) xs
incr″ i (suc x) xs = i ∷ x ∷ xs

incr : Bin → Bin
incr = incr′ 0

infixl 6 _+_
_+_ : Bin → Bin → Bin
+-zip   :     ∀ {x y} → Ordering x y → Bin → Bin → Bin
∔-zip   : ℕ → ∀ {i j} → Ordering i j → Bin → Bin → Bin
+-zip-r :     ℕ → Bin → Bin → Bin
∔-zip-r : ℕ → ℕ → Bin → Bin → Bin
∔-cin   : ℕ → Bin → Bin → Bin
∔-zip-c : ℕ → ℕ → ℕ → Bin → Bin → Bin

[] + ys = ys
(x ∷ xs) + ys = +-zip-r x xs ys

+-zip (less    i k) xs ys = i ∷ +-zip-r k ys xs
+-zip (equal   k  ) xs ys = ∔-cin (suc k) xs ys
+-zip (greater j k) xs ys = j ∷ +-zip-r k xs ys

+-zip-r x xs [] = x ∷ xs
+-zip-r x xs (y ∷ ys) = +-zip (ℕ-compare x y) xs ys

∔-cin i [] = incr′ i
∔-cin i (x ∷ xs) = ∔-zip-r i x xs

∔-zip-r i x xs [] = incr″ i x xs
∔-zip-r i x xs (y ∷ ys) = ∔-zip i (ℕ-compare y x) ys xs

∔-zip-c c zero k xs ys = ∔-zip-r (suc c) k xs ys
∔-zip-c c (suc i) k xs ys = c ∷ i ∷ +-zip-r k xs ys

∔-zip c (less    i k) xs ys = ∔-zip-c c i k ys xs
∔-zip c (greater j k) xs ys = ∔-zip-c c j k xs ys
∔-zip c (equal     k) xs ys = c ∷ ∔-cin k xs ys

pow : ℕ → Bin → Bin
pow i [] = []
pow i (x ∷ xs) = (x ℕ.+ i) ∷ xs

infixl 7 _*_
_*_ : Bin → Bin → Bin
_*_ [] _ = []
_*_ (x ∷ xs) = pow x ∘ foldr (λ y ys → y ∷ xs + ys) []

fromNat : ℕ → Bin
fromNat zero = []
fromNat (suc n) = incr (fromNat n)

infixr 8 _^_
_^_ : ℕ → ℕ → ℕ
x ^ zero = 1
x ^ suc y = x ℕ.* (x ^ y)

toNat : Bin → ℕ
toNat = List.foldr (λ x xs → (2 ^ x) ℕ.* suc (2 ℕ.* xs)) 0

private

  testLimit : ℕ
  testLimit = 25

  nats : List ℕ
  nats = List.downFrom testLimit

  natPairs : List (ℕ × ℕ)
  natPairs = List.concatMap (λ x → List.map (x ,_) nats) nats

  _=[_]_ : (ℕ → ℕ) → List ℕ → (Bin → Bin) → Set
  f =[ ns ] g = List.map f ns ≡ List.map (toNat ∘ g ∘ fromNat) ns

  _=[_]₂_ : (ℕ → ℕ → ℕ) → List (ℕ × ℕ) → (Bin → Bin → Bin) → Set
  f =[ ps ]₂ g =
    List.map (uncurry f) ps ≡ List.map (toNat ∘ uncurry (g on fromNat)) ps

-- And then the tests:

private

  test-+ : ℕ._+_ =[ natPairs ]₂ _+_
  test-+ = refl

  test-* : ℕ._*_ =[ natPairs ]₂ _*_
  test-* = refl

  test-suc : suc =[ nats ] incr
  test-suc = refl

  test-downFrom : List.map (toNat ∘ fromNat) (List.downFrom testLimit) ≡
                  List.downFrom testLimit
  test-downFrom = refl
