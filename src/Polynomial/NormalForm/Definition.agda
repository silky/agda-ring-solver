{-# OPTIONS --without-K #-}

open import Relation.Nullary using (¬_)
open import Level using (_⊔_; Lift)
open import Data.Empty using (⊥)
open import Data.Unit using (⊤)
open import Data.List as List using (_∷_; []; List)
open import Data.Nat as ℕ using (ℕ; suc; zero)
open import Polynomial.Parameters
open import Polynomial.NormalForm.InjectionIndex
open import Function using (_∘_)

module Polynomial.NormalForm.Definition
  {a ℓ}
  (coeffs : RawCoeff a ℓ)
  where

infixl 6 _Δ_
record PowInd {c} (C : Set c) : Set c where
  inductive
  constructor _Δ_
  field
    coeff : C
    pow   : ℕ

module _ where
  open PowInd

  map-coeff : ∀ {c₁ c₂} {C₁ : Set c₁} {C₂ : Set c₂} → (C₁ → C₂) → PowInd C₁ → PowInd C₂
  map-coeff f (x Δ i) = f x Δ i

  map-ind : ∀ {c} {C : Set c} → (ℕ → ℕ) → PowInd C → PowInd C
  map-ind f (x Δ i) = x Δ f i

open RawCoeff coeffs

mutual
  -- A Polynomial is indexed by the number of variables it contains.
  infixl 6 _Π_
  record Poly (n : ℕ) : Set (a ⊔ ℓ) where
    inductive
    constructor _Π_
    field
      {i} : ℕ
      flat  : FlatPoly i
      i≤n   : i ≤′ n

  -- Possible alternative:
  -- infixl 6 _Σ_
  -- data Poly (n : ℕ) : Set (a ⊔ ℓ) where
  --   Κ   : Carrier → Poly n
  --   _Σ_ : ∀ {i} → suc i ≤′ n → (xs : Coeffs i) → .{xn : Norm xs} → Poly n

  data FlatPoly : ℕ → Set (a ⊔ ℓ) where
    Κ : Carrier → FlatPoly zero
    Σ : ∀ {n} → (xs : Coeffs n) → .{xn : Norm xs} → FlatPoly (suc n)

  -- A list of coefficients, paired with the exponent *gap* from the
  -- preceding coefficient. In other words, to represent the
  -- polynomial:
  --
  --   3 + 2x² + 4x⁵ + 2x⁷
  --
  -- We write:
  --
  --   [(3,0),(2,1),(4,2),(2,1)]
  --
  -- Which can be thought of as a representation of the expression:
  --
  --   x⁰ * (3 + x * x¹ * (2 + x * x² * (4 + x * x¹ * (2 + x * 0))))
  --
  -- This is sparse Horner normal form.

  Coeffs : ℕ → Set (a ⊔ ℓ)
  Coeffs = List ∘ PowInd ∘ NonZero

  -- We disallow zeroes in the coefficient list. This condition alone
  -- is enough to ensure a unique representation for any polynomial.
  infixl 6 _≠0
  record NonZero (i : ℕ) : Set (a ⊔ ℓ) where
    inductive
    constructor _≠0
    field
      poly : Poly i
      .{poly≠0} : ¬ Zero poly

  Zero : ∀ {n} → Poly n → Set ℓ
  Zero (Κ x       Π _) = Zero-C x
  Zero (Σ []      Π _) = Lift ℓ ⊤
  Zero (Σ (_ ∷ _) Π _) = Lift ℓ ⊥

  Norm : ∀ {i} → Coeffs i → Set
  Norm []                  = ⊥
  Norm (_ Δ zero  ∷ [])    = ⊥
  Norm (_ Δ zero  ∷ _ ∷ _) = ⊤
  Norm (_ Δ suc _ ∷ _)     = ⊤