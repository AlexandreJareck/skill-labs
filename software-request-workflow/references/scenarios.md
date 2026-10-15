# Minimum scenarios

These examples show decisions, not business answers.

1. **Feature in a new project:** classify as `feature`; record requirements; choose the minimum architecture; derive tasks; validate and document.
2. **Improvement in a legacy project:** classify as `improvement`; inspect established patterns; keep scope local; follow the standard route.
3. **Feature in a legacy project preserving the pattern:** the architecture decision identifies the existing pattern, its suitability, and the task that reuses it.
4. **Feature with an architectural departure:** record the pattern's problem, alternatives, evidence, migration, compatibility, risks, and human approval when hard to reverse.
5. **Bug with logs/traces:** plan a read-only query, correlate IDs and time, test hypotheses, and confirm or bound the cause before the solution.
6. **Bug without observability access:** record missing coverage, use available reproduction/tests/artifacts, and do not pretend the cause is confirmed.
7. **Non-reproducible intermittent issue:** keep the report valid, use temporal correlation and signals; state may remain `investigating` or end `inconclusive`.
8. **Inconclusive diagnosis:** document remaining hypotheses and missing evidence; block dependent decisions; allow mitigation only with explicit risk.
9. **Performance regression:** define p95 and load, capture a baseline, demonstrate the bottleneck, compare equivalent conditions, and state whether the target was met.
10. **Changed requirement:** preserve the version, invalidate dependent decisions/tasks/implementation, and resume at architecture or the earliest affected subphase.
11. **Incomplete input:** classify as `unknown` when the gap changes the route; complete intake, state a reversible assumption or material question, and block dependents.

The script tests exercise these eleven situations as routing, state, dependency, and invalidation invariants; semantic suitability still requires review.
