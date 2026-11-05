# Verification record

Local run: November 5, 2026, Linux x86_64, Lean 4.24.0
(`797c613eb9b6d4ec95db23e3e00af9ac6657f24b`).

Command: `python3 verify.py` with the pinned Lean distribution on PATH.

Result: **PASS**. The library built with warnings as errors. All **13 named
theorems** and **16 regression examples** compiled. Every named theorem's
transitive axiom report contained only `propext` or no axioms. No added axioms,
incomplete proofs or native proof-evaluation shortcuts are present. The 46-entry
Zoo ledger was checked for cardinality, unique names/IDs and explicit unresolved
status. These are checks of the reference model, not Boardy behavioral tests.

Initial development caught a Lean layout error and a missing decidability
instance in a negative regression. Both were corrected before this passing run;
the counterexample was retained as a simplification proof.

The downloaded official Lean distribution had SHA-256:
`b14f5e5159219dd1a1956c3b806813319f5e94ccd5bdfd56f54520609a5bb5ec`.
The workflow checks this exact archive hash before extraction. This is a
reproducibility pin from the downloaded release, not an independent publisher
signature verification.

For subsequent changes, check [Actions](https://github.com/enuminous/Boardy-Monolithic-Lean4-Zoo/actions)
for the exact revision. This document records the local v0.1 verification and
does not assert that a future remote CI run has passed.
