---
name: skill-auditor
description: >
  Audit SKILL.md files for structural quality, token efficiency, and
  instruction-processing effectiveness. Produces a scored report with
  specific, line-level fixes — and optionally generates a revised SKILL.md.
  Use this skill whenever the user asks to review a skill, audit a skill,
  improve a SKILL.md, check a skill for problems, optimize a skill, or says
  things like "is this skill any good", "what's wrong with my skill", "how
  can I make this skill better", "review my CLAUDE.md". Also trigger when the
  user shares a SKILL.md and asks for feedback, or when editing a skill and
  wanting a quality check before shipping. Do NOT use for creating skills
  from scratch — use skill-creator instead.
---

# Skill Auditor

Audit SKILL.md files against empirically-backed principles for LLM
instruction effectiveness. Produces a structured report with a score,
specific findings, and concrete fixes. Optionally generates a revised
version of the skill.

## Hard Rules

1. Every finding must be specific — cite the section or lines affected
2. Every finding must include a concrete fix, not just a diagnosis
3. Do not recommend changes that would make the skill less opinionated —
   opinionated skills outperform generic ones
4. Do not recommend adding content Claude already knows — the most
   common mistake in skill files is over-explaining
5. Respect the author's architectural choices — audit the expression of
   those choices, not the choices themselves

## Scope

- **IN:** SKILL.md files for Claude Code, CLAUDE.md project files,
  Cursor rules files, or any LLM instruction document structured as
  markdown with YAML frontmatter
- **IN:** Auditing, scoring, diagnosing, and revising existing skill files
- **OUT:** Creating skills from scratch (use skill-creator)
- **OUT:** Evaluating skill triggering accuracy (use skill-creator's
  eval loop)
- **OUT:** General prompt engineering advice unrelated to a specific file

## Audit Protocol

When given a skill file to audit:

1. Run the `scripts/analyze.sh` preprocessor on the file to get line
   counts, section map, and token estimates. If the script is not
   available, estimate manually.
2. Read the full SKILL.md (and any referenced files if available)
3. Run each of the 10 audit dimensions below — score it, note findings
4. Produce the audit report in the format specified at the end
5. If the user wants a revised version, generate it following the
   revision protocol

For the research evidence behind each dimension, read
`references/research-basis.md` — load it when you need to explain WHY
a finding matters or when the user asks for evidence.

---

## Audit Dimensions

### 1. Description Field Quality

The description is the single highest-leverage element. It controls
whether the skill fires at all. Skill discovery uses pure LLM
reasoning — no regex, no embeddings.

**Check for:**
- Does it say WHAT the skill does AND WHEN to use it?
- Does it include synonymous trigger phrases a user might say?
- Does it cover the most common real-world moment the user needs this?
- Is it appropriately pushy without overtriggering?
- Does it include negative triggers ("Do NOT use for X")?

**Scoring:**
- GOOD: Covers what/when, 5+ natural trigger phrases, negative boundary
- OKAY: Covers what/when but misses common trigger phrasings
- POOR: Only describes what the skill does, no trigger guidance

**Common fix:** Add the 3 most likely user phrasings that should trigger
this skill but currently wouldn't.

---

### 2. Token Budget Efficiency

Every line competes for finite attention. LLM instruction-following
degrades measurably with instruction count. The question for each
paragraph: does this justify its token cost?

**The token-cost test (apply to every section):**
```
Can Claude already do this without being told?
  YES → Cut it. Move to references/ if the user needs it.
  PARTIALLY → Keep the constraint/opinion, cut the explanation.
  NO → Keep it. This is what skills are for.
```

**Sizing targets:**
- SKILL.md body: under 300 lines ideal, under 500 acceptable
- Single section: under 60 lines before considering extraction
- Reference files: under 300 lines each, TOC if over 150

**Scoring:**
- GOOD: Under 300 lines, every section passes the token-cost test
- OKAY: 300-500 lines, some sections could be extracted
- POOR: Over 500 lines, or significant content Claude already knows

---

### 3. Positional Architecture

LLMs exhibit a U-shaped attention curve: strongest at the beginning
(primacy) and end (recency), weakest in the middle.

**Decision tree for placement:**
```
Is this rule counter to Claude's default behavior?
  YES → First 20 lines of body, reiterate at end
  NO, but it's a hard constraint → First 50 lines
  NO, it's guidance → Middle is fine
  NO, it's reference material → Extract to references/
```

**Scoring:**
- GOOD: Critical constraints in first 20 lines, reiterated at end
- OKAY: Important rules near the top but not in opening section
- POOR: Critical rules buried in the middle, no reiteration

---

### 4. Scope Boundaries

Explicit scope prevents over-application to adjacent contexts.

**Check for:**
- Is there an explicit IN/OUT scope section?
- Does the skill declare what it does NOT cover?
- Would Claude know when to stop applying this skill's rules?
- Are there adjacent domains that could cause confusion?

**Scoring:**
- GOOD: Explicit scope with both IN and OUT boundaries
- OKAY: Implicit scope, inferable but not stated
- POOR: No scope declaration; skill could be over-applied

---

### 5. Structural Signifiers

Format is functional. Prompt formatting produces up to 40% performance
differences. Claude was specifically trained to attend to XML tags
and markdown structure.

**Check for:**
- Consistent markdown headers for section hierarchy
- Code blocks for templates, formats, examples
- Clear separation between philosophy / rules / examples / reference
- No wall-of-text sections longer than ~15 lines without breaks
- Tables for lookup/decision content rather than prose

**Scoring:**
- GOOD: Clear hierarchy, code blocks for structured content, no walls
- OKAY: Some structure but inconsistent, or wall-of-text sections
- POOR: Mostly unstructured prose

---

### 6. Degrees of Freedom

Not all instructions are equally rigid. The skill should signal which
rules are hard constraints vs. flexible guidance.

**Check for:**
- Does the skill distinguish non-negotiable rules from flexible guidance?
- Are high-fragility operations given exact steps?
- Are creative/judgment tasks given direction rather than prescription?
- Do constraint labels exist? ("strict", "preferred", "adapt as needed")

**Scoring:**
- GOOD: Explicit freedom markers, specificity matches fragility
- OKAY: Implicitly variable but no explicit signals
- POOR: Uniformly prescriptive or uniformly vague

---

### 7. Pattern Language Ordering

Instructions should descend from large-scale philosophy to small-scale
implementation, with cross-references showing how rules serve goals.

**Expected flow:**
```
Identity/purpose → Hard constraints → Structure → Behavior → Process → Reference
```

**Check for:**
- Does the document follow a descending hierarchy?
- Do specific rules reference which higher-level goal they serve?
- Are there abrupt jumps between abstraction levels?
- Could a reader understand the WHY, not just the WHAT?

**Scoring:**
- GOOD: Clear descending hierarchy with cross-references
- OKAY: Loosely organized, some level-jumping
- POOR: Flat list of rules with no hierarchy

---

### 8. Strategic Redundancy

Repeating critical instructions at both document boundaries exploits
primacy and recency effects. Distinct from accidental duplication.

**Check for:**
- Are the top 3 most-important rules stated in the opening AND
  restated in a closing section?
- Is repetition intentional (different framing) or accidental?
- Are there rules so critical that violating them breaks the skill —
  and are they repeated?

**Scoring:**
- GOOD: Critical rules bookend the document intentionally
- OKAY: Some repetition but not strategically placed
- POOR: No repetition of critical rules, or accidental duplication

---

### 9. Progressive Disclosure Usage

Skills use three-level loading: metadata (always), SKILL.md body
(on trigger), bundled resources (on demand).

**Extraction decision:**
```
Is this content needed on every invocation?
  YES → Keep inline
  NO → Is it needed on >50% of invocations?
    YES → Keep inline if short, extract if >30 lines
    NO → Extract to references/
```

**Scoring:**
- GOOD: Clear three-level split with loading guidance
- OKAY: Everything inline but under 300 lines (acceptable)
- POOR: Over 500 lines with no extraction

---

### 10. Generative Process

Does the skill enable Claude to handle the most common workflow
end-to-end, not just describe static structure?

**Check for:**
- Is there a "how to extend" or "how to add" workflow?
- Are decision trees included for tricky judgment calls?
- Could Claude handle a new request end-to-end using this skill?

**Scoring:**
- GOOD: Includes workflow/decision trees for common tasks
- OKAY: Describes structure but not the process for extending it
- POOR: Static reference only, no generative guidance

---

## Audit Report Format

```markdown
## Skill Audit: [skill name]

**Overall: [SCORE]/10** — [one-sentence summary]

### Dimension Scores
| # | Dimension | Score | Key Finding |
|---|-----------|-------|-------------|
| 1 | Description | GOOD/OKAY/POOR | ... |
| 2 | Token Budget | GOOD/OKAY/POOR | ... |
| 3 | Positional Architecture | GOOD/OKAY/POOR | ... |
| 4 | Scope Boundaries | GOOD/OKAY/POOR | ... |
| 5 | Structural Signifiers | GOOD/OKAY/POOR | ... |
| 6 | Degrees of Freedom | GOOD/OKAY/POOR | ... |
| 7 | Pattern Language | GOOD/OKAY/POOR | ... |
| 8 | Strategic Redundancy | GOOD/OKAY/POOR | ... |
| 9 | Progressive Disclosure | GOOD/OKAY/POOR | ... |
| 10 | Generative Process | GOOD/OKAY/POOR | ... |

### Critical Fixes (do these first)
1. [Specific fix with section/line reference and rationale]
2. ...

### Recommended Improvements
1. [Specific improvement with section/line reference]
2. ...

### Structure Recommendation
[Suggested file reorganization, if applicable]

### What's Working Well
[2-3 specific things the skill does right]
```

**Scoring: GOOD = 1, OKAY = 0.5, POOR = 0. Total out of 10.**

---

## Revision Protocol

When the user asks for a revised version (or says "fix it", "rewrite
it", "improve it"):

1. Apply all Critical Fixes from the audit report
2. Apply Recommended Improvements that don't conflict with the author's
   intent
3. Restructure to follow the pattern language ordering if needed
4. Add strategic redundancy for the top 3 rules
5. Extract oversized sections to `references/` files
6. Produce the revised SKILL.md as a new file — never overwrite the
   original without confirmation
7. Show a before/after summary: line count change, score change,
   key structural changes

**Revision constraints:**
- Preserve the author's opinions and architectural decisions
- Preserve the author's voice and terminology
- Do not add explanations of things Claude already knows
- Do not change the skill's scope or purpose
- If uncertain about intent, ask before changing

---

## Hard Rules (reiterated)

- Specific findings with section/line references, not abstract advice
- Concrete fixes for every problem, not just diagnosis
- Never dilute opinions — audit structure, not philosophy
- Never add what Claude already knows
- Respect the author's design decisions
- Produce revised files only when asked, never overwrite originals
