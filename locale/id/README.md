# Open Logic Project — Bahasa Indonesia (`id-ID`)

Direktori ini adalah cermin terjemahan yang dipelihara untuk edisi Bahasa
Indonesia dari **Open Logic Project**. Sumber semantiknya ialah repositori
Inggris resmi pada commit beku
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`.

Status saat ini: **321 dari 722 berkas isi telah diterjemahkan dan diperiksa**.
Batas berurutan telah mencapai `OLP-0321`; unit berikutnya ialah `OLP-0322`,
`content/second-order-logic/second-order-logic.tex`.
Ini merupakan checkpoint produksi yang nyata, tetapi belum merupakan edisi
lengkap. Berkas Inggris yang belum diterjemahkan tidak dihitung sebagai cakupan
Bahasa Indonesia dan tidak boleh dipakai sebagai fallback diam-diam.

## Identitas cermin

- Bahasa sasaran: Bahasa Indonesia (`id-ID`), terpisah dari bahasa Melayu.
- Sumber resmi: <https://github.com/OpenLogicProject/OpenLogic>.
- Sumber beku: `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`.
- Lisensi sumber dan adaptasi: Creative Commons Attribution 4.0 International;
  lihat `LICENSE.md` di akar repositori.
- Cermin ini adalah adaptasi independen dan tidak menyiratkan dukungan atau
  pengesahan dari Open Logic Project.

Attribution and the exact change notice are in
[`ATTRIBUTION_AND_CHANGES.md`](ATTRIBUTION_AND_CHANGES.md). The deterministic
upstream-delta procedure is in [`MAINTENANCE.md`](MAINTENANCE.md).

## Struktur

- `content/`: isi Bahasa Indonesia dengan jalur yang mencerminkan
  `content/` Inggris.
- `include/`: kelas subfile untuk bagian, bab, dan subbagian terlokalisasi.
- `open-logic-locale.sty`: judul lingkungan, nama rujukan, dan permukaan
  pembaca Bahasa Indonesia.
- `open-logic-config.sty`: token terminologi lokal.
- `TERMINOLOGY_AND_ADVERSE_LEDGER.csv`: keputusan istilah, varian, bukti,
  kegagalan, dan koreksi sumber.
- `TRANSLATION_STATUS.md`: cakupan, hash sumber, status QA, dan kursor lanjut.
- `BUILD.md`: perintah build, hasil replay, hash PDF, ekstraksi, dan inspeksi
  visual.
- `qa_*_replay.ps1`: pemeriksaan deterministik terhadap sumber beku.

## Build checkpoint saat ini

Dari akar repositori, dengan MiKTeX dan Latexmk yang sudah terpasang:

```powershell
$env:MIKTEX_ENABLE_INSTALLER='0'
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' -cd locale/id/propositional-part-id.tex
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' -cd locale/id/propositional-syntax-semantics-id.tex
```

Checkpoint proposisional menghasilkan dua PDF bounded dengan total 13 halaman dan
SHA-256 `9747a415962fa62c0b263965f966cd457fb42b8b8147666bdcf41520237aa2a8`
serta `8e04657dc409e29d59badaa0b9d411e2a633799384777ac58d44654e20294d0c`.
Perintah QA dan bukti render yang tepat dicatat dalam `BUILD.md`.

Checkpoint berikutnya menambahkan enam unit ikhtisar Sistem Derivasi
(`OLP-0063`--`OLP-0068`). Penggerak bounded berikut menghasilkan PDF delapan
halaman tanpa fallback bahasa Inggris:

```powershell
$env:MIKTEX_ENABLE_INSTALLER='0'
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' -cd locale/id/proof-systems-overview-id.tex
```

PDF itu memiliki SHA-256
`c8e7475d52cd072d13c0e58467d04976f1bfef976d7e2a9a79b7905e26e94902`;
seluruh delapan halamannya telah dirender dan diperiksa.

Checkpoint terbaru menambahkan seluruh lima belas unit Kalkulus Sekuen
(`OLP-0069`--`OLP-0083`). Dari `locale\id`, penggerak bounded berikut
menghasilkan PDF 26 halaman tanpa fallback bahasa Inggris:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error sequent-calculus-id.tex
```

PDF itu memiliki SHA-256
`9990d74508d6f1e5eee911001c5ea9417b4bc37969b6f8344e0682bab166613f`;
seluruh 26 halamannya telah dirender pada 144 dpi dan diperiksa pada resolusi
render asli.

Checkpoint sebelumnya menambahkan seluruh empat belas unit Deduksi Alami
(`OLP-0084`--`OLP-0097`). Penggerak bounded berikut menghasilkan PDF 27
halaman tanpa fallback bahasa Inggris:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error natural-deduction-id.tex
```

PDF itu memiliki SHA-256
`c2ee4b9d2662b986780b2f1580ea4c1c4effe05fb39e4feda54f061370e81704`;
seluruh 27 halamannya telah dirender pada 144 dpi dan diperiksa, termasuk
inspeksi resolusi asli atas setiap halaman yang berubah setelah koreksi akhir.

Checkpoint terbaru menambahkan seluruh empat belas unit Tableau
(`OLP-0098`--`OLP-0111`). Penggerak bounded berikut menghasilkan PDF 28
halaman tanpa fallback bahasa Inggris:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error tableaux-id.tex
```

PDF itu memiliki SHA-256
`c1be0a95411b67ae928146bb812e9b4cfdaeb417e9d192d885d28790fc077bcc`;
seluruh 28 halamannya telah dirender pada 144 dpi dan diperiksa pada resolusi
render asli. Replay semantik independen lulus untuk keempat belas berkas tanpa
masalah yang belum terselesaikan.

Checkpoint terbaru menambahkan seluruh empat belas unit Derivasi Aksiomatik
(`OLP-0112`--`OLP-0125`). Penggerak bounded berikut menghasilkan PDF 15
halaman tanpa rujukan tak terdefinisi atau fallback bahasa Inggris:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error axiomatic-deduction-id.tex
```

PDF itu memiliki SHA-256
`28bd76ef6a1cf25b4f49d684b537379b65ddd1760e2edb6e161bb3d6d83d795a`;
seluruh 15 halamannya telah dirender pada 144 dpi dan diperiksa pada resolusi
asli. Kursor berurutan berikutnya adalah `OLP-0126`.

Checkpoint terbaru menambahkan seluruh dua belas unit Teorema Kelengkapan
(`OLP-0126`--`OLP-0137`). Penggerak bounded berikut menghasilkan PDF 22
halaman:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error completeness-id.tex
```

PDF itu berukuran 268.745 byte dengan SHA-256
`fd962d07b6096d7a243ca39fec1303d4e880ad97c4f55436e44c7c0b3c6e5a2c`.
Replay deterministik lulus 334 pemeriksaan atas 12 berkas dan replay semantik
independen lulus dengan dua risiko lingkup bukti sumber Inggris tetap dicatat.
Semua 22 halaman dirender dan diperiksa pada resolusi tepat; tidak ditemukan
pemotongan, tumpang tindih, glif rusak, formula hilang, atau rujukan tak
terdefinisi. Kursor berurutan berikutnya adalah `OLP-0138`.

Arsitektur DOI/discoverability yang bertahan disimpan di
`..\..\..\_control\INDONESIAN_CORPUS_DOI_AND_DISCOVERABILITY_PROTOCOL_20260813.md`.
Tidak ada DOI edisi Open Logic Indonesia yang boleh dicetak sebelum draf
lengkap mencapai 722/722 dan lulus build serta QA kumulatif.

Checkpoint terbaru juga mengakui sebelas unit Bagian Logika Orde Pertama dan
bab pengantarnya (`OLP-0138`--`OLP-0148`). Penggerak terbatas berikut
menghasilkan pembaca 12 halaman dengan bibliografi resmi proyek:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-introduction-id.tex
```

PDF itu berukuran 164.450 byte dengan SHA-256
`327829be2dba42640f17c585213fb718290befec4a8f4437e5dbf27176df1f92`.
Replay deterministik lulus 302 pemeriksaan dan 333 segmen matematika; semua 12
halaman telah dirender pada 144 dpi dan diperiksa. Kursor global berikutnya
adalah `OLP-0149`.

Checkpoint terbaru menambahkan sepuluh unit Sintaksis Logika Orde Pertama
(`OLP-0149`--`OLP-0158`) dan melokalkan token `subformula`, syarat substitusi
`bebas disubstitusikan bagi`, serta label kasus induksi `atomik` dan `latihan`.
Penggerak kumulatif berikut membangun bab pengantar dan sintaksis tanpa fallback
bahasa Inggris:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-syntax-id.tex
```

PDF itu berukuran 294.747 byte dengan SHA-256
`6b3247acfe2159b4e4c0b442ae9f0636e2a1de8bcbfc28569fc8bf4cf0c717f7`.
Semua 31 halaman telah dirender pada 144 dpi dan diperiksa; tidak ditemukan
pemotongan, tumpang tindih, glif atau formula rusak, atau rujukan tak
terselesaikan. Kursor global berikutnya adalah `OLP-0159`.

Checkpoint terbaru menambahkan delapan unit Semantik Logika Orde Pertama
(`OLP-0159`--`OLP-0166`). Replay deterministik lulus 259 pemeriksaan atas 901
kerangka matematika dan 23 kelas koreksi sumber; tinjauan semantik independen
tidak menemukan masalah Bahasa Indonesia yang belum diselesaikan. Penggerak
kumulatif berikut membangun bab pengantar, sintaksis, dan semantik:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-semantics-id.tex
```

PDF 49 halaman itu berukuran 397.670 byte dengan SHA-256
`afaac6ac9c76e813e75b885d6dcc5052ece4206ab0643874d7f80bc0d191bc94`.
Halaman baru dan berubah 30--49 telah dirender pada 144 dpi dan diperiksa;
halaman 1--29 dipertahankan dari checkpoint yang telah diterima. Tidak
ditemukan pemotongan, tumpang tindih, glif atau formula rusak, atau rujukan tak
terselesaikan. Kursor global berikutnya adalah `OLP-0167`.

Checkpoint terbaru menambahkan tujuh unit bab Teori dan Model-Modelnya
(`OLP-0167`--`OLP-0173`). Replay deterministik lulus 218 pemeriksaan atas 299
kerangka matematika dan lima koreksi sumber. Penggerak kumulatif berikut
membangun bab 15--18:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-models-theories-id.tex
```

PDF 61 halaman itu berukuran 444.457 byte dengan SHA-256
`2ea7a5cc666e43cbc2633653041ad66a1cc675f59872ee1ee9d424a4984a1f68`.
Halaman bab baru 49--60 dan bibliografi halaman 61 telah diperiksa pada 144
dpi; halaman 48 identik piksel dengan checkpoint sebelumnya. Tidak ditemukan
pemotongan, tumpang tindih, glif atau formula rusak, atau rujukan tak
terselesaikan. Kursor global berikutnya adalah `OLP-0174`.

Checkpoint terbaru menambahkan delapan unit bab Melampaui Logika Orde Pertama
(`OLP-0174`--`OLP-0181`). Replay deterministik lulus 235 pemeriksaan atas 334
kerangka matematika, tiga koreksi sumber, dua risiko sumber yang dipertahankan,
dan tiga temuan positif-palsu yang ditarik kembali. Penggerak kumulatif berikut
membangun bab 15--19:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-beyond-id.tex
```

PDF 78 halaman itu berukuran 509.877 byte dengan SHA-256
`e83568c2dd67da6b370fbb5e00669d357557b8146618c3c2931a95eca54f86ac`.
Halaman 1--60 identik piksel dengan checkpoint sebelumnya; seluruh halaman
yang berubah, 61--78, telah diperiksa pada render 144 dpi beresolusi asli.
Tidak ditemukan pemotongan, tumpang tindih, kerusakan glif atau formula,
kehilangan margin, atau rujukan tak terselesaikan. Kursor global berikutnya
adalah `OLP-0182`.

Checkpoint terbaru menambahkan sembilan unit Dasar-Dasar Teori Model
(`OLP-0182`--`OLP-0190`). Replay deterministik lulus 311 pemeriksaan dan
tinjauan semantik independen tidak menyisakan temuan sasaran Bahasa Indonesia.
Penggerak kumulatif berikut membangun bab 15--20:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-model-theory-basics-id.tex
```

PDF 88 halaman itu berukuran 569.200 byte dengan SHA-256
`3e3214708cac2672e691ddbb45b22282861023026bf9f8f4d28ffd7f3efea93b`.
Halaman 1--77 identik piksel dengan checkpoint sebelumnya; seluruh halaman
78--88 telah diperiksa pada render 144 dpi beresolusi asli, termasuk inspeksi
ulang halaman 82 dan 87 setelah koreksi redaksi terakhir. Tidak ditemukan
pemotongan, tumpang tindih, kerusakan glif atau formula, kehilangan margin,
atau rujukan tak terselesaikan. Kursor global berikutnya adalah `OLP-0191`.

Checkpoint satu-pertiga menambahkan 61 unit berurutan
(`OLP-0191`--`OLP-0251`): Model Aritmetika, Interpolasi, teorema
Lindstr\"om, Fungsi Rekursif, dan Teori Komputabilitas. Seluruh 61 berkas
sumber terikat pada commit beku dan lulus replay struktural serta semantik
independen tanpa temuan sasaran yang belum terselesaikan. Penggerak kumulatif
berikut membangun bab 15--25:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error first-order-logic-model-theory-computability-id.tex
```

PDF 175 halaman itu berukuran 965.687 byte dengan SHA-256
`887617dedd182e1693894f777d75ecd3952a8824da91cf04f7a8a931b37f89cf`.
Halaman 1--87 identik piksel dengan checkpoint sebelumnya; seluruh halaman
88--175 diperiksa pada render 144 dpi beresolusi asli. Tiga label rujukan
sintetis yang semula berganda dan satu spasi antarkalimat yang hilang pada
halaman 156 dikoreksi, dibangun ulang, dan diperiksa ulang. Tidak tersisa
pemotongan, tumpang tindih, kerusakan glif atau formula, fallback prosa
Inggris, atau rujukan tak terselesaikan. Kursor global berikutnya adalah
`OLP-0252`.

Checkpoint terbaru menambahkan 70 unit berurutan (`OLP-0252`--`OLP-0321`),
yang menuntaskan bagian Mesin Turing dan Ketaklengkapan dalam sasaran
Bahasa Indonesia. Replay khusus bagian Ketaklengkapan lulus 4.619 pemeriksaan
atas 48 berkas, sedangkan seluruh sumber tranche tetap terikat pada commit
Inggris beku. Penggerak kumulatif berikut menghasilkan pembaca 305 halaman:

```powershell
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' first-order-logic-through-incompleteness-id.tex
```

PDF itu berukuran 1.589.133 byte dengan SHA-256
`4546565efbfc9298e5214e19ad925dcf100f059031e4a85db3d1f4870ef92a15`.
Sebanyak 219 dari 221 halaman checkpoint sebelumnya identik piksel; halaman
95 dan setiap halaman 221--305 diperiksa satu per satu pada resolusi render
asli. Tidak ditemukan pemotongan, tumpang tindih, kerusakan glif atau formula,
fallback prosa Inggris, atau rujukan tak terselesaikan. Kursor global berikutnya
adalah `OLP-0322`.

## Syarat penerimaan tiap batch

Setiap batch harus mengikat hash sumber, mempertahankan perintah LaTeX,
rumus, ID, label, rujukan, sitasi, aset, dan struktur bukti; menerjemahkan semua
permukaan pembaca; lulus replay struktural dan semantik; dibangun bersih;
diperiksa melalui teks hasil ekstraksi dan render halaman; lalu dibekukan dengan
hash target, hash PDF, dan kursor lanjut yang tepat. Koreksi terhadap cacat
sumber dicatat secara eksplisit dan tidak disamarkan sebagai terjemahan biasa.
