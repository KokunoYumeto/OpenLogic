# Attribution and change notice

## Original work

**The Open Logic Text** and the Open Logic Project source corpus are by
[The Open Logic Project](https://openlogicproject.org/people/). The official
source repository is <https://github.com/OpenLogicProject/OpenLogic>. The source
used for this Indonesian adaptation is frozen at commit
`9620cc73f9c8e0ad003c514a5d3748f29611c4c0`.

The original is licensed under the
[Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).
The repository's full licence text remains at `LICENSE.md`.

## Adaptation

This maintained mirror translates the frozen English corpus into Bahasa
Indonesia (`id-ID`). It changes reader-facing prose, headings, theorem and
problem language, captions, navigation, metadata, and localized automatic
labels. It preserves mathematical formulas, identifiers, source paths, LaTeX
structure, labels, references, citations, proof structure, and assets except
where an exact source defect is explicitly corrected and ledgered.

The current checkpoint covers ordered closure units `OLP-0001` through
`OLP-0026` (26/722 files). It is incomplete and must not be represented as the
complete Indonesian Open Logic corpus.

Exact source corrections currently include:

- the natural-number convention is made explicit as including zero;
- an undefined branch carrier is replaced by the declared carrier;
- a subtree premise is made nonempty to agree with the source's tree
  definition;
- an undefined identity symbol is replaced by `\Id{\Nat}`;
- a reflexive-closure symbol is renamed locally to avoid collision with the
  source's transitive-closure notation;
- a modular-equivalence variable scope, a square-root zero case, and a
  left-inverse empty-domain counterexample are repaired.

The full adverse history and evidence are in
`TERMINOLOGY_AND_ADVERSE_LEDGER.csv` and the dated independent-review receipts.

This adaptation is independent. Open Logic Project has not endorsed, certified,
or sponsored it, and no such endorsement is implied.

