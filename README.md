# skill-auditor

Audit [Claude Code](https://code.claude.com) skill files for structural quality, token efficiency, and instruction-processing effectiveness. Produces a scored report with specific, line-level fixes — and optionally generates a revised version of the skill.

Built on empirically-backed principles from Unix philosophy, cognitive load theory, and industrial design — adapted for the hard constraints of LLM instruction processing.

## Why

Skill files are programs. They run on an LLM instead of a CPU, but they have the same failure modes as any software: bloat, poor structure, buried critical logic, missing boundaries. The difference is that LLMs have *measurably tighter* constraints than traditional runtimes:

- **Attention degrades with length.** Instruction-following accuracy drops to ~68% at 500 instructions, even on frontier models ([IFScale, 2025](https://arxiv.org/abs/2507.11538)).
- **Position matters.** Material in the middle of a long context gets significantly degraded attention ([Lost in the Middle, Liu et al., 2024](https://direct.mit.edu/tacl/article/doi/10.1162/tacl_a_00638/119630)).
- **Format is functional.** Prompt formatting produces up to 40% performance differences ([He et al., 2024](https://arxiv.org/abs/2411.10541)).
- **Irrelevant content is actively harmful**, not merely wasteful — it competes for the same attention patterns as relevant instructions.

This skill applies 10 audit dimensions derived from these findings to catch structural problems before they become behavioral bugs.

## Install

### Claude Code CLI

```bash
claude install-skill https://github.com/skatiyar/skill-auditor
```

### Manual

Copy the `skill-auditor/` directory into your project's `.claude/skills/` directory, or into `~/.claude/skills/` for global access.

```
.claude/skills/skill-auditor/
├── SKILL.md
├── references/
│   └── research-basis.md
└── scripts/
    └── analyze.sh
```

## Usage

Give Claude a skill file and ask for an audit:

```
Audit this skill: [paste or attach SKILL.md]
```

```
Review my backend-structure skill for problems
```

```
What's wrong with this SKILL.md and how do I fix it?
```

Claude will run the preprocessor, evaluate 10 dimensions, and produce a scored report with specific fixes. Ask for a revised version and it will generate one.

### The Preprocessor

`scripts/analyze.sh` extracts structural metrics before the audit:

```bash
./scripts/analyze.sh path/to/SKILL.md
```

Output includes line counts, section map, token estimates, wall-of-text detection, frontmatter analysis, repetition patterns, and bundled resource inventory. Claude runs this automatically when the skill triggers.

## Audit Dimensions

| # | Dimension | What It Catches |
|---|-----------|----------------|
| 1 | **Description Quality** | Undertriggering, missing trigger phrases, no negative boundary |
| 2 | **Token Budget** | Content Claude already knows, extractable sections, bloat |
| 3 | **Positional Architecture** | Critical rules buried mid-document, no bookending |
| 4 | **Scope Boundaries** | Missing IN/OUT scope, over-application risk |
| 5 | **Structural Signifiers** | Wall-of-text sections, inconsistent formatting |
| 6 | **Degrees of Freedom** | No distinction between hard rules and flexible guidance |
| 7 | **Pattern Language** | Flat rule lists, abstraction-level jumps, no hierarchy |
| 8 | **Strategic Redundancy** | Critical rules stated once, no primacy/recency exploitation |
| 9 | **Progressive Disclosure** | Everything inline, no reference file extraction |
| 10 | **Generative Process** | Static structure description, no extension workflows |

Each dimension scores **GOOD** (1), **OKAY** (0.5), or **POOR** (0). Total out of 10.

## Example

See [`examples/sample-audit.md`](examples/sample-audit.md) for a full audit of a Go REST API project structure skill — including dimension scores, critical fixes, recommended improvements, and a file reorganization plan.

Abbreviated output:

```
## Skill Audit: backend-structure

Overall: 5.5/10 — Strong opinions well-expressed, but buried in the
wrong positions with significant token waste on patterns Claude already
knows.

### Critical Fixes
1. Move the dependency DAG and error rules to the first 20 lines
2. Extract testing patterns to references/testing-patterns.md (~150 lines)
3. Add explicit IN/OUT scope section
```

## Intellectual Lineage

The audit framework synthesizes three design traditions, adapted for the specific constraints of LLM instruction processing:

**Unix Philosophy** — Raymond's 17 rules, particularly Representation (fold knowledge into data), Parsimony (only be big when nothing else will do), and Transparency (design for inspection). Adapted for context windows and probabilistic execution.

**Cognitive Engineering** — Gerhardt-Powals' 10 principles, particularly "include only information needed at a given time" and "judicious redundancy." Adapted for LLM attention curves rather than human perception.

**Industrial Design** — Dieter Rams (less but better, honest about capability), Don Norman (constraints, signifiers), Christopher Alexander (pattern languages, generative process). Adapted for instruction documents rather than physical or visual interfaces.

The full research basis with citations is in [`references/research-basis.md`](references/research-basis.md).

## Project Structure

```
skill-auditor/
├── SKILL.md                        # Main skill file (343 lines)
├── references/
│   └── research-basis.md           # Evidence behind each dimension
├── scripts/
│   └── analyze.sh                  # Structural preprocessor
├── examples/
│   └── sample-audit.md             # Example audit output
├── LICENSE                         # MIT
└── README.md
```

## Contributing

Improvements welcome. The audit dimensions are designed to be extended — if you have evidence (not opinion) that a structural property affects LLM instruction-following, open an issue with the citation and a proposed dimension.

The bar for inclusion: there must be a published finding, a reproducible measurement, or a documented recommendation from a model provider that supports the claim. The goal is empirically-grounded guidance, not prompt engineering folklore.

## License

MIT
