# Pass criteria: toolkit-new-artifact

**Triggering only.** The prompt deliberately signals "already decided" + "agent" so it should
route to `toolkit-new-artifact` (scaffold a known type) rather than `toolkit-choose-artifact`
(decide the type). Uses `model: sonnet` for the same reason as the `toolkit-choose-artifact`
scenario — these two are the pair most likely to be confused with each other.
