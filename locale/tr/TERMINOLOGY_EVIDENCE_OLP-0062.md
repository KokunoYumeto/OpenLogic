# Turkish terminology evidence -- OLP-0055--OLP-0062

Date: 2026-08-13  
Authority commit: `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`  
Authority tree: `f67757bb9305b173634082ab4cefd5601a707a34`

This record covers the Propositional Logic part driver and its complete
reader-reachable `Syntax and Semantics` chapter for a bounded cumulative
checkpoint through 62 of 722 closure files. It is not the complete
Propositional Logic part; build and publication status are recorded
separately.

## Reader surfaces

The chapter retains `formül`, `sağlama`, `ispat`, `teorem`, `önerme`, and
`tümevarım`. New active surfaces are:

- `propositional logic` -> `önerme mantığı`;
- `syntax` / `semantics` -> `sözdizim` / `semantik`;
- `propositional variable` -> `önerme değişkeni`;
- `logical connective` / `logical operator` -> `mantıksal bağlaç` /
  `mantıksal işleç`;
- `structure` -> `yapı`;
- `truth value` -> `doğruluk değeri`;
- `truth` / `falsity` -> `doğruluk` / `yanlışlık`;
- `valuation` / `evaluation function` -> `değerleme` /
  `değerlendirme fonksiyonu`;
- `atomic formula` -> `atomik formül`;
- `negation`, `conjunction`, `disjunction` -> `değilleme`, `ve bağlacı`,
  `veya bağlacı`;
- `material conditional` / `biconditional` -> `maddi koşul` /
  `iki yönlü koşul`;
- `syntactic identity` -> `sözdizimsel özdeşlik`;
- `unique readability` -> `tek türlü okunabilirlik`;
- `induction on formulas` -> `formüller üzerinde tümevarım`;
- `uniform substitution` / `simultaneous substitution` -> `düzgün yerine
  koyma` / `eşzamanlı yerine koyma`;
- `formation sequence` -> `oluşum dizisi`;
- `satisfiable`, `unsatisfiable`, `tautology`, `contingent` ->
  `sağlanabilir`, `sağlanamaz`, `totoloji`, `olumsal`;
- `entailment` -> `mantıksal gerektirme`;
- `Local Determination` -> `Yerel Belirlenim`;
- `Semantic Deduction Theorem` -> `Semantik Tümdengelim Teoremi`.

Turkish university curricula independently attest `önerme mantığı`,
`doğruluk tablosu`, `mantıksal gerektirme`, `doğruluk fonksiyonu
semantiği`, and `tümdengelim teoremi`. Published Turkish mathematical-logic
metadata also attests `Tek Türlü Okunabilirlik` and
`Yorumlar-Değerlemeler`. The control evidence record preserves the exact
references and decision basis.

## Required distinctions

- A `değerleme` assigns values to propositional variables; the induced
  `değerlendirme fonksiyonu` acts on every formula.
- First-order `yapı` is the mathematical-structure surface contrasted with
  propositional `değerleme`; it is not silently replaced by `model`.
- `Sağlama`, truth, validity, soundness, and consistency are not synonyms.
- `Doğruluk` and `yanlışlık` name concepts or configured constants; the two
  truth values are `doğru` and `yanlış`.
- `Maddi koşul` is a connective; `mantıksal gerektirme` is semantic;
  `türetim` is proof-theoretic.
- `Sözdizimsel özdeşlik` is exact string identity, not biconditional,
  equality, or semantic equivalence.
- Logical `ve` and `veya` do not reuse set-operation `kesişim` and
  `birleşim`; disjunction is inclusive.
- A `totoloji` is true under every valuation. This does not by itself call
  it a theorem in an as-yet untranslated proof system.
- Syntactic prefixes use `başlangıç parçası`, not the order-theoretic
  `başlangıç kesiti`.
- An `oluşum dizisi` may contain redundant entries and is not a proof or
  derivation.

The source says truth-functional completeness is planned; this checkpoint
does not claim it. These are active publication terms without a separate
native-review gate or community-certification claim.
