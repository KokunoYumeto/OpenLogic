# Source-adverse disclosure -- OLP-0049--OLP-0054

Date: 2026-08-13  
Authority commit: `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`  
Authority tree: `f67757bb9305b173634082ab4cefd5601a707a34`

This disclosure covers the complete reader-reachable `Infinite Sets`
chapter. Upstream English files remain byte-untouched. It distinguishes
deterministic Turkish emendations from foundational dependencies that the
frozen source leaves informal.

## Exact source binding

- **OLP-0049**, `content/sets-functions-relations/infinite/infinite.tex`,
  SHA-256 `1f4a788f692454adc1a93e2670899f785f45ee9849952ac2f36fce7cdd77dbff`:
  import driver; no local mathematical defect found.
- **OLP-0050**, `content/sets-functions-relations/infinite/hilberts-hotel.tex`,
  SHA-256 `e9a73caefcc496d7074251a3ac15f66fd577415bd3a531dd23f79375502ee0ed`:
  the grammar defect `must be characterize` at lines 12--15 is repaired.
  The definition at lines 54--63 remains explicitly `Dedekind-sonsuz`, not
  ordinary infinitude.
- **OLP-0051**, `content/sets-functions-relations/infinite/dedekind-algebra.tex`,
  SHA-256 `9cee716bb8cb3bfd507ed5c17bbd4477d05995af6f8f8d411087793bdaa86036`:
  lines 41--66 are typed as `f:A\to A`, `X\subseteq A`, and `o\in A`, fixing
  the unrestricted function evaluation and free ambient `A` in the source.
- **OLP-0052**, `content/sets-functions-relations/infinite/dedekind-induction.tex`,
  SHA-256 `ea5f6c80d70abca6f5598de3e221c2f60524c40cbf533ae8a5336d5bb7186537`:
  the proof at lines 16--27 applies closure minimality to `N\cap X`, yielding
  `N\subseteq N\cap X\subseteq X`. The recursive definitions at lines
  66--80 remain explicitly deferred rather than presented as justified.
- **OLP-0053**, `content/sets-functions-relations/infinite/dedekinds-proof.tex`,
  SHA-256 `a7c41cebb6b7b0e2bed0d187777be4ba69fecdb17baa070975a0ca5c5c55b8bf`:
  the Turkish text preserves the source's own sethood objection to
  Dedekind's thought-totality argument and its warning that the surrounding
  number constructions are naif.
- **OLP-0054**, `content/sets-functions-relations/infinite/card-sb.tex`,
  SHA-256 `88534a3f2be736a704ab31343e45933edb9712fa5b4411eb102c0f4a12d656e9`:
  closure at lines 25--43 is typed relative to `f:C\to C` and `B\subseteq C`;
  the nested macro at lines 51--53 is stated explicitly as `A\approx B` and
  `B\approx C`; and the missing `\ran g\subseteq B` half of the range proof
  at lines 55--83 is supplied. Open Logic's convention
  `\comp{f}{g}=g\circ f` is preserved at lines 67 and 92--100.

The six source files total 21,596 bytes, 506 lines, and 2,925 alphabetic
tokens. Their raw bytes concatenated in OLP order have SHA-256
`fa2726b10ba1016e1d6cd30c9e8d287e26f019ee781ffdb9fb96af88369ac079`.

## Foundational and Choice limits

- Ordinary infinitude and Dedekind infinitude are not silently identified.
  ZF does not prove that every infinite set is Dedekind-infinite.
- The least-closure intersections, formula-defined subsets, images, and
  piecewise functions rely on ordinary set-existence principles in a chapter
  that is still explicitly naif.
- Existence of a Dedekind-infinite set remains an Infinity/set-existence
  assumption. It is not obtained from Choice.
- Given the displayed witnesses and sets, the Dedekind-algebra construction,
  its induction argument, and the Schröder-Bernstein proof require no Axiom
  of Choice.

These deterministic repairs preserve the intended local mathematics; they
do not supply a full axiomatization or claim upstream adoption. This is a
bounded cumulative scope through 54 of 722 closure files, with build and
publication evidence recorded separately.

