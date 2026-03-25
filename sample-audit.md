# Example Audit: backend-structure

This is a sample audit output from running `skill-auditor` against a Go
REST API project structure skill (~400 lines, no reference files).

The skill being audited is opinionated about: domain-driven layout with
chi, e2e-only testing with fakes, strict error handling rules, and
interface-based cross-domain communication.

---

## Skill Audit: backend-structure

**Overall: 5.5/10** — Strong opinions well-expressed, but buried in the
wrong positions with significant token waste on patterns Claude already
knows.

### Dimension Scores
| # | Dimension | Score | Key Finding |
|---|-----------|-------|-------------|
| 1 | Description | OKAY | Solid coverage but misses "where does this code go" and "add new endpoint" triggers |
| 2 | Token Budget | POOR | ~150 lines of testing boilerplate (fakes, TestMain, cupaloy) that Claude already knows |
| 3 | Positional Architecture | POOR | Error handling rules (most opinionated content) buried at line ~250; dependency DAG near bottom |
| 4 | Scope Boundaries | POOR | No explicit scope — could be over-applied to CLI tools, gRPC services, or monorepos |
| 5 | Structural Signifiers | GOOD | Consistent headers, code blocks, tables for "What to Skip" |
| 6 | Degrees of Freedom | OKAY | Implicitly variable (error rules are strict, layout is flexible) but no explicit markers |
| 7 | Pattern Language | OKAY | Reasonable flow but jumps between structure and process; error handling is philosophically misplaced |
| 8 | Strategic Redundancy | POOR | No repetition of critical rules; dependency DAG stated once at line ~350 |
| 9 | Progressive Disclosure | POOR | 400 lines with no reference files; testing and validation sections are extraction candidates |
| 10 | Generative Process | OKAY | Cross-domain cases well-covered, but no "add a new domain" step-by-step workflow |

### Critical Fixes (do these first)

1. **Move the dependency DAG and error rules to the first 20 lines.**
   These are the most counter-to-default instructions. Claude's priors
   will produce unit tests, inline errors, and direct domain imports
   without strong early framing. Currently at lines ~250 (errors) and
   ~350 (DAG).
   *Fix:* Add a "Hard Rules" section immediately after the opening
   paragraph with the 4 non-negotiable constraints.

2. **Extract testing patterns to `references/testing-patterns.md`.**
   The fake implementation, TestMain wiring, snapshot normalisation
   function, and cupaloy setup are ~150 lines that Claude can write
   without being shown. The skill should keep the *philosophy* (all e2e,
   no unit tests, 80% coverage) and the *architecture* (what's faked,
   what's real) — ~30 lines total.
   *Fix:* Create `references/testing-patterns.md` with the full examples.
   SKILL.md testing section becomes: philosophy + architecture + pointer.

3. **Add explicit scope section.**
   No scope declaration means Claude might apply chi-specific patterns
   to a Gin project, or domain-per-package layout to a CLI tool.
   *Fix:* Add after Hard Rules:
   ```
   ## Scope
   - IN: Single-service Go REST APIs with chi, 2-10 domains, SQL backend
   - OUT: gRPC, CLI tools, monorepo layouts, frontend, infrastructure
   ```

### Recommended Improvements

1. **Add "add a new domain" step-by-step** — this is the most common
   real-world trigger and the skill doesn't have a generative workflow
   for it. 7 steps, ~15 lines.

2. **Add constraint labels** — mark error handling as `(strict)` and
   directory layout as `(adapt to project size)` to signal degrees of
   freedom.

3. **Reiterate hard rules at document end** — add a 5-line closing
   section restating the dependency DAG direction and no-unit-tests rule.

4. **Add trigger phrases to description** — "where does this code go",
   "add a new endpoint", "add a new feature", "refactoring a Go API".

5. **Extract validation setup to `references/validation-setup.md`** —
   the validator/v10 registration, custom validators, and handler
   integration are implementation details (~40 lines extractable).

### Structure Recommendation

```
backend-structure/
├── SKILL.md              (~200 lines: philosophy, constraints, structure, brief behavior)
└── references/
    ├── testing-patterns.md    (fakes, TestMain, snapshots, coverage enforcement)
    └── validation-setup.md    (validator config, custom validators, handler integration)
```

### What's Working Well

- **Error handling rules are genuinely valuable** — the "no inline
  errors, all errors must be predefined variables" rule is
  counter-to-default and well-articulated with good/bad examples. This
  is exactly the kind of content skills should contain.
- **Cross-domain communication patterns are excellent** — the 4-case
  taxonomy (shared types → shared infra → interface in caller →
  orchestrating package) is a real decision tree that saves thinking.
- **"What to Skip" table** — concrete, scannable, opinionated. The table
  format is the right structural choice for this content.
