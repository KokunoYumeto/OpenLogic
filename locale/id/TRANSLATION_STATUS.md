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

Current target-file coverage is 40/722 and the exact remainder is 682 files.
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
- The running set-membership token remains `anggota`; `elemen` is an admitted
  synonym and must be replayed in later model-theory/domain contexts.
- OLP-0001 has no mathematical formula or `\olfileid`; its QA is therefore
  structural, semantic, link, build, extraction, and visual rather than formula
  replay.
- No claim is made that the whole 722-file corpus, a complete downstream
  textbook, or public release is complete.

## Continuation cursor

Next global ordered cursor: `OLP-0041`,
`content/sets-functions-relations/arithmetization/arithmetization.tex`.
The remaining closure is 682 source files after the 40 target files currently
present and admitted.
