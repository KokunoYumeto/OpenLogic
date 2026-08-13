# Open Logic Project — Turkish localization

This directory is the Turkish (`tr-Latn`) localization of the Open Logic
Project. It follows the upstream `locale/<langid>` architecture.

## Current release

- Base authority commit:
  `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`
- Base authority tree:
  `f67757bb9305b173634082ab4cefd5601a707a34`
- Translated closure: OLP-0001 through OLP-0019, exactly 19/722 content
  modules
- Reader scope: front matter and routing material, the complete introductory
  Sets chapter, and the complete introductory Relations chapter
- Continuation cursor: OLP-0020,
  `content/sets-functions-relations/functions/functions.tex`
- Cursor source SHA-256:
  `ce481e97a8f301c749d1461326b4ee3d0792b4adc15a1fceb7c6ed3b58ceca54`

The 19-module checkpoint is a cumulative public release, not a claim that the
complete 722-module Turkish edition is finished.

## Build

From `locale/tr/`:

```powershell
latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error checkpoint-0019-tr.tex
```

The release build uses the exact upstream bibliography and contains no English
fallback content modules. The final PDF has 30 US-Letter pages. Its final log
has no fatal errors, unresolved references or citations, missing characters,
or overfull boxes. Three underfull-box notices were visually checked and do
not impair the reader. All 30 pages were rendered at 144 dpi and inspected,
and the extracted text was checked for unresolved markers.

## Review basis

Every translated unit is bound to the exact source and target hashes in
`TRANSLATION_MANIFEST.csv`. Two independent AI/model passes compared source
and Turkish text, repairs were applied, and the settled bytes were rechecked
with zero remaining blocker, major, or minor findings. This review basis is
declared directly; it is not a certification or endorsement by the Open Logic
Project.

Two minimal source emendations resolve undefined symbols in the frozen English
source. They are documented in `SOURCE_ADVERSE.md`.

## License and attribution

The upstream Open Logic Project source and this Turkish adaptation are
distributed under Creative Commons Attribution 4.0 International, except
where the upstream repository notes otherwise. See the repository
`LICENSE.md`. This independent adaptation is not endorsed by the Open Logic
Project.

