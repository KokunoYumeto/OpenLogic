# Turkish cumulative checkpoint OLP-0026 — build and QA

Date: 2026-08-13
Authority commit: `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`

- Coverage: OLP-0001--OLP-0026, 26/722 content modules.
- Reader scope: front matter plus complete introductory Sets, Relations, and
  Functions chapters; no English fallback content.
- Driver: `checkpoint-0026-tr.tex`.
- Build: latexmk 4.88 / MiKTeX pdfTeX 1.40.29, exit 0.
- PDF: 40 US-Letter pages, 353,576 bytes.
- PDF SHA-256:
  `9071BDDDAAF38655EFFD576A28B08824CCFC2397904A2F29CD7DD03B6DE4AC88`.
- Log: zero fatal errors, unresolved references/citations, missing characters,
  or overfull boxes; four visually non-blocking underfull notices.
- Visual QA: 40/40 pages rendered at 144 dpi and inspected.
- Text QA: 88,963 extracted bytes checked; no unresolved markers.
- Structural QA: cumulative replay passes with only declared source-emendation
  macro deltas.
- Independent settled-byte review: blocker 0, major 0, minor 0.
- Publication tag: `tr-olp-0026-20260813`.

This checkpoint supersedes `tr-olp-0019-20260813`. It is not the complete
722-module Turkish edition.
