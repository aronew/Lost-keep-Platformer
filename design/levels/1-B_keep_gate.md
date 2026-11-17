# 1-B The Keep Gate (blockout of the approach and the arena; the boss is not built)

Builder: `game/tools/build_l1_b.gd` → `game/scenes/levels/l1_b_keep_gate.tscn`.
Pictures: `docs/levels/1-B/blockout/`.

**Region 1's boss level,** pad 6 on the map (the skull gate). 160 × 40
tiles.

- **The approach** (0–90): a terrace, two stones over the moat, a rat.
- **The midway banner** (x 90), at the arena's door: a defeat sends her
  back here, not through the approach.
- **The arena** (100–140): the Keep's outer courtyard, 40 tiles of flat
  ground with a raised ledge (3 up) at each end.
- **The way out** (x 150).

**Not built: the boss.** The Keep's fallen warden (an armoured giant) has
no design, no art and no code yet. The arena is empty and the way out is
open, so the stop can be cleared by walking through. No letters, bonus
areas or knot here.

## Validation (in engine)
`room=l1_b`: `mode=tour` **ALL PASS** (the approach, the banner, both
ledges, out).

## Needed from the creative lead before this can go further
- What the warden does: his attacks, how he is hurt, how many phases.
- His art (the prompt books have a throne and a gate, not a fighting
  warden).
- What the Ironbark Ward (the region's reward) looks like when given.
