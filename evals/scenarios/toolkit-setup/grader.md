# Pass criteria: toolkit-setup

**Triggering:** the `toolkit-setup` skill must be invoked (via the `Skill` tool) in response to a
plain-language request to initialize/set up the workspace — the user never names the skill or
its slash command.

**End-to-end:** because the scratch project has `.claude/commands` and `.claude/skills` with
`toolkit-*` entries (mkscratch.sh installs this repo's artifacts there), `setup.sh` should detect
the "project-with-toolkit" context and create `.claude/sessions/README.md` and
`.claude/plans/README.md`. Their presence after the run is checked directly (no LLM judgment
needed) — see `evals/scenarios/lib/grade.sh`.
