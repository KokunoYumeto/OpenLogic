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
`OLP-0111` (111/722 files). It is incomplete and must not be represented as the
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
- Size-of-sets pairing, diagonalization, reduction, variable, and duplicate-
  label defects are repaired at exact paths.
- Arithmetization repairs rational-subtraction orientation, the nonempty-set
  premise in a supremum proof, real-zero notation, and exact Cauchy-appendix
  type/exposition defects.
- Infinite Sets repairs the malformed intermediate Schröder--Bernstein
  consequent and supplies the omitted range-inclusion argument.
- Propositional syntax and semantics repair formation-sequence identity and
  index scope, a fixed-formula rebinding, implication punctuation, and the
  direction of semantic consequence.
- The Proof Systems overview repairs sequent endpoints, tableau rule labels,
  finite-assumption quantification, and the scope of axiomatic derivability.
- Sequent Calculus repairs four exchange-side labels, two omitted De Morgan
  negations, a mismatched-context conjunction proof, two soundness sequents,
  and two proof-system descriptions.
- Natural Deduction repairs quantifier-rule scope and eigenvariable wording,
  several proof-rule labels and side conditions, valuation-versus-structure
  scope, an omitted negation-elimination case, and malformed identity syntax.
- Tableaux repairs the chapter's editorial scope; distinguishes first-order
  structures from propositional valuations; makes the closed-term condition
  explicit; repairs malformed signed-formula, tableau-branch, compactness,
  consistency, quantifier-soundness, and identity-rule expressions; and
  corrects exact line references, indices, polarity signs, and metavariable
  drift where the frozen source conflicts with its own rules or proof context.

The full adverse history and evidence are in
`TERMINOLOGY_AND_ADVERSE_LEDGER.csv` and the dated independent-review receipts.

This adaptation is independent. Open Logic Project has not endorsed, certified,
or sponsored it, and no such endorsement is implied.
