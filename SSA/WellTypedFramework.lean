import SSA.Framework
import Mathlib.Data.Option.Basic

-- Why do we ask for them to make this explicitly?
class TypeSemantics (Kind : Type) : Type 1 where
  toType : Kind → Type
  unit : Kind
  pair : Kind → Kind → Kind
  triple : Kind → Kind → Kind → Kind
  mkPair : ∀ {k1 k2 : Kind}, toType k1 → toType k2 → toType (pair k1 k2)
  fstPair : ∀ {k1 k2 : Kind}, toType (pair k1 k2) → toType k1
  sndPair : ∀ {k1 k2 : Kind}, toType (pair k1 k2) → toType k2
  mkTriple : ∀ {k1 k2 k3 : Kind}, toType k1 → toType k2 → toType k3 → toType (triple k1 k2 k3)
  fstTriple : ∀ {k1 k2 k3 : Kind}, toType (triple k1 k2 k3) → toType k1
  sndTriple : ∀ {k1 k2 k3 : Kind}, toType (triple k1 k2 k3) → toType k2
  trdTriple : ∀ {k1 k2 k3 : Kind}, toType (triple k1 k2 k3) → toType k3

-- Couldn't we do something like this for them?
--
inductive TypeSemanticsInstance (BaseType : Type) : Type where
  | base : BaseType → TypeSemanticsInstance BaseType
  | pair : TypeSemanticsInstance BaseType → TypeSemanticsInstance BaseType → TypeSemanticsInstance BaseType
  | triple : TypeSemanticsInstance BaseType → TypeSemanticsInstance BaseType → TypeSemanticsInstance BaseType → TypeSemanticsInstance BaseType
  | unit : TypeSemanticsInstance BaseType


abbrev Arity := TypeSemanticsInstance Unit

namespace TypeSemanticsInstance

variable {BaseType : Type}

instance {BaseType : Type} : Inhabited (TypeSemanticsInstance BaseType) where default := TypeSemanticsInstance.unit

def toType {BaseType : Type} : TypeSemanticsInstance BaseType → Type
  | .base _ => BaseType
  | .pair k₁ k₂ => (toType k₁) × (toType k₂)
  | .triple k₁ k₂ k₃ => toType k₁ × toType k₂ × toType k₃
  | .unit => Unit

def mkPair {BaseType : Type} {k₁ k₂ : TypeSemanticsInstance BaseType}: toType k₁ → toType k₂ → toType (.pair k₁ k₂)
  | k₁, k₂ => (k₁, k₂)

def mkTriple {BaseType : Type} {k₁ k₂ k₃ : TypeSemanticsInstance BaseType}: toType k₁ → toType k₂ → toType k₃ → toType (.triple k₁ k₂ k₃)
  | k₁, k₂, k₃ => (k₁, k₂, k₃)

def fstPair {BaseType : Type} {k₁ k₂ : TypeSemanticsInstance BaseType} : toType (.pair k₁ k₂) → toType k₁
  | (k₁, _) => k₁

def sndPair {BaseType : Type} {k₁ k₂ : TypeSemanticsInstance BaseType} : toType (.pair k₁ k₂) → toType k₂
  | (_, k₂) => k₂

def fstTriple {BaseType : Type} {k₁ k₂ k₃ : TypeSemanticsInstance BaseType} : toType (.triple k₁ k₂ k₃) → toType k₁
  | (k₁, _, _) => k₁

def sndTriple {BaseType : Type} {k₁ k₂ k₃ : TypeSemanticsInstance BaseType} : toType (.triple k₁ k₂ k₃) → toType k₂
  | (_, k₂, _) => k₂

def trdTriple {BaseType : Type} {k₁ k₂ k₃ : TypeSemanticsInstance BaseType} : toType (.triple k₁ k₂ k₃) → toType k₃
  | (_, _, k₃) => k₃

def arity {BaseType : Type} : TypeSemanticsInstance BaseType → Arity
  | .base _ => .base ()
  | .pair k₁ k₂ => .pair (arity k₁) (arity k₂)
  | .triple k₁ k₂ k₃ => .triple (arity k₁) (arity k₂) (arity k₃)
  | .unit => .unit

end TypeSemanticsInstance

instance {Kind : Type} : TypeSemantics (TypeSemanticsInstance Kind) where
  toType := TypeSemanticsInstance.toType
  pair := TypeSemanticsInstance.pair
  triple := TypeSemanticsInstance.triple
  mkPair := TypeSemanticsInstance.mkPair
  fstPair := TypeSemanticsInstance.fstPair
  sndPair := TypeSemanticsInstance.sndPair
  mkTriple := TypeSemanticsInstance.mkTriple
  fstTriple := TypeSemanticsInstance.fstTriple
  sndTriple := TypeSemanticsInstance.sndTriple
  trdTriple := TypeSemanticsInstance.trdTriple
  unit := TypeSemanticsInstance.unit

open TypeSemantics

class TypedUserSemantics (Op : Type) (Kind : Type) [TypeSemantics Kind] where
  argKind : Op → Kind
  rgnDom : Op → Kind
  rgnCod : Op → Kind
  outKind : Op → Kind
  eval : ∀ (o : Op), toType (argKind o) → (toType (rgnDom o) →
    toType (rgnCod o)) → toType (outKind o)


namespace TypedUserSemantics

variable (Op : Type) (Kind : Type) [TypeSemantics Kind] [TypedUserSemantics Op Kind]

inductive Context (Kind : Type) where
  | empty : Context Kind
  | push : Context Kind → Var → Kind → Context Kind
  deriving DecidableEq

inductive CVar {Kind : Type} : Context Kind → Kind → Type where
  | here : ∀ {Γ : Context Kind} {k : Kind}, CVar (Γ.push v k) k
  | there : ∀ {Γ : Context Kind} {k₁ k₂ : Kind} {v : Var}, CVar Γ k₁ → CVar (Γ.push v k₂) k₁
  deriving DecidableEq

/-- Us mucking around to avoid mutual inductives.  -/
inductive TSSAIndex : Type
/-- LHS := RHS. LHS is a `Var` and RHS is an `SSA Op .EXPR` -/
| STMT : Context Kind → TSSAIndex
/-- Ways of making an RHS -/
| EXPR : Kind → TSSAIndex
/-- The final instruction in a region. Must be a return -/
| TERMINATOR : Kind → TSSAIndex
/-- a lambda -/
| REGION : Kind → Kind → TSSAIndex

@[simp]
def TSSAIndex.toSSAIndex : TSSAIndex Kind → SSAIndex
  | .STMT _ => .STMT
  | .EXPR _ => .EXPR
  | .TERMINATOR _ => .TERMINATOR
  | .REGION _ _ => .REGION

@[simp]
def _root_.SSAIndex.ExtraData (Kind : Type) : SSAIndex → Type
  | .STMT => Context Kind
  | .EXPR => Kind
  | .TERMINATOR => Kind
  | .REGION => Kind × Kind

@[simp]
def _root_.SSAIndex.toTSSAIndex {Kind : Type} : (i : SSAIndex) → i.ExtraData Kind → TSSAIndex Kind
  | .STMT, Γ => .STMT Γ
  | .EXPR, k => .EXPR k
  | .TERMINATOR, k => .TERMINATOR k
  | .REGION, (k₁, k₂) => .REGION k₁ k₂

inductive TSSA (Op : Type) {Kind : Type} [TypeSemantics Kind] [TypedUserSemantics Op Kind] :
    (Γ : Context Kind) → (Γr : Context (Kind × Kind)) → TSSAIndex Kind → Type where
  /-- lhs := rhs; rest of the program -/
  | assign {k : Kind} (lhs : Var) (rhs : TSSA Op Γ Γr (.EXPR k))
      (rest : TSSA Op (Γ.push lhs k) Γr (.STMT Γ')) : TSSA Op Γ Γr (.STMT (Γ'.push lhs k))
  /-- no operation. -/
  | nop : TSSA Op Γ Γr (.STMT Context.empty)
  /-- above; ret v -/
  | ret {k : Kind} (above : TSSA Op Γ Γr (.STMT Γ')) (v : CVar Γ' k) : TSSA Op Γ Γr (.TERMINATOR k)
  /-- (fst, snd) -/
  | pair (fst : CVar Γ k₁) (snd : CVar Γ k₂) : TSSA Op Γ Γr (.EXPR (pair k₁ k₂))
  /-- (fst, snd, third) -/
  | triple (fst : CVar Γ k₁) (snd : CVar Γ k₂) (third : CVar Γ k₃) : TSSA Op Γ Γr (.EXPR (triple k₁ k₂ k₃))
  /-- op (arg) { rgn } rgn is an argument to the operation -/
  | op (o : Op) (arg : CVar Γ (argKind o)) (rgn : TSSA Op Γ Γr (.REGION (rgnDom o) (rgnCod o))) :
      TSSA Op Γ Γr (.EXPR (outKind o))
  /- fun arg => body -/
  | rgn {arg : Var} {dom cod : Kind} (body : TSSA Op (Γ.push arg dom) Γr (.TERMINATOR cod)) :
      TSSA Op Γ Γr (.REGION dom cod)
  /- no function / non-existence of region. -/
  | rgn0 : TSSA Op Γ Γr (.REGION unit unit)
  /- a region variable. --/
  | rgnvar (v : CVar Γr (k₁, k₂)) : TSSA Op Γ Γr (.REGION k₁ k₂)
  /-- a variable. -/
  | var (v : CVar Γ k) : TSSA Op Γ Γr (.EXPR k)
/- TODO - Write a translation that takes a pair of SSA and optionally returns a pair
 of valid contexts and TSSA. Write the evaluation for a TSSA. -/

variable {Op Kind}

@[simp]
def Context.eval (Γ : Context Kind) : Type :=
  ∀ ⦃k : Kind⦄, CVar Γ k → toType k

@[simp]
def Context.evalr (Γr : Context (Kind × Kind)) : Type :=
  ∀ ⦃k₁ k₂ : Kind⦄, CVar Γr (k₁, k₂) → toType k₁ → toType k₂

@[simp]
def TSSAIndex.eval : TSSAIndex Kind → Type
  | .STMT Γ' => Context.eval Γ'
  | .EXPR k => toType k
  | .TERMINATOR k => toType k
  | .REGION dom cod => toType dom → toType cod

@[simp]
def TSSA.eval : {Γ : Context Kind} → {Γr : Context (Kind × Kind)} →
    {i : TSSAIndex Kind} → TSSA Op Γ Γr i → Γ.eval → Γr.evalr → i.eval
  | Γ, Γr, _, .assign lhs rhs rest => fun c₁ c₂ _ v =>
    match v with
    | CVar.here => rhs.eval c₁ c₂
    | CVar.there v => rest.eval
      (fun _ v' =>
        match v' with
        | CVar.here => rhs.eval c₁ c₂
        | CVar.there v'' => c₁ v'') c₂ v
  | _, _, _, .nop => fun _ _ _ v => by cases v
  | _, _, _, .ret above v => fun c₁ c₂ => above.eval c₁ c₂ v
  | _, _, _, .pair fst snd => fun c₁ _ => mkPair (c₁ fst) (c₁ snd)
  | _, _, _, .triple fst snd third =>
    fun c₁ _ => mkTriple (c₁ fst) (c₁ snd) (c₁ third)
  | _, _, _, TSSA.op o arg rg => fun c₁ c₂ =>
    TypedUserSemantics.eval o (c₁ arg) (rg.eval c₁ c₂)
  | _, _, _, .rgn body => fun c₁ c₂ arg =>
    body.eval (fun _ v =>
      match v with
      | CVar.here => arg
      | CVar.there v' => c₁ v') c₂
  | _, _, _, .rgn0 => fun _ _ => id
  | _, _, _, .rgnvar v => fun _ c₂ => c₂ v
  | _, _, _, .var v => fun c₁ _ => c₁ v

variable [DecidableEq Kind]
/-- Lookup a variable in a context given a type.
It finds the last thing in the context with the right name. -/
@[simp]
def Context.lookup : (Γ : Context Kind) → (v : Var) → Option (Σ k : Kind, CVar Γ k)
  | Context.empty, _ => none
  | Context.push Γ v' _, v =>
    match Γ.lookup v with
    | some ⟨_, v⟩ => some ⟨_, CVar.there v⟩
    | none =>
      if h : v = v'
      then h ▸ some ⟨_, CVar.here⟩
      else none

@[simp]
def Context.in : (Γ : Context Kind) → (v : Var) → Bool
  | Context.empty, _ => false
  | Context.push Γ v' _, v => v = v' || Γ.in v

@[simp]
def getContextSTMT : {i' : TSSAIndex Kind // i'.toSSAIndex = .STMT} → Context Kind
  | ⟨.STMT Γ, _⟩ => Γ

@[simp]
def getKindEXPR : {i' : TSSAIndex Kind // i'.toSSAIndex = .EXPR} → Kind
  | ⟨.EXPR k, _⟩ => k

@[simp]
def Context.union : (Γ : Context Kind) → (Γ' : Context Kind) → Context Kind
  | Context.empty, Γ' => Γ'
  | Context.push Γ v k, Γ' =>
    match Γ'.in v with
    | true => Γ.union Γ'
    | false => Context.push (Γ.union Γ') v k

open TypedUserSemantics

class OpArity (Op : Type) where
  arity : Op → TypeSemanticsInstance Unit × TypeSemanticsInstance Unit

-- I guess this is undecidable in general but clearly semi-decidable for the cases we care; don't know how to deal with this in TypeClasses
inductive IsTyped {BaseType : Type} : TypeSemanticsInstance BaseType → Type → Prop
  | unit : IsTyped (.unit) Unit
  | base (v : BaseType) : IsTyped (.base v) BaseType
  | pair (t₁ t₂ : Type) (v₁ v₂ : TypeSemanticsInstance BaseType) (_ : IsTyped v₁ t₁) (_ : IsTyped v₂ t₂) : IsTyped (.pair v₁ v₂) (t₁ × t₂)


inductive  TypeCheckResult {BaseType : Type} : Type
  | unknown
  | typed (arity : Arity) (val : TypeSemanticsInstance BaseType)

def typeCheck {BaseType : Type 0} : TypeSemanticsInstance BaseType → @TypeCheckResult BaseType
  | .unit => TypeCheckResult.unknown
  | .base v => .typed (.base ()) (.base v)
  | .pair v₁ v₂ =>
      match typeCheck v₁, typeCheck v₂ with
      | TypeCheckResult.typed a₁ v₁, TypeCheckResult.typed a₂ v₂ => TypeCheckResult.typed (.pair a₁ a₂) (.pair v₁ v₂)
      | _, _ => TypeCheckResult.unknown
  | .triple v₁ v₂ v₃ =>
      match typeCheck v₁, typeCheck v₂, typeCheck v₃ with
      | TypeCheckResult.typed a₁ v₁, TypeCheckResult.typed a₂ v₂, TypeCheckResult.typed a₃ v₃ => TypeCheckResult.typed (.triple a₁ a₂ a₃) (.triple v₁ v₂ v₃)
      | _, _, _ => TypeCheckResult.unknown


  --| triple  (t₁ t₂ t₂ : Type) (v₁ v₂ v₃ : TypeSemanticsInstance BaseType) (_ : IsTyped v₁ t₁) (_ : IsTyped v₂ t₂) (_ : IsTyped v₃ t₃) : IsTyped (.triple v₁ v₂ v₃) (t₁ × t₂ × t₃)
  --
-- This is ignoring the output for now.
inductive WellTypedArity {BaseType : Type} : TypeSemanticsInstance Unit → TypeSemanticsInstance BaseType → Prop
    | unit : WellTypedArity (.unit) (.unit)
    | base (v : BaseType) : WellTypedArity (.base ()) (.base v)
    | pair (k₁ k₂ : TypeSemanticsInstance BaseType) (k₁' k₂' : TypeSemanticsInstance Unit) (_h₁ : WellTypedArity k₁' k₁) (_h₂ : WellTypedArity k₂' k₂)  : WellTypedArity (.pair k₁' k₂') (.pair k₁ k₂)
    -- triple ...

inductive WellTypedAp {Op : Type} {BaseType : Type} [OpArity Op] : Op → TypeSemanticsInstance BaseType → Prop
  | mk (o : Op) (v : TypeSemanticsInstance BaseType) (hwt : WellTypedArity (OpArity.arity o).1 v) : WellTypedAp o v
-- Need morphisms of contexts.

@[simp]
def SSAtoTSSA : {i : SSAIndex} → SSA Op i →
    Option (Σ (Γ : Context Kind) (Γr : Context (Kind × Kind))
      (d : i.ExtraData Kind),  TSSA Op Γ Γr (i.toTSSAIndex d))
  | _, SSA.assign lhs rhs rest => do
    let ⟨(Γ : Context Kind), Γr, d, rest⟩ ← SSAtoTSSA rest
    let ⟨(Γ₂ : Context Kind), Γr₂, d₂, rhs⟩ ← SSAtoTSSA rhs
    return sorry
  | _, SSA.nop => some ⟨Context.empty, Context.empty, _, TSSA.nop⟩
  | _, SSA.ret above v => do
    let ⟨(Γ : Context Kind), Γr, d, above⟩ ← SSAtoTSSA above
    let v' ← d.lookup v
    some ⟨Γ, Γr, _, TSSA.ret above v'.2⟩
  | _, SSA.pair fst snd => sorry
  | _, SSA.triple fst snd third => _
  | _, SSA.op o arg rg => _
  | _, SSA.rgn _ body => _
  | _, SSA.rgn0 => _
  | _, SSA.rgnvar v => _
  | _, SSA.var v => _

end TypedUserSemantics
