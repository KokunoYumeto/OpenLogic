# Bahasa Indonesia Open Logic Translation Status

Date: 2026-08-13

## Authority and branch state

- Target: Bahasa Indonesia (`id`, reader surface `id-ID`).
- Repository branch: `codex/id-id-main`.
- Frozen English authority: Open Logic Project commit
  `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`.
- English source is the semantic authority. Portuguese localization files are
  architecture/comparator evidence only; Malaysian Malay is a separate target.
- Production authority is source-bound AI translation admitted through exact
  source hashes, structural and semantic replay, builds, extracted-text checks,
  rendered-page inspection, target hashes, and preserved adverse evidence.
- Independent source-bound AI semantic replay has been performed for the
  admitted batches. Human/native review metadata is not present; it remains an
  optional later correction/integration source, not an admission gate.

## Complete closure and deterministic order

`..\_control\OPENLOGIC_CLOSURE_MANIFEST_20260812.csv` enumerates all 722
tracked English `content/**/*.tex` files at the frozen commit. The ordered
depth-first replay from `content/open-logic-about.tex` and then
`content/content.tex` through uncommented `\olimport` edges reaches 642 files.
The remaining 80 tracked English content files (59 under `proof-theory` and 21
elsewhere) remain in scope and are appended in ordinal path order. Reader
reachability is scheduling metadata, never an exclusion rule.

The former 692-file figure is the exact content-TeX count of the separate
official Portuguese repository at commit
`51c227190f56bae45d19a85747fc031de430bd3c`; it is not a valid denominator for
this frozen English tree. The English target closure is therefore 722/722
included, with no source exclusion.

Current target-file coverage is 158/722 and the exact remainder is 564 files.
This is a file-presence count, not a claim that the corpus, any complete book,
or all downstream reader builds are complete.

## Admitted production boundaries

### Canonical reader unit OLP-0001

The first canonical-reader unit is translated in full:

- Source: `content/open-logic-about.tex`
- Target: `locale/id/content/open-logic-about.tex`
- Driver: `locale/id/about-id.tex`
- Build product: `locale/id/about-id.pdf` (1 page)

The unit preserves the starred chapter, TOC insertion, italics, both hyperlink
URLs, paragraph structure, attribution statement, and source/prose scope. The
target introduces no new semantic-authority command and has no `\olfileid` in
either source or target.

### Initial Sets batch

The complete Sets chapter remains an admitted out-of-order batch:

1. `content/sets-functions-relations/sets/sets.tex`
2. `content/sets-functions-relations/sets/basics.tex`
3. `content/sets-functions-relations/sets/subsets.tex`
4. `content/sets-functions-relations/sets/important-sets.tex`
5. `content/sets-functions-relations/sets/unions-and-intersections.tex`
6. `content/sets-functions-relations/sets/pairs-and-products.tex`
7. `content/sets-functions-relations/sets/russells-paradox.tex`

All six upstream `\olfileid` values retain their exact components and add only
the required `[id]` locale argument. The chapter driver preserves all six
imports in source order. English files outside `locale/id` are unchanged.

### Contiguous closure through Functions

The production boundary now covers every ordered closure row from `OLP-0001`
through `OLP-0026`, with no gap:

- `OLP-0002`: translated complete-reader editorial warning and invariant root
  imports;
- `OLP-0003`: translated Sets/Functions/Relations part metadata and invariant
  imports;
- `OLP-0004`--`OLP-0010`: complete Sets chapter;
- `OLP-0011`--`OLP-0019`: complete Relations chapter, nine files;
- `OLP-0020`--`OLP-0026`: complete Functions chapter, seven files.

The Relations and Functions content contains 6,994 English-source TeXcount
words and 6,320 Indonesian TeXcount words. Across all 26 current closure files,
the exact totals are 10,423 English-source words and 9,469 Indonesian words.
Counts are per file without recursive imports.

### Contiguous closure through Size of Sets

`OLP-0027`--`OLP-0040` translates the complete fourteen-file Size of Sets
chapter, including both source-provided elementary and alternative treatments.
The batch contains 8,429 English-source TeXcount words and 7,666 Indonesian
words. Across the contiguous forty-file boundary, the exact totals are 18,852
English-source words and 17,135 Indonesian words.

Two independent read-only semantic replays found no translation-introduced
mathematical omission. Nine source-defect classes were repaired and preserved
with path-scoped replay exceptions: triangular-number range, partial inverse of
an injective pairing function, two pairing-list defects, a wrong alternative-
section reference, undefined sequence subscripts in two reductions, a wrong
function name in the equinumerosity proof, a wrong quantified carrier in
Cantor's theorem, transposed diagonal indices and a duplicated bit flip, and a
duplicate global label between the standard and alternative reduction units.
The exact dispositions and per-file hashes are in
`..\_control\OPENLOGIC_SIZE_OF_SETS_INDEPENDENT_REVIEW_20260813.md`.

### Contiguous closure through Arithmetization

`OLP-0041`--`OLP-0048` translates all eight files imported by the complete
Arithmetization chapter: the root, integers, rationals, real-number
construction, cuts, reflections, detailed algebra checks, and the Cauchy
appendix. The batch contains 4,883 English-source TeXcount words and 4,469
Indonesian words. Across the contiguous forty-eight-file boundary, the exact
totals are 23,735 English-source words and 21,604 Indonesian words.

Two independent paragraph-level semantic replays found no omitted or
untranslated reader-facing prose and no translation-origin polarity,
quantifier, or scope drift. Exact path-scoped source repairs include the sign
orientation in rational subtraction, the nonempty-set premise in the supremum
proof, real-zero notation, explicit principal-root and minimal-pair wording,
and six Cauchy-appendix type or exposition defects. The remaining upstream
mathematical/type risks are retained as adverse evidence rather than hidden.
Exact findings, source/target hashes, and dispositions are in
`..\_control\OPENLOGIC_ARITHMETIZATION_INDEPENDENT_REVIEW_20260813.md`.

## Word counts for the 2026-08-12 initial checkpoint

Counts use TeXcount 3.1.1 with `texcount -sum -1 -utf8`, no recursive imports,
and each file counted once.

| File | English source words | Indonesian words |
|---|---:|---:|
| `open-logic-about.tex` | 204 | 190 |
| `sets.tex` | 9 | 9 |
| `basics.tex` | 515 | 445 |
| `subsets.tex` | 452 | 430 |
| `important-sets.tex` | 311 | 312 |
| `unions-and-intersections.tex` | 650 | 564 |
| `pairs-and-products.tex` | 472 | 436 |
| `russells-paradox.tex` | 535 | 514 |
| **Initial eight-file total** | **3,148** | **2,900** |

## Terminology and review dispositions

The terminology/adverse ledger binds Sets terminology to independent
University of Indonesia, Universitas Terbuka, and UIN KHAS evidence where
available. UIN KHAS section 7.1 supports `pasangan terurut` and `hasil kali
Kartesius`. The OLP-0001 surfaces `Proyek Logika Terbuka`, `Teks Logika
Terbuka`, `metalogika formal`, `metode formal`, and `sumber terbuka` are
recorded with exact source constraints.

The independent Sets review's three corrections are disposed and preserved:

- The source convention `Nat = {0,1,...}` now renders as `himpunan bilangan
  asli (dengan 0)` and is stated explicitly in prose; comparator evidence for
  `bilangan cacah` and natural numbers beginning at 1 remains adverse evidence.
- The two source lexical diaeresis commands are deliberately removed from the
  Indonesian word, so the final source text and PDF use `naif`, not `naïf`.
- Automatic section references use `Bagian`, not `Seksi`.

The 2026-08-13 independent Relations and Functions replay is preserved in
`..\_control\OPENLOGIC_RELATIONS_FUNCTIONS_INDEPENDENT_REVIEW_20260813.md`.
It disposed nine material findings, including three earlier Relations source
defects, the source's undefined identity symbol, its reflexive/transitive
closure symbol collision, directed-edge terminology, the zero case for the
principal square root, the empty-domain counterexample to the left-inverse
claim, and a visible compound-word line-break defect. No other material
semantic omission or mistranslation was found in the sixteen reviewed files.

## Replay, build, extraction, and render evidence

The corrected Sets structural replay passed 63 checks across seven files. It
preserves ordered sequences totaling 779 non-lexical-accent TeX commands, 146
environments, 81 localization tokens, 7 labels, 7 references, 3 assets, 6
imports, and 327 normalized mathematical skeletons. A separate assertion
proves source `na\"ive` count 2, target diaeresis count 0, and target `naif`
count 2.

The OLP-0001 replay passed 9 checks: 5 ordered commands, 0 environments, 2
exact URLs, 1 TOC route, starred-chapter structure, balanced braces, 4
paragraph blocks, 6 Indonesian semantic anchors, and zero residual-English
sentinels.

The Relations replay passed 176 checks across eleven files, including the two
translated root/import files. The Functions replay passed 105 checks across
seven files. Both bind exact manifest source hashes and compare ordered command,
environment, token, label, reference, asset, import, URL, citation, identifier,
and mathematical-skeleton sequences. Exact path-specific normalizations encode
the admitted source corrections; unrelated divergence still fails.

The combined Sets/Relations/Functions driver builds cleanly to 36 pages. The
final PDF is 312,855 bytes with SHA-256
`98b32b34fa0df63609227fb2e9b4fc1f33b73ae4ec6285ebe57b86b4ed8c2807`.
Extracted text contains no undefined marker or English environment/reference
label. All 36 pages were inspected across the complete render, and every page
changed by the final semantic dispositions was re-rendered at 180 dpi and
inspected at original resolution.

`BUILD.md` records the exact commands, toolchain, logs, PDF hashes, extracted-
text assertions, and visual review. The corrected Sets PDF is 11 pages; all 11
were inspected, with exact-page review of every correction and relevant
diagram. The OLP-0001 PDF is one page and was inspected at original rendered
resolution.

The Size of Sets replay passed 210 checks across fourteen files. It binds the
exact manifest hashes and ordered closure IDs `OLP-0027`--`OLP-0040`, then
compares uncommented commands, environments, localization tokens, labels,
references, assets, imports, URLs, citations, document classes, file/chapter
IDs, brace balance, and mathematical skeletons. Its path-scoped source
normalizations are enumerated in the independent review receipt; unrelated
divergence remains a hard failure.

The combined driver through Size of Sets builds cleanly to 61 pages and 436,633
bytes, SHA-256
`43644ca531e5e058bb0bf2ee2fec89c304e5387546055087e358fd303c888d71`.
The log contains no fatal error, undefined reference/citation, multiply defined
label, missing glyph, or underfull box. Extracted text is 143,990 bytes with no
unresolved marker or English environment/reference label. Pages 35--61 were
rendered at 144 dpi and all 27 inspected; thirteen formula-, table-, diagonal-,
and correction-heavy pages were additionally inspected at original render
resolution. No clipping, overlap, blank page, broken glyph, lost formula,
damaged table, or margin loss was found.

The Arithmetization replay passed 120 checks across eight files and binds
`OLP-0041`--`OLP-0048` to the frozen source hashes. It compares exact ordered
commands, environments, localization tokens, labels, references, assets,
imports, URLs, citations, document classes, file/chapter IDs, and mathematical
skeletons. Eleven path-specific source normalizations and twelve positive and
rejected-form assertions make the admitted repairs explicit; unrelated drift
remains a hard failure.

The combined driver through Arithmetization builds cleanly to 79 pages and
539,582 bytes, SHA-256
`e938bf09813d45a82516d7646b120358c113337d9c7bdaa8a1a607a36323a1d7`.
The final log contains no fatal error, undefined reference/citation,
multiply-defined label, or missing glyph. Extracted text is 188,162 bytes with
zero unresolved marker or English environment/reference label. Pages 60--79
were rendered at 144 dpi and all twenty inspected; formula-, diagram-, and
proof-dense pages were additionally inspected at readable original resolution.
No clipping, overlap, blank page, broken glyph, lost formula, or margin loss was
found.

### Contiguous Infinite Sets batch

Ordered units `OLP-0049`--`OLP-0054` add the complete Infinite Sets chapter:

1. `infinite.tex`
2. `hilberts-hotel.tex`
3. `dedekind-algebra.tex`
4. `dedekind-induction.tex`
5. `dedekinds-proof.tex`
6. `card-sb.tex`

The Infinite replay passed 115 checks across all six files. It binds exact
manifest source and target hashes and compares ordered commands, environments,
localization tokens, labels, references, citations, imports, URLs, file IDs,
brace balance, and mathematical skeletons. Two exact source repairs and their
corrected target forms are asserted positively; three assertions preserve the
unbound-carrier/endofunction adverse source defect rather than concealing it.

Independent paragraph-level semantic replay found one residual `{iff}` token,
which was corrected to `jika dan hanya jika`, and no other omitted prose or
translation-origin polarity, quantifier, scope, or mathematical error. The
combined driver through Infinite Sets builds cleanly to 87 pages and 583,365
bytes, SHA-256
`825d4ae9d41ee7f3243ce922652a2e4b539c124b968192cc43a48f0ca4202618`.
The log contains zero fatal error, unresolved reference/citation,
multiply-defined label, or missing glyph. Extracted text is 208,533 bytes with
zero unresolved marker or English environment/reference heading. Final pages
78--87 were rendered at 144 dpi and all ten inspected; page 79 was additionally
inspected at 300 dpi. No clipping, overlap, blank changed page, broken glyph,
lost formula, or margin loss was found.

### Propositional Logic syntax and semantics

Ordered units `OLP-0055`--`OLP-0062` add the Propositional Logic part metadata
and its complete Syntax and Semantics chapter. The batch contains 2,853
English-source and 2,715 Indonesian TeXcount words; cumulative counts through
OLP-0062 are 29,001 and 26,631.

Final deterministic replay passed eight files, 112 comparison groups, and 424
mathematical skeletons. Two independent paragraph-level reviews found and
corrected the direction of semantic consequence, then found no remaining
translation-origin omission, polarity, quantifier, scope, mathematical, or
material register defect. Exact path-scoped source repairs remove a standalone
`\iftag` period, an unmatched parenthesis in the implication definition, and
an incorrect `\equiv` where the proof requires syntactic identity `\ident`.
The source's formation-sequence length/index mismatch and its accidental
rebinding of the fixed formula in Local Determination are also repaired in the
Indonesian statements.

All reader-facing OLP-0055--0062 material was built without English fallback in
two bounded drivers: the two-page part surface and the eleven-page chapter.
Both builds exited 0. All thirteen pages were rendered at 144 dpi and inspected;
extracted text contains no unresolved marker, English reference/environment
heading, or localization-token fallback. Exact hashes and dispositions are in
`..\_control\OPENLOGIC_PROPOSITIONAL_SYNTAX_SEMANTICS_INDEPENDENT_REVIEW_20260813.md`.

## Preserved risks and nonclaims

- `cleveref` has no installed Indonesian language module. The locale driver
  initializes it under English, restores Babel Indonesian, and declares exact
  Indonesian names. Extracted final text has no residual English reference or
  environment labels.
- Five Sets overfull-box warnings remain, maximum 5.589 pt. Original-resolution
  render inspection found no clipping, overlap, formula loss, or margin loss.
- Relations and Functions have no overfull or underfull box warning in the
  final combined build.
- Size of Sets adds seven small overfull-box warnings, so the 61-page combined
  log contains twelve in total; the overall maximum remains 5.589 pt. Every
  affected page was included in the exact-resolution render review, with no
  visible loss.
- The 79-page Arithmetization build contains fifteen small overfull boxes,
  maximum 5.66658 pt, one underfull bibliography line, and one underfull vbox.
  Render inspection found no visible loss.
- The two forward references from Arithmetization into the later History part
  use Indonesian label metadata in the bounded driver. They do not import
  untranslated English prose and will be replaced by the real translated
  History labels in the complete reader build.
- The 87-page Infinite build contains eighteen overfull boxes, maximum 6.08615
  pt, one underfull bibliography line, and one inherited underfull vbox. The
  initial 17.92607 pt line was removed by a semantic-neutral register
  refinement before the final build; all remaining warnings are visually
  harmless in the inspected render.
- The bounded Infinite driver adds Indonesian metadata for two later Set Theory
  references while retaining the two History metadata labels. It imports no
  untranslated English prose; real translated labels will replace these
  bounded-build stubs.
- The running set-membership token remains `anggota`; `elemen` is an admitted
  synonym and must be replayed in later model-theory/domain contexts.
- OLP-0001 has no mathematical formula or `\olfileid`; its QA is therefore
  structural, semantic, link, build, extraction, and visual rather than formula
  replay.
- The bounded Sequent Calculus build contains seven small overfull boxes,
  maximum 5.95644 pt. All 26 pages, including every proof-tree-heavy page, were
  inspected at original render resolution with no visible clipping or loss.
- The bounded Natural Deduction build contains eight overfull boxes, maximum
  24.25922 pt, and one underfull vbox. All 27 pages were rendered and inspected;
  every page changed after the final semantic corrections was inspected again
  at original render resolution, with no visible clipping, overlap, or loss.
- The bounded Tableaux build contains eleven overfull boxes, maximum 31.60602
  pt, and four underfull vboxes. All 28 pages were rendered at 144 dpi and
  inspected at original render resolution. The warnings are visually benign:
  no clipping, overlap, broken glyph, lost formula, cutoff tableau, or margin
  loss was found. All fonts are embedded; one rendered Type 3 mathematical
  face remains and did not prevent searchable-text extraction.
- No claim is made that the whole 722-file corpus, a complete downstream
  textbook, or public release is complete.

## Continuation cursor

The complete Sequent Calculus chapter adds OLP-0069--OLP-0083. Its fifteen-file
replay passes 248 checks and 1,009 mathematical skeletons; an independent
read-only semantic replay passes after seven exact source-correction classes.
The bounded driver builds to 26 pages, all rendered at 144 dpi and inspected at
original resolution. TeXcount reports 5,455 English-source and 4,912
Indonesian words for this batch, and 37,187 versus 33,962 cumulatively. Exact
hashes and dispositions are recorded in
`..\_control\OPENLOGIC_SEQUENT_CALCULUS_INDEPENDENT_REVIEW_20260813.md`.

### Contiguous Natural Deduction batch

The complete Natural Deduction chapter adds `OLP-0084`--`OLP-0097`. Its
fourteen-file replay passes 225 checks, 967 mathematical skeletons, and 63
proof/derivation blocks. Independent read-only semantic replay passes all
fourteen live targets after exact correction dispositions. The bounded driver
builds to 27 pages; all pages were rendered at 144 dpi and inspected, with the
four final-delta pages additionally inspected at original resolution.

TeXcount reports 5,270 English-source and 4,847 Indonesian words for this
batch, and 42,457 versus 38,809 cumulatively. Exact hashes and dispositions are
recorded in
`..\_control\OPENLOGIC_NATURAL_DEDUCTION_INDEPENDENT_REVIEW_20260813.md`.

### Contiguous Tableaux batch

The complete Tableaux chapter adds `OLP-0098`--`OLP-0111`. Independent
read-only semantic replay passes all fourteen final live targets after exact
source-correction dispositions, with no unresolved omission, reader-facing
English, polarity, quantifier, scope, mathematical, proof-tree, or material-
register defect. The bounded driver builds to 28 pages; all pages were rendered
at 144 dpi and inspected at original resolution.

TeXcount reports 6,062 English-source and 5,616 Indonesian words for this
batch, and 48,519 versus 44,425 cumulatively. Exact hashes and dispositions are
recorded in
`..\_control\OPENLOGIC_TABLEAUX_INDEPENDENT_REVIEW_20260813.md`.

Next global ordered cursor: `OLP-0112`,
`content/first-order-logic/axiomatic-deduction/axiomatic-deduction.tex`.
The remaining closure is 611 source files after the 111 target files currently
present and admitted.

### Contiguous Axiomatic Deduction batch

The complete Axiomatic Deduction chapter adds `OLP-0112`--`OLP-0125`.
Independent read-only semantic replay passes all fourteen final live targets
after exact source-correction dispositions. No unresolved translation-origin
omission, reader-facing English, polarity, quantifier, scope, formula, proof,
or material-register defect remains. The bounded driver builds to 15 pages;
all pages were rendered at 144 dpi and inspected at original resolution.

TeXcount reports 3,442 English-source and 3,216 Indonesian words for this
batch, and 51,961 versus 47,641 cumulatively. Exact hashes and dispositions
are recorded in
`..\_control\OPENLOGIC_AXIOMATIC_DEDUCTION_INDEPENDENT_REVIEW_20260813.md`.

Next global ordered cursor: `OLP-0126`,
`content/first-order-logic/completeness/completeness.tex`.
The remaining closure is 597 source files after the 125 target files currently
present and admitted.

### Contiguous Completeness batch

The complete Completeness chapter adds `OLP-0126`--`OLP-0137`. The frozen-byte
deterministic replay passes 334 checks across all twelve files, admits exactly
21 path-scoped correction classes covering 27 source occurrences, and preserves
all unrelated command, environment, token, label, reference, import, tag-key,
and mathematical structure. Its SHA-256 is
`df272d805090f777199872be236d149b0932a584738e70bf7442bc2a2774f77e`.

Independent read-only semantic replay passes all twelve final targets with no
translation-origin omission, reversal, quantifier swap, term/formula-variable
corruption, or untranslated reader prose. It preserves two upstream risks:
the direct compactness proof's identity-enabled case appears to require the
quotient/factored term-model analogue, and the identity well-definedness
statement does not explicitly quantify its indexed equivalences. Exact hashes,
corrections, and dispositions are in
`..\..\..\_control\OPENLOGIC_COMPLETENESS_INDEPENDENT_REVIEW_20260813.md` (SHA-256
`05c6ae1b2616db86d7e7f9b0de1f46bc71f13444574a4995fc71fab93f8b3e02`).

The bounded driver builds to 22 pages and 268,745 bytes, SHA-256
`fd962d07b6096d7a243ca39fec1303d4e880ad97c4f55436e44c7c0b3c6e5a2c`.
The final log contains zero undefined reference/citation, missing glyph, or
fatal condition. Seventeen overfull boxes (maximum 29.23381 pt) and two
underfull boxes remain; exact-resolution inspection found them visually clean.
All 22 pages were rendered and inspected. Extracted-text searches found zero
`??` or English environment labels, and verified canonical chapter number 23
and the required full-reader prerequisite reference numbers.

TeXcount reports 8,171 English-source and 7,824 Indonesian words for this
batch, and 60,132 versus 55,465 cumulatively. No native/human review metadata
is present; its absence is not an admission blocker.

Next global ordered cursor: `OLP-0138`,
`content/first-order-logic/first-order-logic.tex`.
The remaining closure is 585 source files after the 137 target files currently
present and admitted.

## Publication/discoverability gate

The durable language-and-corpus DOI architecture is recorded in
`..\..\..\_control\INDONESIAN_CORPUS_DOI_AND_DISCOVERABILITY_PROTOCOL_20260813.md`.
It does not change the translation cursor. No Indonesian Open Logic DOI has
been minted, and none may be minted before a complete-draft 722/722 closure
with a cumulative reader build, source package, provenance package, QA
receipts, and checksums.

### Contiguous First-Order Logic introduction batch

The First-Order Logic part wrapper and complete introductory chapter add
`OLP-0138`--`OLP-0148`. Exact frozen-source and target replay passes 302
checks across all eleven files, including 333 mathematical skeletons, one
mathematical environment, 219 semantic tokens, and seven path-scoped source
correction classes over nine exact source occurrences. Independent semantic
review passes the final target bytes and preserves seven upstream exposition
risks for the eventual concise maintainer issue. Exact bindings and
dispositions are in
`..\..\..\_control\OPENLOGIC_FOL_INTRODUCTION_INDEPENDENT_REVIEW_20260813.md`
(SHA-256
`e63ba97fd0ee3f4101543bb609f6591fe4e9a96863bf1d712647db5edaab5537`).

The bounded driver builds to 12 pages and 164,450 bytes, SHA-256
`327829be2dba42640f17c585213fb718290befec4a8f4437e5dbf27176df1f92`.
The canonical project bibliography resolves the single citation. The final
log contains zero undefined reference/citation, missing glyph, or fatal
condition. Four overfull boxes remain, maximum 13.60612 pt; inspection found
them visually contained. All 12 pages were rendered at 144 dpi and inspected
with no clipping, overlap, damaged glyph, lost formula, or margin loss.
Extracted text is 31,345 bytes / 4,616 whitespace-delimited words, SHA-256
`cb251711317998a3e9fa69880bcf103d51c51d40fc0be791b78d18c785b1617f`.

TeXcount reports 4,433 English-source and 4,070 Indonesian words for this
batch, and 64,565 versus 59,535 cumulatively. No native/human review metadata
is present; its absence is not an admission blocker.

Next global ordered cursor: `OLP-0149`,
`content/first-order-logic/syntax-and-semantics/syntax.tex`.
The remaining closure is 574 source files after the 148 target files currently
present and admitted.

### Contiguous First-Order Logic syntax batch

The complete Syntax of First-Order Logic chapter adds `OLP-0149`--`OLP-0158`.
All ten frozen source hashes match the 722-file manifest. Deterministic replay
binds the final commands, environments, semantic tokens, labels, references,
imports, tag logic, mathematical skeletons, and localized IDs; exact aggregate
counts and correction dispositions are recorded in
`..\..\..\_control\OPENLOGIC_FOL_SYNTAX_INDEPENDENT_REVIEW_20260813.md`.

The cumulative bounded driver builds to 31 pages and 294,747 bytes, SHA-256
`6b3247acfe2159b4e4c0b442ae9f0636e2a1de8bcbfc28569fc8bf4cf0c717f7`.
The final log contains zero undefined reference/citation, missing glyph, or
fatal condition. Fourteen overfull boxes remain: four inherited from the
introduction and ten in the syntax chapter; the overall maximum is 13.60612 pt
and the syntax-only maximum is 11.24406 pt. All 31 pages were rendered at 144
dpi and inspected at original render resolution. No clipping, overlap, blank
content page, broken glyph, lost formula, damaged table, or margin loss was
found. The final extracted text is 72,599 bytes / 10,946 whitespace-delimited
words, SHA-256
`02ddfbb7f9ea14b7f265e626dd8b63a4bf4827ae5929a23c847de25561a9fc4c`;
it contains zero unresolved marker, English environment label, raw `free for`,
or `sub-formula`, and positively contains `subformula`, `atomik`, `latihan`, and
`bebas disubstitusikan bagi`.

TeXcount reports 5,535 English-source and 5,068 Indonesian words for this
batch, and 70,100 versus 64,603 cumulatively. No native/human review metadata
is present; its absence is not an admission blocker.

Next global ordered cursor: `OLP-0159`,
`content/first-order-logic/syntax-and-semantics/semantics.tex`.
The remaining closure is 564 source files after the 158 target files currently
present and admitted.
