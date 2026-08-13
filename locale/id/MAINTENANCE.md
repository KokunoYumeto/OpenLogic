# Deterministic maintenance and continuation procedure

## Frozen baseline

The controlling English baseline is commit
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`. The complete source closure and
stable order are stored in
`..\_control\OPENLOGIC_CLOSURE_MANIFEST_20260812.csv`: 722 included content
files, of which 642 are canonical-reader reachable and 80 are retained
non-reader files. Reachability changes scheduling, never scope.

Never switch the baseline silently. A later upstream update requires a new
manifest, both commit IDs, exact added/removed/changed paths, old and new source
hashes, dependency deltas, and an explicit migration receipt.

## Continue translation

1. Read `TRANSLATION_STATUS.md`, the closure manifest, and the terminology and
   adverse ledger from disk. Do not infer the cursor from conversation memory.
2. Verify repository HEAD and the source hash for the exact next closure row.
3. Assign one writer to a nonoverlapping target tree. Never allow concurrent
   writers on the same file.
4. Mirror the English path under `locale/id/content/` and add only the `[id]`
   locale selector to stable `\olfileid` commands.
5. Preserve LaTeX commands, environments, formulas, labels, references,
   citations, URLs, imports, assets, IDs, proof trees, and code tokens. Translate
   every reader-facing surface; do not admit English fallback prose.
6. Resolve terminology from the existing Indonesian comparator evidence when
   useful. If evidence is absent, make a source-bound decision and record the
   preferred term, rejected variants, semantic constraint, and exact evidence.
7. Run path-specific structural replay, independent semantic replay, and a clean
   build with automatic package installation disabled.
8. Extract searchable text and check unresolved markers, residual English
   labels, copy/paste, and required semantic anchors.
9. Render and inspect every changed page at exact readable resolution. Record
   clipping, overlap, glyph, formula, diagram, and reference results.
10. Append failures and corrections; never erase adverse evidence. Freeze source,
    target, build, PDF, manifest, and receipt hashes plus the exact next cursor.

## Current continuation state

- Admitted ordered boundary: `OLP-0083`.
- Next row: `OLP-0084`.
- Next source:
  `content/first-order-logic/natural-deduction/natural-deduction.tex`.
- Current coverage: 83/722; exact remainder: 639.

After the final row, run a clean complete Indonesian reader build, full
extraction/search replay, page-level visual QA, full hash inventory, and a
zero-omission comparison against all 722 closure rows before describing the
edition as complete.
