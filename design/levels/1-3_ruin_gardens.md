# 1-3 The Ruin Gardens (blockout, awaiting the creative lead's review)

Builder: `game/tools/build_l1_3.gd` → `game/scenes/levels/l1_3_ruin_gardens.tscn`.
Pictures: `docs/levels/1-3/blockout/`. Planned from pieces
(`level_builder.gd`'s `plan_leg`): the same lists make the collision and
the scripted tour.

**The level's one idea: the climb.** The region's vertical level: 80 tiles
wide and 100 high (about 4 screens of climbing), in three legs that zigzag
up the hill. **A fall never kills here:** she lands on the leg below and
climbs again. It hides the region's secret exit.

## The three legs

| Leg | Rows | What happens |
|---|---|---|
| **1: the hill's terraces** (teach, test), going right | 94 → 72 | Solid ground. Steps of 3 beside her, and **two sunken beds** to hop (4 across, 2 up; the second has thorns in it). A Mossback on the second terrace. **Letter K** over the first bed. It ends on a wide landing against the cliff: **the midway banner**. |
| **The first turn** | 72 → 67 | A step against the cliff (a chest on it), then back west over a small island. |
| **2: the hanging gardens** (twist), going left | 67 → 49 | The same climb with nothing under it but the hill: floating terraces, steps of 3 and hops of 4. **A rat** on the second. It ends on a landing against the hill's west face. |
| **The second turn** | 49 → 44 | A step, an island. |
| **3: to the arch** (finish), going right | 44 → 26 | The last gardens, the same rhythm at a run. **Letter O** over a hop. A chest, and **the cliff's arch**: the way out. |

The legs are kept apart: no garden hangs less than 6 rows over a spot she
jumps from on the leg below.

## Secrets
- **The great secret: Morvath's thorn knot.** The first terrace's west face,
  which every player jumps onto, is a false wall: a tunnel behind it leads
  to a hidden cave under the hill. Its tell is a single bead at the foot of
  the face (Resin never lies).
- **Bonus 1** (pillars, 12 s): **left at the start**, a glowing hollow
  against the hill's west face.
- **Letter L:** the first sunken bed's far face is a false wall (motes
  drift into it).
- **Letter E, a dare:** it hangs in a gap of the hanging gardens. Dropping
  for it lands her on the hill below, beside L's false wall, with leg 1's
  end to climb again.
- **At the top, back west from the arch:** an island with **bonus 2**'s
  hollow on it (blocks, 16 s). The hollow takes her to the bonus every time
  she walks in; once it is won it lets her by, to a second island and
  **the secret exit**, which opens the grotto (1-S) on the map.
- **Chests (2):** on the first turn's step, by the arch.

## Validation (in engine)
`room=l1_3`: `mode=tour` **ALL PASS** (the whole climb, the banner, the
arch); `mode=secrets` **ALL PASS** (the knot asleep behind the face, then
woken; bonus 1 from the start; L behind its false wall; E by the drop; K
and O; both chests; back west at the top into bonus 2, past it once won,
and out by the secret exit, which sets `l13_secret_exit`).

## Open for the review
- **Is a fall that only costs height the right stake** for the first
  vertical level, or should the hanging gardens be over a pit?
- **The three legs share one rhythm** (3, 3, hop, 3, hop, 3, 3). Leg 2
  wants a twist of its own beyond "nothing under it".
- **Two secrets are at the start** (the knot's false wall, bonus 1 to the
  left). Move one?
- **The secret exit needs bonus 2 won.** Right, or too hidden?
