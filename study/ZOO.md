# Fixed Zoo operations and Boardy applicability

Source freeze: [Monolithic-Zoo-Lean4 at 509480eb63d9fa2ca89f17506793a1f9412d2439](https://github.com/enuminous/Monolithic-Zoo-Lean4/tree/509480eb63d9fa2ca89f17506793a1f9412d2439).
The [coverage ledger](zoo-coverage.json) preserves every one of the 46 original
animal names, module URLs and upstream operational scopes. The upstream license
for that metadata is retained in [UPSTREAM-LICENSE.txt](UPSTREAM-LICENSE.txt).
Upstream proof statuses do not become proof statuses about Boardy.

No animals were renamed into generic personality metaphors or assigned new
operations. The following source-defined operations were inspected to establish
what input is missing. They have **not** been executed on Boardy data.

| Operation | Purpose / fixed transform | Required input and output | Applicability criterion and result |
|---|---|---|---|
| OWL | Early-warning rank aggregation over contradiction and instability columns | Two base columns plus four per horizon; ranked score per row | Requires a validated, temporally valid feature extractor and held-out outcome. UNRESOLVED: absent |
| FOX | Feedback-oscillation rank aggregation | Six base columns plus four per horizon; ranked score per row | Requires measured feedback/oscillation features, not an impression that messages repeat. UNRESOLVED: absent |
| RAVEN | Residual-structure rank aggregation after ordinary models | Four base columns plus three per horizon; ranked score per row | Requires an explicit ordinary baseline and out-of-sample residuals. UNRESOLVED: absent |
| TURTLE | Source decision tree for evidence aggregation | Applicability, veto, independent group counts and invariant score; five-way verdict | No-applicable input maps to insufficient by source definition. No Boardy score was supplied or evaluated. UNRESOLVED |

OWL/FOX/RAVEN's pinned Lean modules implement aggregation over **supplied**
columns; feature extraction, training and empirical calibration are outside their
scope. Column count and output length theorems cannot establish predictive value.
Full-column ranks also need a prospective construction to avoid future leakage.

Each other roster entry is explicitly `not_run` and `unresolved`, with its exact
source module linked. This is coverage accounting, not a completed full-Zoo
evaluation. An animal-specific input mapping, outcome and frozen decision rule
must be reviewed before changing any entry to demonstrated or rejected.

The protocol's binary safety criteria are separate from animal verdicts.
Missing data is not a pass, and a fabricated numerical score is not evidence.
Multiple rank aggregators over the same observations are not independent trials.
