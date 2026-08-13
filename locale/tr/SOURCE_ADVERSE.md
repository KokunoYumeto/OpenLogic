# Source-adverse ledger through OLP-0026

Date: 2026-08-13
Authority commit: `9620cc73f9c8e0ad003c514a5d3748f29611c4c0`

The upstream checkout remains byte-untouched. The Turkish reader contains
transparent, source-audited emendations for eight defects in the frozen English
source. Exact source and target states remain separately hash-bound.

## OLP-0012 — undefined identity symbol

Source `relations/relations-as-sets.tex`, SHA-256
`412c6fa44ead94f076dfea7cd23f9e3cd748b08c1882dcb129b15f8efcf5c29c`,
uses undefined `I` where the local definition requires the identity relation
on `Nat`. Turkish uses `\Id{\Nat}`.

## OLP-0018 — undefined branch universe

Source `relations/trees.tex`, SHA-256
`57cc56ee55506aa19e7be6129d2cad6b8635fd2d6407399d4f774782f2cdd588`,
uses undefined `X` where the tree domain is `A`. Turkish uses `A\setminus B`.

## OLP-0021 — function basics

Source `functions/function-basics.tex`, SHA-256
`f01a58d84a175f42d8c233ef0e7d41c23d406b54e8f11475c14514b64eca3dc7`,
calls the selected square root positive while declaring a function on natural
numbers including zero, and switches an example variable from `x` to `n`.
Turkish says nonnegative principal root and uses `x` consistently.

## OLP-0022 — malformed range expression

Source `functions/function-kinds.tex`, SHA-256
`6dfe2a70579f8e3521d8e2286e2360dd58a19fbeda9718b62342105388ab4f93`,
prints `\Setabs{f(x) \in B}{x \in A}`. Turkish uses
`\Setabs{f(x)}{x \in A}`.

## OLP-0023 — omitted proof step and misleading domain phrase

Source `functions/functions-relations.tex`, SHA-256
`0205f7168e0679f513e7c95ea7124ce364bce36f9e04f06d519e90f6a5480a5c`,
proves uniqueness but omits the existence step supplied by its own condition
(2), and calls the graph a relation “on A x B.” Turkish states both existence
and uniqueness and describes a relation between `A` and `B`, equivalently a
subset of `A x B`.

## OLP-0024 — missing nonempty-domain hypothesis

Source `functions/inverses.tex`, SHA-256
`93a84a2705e1ed3c92a7f5206c4308420bebbbbcb43824c1eb50e05f83777c4b`,
claims every injection `A -> B` has a left inverse `B -> A`, false for empty
`A` and nonempty `B`; its proof then chooses an element of `A`. Turkish states
`A != emptyset`. The separate Axiom of Choice dependence for right inverses is
retained in full.

These corrections preserve the intended mathematics while preventing an
unqualified literal-source claim. They do not extend translated coverage.
