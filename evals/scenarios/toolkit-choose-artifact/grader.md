# Pass criteria: toolkit-choose-artifact

**Triggering only.** Uses `model: sonnet` rather than the default `haiku` — this scenario and
`toolkit-new-artifact`'s are the pair most likely to be confused with each other (one decides the
type, the other scaffolds a chosen type), so it's graded on a stronger model to reduce
description-matching false negatives that are really model-capability noise, not a real
regression in the skill's description.
