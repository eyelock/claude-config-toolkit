#!/bin/bash
# Shared YAML-frontmatter helpers for the scenario harness. Source, don't execute.

fm_block() {
  # fm_block <file> -- prints the frontmatter block (between the first two '---' lines)
  sed -n '/^---$/,/^---$/p' "$1" | sed '1d;$d'
}

fm_field() {
  # fm_field <file> <field> -- prints a scalar field's value, quotes stripped
  fm_block "$1" | grep "^${2}:" | head -1 | sed "s/^${2}: *//" | sed 's/^"//; s/"$//'
}

fm_list() {
  # fm_list <file> <field> -- prints a YAML flow-list field's items, one per line
  # Handles: field: [a, b, c]
  fm_block "$1" | grep "^${2}:" | head -1 | sed "s/^${2}: *//" \
    | tr -d '[]' | tr ',' '\n' | sed 's/^ *//; s/ *$//; s/^"//; s/"$//' | grep -v '^$'
}

fm_body() {
  # fm_body <file> -- prints everything after the second '---' line (the prompt text)
  awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$1"
}
