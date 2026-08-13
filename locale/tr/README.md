# Open Logic Project — Turkish localization

This directory is the Turkish (`tr-Latn`) localization of the Open Logic
Project. It follows the upstream `locale/<langid>` architecture.

## Current cumulative checkpoint

- Base authority commit:
  `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`
- Base authority tree:
  `f67757bb9305b173634082ab4cefd5601a707a34`
- Translated closure: OLP-0001 through OLP-0026, exactly 26/722 content
  modules
- Reader scope: front matter and routing material, the complete introductory
  Sets, Relations, and Functions chapters
- Continuation cursor: OLP-0027,
  `content/sets-functions-relations/size-of-sets/size-of-sets-complete.tex`
- Cursor source SHA-256:
  `d2b1a2f68e99efc2e5fd9f15316db26d7f898bd61135213309f61d28a6f00a60`

The 26-module checkpoint is cumulative, not a claim that the
complete 722-module Turkish edition is finished.

## Build

From `locale/tr/`:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error checkpoint-0026-tr.tex
```

The release driver uses the exact upstream bibliography and contains no English
fallback content modules. Exact build, render, page-count, and public-readback
receipts are updated after every tagged release.

## Review basis

Every translated unit is bound to exact source and target hashes. Independent
AI/model passes compare source and Turkish text; repairs are applied and the
settled bytes are rechecked. This review basis is declared directly; it is not
an endorsement by the Open Logic Project.

The cumulative terminology ledger is `TERMINOLOGY.csv`; the Functions evidence
note is `TERMINOLOGY_EVIDENCE_OLP-0026.md`.

Source emendations resolve documented defects in the frozen English source.
They are disclosed in the checkpoint source-adverse record.

## License and attribution

The upstream Open Logic Project source and this Turkish adaptation are
distributed under Creative Commons Attribution 4.0 International, except
where the upstream repository notes otherwise. See the repository
`LICENSE.md`. This independent adaptation is not endorsed by the Open Logic
Project.
