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
