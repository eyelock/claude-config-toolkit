# Pass criteria: toolkit-handover

**Triggering:** the `toolkit-handover` skill must be invoked for a plain-language "help me
capture context before I pause / switch tasks" request — the user never says "handover" or names
the skill/slash-command.

**End-to-end:** `new-handover.sh` resolves `sessions/` relative to its own file location
(`skills/toolkit-handover/scripts/../../../sessions`), which lands on the scratch project's root
`sessions/` (created by `mkscratch.sh`) regardless of the .claude/ install location — so a real
run should leave a `sessions/YYYY-MM-DD-*.md` file behind. Checked directly via glob in
`evals/scenarios/lib/grade.sh`.
