{-# OPTIONS --without-K --safe #-}

open import Polynomial.Parameters

-- Here, we provide proofs of homomorphism between the operations
-- defined on polynomials and those on the underlying ring.

module Polynomial.Homomorphism
  {r₁ r₂ r₃ r₄}
  (homo : Homomorphism r₁ r₂ r₃ r₄)
  where

open import Polynomial.Homomorphism.Addition       homo using (⊞-hom) public
open import Polynomial.Homomorphism.Multiplication homo using (⊠-hom) public
open import Polynomial.Homomorphism.Negation       homo using (⊟-hom) public
open import Polynomial.Homomorphism.Semantics      homo using (κ-hom; ι-hom) public
