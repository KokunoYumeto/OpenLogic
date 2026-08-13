# Source-adverse disclosure -- OLP-0055--OLP-0062

Date: 2026-08-13  
Authority commit: `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`  
Authority tree: `f67757bb9305b173634082ab4cefd5601a707a34`

This disclosure covers the Propositional Logic part driver and the complete
reader-reachable `Syntax and Semantics` chapter. Upstream English files
remain byte-untouched. The tranche is a bounded cumulative scope through 62
of 722 closure files, not the complete Propositional Logic part.

## Exact source binding and dispositions

- **OLP-0055**, `content/propositional-logic/propositional-logic.tex`,
  SHA-256 `8cfcb14b29eae3ae53c6ef626987e2323b8c870010e27d52d454296f24452799`:
  no local mathematical defect found. Its seven imports extend into
  untranslated proof-system and completeness material, so the bounded
  Turkish driver suppresses those imports and explicitly admits the first
  translated chapter.
- **OLP-0056**,
  `content/propositional-logic/syntax-and-semantics/syntax-and-semantics.tex`,
  SHA-256 `799d1dab63cda19a28c1dbf7097052fb790bbce609aecd5367d2e368decdb18b`:
  six-file chapter driver; no local defect found. Its editorial limitation
  to a quick summary is preserved.
- **OLP-0057**,
  `content/propositional-logic/syntax-and-semantics/introduction.tex`,
  SHA-256 `2ad06497283fa1399d56862c75caf1a418bb753fbb0195658af9f0c57183a441`:
  lines 18--19 pluralize the variables determining a formula's value;
  line 64 says `formüller için sağlama bağıntısı` rather than introducing
  an undefined separate sentence category.
- **OLP-0058**,
  `content/propositional-logic/syntax-and-semantics/formulas.tex`,
  SHA-256 `8777d77e48e3a41a527b1b737c67e00cb7850f4fa0902ce24846000b40724756`:
  lines 13--18 supply the missing conjunction in the `prvTrue=true`,
  `prvFalse=false` branch and use one grammatical construction frame for all
  four truth/falsity-constant tag combinations;
  lines 158--160 remove the unmatched closing parenthesis from the `defIf`
  abbreviation. `defIf` is false in both frozen default and complete-reader
  configurations, so this modular repair is not claimed as render-tested
  until that dormant branch is activated.
- **OLP-0059**,
  `content/propositional-logic/syntax-and-semantics/preliminaries.tex`,
  SHA-256 `78673f8419aa1f936f1ecc5629c0fa92c74fd4ee3102badf5f389e3d775f48d6`:
  the incorrect line-2 chapter comment is corrected to
  `syntax-and-semantics`; the concise unique-readability proof and assigned
  problems remain source omissions rather than supplied proofs.
- **OLP-0060**,
  `content/propositional-logic/syntax-and-semantics/formation-sequences.tex`,
  SHA-256 `4057bf6b85c70ad9ee56dc5365b21a1daa0a99550079bdafb1ab16f36b943356`:
  line 1 is corrected from `first-order-logic` to `propositional-logic`;
  line 141 uses the defined syntactic identity `\ident`, not semantic
  `\equiv`; and lines 126--149 consistently induct on final index `n`, so
  the prefix final indices `j,k<n` fall under the induction hypothesis.
- **OLP-0061**,
  `content/propositional-logic/syntax-and-semantics/valuations-sat.tex`,
  SHA-256 `d1454e8c2366f3a204a371523f41feacbdc72402f7a3a7ae6635b60b17c90481`:
  Local Determination at lines 133--139 is restricted to variables occurring
  in the fixed formula `A`, repairing the source's ambiguous `some formula
  A` restatement.
- **OLP-0062**,
  `content/propositional-logic/syntax-and-semantics/semantic-notions.tex`,
  SHA-256 `0167b2bab0dc2a75d011556643190a246d29831244a60bde5515b1b2f431406a`:
  no local mathematical defect found. All displayed `Exercise` proofs remain
  deliberate omissions.

The eight frozen sources total 32,484 bytes, 919 lines, and 3,568 alphabetic
tokens. Their raw bytes concatenated in OLP order have SHA-256
`5b2c3e4838b41c83a19f0f03f09892002ea1898f1fee82fb03661c85547d30a6`.

## Framework limits

- The next reader row is OLP-0063,
  `content/first-order-logic/proof-systems/proof-systems.tex`, SHA-256
  `85b8a0fca16c329ad16b3c17975735c159e0cf9d38e8dfc7501acba84171fb6c`.
- Propositional `soundness.tex` and `completeness.tex` are retained
  non-reader closure files OLP-0715 and OLP-0714, not members of this chapter
  boundary.
- The source's tag architecture permits other primitive/defined connective
  configurations. Preserving dormant branches is not the same as rendering
  all configurations.
- The source presents induction and recursive evaluation at textbook level,
  leaves several proofs as exercises, and says truth-functional completeness
  is planned. This checkpoint does not supply or claim those results.

These deterministic repairs preserve the intended local mathematics while
keeping exact English provenance visible. Build, render, and publication
evidence remain separate; no native-review gate or certification claim is
imposed.
