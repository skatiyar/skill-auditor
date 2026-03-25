#!/usr/bin/env bash
# skill-auditor/scripts/analyze.sh
#
# Preprocessor for skill audit. Extracts structural metrics from a
# SKILL.md file to inform the audit. Run before reading the file.
#
# Usage: ./scripts/analyze.sh <path-to-SKILL.md>
#
# Output: structured report with line counts, section map, token
# estimates, and structural warnings.

set -euo pipefail

FILE="${1:?Usage: analyze.sh <path-to-SKILL.md>}"

if [ ! -f "$FILE" ]; then
    echo "ERROR: File not found: $FILE"
    exit 1
fi

SKILL_DIR="$(dirname "$FILE")"

# --- Metrics ---

total_lines=$(wc -l < "$FILE")
blank_lines=$(grep -c '^$' "$FILE" || true)
content_lines=$((total_lines - blank_lines))

# Token estimate: ~1.3 tokens per word for English markdown
word_count=$(wc -w < "$FILE")
token_estimate=$(( (word_count * 13 + 5) / 10 ))

# Code block lines
code_lines=$(awk '/^```/{flag=!flag; next} flag{n++} END{print n+0}' "$FILE")

# --- YAML Frontmatter ---

has_frontmatter="no"
description_length=0
has_name="no"
if head -1 "$FILE" | grep -q '^---'; then
    has_frontmatter="yes"
    # Extract frontmatter
    frontmatter=$(awk '/^---/{n++; next} n==1{print} n>=2{exit}' "$FILE")
    if echo "$frontmatter" | grep -q '^name:'; then
        has_name="yes"
    fi
    desc=$(echo "$frontmatter" | awk '/^description:/{found=1; sub(/^description: */, ""); print; next} found && /^  /{print; next} found{exit}')
    description_length=$(echo "$desc" | wc -w | tr -d ' ')
fi

# --- Section Map ---

echo "============================================"
echo "  SKILL AUDIT PREPROCESSOR"
echo "============================================"
echo ""
echo "File: $FILE"
echo "Total lines: $total_lines"
echo "Content lines: $content_lines (blank: $blank_lines)"
echo "Code block lines: $code_lines"
echo "Word count: $word_count"
echo "Token estimate: ~$token_estimate"
echo ""

# --- Sizing Verdicts ---

echo "--- Sizing Verdicts ---"
if [ "$total_lines" -le 300 ]; then
    echo "Body length: GOOD ($total_lines lines, target <300)"
elif [ "$total_lines" -le 500 ]; then
    echo "Body length: OKAY ($total_lines lines, target <300, max 500)"
else
    echo "Body length: OVER LIMIT ($total_lines lines, max 500)"
fi

code_pct=0
if [ "$content_lines" -gt 0 ]; then
    code_pct=$(( (code_lines * 100) / content_lines ))
fi
if [ "$code_pct" -gt 50 ]; then
    echo "Code density: HIGH ($code_pct% — consider extracting examples to references/)"
else
    echo "Code density: $code_pct%"
fi
echo ""

# --- Frontmatter ---

echo "--- Frontmatter ---"
echo "Has frontmatter: $has_frontmatter"
echo "Has name: $has_name"
echo "Description word count: $description_length"
if [ "$description_length" -lt 20 ]; then
    echo "Description: SHORT — likely undertriggering"
elif [ "$description_length" -gt 100 ]; then
    echo "Description: LONG — consider trimming"
else
    echo "Description: OK"
fi
echo ""

# --- Section Map ---

echo "--- Section Map (headers with line numbers) ---"
grep -n '^#' "$FILE" | while IFS= read -r line; do
    lineno=$(echo "$line" | cut -d: -f1)
    header=$(echo "$line" | cut -d: -f2-)
    echo "  L$lineno: $header"
done
echo ""

# --- Long Sections (wall-of-text detection) ---

echo "--- Wall-of-Text Detection (>15 consecutive non-blank, non-header, non-code lines) ---"
awk '
BEGIN { run=0; start=0; in_code=0; found=0 }
/^```/ { in_code=!in_code; run=0; next }
in_code { next }
/^$/ || /^#/ { 
    if (run > 15) { 
        printf "  L%d-L%d: %d lines without structural break\n", start, NR-1, run
        found=1
    }
    run=0; next 
}
{ 
    if (run==0) start=NR
    run++ 
}
END { 
    if (run > 15) {
        printf "  L%d-L%d: %d lines without structural break\n", start, NR, run
        found=1
    }
    if (!found) print "  None found"
}
' "$FILE"
echo ""

# --- Strategic Redundancy Detection ---

echo "--- Repetition Analysis ---"
# Find the first and last h2 sections
first_h2=$(grep -n '^## ' "$FILE" | head -1 | cut -d: -f1)
last_h2=$(grep -n '^## ' "$FILE" | tail -1 | cut -d: -f1)
if [ -n "$first_h2" ] && [ -n "$last_h2" ] && [ "$first_h2" != "$last_h2" ]; then
    first_section=$(sed -n "${first_h2}p" "$FILE")
    last_section=$(sed -n "${last_h2}p" "$FILE")
    echo "  First ## section: $first_section (L$first_h2)"
    echo "  Last ## section:  $last_section (L$last_h2)"
    
    # Check if keywords from the first section appear in the last
    # (rough heuristic for bookending)
    if echo "$last_section" | grep -qi 'rule\|reiterat\|summar\|repeat\|critical\|important'; then
        echo "  Bookending: LIKELY (last section appears to reiterate)"
    else
        echo "  Bookending: NOT DETECTED"
    fi
else
    echo "  Insufficient sections for analysis"
fi
echo ""

# --- Reference Files ---

echo "--- Bundled Resources ---"
if [ -d "$SKILL_DIR/references" ]; then
    echo "  references/:"
    for f in "$SKILL_DIR/references"/*; do
        if [ -f "$f" ]; then
            fname=$(basename "$f")
            flines=$(wc -l < "$f")
            echo "    $fname ($flines lines)"
        fi
    done
else
    echo "  No references/ directory"
fi

if [ -d "$SKILL_DIR/scripts" ]; then
    echo "  scripts/:"
    for f in "$SKILL_DIR/scripts"/*; do
        if [ -f "$f" ]; then
            fname=$(basename "$f")
            echo "    $fname"
        fi
    done
else
    echo "  No scripts/ directory"
fi

if [ -d "$SKILL_DIR/assets" ]; then
    echo "  assets/:"
    for f in "$SKILL_DIR/assets"/*; do
        if [ -f "$f" ]; then
            echo "    $(basename "$f")"
        fi
    done
else
    echo "  No assets/ directory"
fi
echo ""

echo "--- Inline Pointers to Reference Files ---"
grep -n 'references/\|REFERENCE\|FORMS\|scripts/' "$FILE" 2>/dev/null | while IFS= read -r line; do
    echo "  $line"
done || echo "  No references to bundled files found"
echo ""

echo "============================================"
echo "  Preprocessor complete. Proceed to audit."
echo "============================================"
