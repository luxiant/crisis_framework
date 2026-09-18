/-
전술별 공리 기준선 프로브 — 스크래치

`Scratch/IntBaseline.lean` 에서 따름정리 둘만 `Classical.choice` 를 끌어온 원인을 좁히기 위한 보조 검사.
빌드 타깃 밖. 실행: `lake env lean Scratch/TacticProbe.lean`
-/

import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

open Finset

-- aggErrZ 자체
def aggErrZ {ι : Type} (S : Finset ι) (cap equity : ι → Int) : Int :=
  (S.card : Int) * (∑ i ∈ S, cap i * equity i)
    - (∑ i ∈ S, cap i) * (∑ i ∈ S, equity i)
#print axioms aggErrZ

-- linarith 단독이 Classical.choice 를 끌어오는가
theorem lin_probe (a : Int) (h : 2 * a = 0) : a = 0 := by linarith
#print axioms lin_probe

theorem omega_probe (a : Int) (h : 2 * a = 0) : a = 0 := by omega
#print axioms omega_probe

-- ring / norm_num 기준선
theorem ring_probe (a b : Int) : (a + b) * (a - b) = a*a - b*b := by ring
#print axioms ring_probe

theorem normnum_probe : (2:Int) * 3 = 6 := by norm_num
#print axioms normnum_probe

-- simp 단독
theorem simp_probe (S : Finset (Fin 2)) (c : Int) :
    (∑ _i ∈ S, c) = S.card • c := by simp
#print axioms simp_probe
