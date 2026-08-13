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
