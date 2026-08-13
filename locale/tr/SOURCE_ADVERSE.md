# Source-adverse ledger — OLP-0011 through OLP-0019

Date: 2026-08-13  
Authority commit: `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`

This ledger records two defects inherited from the exact frozen English source.
The upstream checkout remains byte-untouched. The Turkish reader contains
transparent, minimal emendations so that it does not reproduce undefined
symbols. These emendations prevent an unqualified literal/source-faithful
claim; the exact source and target states remain separately hash-bound.

## OLP-0012 — undefined identity symbol

- Source: `content/sets-functions-relations/relations/relations-as-sets.tex`.
- Frozen source SHA-256:
  `412c6fa44ead94f076dfea7cd23f9e3cd748b08c1882dcb129b15f8efcf5c29c`.
- Source lines 98--100 use `$I$` in `$K=L\cup I$` and `$H=G\cup I$`, although
  the preceding paragraph defines the identity relation only as `\Id{A}`.
- Turkish emendation: both occurrences are written `\Id{\Nat}`, the identity
  relation on the locally declared domain `\Nat`.
- Mathematical effect: resolves the intended already-defined object; no
  theorem, example extension, or order direction changes.

## OLP-0018 — undefined branch universe

- Source: `content/sets-functions-relations/relations/trees.tex`.
- Frozen source SHA-256:
  `57cc56ee55506aa19e7be6129d2cad6b8635fd2d6407399d4f774782f2cdd588`.
- Source line 94 uses `$z\in X\setminus B$`, although the tree was declared
  `T=\tuple{A,\le}` and no `$X$` is introduced in the definition.
- Turkish emendation: `$z\in A\setminus B$`.
- Mathematical effect: restores maximality relative to the declared tree
  domain; it does not alter the intended definition of a branch.

Both findings came from independent AI/model source comparison. They are not
human or community adjudications. Any later upstream correction must be bound
by a new official source commit rather than silently rewriting this authority.
