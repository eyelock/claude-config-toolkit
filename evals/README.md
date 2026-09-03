# Evals

Three tiers of regression coverage for this repo's Claude Code artifacts (commands, skills,
agents, rules). Ordered cheapest/fastest first — each tier catches bugs the one before it can't.

| Tier | What it checks | Cost | Run with |
|---|---|---|---|
| 1. Structural | Frontmatter correctness: `name` matches filename/dirname, required fields present, `tools`/`model` values valid, no half-finished skills | Free, instant | `make validate` |
| 2. Script | The bundled `*.sh` scripts (new-handover, setup, validate-frontmatter, ...) actually work — run against real fixtures/scratch dirs. Also unit-tests the tier-3 grading logic itself, with canned transcripts, so grading bugs are caught without spending API budget | Free, ~seconds | `make test-scripts` |
| 3. LLM-in-the-loop | Does a skill actually *trigger* on the prompts it's meant for (and stay silent on unrelated ones)? Does a full skill workflow produce the right files end-to-end? | Costs tokens | `make eval` |

`make test` runs tiers 1+2 (always free, what CI runs on every push/PR). `make eval` is separate
and opt-in because it spends real money on API calls.

**Auth:** `make eval` does not gate on `ANTHROPIC_API_KEY` — it just runs `claude -p`, which
authenticates however you normally use Claude Code locally (OAuth/keychain login, or an API key
if that's how you're set up). The `ANTHROPIC_API_KEY`-presence gate lives only in
`.github/workflows/ci.yml`: CI has no OAuth session, so it needs the secret explicitly, and skips
the eval job with a notice when the secret isn't configured on the repo rather than failing PRs
from contributors who don't have API access. That's a CI-specific concern, not something the
scripts under `evals/scenarios/lib/` know or care about.

## Why a custom harness instead of `claude plugin eval`

Claude Code has an official `claude plugin eval` feature, but as of writing it's early-access/
gated and not available in every org, and it's unconfirmed whether it works against a loose
artifact collection (no `.claude-plugin/plugin.json`) like this repo. The `evals/<case>/prompt.md`
+ grader convention here is loosely modeled on it, so migrating later — once/if the gate opens and
this repo is packaged as a formal plugin — should be low-friction. Until then, this is a small,
dependency-light (`bash` + `jq`) harness that runs anywhere.

## Layout

```
evals/
  scripts/            # Tier 2: bash unit tests, no LLM/network
    lib/assert.sh          # tiny assertion helpers
    test-*.sh               # one file per bundled script (+ test-grader.sh for tier 3's logic)
    run-all.sh
  scenarios/           # Tier 3: LLM-in-the-loop
    lib/
      mkscratch.sh          # builds a throwaway project with this repo's artifacts installed
      frontmatter.sh        # shared prompt.md YAML-frontmatter parsing
      run-scenario.sh        # runs one scenario: mkscratch -> claude -p -> grade
      grade.sh               # grades a transcript against a prompt.md's frontmatter
      run-all.sh              # runs every scenario; skips (exit 0) if ANTHROPIC_API_KEY is unset
    <skill-name>/
      prompt.md              # YAML frontmatter (expect_skill / forbid_skills / expect_files,
                              #   model, max_budget_usd, timeout_seconds) + the prompt body
      grader.md               # human-readable rationale for what "pass" means (documentation —
                               #   the actual pass/fail check is mechanical, driven by prompt.md)
    _negative-control/    # a prompt that should trigger none of the skills
```

## Writing a new scenario

1. `mkdir evals/scenarios/your-case`
2. `prompt.md`: frontmatter with `expect_skill: <name>` (or `forbid_skills: [a, b]` for a
   negative case), optionally `expect_files: [glob, ...]` for end-to-end checks, then the prompt
   text a real user might type — never name the skill or its slash command, that's what you're
   testing.
3. `grader.md`: a couple of sentences on *why* this should/shouldn't trigger and what would make
   it a false pass/fail. Not executed — for humans reviewing a failure.
4. `bash evals/scenarios/lib/run-scenario.sh evals/scenarios/your-case` to try it locally
   (needs `ANTHROPIC_API_KEY`).

## Grading model: `expect_skill` / `forbid_skills` / `expect_files`

`grade.sh` parses the transcript's `stream-json` output for `Skill` tool-use events and compares
the invoked skill name(s) against `prompt.md`'s frontmatter — no LLM judge, fully deterministic
given a transcript. `expect_files` (glob patterns, relative to the scratch project root) checks
real file output for end-to-end cases. A `prompt.md` with none of these three fields fails loudly
rather than silently passing — see `test-grader.sh` for the exact contract.

## Cost controls

Every scenario run is capped with `--max-budget-usd` (per-scenario, in `prompt.md`) and a wall-clock
`timeout`/`gtimeout` (`timeout_seconds`), and runs with `--permission-mode bypassPermissions`
inside a throwaway `mktemp -d` scratch directory (never this repo's working tree) so it can act
without prompting. Default model is `haiku` (cheap); a couple of scenarios pin `sonnet` where two
similarly-described skills are easy to confuse and the extra reliability is worth the cost — see
those scenarios' `grader.md`.

## CI

`.github/workflows/ci.yml` always runs tiers 1+2. The LLM tier runs only when the
`ANTHROPIC_API_KEY` secret is set on the repo — otherwise that job logs a skip notice and exits 0
rather than failing a PR that a contributor without API access can't do anything about.
