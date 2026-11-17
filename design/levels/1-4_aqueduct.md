# 1-4 The Aqueduct (blockout, awaiting the creative lead's review)

Builder: `game/tools/build_l1_4.gd` → `game/scenes/levels/l1_4_aqueduct.tscn`.
Pictures: `docs/levels/1-4/blockout/`.

**The level's one idea: things that really move.** Timber rafts and
counterweighted lifts. Each waits for her to step on, makes its run, and
goes back for her. 360 × 40 tiles; the road is row 30, water under
everything; the aqueduct's deck is row 22.

## The four beats

| Beat | Tiles | What happens |
|---|---|---|
| **TEACH** | 0–98 | **A raft over a dry channel** (3 deep: a miss costs nothing; **letter K** rides with her). **A lift up a wall no jump reaches** (6 up), standing beside the wall on dry ground. A chest on the wall. A Mossback. |
| **TEST** | 98–188 | **A raft over the gorge** (21 tiles of water). **A lift over water** up to the aqueduct. On the deck: **the midway banner**, and a rat with room to fight. |
| **TWIST** | 188–232 | **Raft to lift:** a raft high over open water carries her to a lift that takes her down to a stone. Two hops to the bank. |
| **FINISH** | 232–360 | Thorns to jump, **a fast raft** over the last water (**letter O** over its run), the gate's terraces, a chest, the gate. |

## Secrets
- **The great secret: Morvath's thorn knot.** The lift at the aqueduct's
  foot is a bridge to whoever doesn't stop on it: walk straight across
  before it rises and there is a cave under the aqueduct. The cave's mouth
  is in plain sight from the bank. The lift takes her up from the cave's
  side afterwards.
- **Under the first raft** (the dry channel): **letter E**, and **bonus 1**'s
  hollow in the channel's west face (pillars, 12 s).
- **Letter L:** over the first lift's top stop: a jump from the lift.
- **Bonus 2** (blocks, 16 s): the wall's east face is a false wall, behind
  her as she steps down (motes drift into it).
- **Chests (2):** on the wall, by the gate.

## Validation (in engine)
`room=l1_4`: `mode=tour` **ALL PASS** (all seven movers ridden, the banner,
the gate); `mode=secrets` **ALL PASS** (K on the raft; E and bonus 1 in the
channel; L from the lift; bonus 2 behind the false wall; across the lift
into the cave, the knot, and up by the lift from the cave's side; O; both
chests).

## Open for the review
- **Rafts wait for her.** DKC's move on their own, so timing is the
  challenge. Region 1 is easy, so they wait; say if one should not.
- **The raft to lift twist** is the only place two movers meet. More?
- **Crossing the lift for the knot** depends on how slowly the lift starts.
  Too easy to do by accident?
