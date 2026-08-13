# Source-adverse disclosure — OLP-0027--OLP-0040

Date: 2026-08-13  
Authority commit: `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`

The Turkish Size of Sets chapter transparently emends the following frozen
English-source defects. Upstream files remain byte-untouched.

- OLP-0031 `pairing.tex`, source SHA-256
  `345a39184e28af727e378d5b5883b5e7d2e1c27cd729329376d19426ddaed484`:
  triangular-number prose is aligned with its formula; the `rather that`
  typo is rendered as intended; the countable-union problem receives an
  explicit countable-choice qualification; the malformed phrase “complement
  of a finite set Nat” is replaced by the formula-governed definition of
  finite complement; and the inverse of an arbitrary
  injection is correctly used on its range rather than as an automatically
  total enumeration on all natural numbers, with the empty product handled
  separately.
- OLP-0032 `pairing-alt.tex`, source SHA-256
  `fd523f5306e1fd0e5c03f4c572d244fb017d1c0be27939f180bc6867a214e425`:
  the second pair is corrected from `(0,2)` to `(0,1)`, and the duplicated
  `(2,m)` progression is corrected to `(2,m), (3,m), ...`.
- OLP-0034 `reduction.tex`, source SHA-256
  `33f0cbb35c8c1fa3ff0e4f44fa626fdc298d1c4612aeaafb41bcb920e5d18ac8`:
  undefined `s_k` is replaced by a bound sequence `s`; the displayed finite
  zero string receives an infinite tail and is therefore genuinely in
  `{0,1}^omega`.
- OLP-0035 `equinumerous-sets.tex`, source SHA-256
  `7b0444e3293b300b72b7a6d49638913a778f5131fd94650dd64a5f11040c91f2`:
  the empty-set argument uses the actual bijection `f(x)=y`, not the
  unrelated `g(x)=y`.
- OLP-0036 `comparing-size.tex`, source SHA-256
  `cb92c7e6df9529ced700d708ad8c6efda9a0d8c3f8e69d08bcb4d614c6f5041b`:
  the non-enumerability comparison is qualified by the relevant
  comparability/choice assumptions; the diagonal proof quantifies over
  every `x in A`, not only `x in A-bar`.
- OLP-0039 `non-enumerability-alt.tex`, source SHA-256
  `0c20a2c420fbf4dbd801bb97e37799b3c602ae33ef2b1dc85ff94e24208ca2bb`:
  `s_n(m)` is the `m`-th digit of the `n`-th string; the complementary step
  changes `1` to `0` and `0` to `1`; and the proof's indexed object is stated
  as an arbitrary infinite list rather than a possibly finite enumeration.
- OLP-0040 `reduction-alt.tex`, source SHA-256
  `46381b85c0e9a1ab48cb9301518de91f073d649c3b1119325c1409f5a6c1d663`:
  undefined `s_k` is replaced by `s`, and a raw label duplicated from the
  other reduction variant is renamed `sfr:siz:red-alt:prob:nat-nat`.

These declared changes preserve the intended mathematics. They are not a
claim that upstream adopted the corrections, and this 40/722 checkpoint is
not the complete Turkish corpus.
