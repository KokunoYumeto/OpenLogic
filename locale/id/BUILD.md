# Bahasa Indonesia Open Logic Build and QA

Date: 2026-08-12  
Repository: `C:\Users\Floris\Documents\interlanguage\04_mirrors\id\openlogic`  
Authority commit: `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`

## Structural replay

The corrected Sets batch was replayed from the repository root with:

```powershell
& 'locale\id\qa_structural_replay.ps1'
```

Result: exit code 0.

```text
LEXICAL_ACCENT_CORRECTION_OK source_naive=2 target_diaeresis=0 target_naif=2
STRUCTURAL_REPLAY_OK files=7 checks=63 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0
```

OLP-0001 was replayed separately with:

```powershell
& 'locale\id\qa_olp0001_replay.ps1'
```

Result: exit code 0.

```text
OLP0001_REPLAY_OK files=1 checks=9 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0
```

That replay compares ordered TeX commands, environments, both hyperlink URLs,
TOC routing, starred-chapter structure, brace balance, paragraph blocks, six
Indonesian semantic anchors, and four residual-English sentinels.

## Isolated builds

Both drivers were built from the repository root with automatic package
installation disabled:

```powershell
$env:MIKTEX_ENABLE_INSTALLER='0'
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' -cd locale/id/sets-id.tex
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' -cd locale/id/about-id.tex
```

Toolchain: Latexmk 4.88 and MiKTeX pdfTeX 1.40.29.

| Driver | Result | PDF | Pages | Bytes | SHA-256 |
|---|---|---|---:|---:|---|
| `sets-id.tex` | exit 0 | `locale/id/sets-id.pdf` | 11 | 167,775 | `6e4a9ac20dde4c3b84b1d8e9af3f49f8c5ee453fa6351ce7875696eeb7c5b93a` |
| `about-id.tex` | exit 0 | `locale/id/about-id.pdf` | 1 | 44,688 | `683283e3f4fd59e817a99531af54c94131ecad4b8dcfcaebcb3429e3e9c665b4` |

Neither log contains a fatal error, undefined reference, or
multiply-defined-label warning. Both preserve the upstream `hyperref`
bookmarks warning, two package-provides-name warnings, and the upstream memoir
deprecation warning. Sets preserves five overfull boxes (4.47737 pt, 5.589 pt,
1.63104 pt, 1.65683 pt, and 3.45694 pt); OLP-0001 has no overfull or underfull
box warning.

## Render and visual review

Bundled Poppler `pdfinfo.exe` confirmed letter-size, PDF 1.5, unencrypted,
non-form PDFs: 11 pages for Sets and one page for OLP-0001. The final PDFs
were rendered at 144 dpi with bundled `pdftoppm.exe`.

All 11 Sets pages were inspected in a complete contact sheet. Pages 4, 5, 8,
10, and 11 were additionally inspected at original rendered resolution to
verify the corrected natural-number convention, `Bagian` cross-reference,
`hasil kali Kartesius`, Russell-paradox typography, diagrams, formulae, and
problem list. Result: 11/11 pages legible, with no clipping, overlap, blank
page, broken glyph, damaged formula, missing diagram, or margin loss.

The sole OLP-0001 page was inspected at original rendered resolution. Its
heading, three prose paragraphs, italics, line breaks, and final web label are
legible, with no clipping, overlap, broken glyph, or margin loss. Temporary
PNG and extracted-text QA files were removed after inspection.

## Extracted-text checks

Text was extracted with `pdftotext -layout` from both final PDFs. Sets has one
rendered `naif`, zero `naïf`, zero `Seksi`, one `Bagian 1.1`, one explicit
`himpunan bilangan asli (dengan 0)` caption, one convention sentence stating
that natural numbers include zero in this text, two `hasil kali Kartesius`
occurrences, zero `perkalian Kartesius`, zero English environment labels, and
zero `??` or `Undefined` markers.

OLP-0001 contains the Indonesian title and the anchors `metalogika formal`,
`metode formal`, `Creative Commons Atribusi`, and `openlogicproject.org`. It
contains zero source-English sentence sentinels and zero `??` or `Undefined`
markers.

## Count method

Each source and Indonesian file was counted once, without recursive imports,
using `texcount -sum -1 -utf8`.

- Sets: 2,944 English-source words and 2,710 Indonesian words.
- OLP-0001: 204 English-source words and 190 Indonesian words.
- Initial eight translated closure files: 3,148 English-source words and
  2,900 Indonesian words.

## Relations and Functions checkpoint — 2026-08-13

### Source binding and structural replay

The checkpoint extends the contiguous Indonesian closure through `OLP-0026`.
The frozen authority remains
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`; every replayed source hash equals
its row in `..\_control\OPENLOGIC_CLOSURE_MANIFEST_20260812.csv`.

```powershell
& 'locale\id\qa_relations_batch_replay.ps1'
& 'locale\id\qa_functions_batch_replay.ps1'
```

Both commands exited 0:

```text
RELATIONS_BATCH_REPLAY_OK files=11 checks=176 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0
FUNCTIONS_BATCH_REPLAY_OK files=7 checks=105 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0
```

The replays compare ordered TeX commands, environments, localization tokens,
labels, references, assets, imports, URLs, citations, document classes, stable
file/chapter/part identifiers, balanced braces, and normalized mathematical
skeletons. Exact source corrections are normalized only at their declared path:
the undefined identity `I` becomes `\Id{\Nat}`, reflexive closure uses local
`S` rather than the later transitive-closure symbol `R^+`, the tree carrier is
`A` rather than undefined `X`, and the subtree premise is nonempty. The semantic
review receipt records these and all prose-level dispositions.

### Final combined build

The final combined driver was built from the repository root with automatic
package installation disabled:

```powershell
$env:MIKTEX_ENABLE_INSTALLER='0'
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' -cd locale/id/functions-id.tex
```

Result: exit 0 using Latexmk 4.88 and MiKTeX pdfTeX 1.40.29.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `functions-id.tex` | `locale/id/functions-id.pdf` | 36 | 312,855 | `98b32b34fa0df63609227fb2e9b4fc1f33b73ae4ec6285ebe57b86b4ed8c2807` |

The final log contains no fatal error, undefined reference, undefined citation,
multiply-defined label, missing glyph, or underfull box. Relations and Functions
have no overfull box. The five retained overfull boxes are all in the previously
admitted Sets chapter (4.47737, 5.589, 1.63104, 1.65683, and 3.45694 pt) and
remain visually harmless.

### Extraction and rendered-page review

`pdftotext -layout` exited 0 and produced 78,384 bytes. Sentinel search found
zero `??`, `Undefined`, English environment/reference labels, the rejected
`akar kuadrat positif`, the broken `kadang- kadang`, the undefined identity
symbol in the natural-number relation example, or the collided reflexive-closure
notation. Positive checks located `\Id{\Nat}`, `S = R \cup \Id{A}`, `busur`,
`akar kuadrat utama, yaitu akar kuadrat nonnegatif`, contiguous
`kadang-kadang`, and the nonempty-domain premise.

All 36 pages were inspected across the complete combined render. After the final
semantic corrections, affected pages 13, 18--20, 26, and 28--32 were rendered
again at 180 dpi and inspected at original resolution. Headings, prose, formulas,
proof-end markers, cross-references, and diagrams are legible; there is no
clipping, overlap, blank changed page, broken glyph, lost formula, missing asset,
or unresolved reference.

### Counts and next cursor

TeXcount 3.1.1 (`texcount -sum -1 -utf8`, each file once, no recursive imports)
reports 10,423 English-source words and 9,469 Indonesian words across the 26
current target files. The exact continuation cursor is `OLP-0027`,
`content/sets-functions-relations/size-of-sets/size-of-sets-complete.tex`.

## Size of Sets checkpoint — 2026-08-13

### Source binding, replay, and semantic review

The contiguous boundary extends through `OLP-0040`. Frozen English authority
remains `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`, which is an ancestor of the
locale checkpoint branch. Every source hash equals its row in the 722-file
closure manifest.

```powershell
& 'locale\id\qa_size_of_sets_batch_replay.ps1'
```

Result: exit code 0.

```text
SIZE_OF_SETS_BATCH_REPLAY_OK files=14 checks=210 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 closure=OLP-0027..OLP-0040
```

The script compares uncommented ordered commands, environments, localization
tokens, labels, references, assets, imports, URLs, citations, document classes,
stable file/chapter IDs, brace balance, and mathematical skeletons. Exact
path-scoped normalizations cover only the admitted English-source corrections;
unrelated divergence fails. Two independent read-only semantic replays found no
translation-introduced material error. Exact findings, source/target hashes,
and dispositions are in
`..\_control\OPENLOGIC_SIZE_OF_SETS_INDEPENDENT_REVIEW_20260813.md`.

### Clean combined build

```powershell
$env:MIKTEX_ENABLE_INSTALLER='0'
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' -cd locale/id/size-of-sets-id.tex
```

Result: exit 0 using Latexmk 4.88 and MiKTeX pdfTeX 1.40.29.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `size-of-sets-id.tex` | `locale/id/size-of-sets-id.pdf` | 61 | 436,633 | `43644ca531e5e058bb0bf2ee2fec89c304e5387546055087e358fd303c888d71` |

The final log has zero fatal errors, undefined references/citations, multiply
defined labels, missing glyphs, or underfull boxes. There are twelve small
overfull boxes: five in the admitted Sets chapter and seven in Size of Sets;
the overall maximum is 5.589 pt. Render inspection found all visually harmless.

### Extraction and visual review

`pdftotext -layout` exited 0 and produced 143,990 bytes. Searches returned zero
`??`, `Undefined`, English environment/reference labels, `Seksi`, rejected
earlier term forms, and broken compound words. Positive anchors include `Ukuran
Himpunan`, `Enumerasi dan Himpunan Terhitung`, `Himpunan Takterhitung`,
`Teorema Cantor`, `metode diagonalisasi`, and `fungsi pemasangan`. The three
generic English sentinel hits after Bab 4 occur only in preserved bibliography
titles.

Pages 35--61 were rendered at 144 dpi. All 27 pages were inspected in complete
contact sheets. Pages 36, 38, 40, 41, 43--46, 51, and 54--57 were also inspected
at original render resolution because they contain chapter transitions,
formulae, arrays, diagonal constructions, or admitted source corrections. No
clipping, overlap, blank page, broken glyph, lost formula, damaged table, or
margin loss was found.

### Counts and next cursor

TeXcount 3.1.1 (`-sum -1 -utf8`, each file once, no recursive imports) reports
8,429 English-source words and 7,666 Indonesian words for the fourteen-file
batch, and 18,852 English-source words versus 17,135 Indonesian words across
all forty admitted files. The exact next cursor is `OLP-0041`,
`content/sets-functions-relations/arithmetization/arithmetization.tex`.

## Arithmetization checkpoint — 2026-08-13

### Source binding, replay, and semantic review

The contiguous boundary extends through `OLP-0048`. Frozen English authority
remains `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`, and every source hash equals
its exact closure-manifest row.

```powershell
& 'locale\id\qa_arithmetization_batch_replay.ps1'
```

Result: exit code 0.

```text
ARITHMETIZATION_BATCH_REPLAY_OK files=8 checks=120 source_corrections=11 target_corrections=12 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 closure=OLP-0041..OLP-0048
```

Two independent read-only semantic reviews covered every paragraph. They found
no omitted or untranslated reader-facing prose and no translation-origin
polarity, quantifier, or scope drift. The exact repairs, retained source
defects, and per-file hashes are recorded in
`..\_control\OPENLOGIC_ARITHMETIZATION_INDEPENDENT_REVIEW_20260813.md`.

### Clean combined build

```powershell
$env:MIKTEX_ENABLE_INSTALLER='0'
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' -cd locale/id/arithmetization-id.tex
```

Result: exit 0 using Latexmk 4.88 and MiKTeX pdfTeX 1.40.29.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `arithmetization-id.tex` | `locale/id/arithmetization-id.pdf` | 79 | 539,582 | `e938bf09813d45a82516d7646b120358c113337d9c7bdaa8a1a607a36323a1d7` |

The final log has zero fatal errors, undefined references/citations,
multiply-defined labels, or missing glyphs. Fifteen small overfull boxes remain,
with a maximum of 5.66658 pt; one underfull bibliography line and one underfull
vbox are retained. Every affected page was included in visual review and no
visible content loss was found.

The bounded driver declares Indonesian metadata for two forward references to
the later History part. It does not import untranslated History prose. The
metadata will yield to the real localized labels when that part joins the
complete Indonesian reader.

### Extraction and visual review

`pdftotext -layout` exited 0 and produced 188,162 bytes. Searches found zero
`??`, `Undefined`, English theorem/environment/reference labels, or residual
reader-facing English prose. Positive anchors include `Aritmetisasi`, `Garis
Bilangan Real`, `Potongan`, `Barisan Cauchy`, and the two forward-reference
surfaces `Bagian H.1` and `Bagian H.2`.

Pages 60--79 were rendered at 144 dpi and all twenty pages were inspected in
complete contact sheets. Formula-, diagram-, and proof-dense pages 65 and
69--77 were additionally inspected at readable original resolution. Headings,
prose, formulas, proof-end marks, the diagram, exercises, references, and
bibliography are legible; there is no clipping, overlap, blank changed page,
broken glyph, lost formula, or margin loss.

### Counts and next cursor

TeXcount 3.1.1 (`-sum -1 -utf8`, each file once, no recursive imports) reports
4,883 English-source words and 4,469 Indonesian words for the eight-file batch,
and 23,735 English-source words versus 21,604 Indonesian words across all
forty-eight admitted files. The exact next cursor is `OLP-0049`,
`content/sets-functions-relations/infinite/infinite.tex`.

## Infinite Sets checkpoint — 2026-08-13

### Source binding, replay, and semantic review

The contiguous boundary extends through `OLP-0054`. Frozen English authority
remains `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`, and every source hash
equals its exact closure-manifest row.

```powershell
& 'locale\id\qa_infinite_batch_replay.ps1'
```

Result: exit code 0.

```text
INFINITE_BATCH_REPLAY_OK files=6 checks=115 source_corrections=2 reader_text_exceptions=1 target_corrections=2 adverse_assertions=3 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 closure=OLP-0049..OLP-0054
```

Independent read-only semantic replay covered every paragraph. It found one
residual `{iff}` token, corrected to `jika dan hanya jika`, and no other
omission or translation-origin polarity, quantifier, scope, or mathematical
error. The exact per-file hashes, two `card-sb.tex` source repairs, preserved
Closure-lemma source defects, and review disposition are in
`..\_control\OPENLOGIC_INFINITE_SETS_INDEPENDENT_REVIEW_20260813.md`.

### Clean combined build

```powershell
$env:MIKTEX_ENABLE_INSTALLER='0'
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' -cd locale/id/infinite-id.tex
```

Result: exit 0 using Latexmk 4.88 and MiKTeX pdfTeX 1.40.29.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `infinite-id.tex` | `locale/id/infinite-id.pdf` | 87 | 583,365 | `825d4ae9d41ee7f3243ce922652a2e4b539c124b968192cc43a48f0ca4202618` |

The final log has zero fatal errors, undefined references/citations,
multiply-defined labels, or missing glyphs. Eighteen overfull boxes remain,
maximum 6.08615 pt, plus one underfull bibliography line and one inherited
underfull vbox. A semantic-neutral shortening removed the initial 17.92607 pt
line before this final build. Render inspection found no visible loss.

The bounded driver declares Indonesian metadata for two forward references to
the later Set Theory part and retains the two later History references. It does
not import untranslated prose; those stubs yield to real localized labels when
the corresponding parts enter the complete reader.

### Extraction and visual review

`pdftotext -layout` exited 0 and produced 208,533 bytes. Searches found zero
`??`, `Undefined`, or English theorem/environment/reference labels. Positive
anchors include `Himpunan Tak Hingga`, `Hotel Hilbert`, `Aljabar Dedekind`,
`Induksi aritmetis`, and `Membuktikan Schröder--Bernstein`.

Final pages 78--87 were rendered at 144 dpi and all ten inspected at readable
resolution. Page 79 was additionally rendered and inspected at 300 dpi. The
chapter transition, Hotel Hilbert diagram, formulas, proof-end marks,
cross-references, and bibliography are legible; there is no clipping, overlap,
blank changed page, broken glyph, lost formula, or margin loss.

### Counts and next cursor

TeXcount 3.1.1 (`-sum -1 -utf8`, each file once, no recursive imports) reports
2,413 English-source words and 2,312 Indonesian words for the six-file batch,
and 26,148 English-source words versus 23,916 Indonesian words across all
fifty-four admitted files. The exact next cursor is `OLP-0055`,
`content/propositional-logic/propositional-logic.tex`.

## Propositional Logic syntax and semantics checkpoint — 2026-08-13

### Source binding, replay, and semantic review

The contiguous boundary extends through `OLP-0062`. Every source hash equals
its row in the frozen 722-file closure manifest. The durable replay command is:

```powershell
& 'locale\id\qa_propositional_syntax_batch_replay.ps1'
```

Its final result is:

```text
PROP_SYNTAX_REPLAY_OK files=8 checks=112 math_skeletons=424 reader_order_exceptions=1 source_corrections=3 correction_assertions=3 closure=OLP-0055..OLP-0062 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0
```

Two independent paragraph-level semantic replays found no remaining omission,
reader-facing English, polarity, quantifier, scope, mathematical, or material
register defect. The exact three path-scoped structural repairs and two
semantic source repairs are recorded in
`..\_control\OPENLOGIC_PROPOSITIONAL_SYNTAX_SEMANTICS_INDEPENDENT_REVIEW_20260813.md`.

### Clean bounded builds

OLP-0055 imports later untranslated proof-system units. It is therefore built
in a bounded part driver that suppresses only downstream imports; the complete
OLP-0056--0062 chapter is built separately. This renders every translated
reader surface without importing English fallback.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `propositional-part-id.tex` | `locale/id/propositional-part-id.pdf` | 2 | 38,380 | `9747a415962fa62c0b263965f966cd457fb42b8b8147666bdcf41520237aa2a8` |
| `propositional-syntax-semantics-id.tex` | `locale/id/propositional-syntax-semantics-id.pdf` | 11 | 195,778 | `8e04657dc409e29d59badaa0b9d411e2a633799384777ac58d44654e20294d0c` |

Both `latexmk` runs exited 0 under MiKTeX with automatic installation disabled.
The logs contain no fatal error, undefined reference/citation,
multiply-defined label, missing glyph, or underfull box. The chapter has three
small overfull boxes, maximum 5.47389 pt; all are visually harmless.

### Extraction, render review, and counts

`pdftotext -layout` produced 779 and 22,282 bytes. Searches found zero `??`,
`Undefined`, English environment/reference headings, localization-token
fallbacks, and the rejected standalone punctuation artifact. Both part pages
and all eleven chapter pages were rendered at 144 dpi and inspected. No
clipping, overlap, blank content page, broken glyph, lost formula, damaged
table, or margin loss was found.

TeXcount 3.1.1 reports 2,853 English-source and 2,715 Indonesian words for this
eight-file batch, and 29,001 versus 26,631 across all sixty-two admitted files.
The exact next cursor is `OLP-0063`,
`content/first-order-logic/proof-systems/proof-systems.tex`.

## Proof Systems overview checkpoint — 2026-08-13

`qa_proof_systems_overview_batch_replay.ps1` passes six files and 122 checks,
including 359 ordered commands, 26 environment markers, 156 localization
tokens, five imports, 137 mathematical skeletons, four proof/derivation blocks,
ten localized file IDs, and exact assertions for every declared source repair.
The batch contains 2,731 English-source and 2,419 Indonesian TeXcount words;
cumulative counts through OLP-0068 are 31,732 and 29,050.

`proof-systems-overview-id.tex` builds with `latexmk` exit 0 to an eight-page,
118,822-byte PDF, SHA-256
`c8e7475d52cd072d13c0e58467d04976f1bfef976d7e2a9a79b7905e26e94902`.
The log has zero fatal error, undefined control sequence/reference/citation,
multiply defined label, or missing glyph. Three overfull boxes remain (9.2365,
0.67668, and 0.19641 pt); all are visually harmless.

Extracted text is 20,256 bytes and contains zero unresolved marker, English
environment/reference heading, named English proof-system fallback, hard-coded
`Assumption`, or rejected `Sistem Suatu derivasi`. All eight pages were rendered
at 144 dpi and inspected. No clipping, overlap, blank content page, broken
glyph, lost formula, damaged proof tree, or margin loss was found. The exact
next cursor is OLP-0069.

## Sequent Calculus checkpoint — 2026-08-13

### Source binding, replay, and semantic review

The gap-free boundary extends through `OLP-0083`. Every source hash equals its
row in the frozen 722-file closure manifest. The durable replay command is:

```powershell
& 'locale\id\qa_sequent_calculus_batch_replay.ps1'
```

Its final result is:

```text
SEQUENT_CALCULUS_BATCH_REPLAY_OK files=15 checks=248 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 next=OLP-0084
```

The replay binds 3,690 commands, 358 environment markers, 180 localization
tokens, 22 labels, 15 references, 14 imports, 1,009 mathematical skeletons,
and 58 proof/derivation blocks. Seven source-correction classes comprise twelve
exact occurrences. An independent read-only semantic replay found no remaining
translation-origin omission, reader-facing English, polarity, quantifier,
scope, altered exercise, mathematical, or material-register defect. Full
dispositions and hashes are in
`..\_control\OPENLOGIC_SEQUENT_CALCULUS_INDEPENDENT_REVIEW_20260813.md`.

### Clean bounded build

Run from `locale\id`:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error sequent-calculus-id.tex
```

Result: exit 0 using Latexmk 4.88 and MiKTeX pdfTeX 1.40.29.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `sequent-calculus-id.tex` | `locale/id/sequent-calculus-id.pdf` | 26 | 212,888 | `9990d74508d6f1e5eee911001c5ea9417b4bc37969b6f8344e0682bab166613f` |

The final log has zero fatal error, undefined control sequence/reference/
citation, multiply defined label, underfull box, or missing glyph. Seven small
overfull boxes remain, maximum 5.95644 pt; render inspection found no visible
loss. `pdfinfo` confirms 26 letter-size pages, no encryption or forms. Every
font is embedded; the one Type 3 mathematical font renders correctly.

### Extraction, render review, and counts

`pdftotext -layout` produced 58,371 bytes and 7,935 whitespace-delimited words.
Searches found zero `??`, `Undefined`, English environment/reference heading,
localization-token fallback, or reader-facing English residue. All 26 pages
were rendered at 144 dpi and inspected at original render resolution. No
clipping, overlap, blank content page, broken glyph, lost formula, cutoff proof
tree, damaged hyperlink, or margin loss was found.

After final source-whitespace cleanup, a fresh 144-dpi render of all 26 pages
was compared byte-for-byte with the inspected render: all 26 PNG pairs were
identical. The PDF SHA above binds the final rebuild bytes.

TeXcount 3.1.1 reports 5,455 English-source and 4,912 Indonesian words for this
batch, and 37,187 versus 33,962 across all eighty-three admitted files. The
exact next cursor is `OLP-0084`,
`content/first-order-logic/natural-deduction/natural-deduction.tex`.

## Natural Deduction checkpoint — 2026-08-13

### Source binding, replay, and semantic review

The gap-free boundary extends through `OLP-0097`. Every source hash equals its
row in the frozen 722-file closure manifest. The durable replay command is:

```powershell
& 'locale\id\qa_natural_deduction_batch_replay.ps1'
```

Its final result is:

```text
NATURAL_DEDUCTION_BATCH_REPLAY_OK files=14 checks=225 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 next=OLP-0098
```

The replay binds 3,082 commands, 362 environment markers, 268 localization
tokens, 21 labels, 12 references, 13 imports, 967 mathematical skeletons, and
63 proof/derivation blocks. Exact path-scoped source corrections remain hard-
bound in the replay; unrelated structural drift fails. Independent read-only
semantic replay of all fourteen final live targets found no remaining
translation-origin omission, reader-facing English, polarity, quantifier,
scope, exercise, formula, or proof-tree defect. Full dispositions and hashes
are in
`..\_control\OPENLOGIC_NATURAL_DEDUCTION_INDEPENDENT_REVIEW_20260813.md`.

### Clean bounded build

Run from `locale\id`:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error natural-deduction-id.tex
```

Result: exit 0 using Latexmk 4.88 and MiKTeX pdfTeX 1.40.29.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `natural-deduction-id.tex` | `locale/id/natural-deduction-id.pdf` | 27 | 209,663 | `c2ee4b9d2662b986780b2f1580ea4c1c4effe05fb39e4feda54f061370e81704` |

The final log has zero fatal error, undefined control sequence/reference/
citation, multiply defined label, or missing glyph. Two inherited package-name
warnings, eight overfull boxes (maximum 24.25922 pt), and one underfull vbox
remain. Exact-resolution render inspection found no visible loss. `pdfinfo`
confirms 27 letter-size pages, no encryption, and no forms. All fonts are
embedded; the one Type 3 mathematical font lacks a Unicode map but renders
correctly and did not prevent successful text extraction.

### Extraction, render review, and counts

`pdftotext -layout` produced 61,952 bytes, SHA-256
`b1f5ebffc5a9a8039c00bcce9093f02aee7ec6e3b59d797a489d69d9d99d0952`,
and 7,220 whitespace-delimited words. Searches found zero `??`, `Undefined`,
English environment/reference heading, raw localization token, named English
technical fallback, or reader-facing English residue.

All 27 pages were rendered at 144 dpi and inspected at original render
resolution. A post-layout-fix render differed only on pages 25--27, which were
reinspected and passed. The final semantic edits changed only pages 4, 8, 9,
and 19 relative to that inspected render; all four were inspected again at
original resolution. No clipping, overlap, blank content page, broken glyph,
lost formula, cutoff proof tree, merged problem heading, damaged hyperlink, or
margin loss was found.

After final source-whitespace cleanup, the PDF was rebuilt and all 27 pages
were rendered once more. Every page PNG was byte-identical to the already
inspected final render; the updated PDF hash above binds those final source
bytes.

TeXcount 3.1.1 reports 5,270 English-source and 4,847 Indonesian words for this
batch, and 42,457 versus 38,809 across all ninety-seven admitted files. The
exact next cursor is `OLP-0098`,
`content/first-order-logic/tableaux/tableaux.tex`.

## Tableaux checkpoint — 2026-08-13

The gap-free boundary extends through `OLP-0111`. Frozen source authority is
commit `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`; all fourteen source and target
hashes are bound by `qa_tableaux_batch_replay.ps1`.

```text
STRUCTURAL_TOTALS environments=346 labels=22 references=16 citations=0 assets=0 imports=13 math=587 formal_blocks=51 correction_assertions=24
TABLEAUX_BATCH_REPLAY_OK files=14 checks=238 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 next=OLP-0112
```

Independent semantic replay passes all fourteen final live files with no
unresolved finding. Exact dispositions and hashes are in
`..\_control\OPENLOGIC_TABLEAUX_INDEPENDENT_REVIEW_20260813.md`.

`latexmk -pdf -interaction=nonstopmode -halt-on-error tableaux-id.tex` exited
0. `tableaux-id.pdf` is 28 pages and 229,826 bytes, SHA-256
`c1be0a95411b67ae928146bb812e9b4cfdaeb417e9d192d885d28790fc077bcc`.
The log has zero fatal error, undefined control sequence/reference/citation,
multiply defined label, or missing glyph. Eleven overfull boxes (maximum
31.60602 pt) and four underfull vboxes are visually benign. All fonts are
embedded; one rendered Type 3 mathematical face remains.

`pdftotext -layout` produced 59,155 bytes, SHA-256
`094d583be968913a4da76b5e98efb26328eccc9d977b08b4533ddff4a9ab4fbe`.
All 28 pages were rendered at 144 dpi and inspected at original resolution.
No clipping, overlap, blank content page, broken glyph, lost formula, cutoff
tableau, damaged hyperlink, or margin loss was found.

TeXcount reports 6,062 English-source and 5,616 Indonesian words for the batch,
and 48,519 versus 44,425 cumulatively. The next cursor is `OLP-0112`,
`content/first-order-logic/axiomatic-deduction/axiomatic-deduction.tex`.

## Axiomatic Deduction checkpoint — 2026-08-13

### Source binding, replay, and semantic review

The gap-free boundary extends through `OLP-0125`. Every source hash equals its
row in the frozen 722-file closure manifest and its Git blob at commit
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`. The durable replay command is:

```powershell
& 'locale\id\qa_axiomatic_deduction_batch_replay.ps1'
```

Its final result is:

```text
AXIOMATIC_DEDUCTION_BATCH_REPLAY_OK files=14 checks=384 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 closure=OLP-0112..OLP-0125
```

The replay binds 1,540 commands, 250 environment markers, 142 localization
tokens, 54 labels, 88 references, 13 imports, 482 mathematical skeletons, six
mathematical environments, five formal structures, 21 localized file IDs, and
two localized chapter IDs; citations and assets are zero. It positively binds
27 source-correction classes across 29 exact source occurrences and rejects all
27 superseded target forms. Source-set SHA-256 is
`8e7416b0860fe43fd7116585561c82291d904c0c64e4f65f5997825bb5fd2825`;
target-set SHA-256 is
`188ab8a93cbb307cb5ddc959c98da6e943789dba38cac07138dfadff591c19ba`.
Independent paragraph, formula, rule, and cross-unit semantic replay passes all
fourteen final files with no unresolved finding. Exact dispositions are in
`..\_control\OPENLOGIC_AXIOMATIC_DEDUCTION_INDEPENDENT_REVIEW_20260813.md`.

### Clean bounded build

Run from `locale\id`, with automatic package installation disabled:

```powershell
$env:MIKTEX_ENABLE_INSTALLER='0'
latexmk -gg -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' axiomatic-deduction-id.tex
```

Result: exit 0 using Latexmk 4.88 and MiKTeX pdfTeX 1.40.29.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `axiomatic-deduction-id.tex` | `locale/id/axiomatic-deduction-id.pdf` | 15 | 202,123 | `28bd76ef6a1cf25b4f49d684b537379b65ddd1760e2edb6e161bb3d6d83d795a` |

The final log has zero fatal error, undefined control sequence/reference/
citation, multiply defined label, underfull box, or missing glyph. Four small
overfull boxes remain, maximum 5.85645 pt; exact-resolution inspection found no
visible loss. `pdfinfo` confirms 15 letter-size pages, no encryption, forms, or
JavaScript. The PDF is searchable but not tagged. Every font is embedded and
has a ToUnicode map.

The locale now renders the invariant `\Hyp` calls as Indonesian `Hip` and
cleveref equation references as `Pers.` rather than the English `Hyp` and
`Eq.`. These two reader-facing corrections leave content commands, labels,
equation numbers, and hyperlink targets invariant.

### Extraction, render review, and counts

`pdftotext -layout` produced 31,730 bytes, SHA-256
`61dbf96c94602bcfae2f78a18cf6658320dc7179094d5a069cac208fed19eb6d`,
and 4,900 whitespace-delimited words. Searches found zero `??`, `Undefined`,
English environment/reference heading, named English proof-system fallback,
raw `Eq.`, or unresolved `Hyp` label.

All 15 pages were rendered at 144 dpi after the final locale changes and
inspected at original render resolution. No clipping, overlap, blank content
page, broken glyph, lost formula, malformed derivation, damaged hyperlink, or
margin loss was found.

TeXcount 3.1.1 (`-sum -1 -utf8`, each file once, no recursive imports) reports
3,442 English-source and 3,216 Indonesian words for this batch, and 51,961
versus 47,641 across all 125 admitted files. The exact next cursor is
`OLP-0126`, `content/first-order-logic/completeness/completeness.tex`.

## Completeness checkpoint — 2026-08-13

### Source binding, replay, and independent semantic review

The gap-free boundary extends through `OLP-0137`. Every source hash equals its
row in the frozen 722-file closure manifest and its Git object at commit
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`. The durable replay requires
PowerShell 7 (`pwsh`); Windows PowerShell 5.1 does not expose the
`ProcessStartInfo.ArgumentList` API used by the bounded runner. Run from the
repository root:

```powershell
pwsh -NoProfile -File .\locale\id\qa_completeness_batch_replay.ps1
```

The replay script SHA-256 is
`df272d805090f777199872be236d149b0932a584738e70bf7442bc2a2774f77e`.
Its final result is:

```text
STRUCTURAL_TOTALS commands=2423 environments=238 semantic_tokens=254 labels=30 references=91 citations=0 assets=0 imports=11 tag_keys=182 math_skeletons=959 math_environments=4 localized_file_ids=19 localized_chapter_ids=2
CORRECTION_TOTALS classes=21 source_occurrences=27 target_assertions=21
COMPLETENESS_BATCH_REPLAY_OK files=12 checks=334 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 closure=OLP-0126..OLP-0137
```

Independent semantic review passes all twelve final target files. Its receipt,
`..\..\..\_control\OPENLOGIC_COMPLETENESS_INDEPENDENT_REVIEW_20260813.md`,
has SHA-256
`05c6ae1b2616db86d7e7f9b0de1f46bc71f13444574a4995fc71fab93f8b3e02`.
It preserves two upstream risks rather than disguising them as translation
defects: the direct compactness proof's identity-enabled case appears to need
the quotient/factored term-model analogue, and the identity well-definedness
statement leaves the scope `i=1,...,n` implicit.

### Clean bounded build

Run from `locale\id`, with automatic package installation disabled:

```powershell
$env:MIKTEX_ENABLE_INSTALLER='0'
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' completeness-id.tex
```

Result: exit 0.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `completeness-id.tex` | `locale/id/completeness-id.pdf` | 22 | 268,745 | `fd962d07b6096d7a243ca39fec1303d4e880ad97c4f55436e44c7c0b3c6e5a2c` |

The final log has zero fatal condition, undefined reference/citation, or
missing glyph. It contains 17 overfull boxes, maximum 29.23381 pt, and two
underfull boxes. All 22 pages were rendered at exact readable resolution and
visually inspected; the boxes produced no clipping, overlap, damaged glyph,
lost formula, reference damage, or margin loss. A final rebuild after removing
one whitespace-only line produced 22 rendered page PNGs byte-identical to the
already inspected render.

### Extraction, canonical placement, and counts

Extracted-text searches found zero `??` and zero English environment labels.
The bounded build also verified canonical chapter number 23 and the full-reader
prerequisite reference numbers. The PDF is therefore an admitted bounded
chapter build, not a claim that the full 722-file Indonesian reader exists.

TeXcount 3.1.1 (`-sum -1 -utf8`, each file once, no recursive imports) reports
8,171 English-source and 7,824 Indonesian words for this batch, and 60,132
versus 55,465 across all 137 admitted files. No native/human review metadata
is present; its absence is not an admission blocker. The exact next cursor is
`OLP-0138`, `content/first-order-logic/first-order-logic.tex`; 585 closure rows
remain.

## First-Order Logic introduction checkpoint — 2026-08-13

### Source binding, replay, and independent semantic review

The gap-free boundary extends through `OLP-0148`. Run from the repository root:

```powershell
pwsh -NoProfile -File .\locale\id\qa_fol_introduction_batch_replay.ps1
```

The replay script SHA-256 is
`481b71fe273995c9f640119362d647efdc339caa81df23f999b8e9693eb8ff19`.
Its final result is:

```text
STRUCTURAL_TOTALS commands=633 environments=40 semantic_tokens=219 labels=4 references=7 citations=1 assets=0 imports=20 tag_keys=8 math_skeletons=333 math_environments=1 localized_file_ids=9 chapter_ids=1
CORRECTION_TOTALS classes=7 source_occurrences=9 target_assertions=7 target_review_assertions=16
FOL_INTRODUCTION_BATCH_REPLAY_OK files=11 checks=302 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 closure=OLP-0138..OLP-0148
```

Source-set SHA-256 is
`ef53444959f569edf49d2dc543b4e07b98ec3b96091b1ce35dde9542182ba67c`;
target-set SHA-256 is
`688f5678509d8de08b0cea2526d8408d77290273a95f618fa6e53348cf9076c4`.
Independent semantic review passes every final live file. Its receipt has
SHA-256 `e63ba97fd0ee3f4101543bb609f6591fe4e9a96863bf1d712647db5edaab5537`.

### Clean bounded build and visual QA

Run from `locale\id`, with automatic package installation disabled:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-introduction-id.tex
```

Result: exit 0. The driver is 1,907 bytes, SHA-256
`c2ce7927c08e0fd8169b83df2c32f1484a205f2f8f58604c6c7dc37a2482552e`.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `first-order-logic-introduction-id.tex` | `locale/id/first-order-logic-introduction-id.pdf` | 12 | 164,450 | `327829be2dba42640f17c585213fb718290befec4a8f4437e5dbf27176df1f92` |

The final log has zero fatal condition, undefined reference/citation, or
missing glyph. Four overfull boxes remain, maximum 13.60612 pt. All 12 pages
were rendered at 144 dpi and inspected at original render resolution; no
clipping, overlap, broken glyph, lost formula, damaged citation, or margin
loss was found. All fonts are embedded; one inherited Type 3 mathematical
font lacks a ToUnicode map, while searchable-text extraction remains intact.

`pdftotext -layout` produced 31,345 bytes and 4,616 whitespace-delimited
words, SHA-256
`cb251711317998a3e9fa69880bcf103d51c51d40fc0be791b78d18c785b1617f`.
Searches found zero unresolved marker or English environment/reference label.
TeXcount reports 4,433 English-source and 4,070 Indonesian words for the batch,
and 64,565 versus 59,535 across 148 admitted files. The exact next cursor is
`OLP-0149`; 574 closure rows remain.

## First-Order Logic syntax checkpoint — 2026-08-13

### Source binding, deterministic replay, and independent review

The gap-free boundary extends through `OLP-0158`. Every source hash equals its
row in the frozen 722-file manifest and its Git object at commit
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`. Run from the repository root:

```powershell
pwsh -NoProfile -File .\locale\id\qa_fol_syntax_batch_replay.ps1
```

The replay script is 31,338 bytes, SHA-256
`80cd54f89f97be67be928703b0f8e2b7fec2d3058d85b9caf6db0dd1c71a3a81`.
Its final result is:

```text
STRUCTURAL_TOTALS commands=1430 environments=226 semantic_tokens=256 labels=20 references=16 citations=2 assets=0 imports=9 tagged_items=90 tag_conditionals=47 math_skeletons=793 math_environments=1 localized_file_ids=9 chapter_ids=1
CORRECTION_TOTALS classes=10 source_occurrences=12 target_assertions=10 target_review_assertions=4
BINDING_DIGESTS source_set_sha256=99908dd2f6e32d8cb2f018dd47c943123219cc93805a03015f3a8753941c0598 target_set_sha256=660c13dfbe7a039f2c4190c4eb857eedeb7a14f941bf80bf47e7ab96676439e9
FOL_SYNTAX_BATCH_REPLAY_OK files=10 checks=293 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 closure=OLP-0149..OLP-0158
```

The independent review receipt is 8,959 bytes, SHA-256
`928e1d63632cf638618d66d12ab01632d9fddc326d547bdfe9a03ba1ca98eee6`.
It records the ten exact correction classes, four final localization assertions,
and no unresolved Indonesian semantic finding.

### Clean cumulative build

Run from `locale\id`, with automatic package installation disabled:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-syntax-id.tex
```

Result: exit 0 using Latexmk 4.88 and MiKTeX pdfTeX 1.40.29. The driver is
1,891 bytes, SHA-256
`ae270afc1d645076dded09a7c238edc242af2bdbc567999ca7bb4e6167923697`.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `first-order-logic-syntax-id.tex` | `locale/id/first-order-logic-syntax-id.pdf` | 31 | 294,747 | `6b3247acfe2159b4e4c0b442ae9f0636e2a1de8bcbfc28569fc8bf4cf0c717f7` |

The final log has zero fatal condition, undefined reference/citation, missing
file, or missing glyph. Fourteen overfull boxes remain: four inherited from the
introduction and ten in the syntax chapter. The overall maximum is 13.60612 pt;
the syntax-only maximum is 11.24406 pt. Exact-resolution inspection found no
visible loss. All fonts are embedded; one inherited Type 3 mathematical font
lacks a ToUnicode map, while searchable extraction remains intact.

### Extraction, render review, and counts

`pdftotext -layout` produced 72,599 bytes and 10,946 whitespace-delimited
words, SHA-256
`02ddfbb7f9ea14b7f265e626dd8b63a4bf4827ae5929a23c847de25561a9fc4c`.
Searches found zero `??`, `Undefined`, English environment/reference label,
raw `free for`, `is atomic`, `exercise.`, or `sub-formula`. Positive anchors
include `subformula`, `atomik`, `latihan`, and `bebas disubstitusikan bagi`.
The only English `proposition` substring is inside the preserved bibliography
title “Formation sequences for propositional formulas.”

All 31 pages were rendered at 144 dpi and inspected at original render
resolution. Page 26 was rebuilt, rerendered, and reinspected after the final
token correction. No clipping, overlap, blank content page, broken glyph, lost
formula, damaged table, unresolved citation, or margin loss was found.

TeXcount 3.1.1 (`-sum -1 -utf8`, each file once, no recursive imports) reports
5,535 English-source and 5,068 Indonesian words for this batch, and 70,100
versus 64,603 across all 158 admitted files. The exact next cursor is
`OLP-0159`, `content/first-order-logic/syntax-and-semantics/semantics.tex`;
564 closure rows remain.

## First-Order Logic semantics checkpoint — 2026-08-13

### Source binding, deterministic replay, and independent review

The gap-free boundary extends through `OLP-0166`. Every source hash equals its
row in the frozen 722-file manifest and its Git object at commit
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`. Run from the repository root:

```powershell
pwsh -NoProfile -File .\locale\id\qa_fol_semantics_batch_replay.ps1
```

The replay script is 35,586 bytes, SHA-256
`affe4ae38757ccd6863e1b897bbaaa47cb66f946ffda57c4ec886a4afd251852`.
Its final result is:

```text
STRUCTURAL_TOTALS commands=1894 environments=216 semantic_tokens=246 labels=17 references=22 citations=0 assets=0 imports=7 tagged_items=37 tag_conditionals=23 math_skeletons=901 math_environments=10 localized_file_ids=7 chapter_ids=1
CORRECTION_TOTALS source_classes=23 source_occurrences=26 structural_normalizations=18 target_assertions=23 target_review_assertions=1
BINDING_DIGESTS source_set_sha256=a62e0bdd463c6152371597c2bf87ff175466de13b5d99498e905854280f2140e target_set_sha256=5e84209b9795f16388bdfa609d6abcd16dcc20823204b5baceb2d2083f5221ad
FOL_SEMANTICS_BATCH_REPLAY_OK files=8 checks=259 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 closure=OLP-0159..OLP-0166
```

The independent review receipt is 10,998 bytes, SHA-256
`986d9b94f7150d23b0bda9262665b57bc4832992b010564ab29bbec22e7086f8`.
It records every admitted source correction, one independently repaired target
logic defect, two residual upstream clarification candidates, and no unresolved
Indonesian semantic finding.

### Clean cumulative build

Run from `locale\id`, with automatic package installation disabled:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-semantics-id.tex
```

Result: exit 0 using Latexmk 4.88 and MiKTeX pdfTeX 1.40.29. The driver is
1,978 bytes, SHA-256
`df5df0962b5a3fe449fedbbcb7ddac5a216bfb26b76295b2306840375f03565b`.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `first-order-logic-semantics-id.tex` | `locale/id/first-order-logic-semantics-id.pdf` | 49 | 397,670 | `afaac6ac9c76e813e75b885d6dcc5052ece4206ab0643874d7f80bc0d191bc94` |

The final log has zero undefined control sequence, LaTeX error, emergency/fatal
condition, undefined reference/citation, multiply-defined label, missing file,
missing glyph, or underfull box. Twenty-five overfull boxes remain, maximum
24.44377 pt. Exact-page inspection found no visible clipping or margin loss.
All fonts are embedded; one inherited Type 3 mathematical font lacks a
ToUnicode map, while searchable extraction remains intact.

### Extraction, render review, and counts

`pdftotext -layout` produced 118,044 bytes and 18,420
whitespace-delimited words, SHA-256
`ecbe5d946b33510f56e2b90a0d68af804fd152662edbb9373dd32eb3e4007fab`.
The changed semantics span on pages 30--47 is 44,317 bytes and 7,240 words,
SHA-256
`c991187e89a4edd512a338e9d784f3b621c855fac2535f3c5361c718af291851`.
Searches found zero `??`, `Undefined`, raw LaTeX/OLP token, English environment
label, or replacement/square encoding failure.

All 49 pages were rendered at 144 dpi. Pages 30--49 were inspected directly at
original render resolution after the final build; pages 1--29 are byte-stable
in content from the prior admitted cumulative checkpoint and retain its
all-page inspection evidence. No clipping, overlap, blank content page, broken
glyph, lost formula, damaged table, unresolved reference, or margin loss was
found.

TeXcount 3.1.1 (`-sum -1 -utf8`, each file once, no recursive imports) reports
4,914 English-source and 4,700 Indonesian words for this batch, and 75,014
versus 69,303 across all 166 admitted files. The exact next cursor is
`OLP-0167`, `content/first-order-logic/models-theories/models-theories.tex`;
556 closure rows remain.

## Theories and Their Models checkpoint — 2026-08-13

### Source binding, deterministic replay, and independent review

The gap-free boundary extends through `OLP-0173`. Every source hash equals its
row in the frozen 722-file manifest and its Git object at commit
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`. Run from the repository root:

```powershell
pwsh -NoProfile -File .\locale\id\qa_models_theories_batch_replay.ps1
```

The replay script is 30,676 bytes, SHA-256
`a1ba04487be799c0f365e57aeb2637791c8ad0701955430989bb6f0cd33212a0`.
Its final result is:

```text
STRUCTURAL_TOTALS commands=917 environments=94 semantic_tokens=109 labels=0 references=0 citations=0 assets=0 imports=6 tagged_items=0 tag_conditionals=0 math_skeletons=299 math_environments=13 localized_file_ids=6 chapter_ids=1 uppercase_tokens=7
CORRECTION_TOTALS source_classes=5 source_occurrences=5 structural_normalizations=5 target_assertions=5 target_review_assertions=3 uppercase_false_findings_retracted=7
BINDING_DIGESTS source_set_sha256=e333a41b16dd6412887baab269bae396b898ee7ce84af48885a1d3c15bde9a76 target_set_sha256=07b631a2f48c55683de6112c2b68039f507c41bb44334272af6f09c95fa4f3b3
MODELS_THEORIES_BATCH_REPLAY_OK files=7 checks=218 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 closure=OLP-0167..OLP-0173
```

The independent review receipt is 8,902 bytes, SHA-256
`1a4081e3587d2b66ee56ac4afd19a28956ee4f8d70c5f2138c2735b25597ec25`.
It records five exact source corrections, three target wording assertions, the
uppercase-token false-positive retractions, and no unresolved Indonesian
semantic finding.

### Clean cumulative build

Run from `locale\id`, with automatic package installation disabled:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-models-theories-id.tex
```

Result: exit 0 using Latexmk 4.88 and MiKTeX pdfTeX 1.40.29. The driver is
2,086 bytes, SHA-256
`e72d11a207e67d8d621a9d92c78ee46e23b06b3db1181b03177fc6cf320614db`.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `first-order-logic-models-theories-id.tex` | `locale/id/first-order-logic-models-theories-id.pdf` | 61 | 444,457 | `2ea7a5cc666e43cbc2633653041ad66a1cc675f59872ee1ee9d424a4984a1f68` |

The final log has zero fatal/LaTeX error, emergency stop, undefined control,
undefined reference/citation, multiply-defined label, missing file/glyph, or
underfull box. Thirty-three overfull hboxes remain, maximum 24.44377 pt overall
and 21.16646 pt in the new chapter. Exact-page inspection found no visible
clipping or margin loss. All 17 fonts are embedded; one inherited Type 3
mathematical font lacks a ToUnicode map, while searchable extraction remains
intact.

### Extraction, render review, and counts

`pdftotext -layout` produced 147,820 bytes and 22,914
whitespace-delimited words, SHA-256
`aaf56690851e0783d9e7227ff03b68bd10173da05beb51d0187778a81dceaf00`.
The new chapter extraction is 29,776 bytes and 4,494 words, SHA-256
`20f803ad6b8eba75d24c0ca39a874937a656a5a326188bcc42c9446209e82e8b`.
Searches found zero `??`, `Undefined`, U+FFFD, raw TeX command/environment,
English environment heading, or English fallback phrase.

Pages 49--60 were rendered at 144 dpi and inspected at original resolution;
bibliography page 61 was also inspected. Page 48 is byte- and pixel-identical
to its prior admitted render (SHA-256
`c08e0e18d8f0c0e5b9d05dee227697af8d09c75a9c54b58af08353c775a2cb73`).
No clipping, overlap, blank content page, cropped equation, broken glyph, black
box, unreadable text, or margin/page-number defect was found.

TeXcount 3.1.1 (`-sum -1 -utf8`, each file once, no recursive imports) reports
3,571 English-source and 3,168 Indonesian words for this batch, and 78,585
versus 72,471 across all 173 admitted files. The exact next cursor is
`OLP-0174`, `content/first-order-logic/beyond/beyond.tex`; 549 closure rows
remain.

## Beyond First-Order Logic checkpoint — 2026-08-13

### Source binding, deterministic replay, and independent review

The gap-free boundary extends through `OLP-0181`. Every source hash equals its
row in the frozen 722-file manifest and its Git object at commit
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`. Run from the repository root:

```powershell
pwsh -NoProfile -File .\locale\id\qa_beyond_batch_replay.ps1
```

The replay script is 21,056 bytes, SHA-256
`d96f4ce312756634aa18678b80b319d55138626bf9fc290a857bd2b0ec7bcb6b`.
Its final result is:

```text
STRUCTURAL_TOTALS commands=618 environments=56 semantic_tokens=112 labels=0 references=0 citations=0 assets=0 imports=7 tagged_items=0 tag_conditionals=0 math_skeletons=334 math_environments=3 localized_file_ids=7 chapter_ids=1
REVIEW_TOTALS source_corrections=3 correction_occurrences=3 structural_normalizations=3 review_classes=6 source_risk_classes=2 false_positive_retractions=3
BINDING_DIGESTS source_set_sha256=fedddd8e0d63594591f2c12298a61d686fb156168a7cf7fa9e92c28d18fbe9e5 target_set_sha256=2837060bd283e85679ea5463f66ac8297bbdf7d6dfd6077a1250a0993548b961
BEYOND_BATCH_REPLAY_OK files=8 checks=235 upstream=9620cc73f9c8e0ad003c514a5d3748f29611c4c0 closure=OLP-0174..OLP-0181
```

The independent review receipt is 7,892 bytes, SHA-256
`ca792e9830bcbcc12527912febbf7f52bf8c677adcd04b4068ff881158ce5eb0`.
It records three exact source corrections, stable Indonesian term choices,
two preserved source risks, three false-positive retractions, and no unresolved
Indonesian semantic finding.

### Clean cumulative build

Run from `locale\id`, with automatic package installation disabled:

```powershell
$env:MIKTEX_ENABLE_INSTALLER='0'
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-beyond-id.tex
```

Result: exit 0 using MiKTeX pdfTeX 1.40.29. The driver is 2,049 bytes,
SHA-256
`8c774752b6a295e3a0d8d8a514820aa130661cf6d2747aedf8c45ec118770793`.

| Driver | PDF | Pages | Bytes | SHA-256 |
|---|---|---:|---:|---|
| `first-order-logic-beyond-id.tex` | `locale/id/first-order-logic-beyond-id.pdf` | 78 | 509,877 | `e83568c2dd67da6b370fbb5e00669d357557b8146618c3c2931a95eca54f86ac` |

The final log is 94,356 bytes, SHA-256
`e43354a49f3873f5ede6d517c259112b34b426497d2d5f782da42b98dc18ebda`.
It has zero fatal/LaTeX error, emergency stop, undefined control,
undefined reference/citation, missing file, or missing glyph. Thirty-five
overfull hboxes remain, maximum 24.44377 pt overall. The prior cumulative log
had 33; the only two new warnings are 7.30153 pt and 8.78676 pt, and neither
causes visible clipping. One underfull vbox remains without a visible defect.
All 17 fonts are embedded; 16 have ToUnicode maps. The inherited Type 3
mathematical font `F111` lacks ToUnicode, while searchable extraction remains
intact.

### Extraction, render review, and counts

Plain `pdftotext -enc UTF-8` extraction of the complete PDF produced 173,703
bytes and 28,165 whitespace-delimited words, SHA-256
`b2340c50ac718a0857fe201eff4f52d872693eaacec09676f0a11eed3646a084`.
The raw pages 61--78 extraction is 40,234 bytes and 5,821 words, SHA-256
`5fa93b354a6986002f2d240a1a68da7824607bc871194049f6f1e8dc89b5dc1b`;
the `-layout` extraction for those pages is 42,952 bytes and 6,012 words,
SHA-256
`cabe6f834a7b3c6084728d7119ef29de1e8630b9446476dcf009d7db8a984c60`.
Searches found zero `??`, `Undefined`, U+FFFD, placeholder, raw
TeX/OLP command token, or English fallback prose. Remaining English occurs
only in project names and bibliographic titles.

Both PDFs were rendered completely at 144 dpi. Raster SHA-256 comparisons
prove pages 1--60 pixel-identical to the prior admitted PDF; page 61 is the
first difference. Pages 61--78 were individually inspected at their original
1224-by-1584-pixel render resolution, including formula-dense pages and
bibliography page 78. No clipping, overlap, margin loss, cropped formula,
broken reference, black box, unreadable glyph, or page-number defect was
found. Page 77's large blank remainder is normal chapter-end pagination.

TeXcount 3.1.1 (`-sum -1 -utf8`, each file once, no recursive imports) reports
5,695 English-source and 4,979 Indonesian words for this batch, and 84,280
versus 77,450 across all 181 admitted files. The exact next cursor is
`OLP-0182`, `content/model-theory/model-theory.tex`; 541 closure rows remain.
