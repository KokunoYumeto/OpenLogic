# Turkish terminology evidence — OLP-0041--OLP-0048

Date: 2026-08-13

Scope: the complete reader-reachable `arithmetization` chapter at official
Open Logic commit `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`. This is a
bounded 48/722 checkpoint, not a claim about the untranslated corpus.

## Number-system and analysis terms

- `Dedekind kesimi`, `tam sayı`, `rasyonel sayı`, and `reel sayı` are
  independently attested in Turkish university mathematics curricula. Sinop
  University's *Soyut Matematik II* record explicitly places `tam sayılar`,
  `rasyonel sayılar`, `Dedekind kesimi`, and `reel sayılar` in one
  number-construction sequence:
  <https://fef.sinop.edu.tr/wp-content/uploads/sites/16/2026/04/2025-Yili-Program-Oz-Degerlendirme-Raporu-Mat.pdf>.
- Cumhuriyet University's mathematics curriculum independently joins
  `Dedekind kesimi`, `tamlık aksiyomu`, rational sequences, and `Cauchy
  dizileri` in its real-number construction:
  <https://fen.cumhuriyet.edu.tr/userfiles/file/Ders%20%C4%B0%C3%A7erikleri/Matematik%20B%C3%B6l%C3%BCm%C3%BC%20Lisans%20Ders%20%C4%B0%C3%A7erikleri%281%29.pdf>.
- The TÜBA Open Course Ware summary for *Sayıların İnşası* uses `gerçel
  (reel) sayılar`, records both surfaces as a crosswalk, and explicitly names
  both sequence and Dedekind-cut constructions:
  <https://acikders.tuba.gov.tr/course/info.php?id=27>.
- Yıldız Technical University's analysis course record attests `sıralı
  cisim`, `reel sayı sistemi`, and `Cauchy dizisi` together:
  <https://fed.yildiz.edu.tr/sites/fed.yildiz.edu.tr/files/2025-09/mat1141-matematik-analiz-1.pdf>.
- Yeditepe University's Real Analysis I outcome gives `tam sıralı bir cisim`
  for `complete ordered field`:
  <https://akts.yeditepe.edu.tr/web/Ects/CourseDetail?BID=461&DID=936&G=1&PID=531&Y=4&Z=Z>.
- Turkish university analysis records directly attest `üst sınır`, `alt
  sınır`, `en küçük üst sınır`, and `en büyük alt sınır`; the long reader
  surfaces are retained rather than silently replaced by `supremum` and
  `infimum`:
  <https://fened.gop.edu.tr/depo/menuler/birim_11069/bilgilenirme_kilavuzu_451/dosya_icerik/9665264/bilgilenirme_kilavuzu_20190924143817.pdf>.
- `aritmetikleştirme` is attested in Turkish work on Gödel's construction and
  is retained here for the earlier number-system construction, with a scope
  warning against conflating the two topics:
  <https://gcris.pau.edu.tr/bitstream/11499/2703/1/Ali%20Bilge%20%C3%96zt%C3%BCrk.%20pdf>.

The edition chooses `gerçel sayı` as its consistent producer surface while
retaining `reel sayı` as an attested search and reader crosswalk. It uses
`değişmeli halka`, `sıralı halka`, `sıralı cisim`, `tam sıralı cisim`,
`Cauchy dizisi`, `ondalık açılım`, and `sıfıra yakınsar` in their stated
algebraic or analytic scopes.

## Three-way cut and prefix lock

These surfaces are deliberately not merged:

1. `Dedekind cut` is `Dedekind kesimi`: the complete lower set that represents
   a real number.
2. An order-theoretic downward-closed `initial segment` is `başlangıç
   kesiti`: a property required of a Dedekind cut, not another name for that
   whole cut.
3. A finite initial segment of the naturals, or a syntactic `initial part` in
   the prefix sense, is `başlangıç parçası`.

This lock preserves the already published Turkish distinction between
order-theoretic segments and finite enumeration prefixes and prevents the
word `cut` from erasing the construction/property distinction.

## Algebraic collision controls

- `toplamsal ters` and `çarpımsal ters` remain distinct from `ters fonksiyon`.
- `Tamlık Özelliği` here means the least-upper-bound property of the reals. It
  does not replace or merge with metalogical completeness, although both use
  the Turkish headword `tamlık`.
- `tam sıralı cisim` is a complete ordered field. It does not mean merely a
  field carrying the previously defined `tam sıralama` relation.
- `üçleme` is recorded with the strict, exclusive alternatives
  `a<b`, `a=b`, `a>b`; the source's non-strict disjunction is not reused as
  its definition.

Rows `OLP-TR-TERM-0101`--`OLP-TR-TERM-0128` in `TERMS.csv` are active
producer decisions. Evidence-checked means the Turkish surface was checked
against the cited institutional record; it is not a claim of community
certification and creates no separate review gate.
