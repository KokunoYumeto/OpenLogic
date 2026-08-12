# Open Logic Project — Bahasa Indonesia (`id-ID`)

Direktori ini adalah cermin terjemahan yang dipelihara untuk edisi Bahasa
Indonesia dari **Open Logic Project**. Sumber semantiknya ialah repositori
Inggris resmi pada commit beku
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`.

Status saat ini: **48 dari 722 berkas isi telah diterjemahkan dan diperiksa**.
Batas berurutan telah mencapai `OLP-0048`; unit berikutnya ialah `OLP-0049`,
`content/sets-functions-relations/infinite/infinite.tex`.
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
latexmk -pdf -dvi- -ps- -interaction=nonstopmode -halt-on-error '-pdflatex=pdflatex -disable-installer %O %S' -cd locale/id/arithmetization-id.tex
```

Hasil terakhir ialah PDF 79 halaman dengan SHA-256
`e938bf09813d45a82516d7646b120358c113337d9c7bdaa8a1a607a36323a1d7`.
Perintah QA dan bukti render yang tepat dicatat dalam `BUILD.md`.

## Syarat penerimaan tiap batch

Setiap batch harus mengikat hash sumber, mempertahankan perintah LaTeX,
rumus, ID, label, rujukan, sitasi, aset, dan struktur bukti; menerjemahkan semua
permukaan pembaca; lulus replay struktural dan semantik; dibangun bersih;
diperiksa melalui teks hasil ekstraksi dan render halaman; lalu dibekukan dengan
hash target, hash PDF, dan kursor lanjut yang tepat. Koreksi terhadap cacat
sumber dicatat secara eksplisit dan tidak disamarkan sebagai terjemahan biasa.
