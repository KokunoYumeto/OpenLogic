# Source-adverse disclosure — OLP-0041--OLP-0048

Date: 2026-08-13  
Authority commit: `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`  
Authority tree: `f67757bb9305b173634082ab4cefd5601a707a34`

This disclosure covers the complete reader-reachable Arithmetization chapter.
It separates deterministic Turkish emendations from mathematical construction
or proof gaps that remain unresolved in the frozen source. Upstream files are
byte-untouched.

## Exact source binding and local emendations

- **OLP-0041**, `content/sets-functions-relations/arithmetization/arithmetization.tex`,
  SHA-256 `05f8775a82c294927a6195ae372c1910e4777909fe8ad2aaa9cbf6dea566fe24`:
  import driver; no local mathematical defect found at lines 8--22.
- **OLP-0042**, `content/sets-functions-relations/arithmetization/integers.tex`,
  SHA-256 `f93b142146b9527128437355d7e3922204eede2ca9c75a941d3c09a9a848ce77`:
  the missing `to` in the notational convention at source line 55 is repaired.
  The unproved representative-independence of the class operations and order
  at lines 41--55 remains disclosed.
- **OLP-0043**, `content/sets-functions-relations/arithmetization/rationals.tex`,
  SHA-256 `7140495368042fcbc55907e6ee568c5bc8b7066e44a01a50cbf4202acebe71d2`:
  source lines 53--60 say `r-s` where the prose and displayed formula require
  `s-r`; Turkish uses `s-r`. Representative-independence, subtraction, and
  reciprocals are not supplied at lines 35--67.
- **OLP-0044**, `content/sets-functions-relations/arithmetization/reals.tex`,
  SHA-256 `3df30161417b836178ff701aa3d778b9ec7c1ba8e3a8a54f98b5584a7960f453`:
  lines 30--32 explicitly use positive numerator and denominator; the
  geometric descent at lines 32 and 55--57 is tied to the actual
  unsimplifiable-fraction choice rather than an unmade “smallest” choice; the
  stray `<` at line 80 is omitted. The source reference at line 72 points to
  History material outside this partial driver, so Turkish names “Tarihten Çok
  Mit mi?” without generating a false page link.
- **OLP-0045**, `content/sets-functions-relations/arithmetization/cuts.tex`,
  SHA-256 `e7cb1029bcb0f0f1ac677c005af8d4e6a10df84bfff50c7483447b972324b44c`:
  chained `p<q\in\alpha` at lines 32 and 69 is expanded; the wrong causal
  clause at lines 64--68 is corrected; `\mathbb R` at line 77 is normalized
  to `\Real`; and lines 91--107 use `0_\Real`, type `p,q` as rationals, and
  restore the zero-factor multiplication case. Subtraction, division, and
  reciprocals remain undefined at lines 85--112.
- **OLP-0046**, `content/sets-functions-relations/arithmetization/reflections.tex`,
  SHA-256 `01032be342b6892c970733acf0b553216c39c5e864c0378d25fea8c5eaa11ead`:
  grammar at lines 28--30 and 66--73 is repaired without changing the claims.
- **OLP-0047**, `content/sets-functions-relations/arithmetization/checking-details.tex`,
  SHA-256 `d791c146f159c8e43368c12cd1a10e61a53f501baf9f3d2c606c7bd589c0ae01`:
  undefined `\sim_\Int` at lines 64--71 is replaced by `\Intequiv`;
  trichotomy at lines 104--109 is stated as the strict exclusive alternatives
  `a<b`, `a=b`, `a>b`; and the missing noun at lines 145--151 is restored.
  The assertion at lines 170--176 is made conditional on first defining the
  omitted subtraction, division, and inverse operations. The appendix still
  omits quotient well-definedness and the properness argument for cut addition
  at lines 158--161.
- **OLP-0048**, `content/sets-functions-relations/arithmetization/cauchy.tex`,
  SHA-256 `35d0a39913340eadcab7fb9d7742b56aef0d0f29868cd65eeca9dc53694e8ac2`:
  decimal digits at lines 28--35 have codomain `{0,...,9}`; “equivalence
  relations” at lines 109--125 becomes equivalence classes and the defined
  `\Realequiv` notation is retained; `0_\Rat` at lines 149--170 becomes
  `0_\Real`; and field/completeness statements at lines 149--185 and
  215--226 are typed at the equivalence-class level. The two History references
  at lines 75--81 and 112--117 name “Limitlerin Kesin Tanımı” descriptively
  because that untranslated section is outside this partial driver.

## Unresolved mathematical gaps

- Integer and rational quotient operations and order are not proved
  independent of representatives. Rational subtraction and reciprocals are
  not defined before the ordered-field exercise.
- The Dedekind-cut construction does not define subtraction, division, or
  reciprocals, and the cut-addition proof asserts properness without its
  rational upper-bound step.
- The Cauchy presentation uses `\sqrt2` to motivate convergence before the
  real construction is available (source lines 89--95), omits congruence and a
  nonzero reciprocal construction before its field theorem (lines 109--170),
  and assumes rational bounding/Archimedean lemmas and recursion in the
  completeness sketch (lines 181--227).

The Dedekind union and displayed bisection are deterministic and do not, by
themselves, require an Axiom of Choice qualification. The declared
emendations preserve the intended local mathematics; they do not supply the
listed missing proofs or claim upstream adoption.

This is a bounded 48/722 checkpoint, not the complete Turkish Open Logic
corpus.
