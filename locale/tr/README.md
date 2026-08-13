# Open Logic Project — Turkish localization

This directory is the Turkish (`tr-Latn`) localization of the Open Logic
Project. It follows the upstream `locale/<langid>` architecture.

## Current cumulative checkpoint

- Base authority commit:
  `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`
- Base authority tree:
  `f67757bb9305b173634082ab4cefd5601a707a34`
- Translated closure: OLP-0001 through OLP-0062, exactly 62/722 content
  modules
- Reader scope: front matter and routing material, the complete introductory
  Sets, Relations, Functions, Size of Sets, Arithmetization, and Infinite Sets
  chapters, and the complete reader-reachable Propositional Logic `Syntax and
  Semantics` chapter
- Continuation cursor: OLP-0063,
  `content/first-order-logic/proof-systems/proof-systems.tex`
- Cursor source SHA-256:
  `85b8a0fca16c329ad16b3c17975735c159e0cf9d38e8dfc7501acba84171fb6c`

The 62-module checkpoint is cumulative, not a claim that the
complete 722-module Turkish edition is finished.

## Build

From `locale/tr/`:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error checkpoint-0062-tr.tex
```

The release driver uses the exact upstream bibliography and contains no English
fallback content modules. Exact build, render, page-count, and public-readback
receipts are updated after every tagged release.

## Review basis

Every translated unit is bound to exact source and target hashes. Independent
AI/model passes compare source and Turkish text; repairs are applied and the
settled bytes are rechecked. This review basis is declared directly; it is not
an endorsement by the Open Logic Project.

The cumulative terminology ledger is `TERMINOLOGY.csv`; the evidence notes are
`TERMINOLOGY_EVIDENCE_OLP-0026.md`,
`TERMINOLOGY_EVIDENCE_OLP-0040.md`,
`TERMINOLOGY_EVIDENCE_OLP-0048.md`, and
`TERMINOLOGY_EVIDENCE_OLP-0054.md`, and
`TERMINOLOGY_EVIDENCE_OLP-0062.md`.

Source emendations resolve documented defects in the frozen English source.
They are disclosed in `SOURCE_ADVERSE_0062.md` and the cumulative
`SOURCE_ADVERSE.md` record.

## License and attribution

The upstream Open Logic Project source and this Turkish adaptation are
distributed under Creative Commons Attribution 4.0 International, except
where the upstream repository notes otherwise. See the repository
`LICENSE.md`. This independent adaptation is not endorsed by the Open Logic
Project.
