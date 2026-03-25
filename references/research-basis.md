# Research Basis for Skill Audit Dimensions

Read this file when you need to explain WHY a particular audit finding
matters, or when the user asks for evidence behind a recommendation.
Each section maps to an audit dimension in the main SKILL.md.

---

## 1. Description Field — Why It's Highest Leverage

Skill triggering uses pure LLM reasoning — no regex, no embeddings, no
algorithmic routing. Claude sees only the `name` and `description` from
YAML frontmatter (~100 tokens per skill) when deciding whether to load a
skill. If the description doesn't match the user's phrasing, the skill
never fires and the entire body is irrelevant.

Anthropic's skill-creator documentation notes that Claude tends to
"undertrigger" — failing to use skills when they'd be useful. The
recommendation is to make descriptions "a little bit pushy" with specific
trigger phrases. However, newer models (Opus 4.5+) can overtrigger,
requiring negative boundaries ("Do NOT use for X").

The description is the only part that's always in context. Every other
word in the skill competes for attention; the description gets guaranteed
processing.

---

## 2. Token Budget — The Empirical Case for Conciseness

### Instruction-count degradation
The IFScale benchmark (Jaroslawicz et al., 2025, Distyl AI) tested 20
frontier models on multi-instruction following:
- Even the best models achieve only ~68% accuracy at 500 instructions
- Three degradation patterns: threshold decay (collapse after critical
  density), linear decay (steady decline), exponential decay (rapid
  early decline)
- Claude Sonnet 4 exhibits linear decay — each added instruction
  reduces overall compliance

### Input length degrades reasoning
Levy et al. ("Same Task, More Tokens," ACL 2024) found measurable
reasoning degradation beginning at approximately 3,000 input tokens —
far below technical context window limits. Chain-of-thought prompting
does not mitigate this.

### Irrelevant content is actively harmful
LLMs exhibit "identification without exclusion" — they can identify
irrelevant details but fail to ignore them during generation.
Semantically similar but irrelevant content is worse than unrelated
noise. The "Cognitive Overload Attack" paper (Upadhayay et al., 2024)
showed excessive context complexity can degrade instruction-following
to near-zero, with models defaulting to pretraining knowledge.

### Practical threshold
Anthropic recommends under 500 lines for SKILL.md bodies. Practitioners
report 3x token reduction by eliminating explanations of things Claude
already knows.

### CLI agents as supporting evidence
Reinhard (Feb 2026): CLI-based agent architectures use 35x fewer tokens
than MCP approaches for equivalent tasks. Crosley's "CLI Thesis": 94%
lower token costs and 3.5x faster execution. The mechanism: terse,
structured output is cheaper to process than verbose wrappers.

---

## 3. Positional Architecture — The U-Shaped Attention Curve

### "Lost in the Middle" (Liu et al., 2024, TACL)
LLM performance follows a U-shaped curve by information position.
Performance is highest at the beginning (primacy) and end (recency),
with significant degradation in the middle. GPT-3.5-Turbo's performance
with mid-context information was LOWER than with no documents at all.

### Universal primacy bias
IFScale confirmed "universal primacy bias" across all 20 tested models,
suggesting a transformer architectural limitation rather than
model-specific behavior.

### Instruction reordering sensitivity
The RIFT testbed showed accuracy drops of up to 72% under non-sequential
instruction conditions.

### Strategic duplication works
Google Research (2025): duplicating the entire prompt improved
performance in 47 of 70 benchmark-model combinations. Strategic
repetition at document boundaries is a low-cost reliability boost.

---

## 4. Scope Boundaries — Converging Evidence

### Rams: "Good design is honest"
Adapted to AI by O'Regan: a well-designed system signals capability
boundaries. A skill without scope gets applied where its rules
produce wrong outputs.

### Norman: Constraints
Explicit constraints prevent wandering into unintended territory. Most
effective as positive ("handle X, Y, Z") combined with negative
("not for A, B, C").

### Instruction hierarchy research
Wallace et al. (2024): 63% improved robustness from explicit privilege
and scope levels. Explicit boundaries reduce the search space for
"what should I do here?"

### Negative instructions caveat
KAIST research: larger models perform worse on negated instructions.
Positive framing ("do X") outperforms negative ("don't do Y"). Use
IN/OUT scope, but weight the IN side.

---

## 5. Structural Signifiers — Format Is Functional

### Performance impact
He et al. (arXiv:2411.10541): performance varies up to 40% based on
format alone, no single format universally optimal.

### Claude and XML/markdown
Anthropic confirms Claude was fine-tuned to attend to XML tags. Zack
Witten (Anthropic): "blob-prompts" lead to misinterpreting examples
as instructions. For SKILL.md files, markdown headers create hierarchy,
code blocks create boundaries, tables create lookup structures.

### Wall-of-text penalty
Unstructured prose compounds mid-context degradation. Without breaks,
the model has no landmarks to anchor attention.

---

## 6. Degrees of Freedom — Anthropic's Framework

Anthropic's skill authoring guidance introduces a "degrees of freedom"
pattern:
- **Low freedom** (fragile): Exact scripts, precise steps
- **Medium freedom** (structured): Pseudocode, parameters, patterns
- **High freedom** (creative): Principles, examples, direction

Without explicit markers, Claude treats all instructions at the same
rigidity — producing over-constrained or under-constrained behavior.

---

## 7. Pattern Language — Alexander's Insight

Alexander's pattern language (1977): ordered system flowing from
large-scale to small-scale, each pattern resolving specific tensions.

GoF patterns are isolated micro-architectures. Alexander's vision is
an interconnected system. For skills: instructions form a language
(ordered hierarchy), not a flat collection.

Gabriel's translation to software: "habitability" — the characteristic
enabling people to understand construction and change it comfortably.
For skills: could a new author extend it consistently?

Alexander's patterns enable infinite appropriate variations rather than
prescribing exact outputs. A skill teaching underlying patterns handles
novel inputs the author didn't anticipate.

---

## 8. Strategic Redundancy — Evidence

### Prompt duplication
Google Research (2025): appending a prompt copy improved performance
in 47/70 benchmark-model tests. Critical instructions at position 0
benefit from primacy; at position N from recency.

### Gerhardt-Powals Principle 10
"Judicious redundancy" explicitly resolves the tension between
minimalism and consistency. Token cost of repeating 3-5 rules in a
closing section is outweighed by the reliability gain.

### Redundancy vs. duplication
Strategic redundancy = same rule in two positions, potentially
different framing. Accidental duplication = same paragraph twice,
wastes tokens without positional benefit.

---

## 9. Progressive Disclosure — Three-Level Architecture

Anthropic's system:
1. **Metadata** — Always in context (~100 tokens per skill)
2. **SKILL.md body** — On trigger (under 500 lines ideal)
3. **Bundled resources** — On demand (`references/`, `scripts/`,
   `assets/`). Scripts execute without loading into context.

Maps to Unix Rule of Parsimony adapted for context windows: don't load
big when small will do.

### Extraction heuristic
- Content needed <50% of invocations → `references/`
- Code templates >30 lines → `references/`
- Lookup tables, format specs → `references/`
- Domain knowledge Claude lacks → keep inline (this IS the skill)

---

## 10. Generative Process — Enabling Workflows

### Common failure mode
Skill describes structure but not extension process. User says "add a
new endpoint" — Claude knows rules but not sequence.

### Decision trees as generators
Decision trees produce correct behavior for unenumerated inputs. More
token-efficient than listing every scenario.

### Alexander's generative process
Patterns used in sequence: large-scale first, then medium, then small.
A skill's process follows the same order: determine task type → apply
structural pattern → fill implementation.

---

## Source Framework Summary

| Tradition | Key Principles Used | Adapted For |
|-----------|-------------------|-------------|
| Unix (Raymond, 2003) | Representation, Transparency, Parsimony, Composition | Context windows, probabilistic execution |
| Cognitive Engineering (Gerhardt-Powals, 1996) | Reduce uncertainty, fuse data, show only what's needed, judicious redundancy | LLM attention vs. human perception |
| Rams (1976) | Less but better, honest about capability, thorough in detail | Instruction documents vs. physical products |
| Norman (1988) | Constraints, signifiers, conceptual models | LLM input parsing vs. visual interfaces |
| Alexander (1977) | Pattern languages, generative process, quality without a name | Skill file architecture vs. building architecture |
