# 1-4 The Aqueduct (blockout, awaiting the creative lead's review)

Builder: `game/tools/build_l1_4.gd` → `game/scenes/levels/l1_4_aqueduct.tscn`.
Pictures: `docs/levels/1-4/blockout/`.

**The level's one idea: things that really move.** Timber rafts and
counterweighted lifts. 360 × 40 tiles; the road is row 30, water under
everything; the aqueduct's deck is row 22.

**Rafts run back and forth on their own** (the creative lead, 2026-11: "they
shouldn't wait, they should be moving back and forth and almost in a way
that you need to time jumps properly"). Each rests one second at each end
of its run, and its run stops **two tiles short of each bank**: she jumps on
when it is near, and off before it leaves. **Lifts run up and down on
their own too** (the creative lead: "make the lifts move on their own too"):
each rests beside the floor at the bottom of its run and beside the floor at
the top, and she steps on and off while it rests.

## The four beats

| Beat | Tiles | What happens |
|---|---|---|
| **TEACH** | 0–98 | **A raft over a dry channel** (3 deep: a mistimed jump costs nothing; **letter K** over its run). **A lift up a wall no jump reaches** (6 up), on dry ground: it rests a row off the ground (a hop on) and level with the wall's top (a step off). A chest on the wall. A Mossback. |
| **TEST** | 98–188 | **A raft over the gorge** (16 tiles of water; a miss is a flame). **A lift over water** up to the aqueduct: it rests level with the bank (step on) and with the deck (step off); when it is up, its place is open water. On the deck: **the midway banner**, and a rat with room to fight. |
| **TWIST** | 188–233 | **Raft to raft:** two rafts out of step, high over open water. They meet in the middle, 3 tiles apart, rest a second, and part: she crosses from one to the other while they are close. The second raft, the lift beyond it and the first raft keep one time (1.4 s of rest): whenever the second raft rests at its far end, the lift is resting at the top beside it. She steps across; it takes her down to a stone. Two hops to the bank. |
| **FINISH** | 233–360 | Thorns to jump, **a fast raft** over the last water (**letter O** over its run), the gate's terraces, a chest, the gate. |

| Raft | Run | Speed | One way |
|---|---|---|---|
| 1, the dry channel | 5 tiles | 48 px/s | 2.3 s |
| 2, the gorge | 9 | 64 | 3.2 s |
| 3 and 4, the twist | 7 each | 56 | 2.8 s |
| 5, the fast one | 13 | 96 | 3.0 s |

## Secrets
- **The great secret: Morvath's thorn knot.** The lift at the aqueduct's
  foot is also a bridge: while it rests at the bottom, walk straight across
  it instead of riding, and there is a cave under the aqueduct. The cave's
  mouth is in plain sight from the bank. From the cave's side the lift takes
  her up the next time it comes down.
- **Under the first raft** (the dry channel): **letter E**, and **bonus 1**'s
  hollow in the channel's west face (pillars, 12 s).
- **Letter L:** over the first lift's top stop: a jump from the lift.
- **Bonus 2** (blocks, 16 s): the wall's east face is a false wall, behind
  her as she steps down (motes drift into it).
- **Chests (2):** on the wall, by the gate.

## Validation (in engine)
`room=l1_4`: `mode=tour` **ALL PASS**, with fixed and with real frame times
(a timed jump onto every raft and off it, raft to raft, a timed step onto
all three lifts, the banner, the gate); `mode=secrets` **ALL PASS** (K on the raft; E and bonus 1 in the
channel; L from the lift; bonus 2 behind the false wall; across the lift
while it rests into the cave, the knot, and up by the lift from the cave's
side; O; both
chests).

## Open for the review
- **The rafts' timing:** a second of rest at each end and a jump of two
  tiles. Too generous, or too tight for region 1? Nobody has played it.
- **Waiting for a raft** takes up to a full run and back (about 8 s on the
  slowest). If that drags, the runs get shorter.
- **Crossing the lift for the knot** depends on how slowly the lift starts.
  Too easy to do by accident?

## Changed after the creative lead's review (2026-11)
The rafts first waited for her to step on. Now they run on their own and
she times her jumps (above); the gorge is narrower (16 tiles, was 24) so the
wait for its raft is short; the twist is raft to raft (it was a raft that
handed her to a lift). Then the lifts were set running too: they had waited
for her weight.
