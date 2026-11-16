# 1-2 The Gate Road (blockout, awaiting the creative lead's review)

Builder: `game/tools/build_l1_2.gd` → `game/scenes/levels/l1_2_gate_road.tscn`
(`blockout = true`: the black box, labels, real or stand-in sprites for
everything that acts; no art until the layout is approved).
Pictures: `docs/levels/1-2/blockout/` (the poster with the walked routes, and
an in-game shot of every beat).

**The level's one idea: hopping over water.** Small stone islands standing
in it, then the big floating islands above it. From Lost Keep's IB-04 (its
pool with six islands and the high path over it), made long and horizontal.
**Looks to match when it is dressed:** `docs/mockups/platformer/bright_day/`
(the ponds, the floating islands) and `flooded_ruins/` (stone pillars in
water).

Built to the methods in `design/research/platformer-fun.md` (Donkey Kong
Country 1 to 3, Super Mario): one idea in four beats, a chain inside a beat,
Resin that never lies, a dare beside the safe line, a great secret that
turns a habit against the player.

## Size and shape
- 440 × 40 tiles (7,040 × 640 px): about 11 screens long and 1.8 high, as
  1-1. The room is 540 wide: its two bonus areas lie beside the level
  (x 452–536), out of its view.
- The road's walking line is row 30 (y 480); still water lies under
  everything two tiles below it (y 512). The high path runs at rows 16 to 20.
- **Stone islands** stand on the water bed. **Floating islands** are three
  tiles thick and hang clear of what is under them: at least 6 rows over any
  floor she jumps from (a full jump needs 82 px).
- Start at x 5. The gateway out is at x 428, on the gate's ledge (row 24).
- **One checkpoint, at the middle** (x 220): the Guard's banner, where the
  road ends and the islands begin.

## The four beats

| Beat | Tiles | What happens |
|---|---|---|
| **TEACH** | 0–112 | **Three broken wall stubs on the road** (2 up, then two hops of 4): the level's hop, first over dry ground where a miss costs nothing. A pot, a **Mossback**. **The first water**: two wide stone islands (5 and 4 tiles, gaps of 4; **letter K** over the second hop). Two banks (3 up, 2 up) to **the first floating island**, over dry ground (a chest on it); off its far end to the road. |
| **TEST** | 112–220 | **The old rampart** across the road: three terraces up (3 each) to the tower's top, down two big steps. **The long pool** (60 tiles), crossed by **a chain of seven stones, no two hops alike** (below). Over it, **the high path** (secret). A block on the far bank (3 up). |
| **TWIST** | 220–322 | **The midway banner** (the checkpoint). Two terraces up, and **the road ends**: 84 tiles of open water with nothing standing in it. **The floating islands are the only way**: six of them at different heights (up 2, down 2, up 2, down 2, up 2, down 3; gaps of 4), with **a rat on the great island** (26 tiles: room to fight). |
| **FINISH** | 322–440 | A thorn bed, then both kinds at a run: two stones climbing out of the water (up 1, up 2), two floating islands (up 2, up 2; **letter O** over the jump onto the first), down to a stone pillar (3 down), the bank, and **the gatehouse**: a terrace, the gate's ledge, the last chest, the gateway. |

### The long pool's chain
Each hop is a step on from the last (Super Mario World's way: the same
thing made harder, or the same thing with something added):

| Hop | Gap | Lands on | What is new |
|---|---|---|---|
| 1 | 3 | 5 wide, 1 up | The easiest: near and wide |
| 2 | 4 | 4 wide, 1 up | Farther |
| 3 | 4 | 3 wide, 2 up | Narrower and higher |
| 4 | 4 | 4 wide, 3 down | A drop: the landing comes late |
| 5 | 4 | 6 wide, 1 up | **The rest:** a wide stone, a pot |
| 6 | 4 | 3 wide, 1 up | Small again, after the rest |
| 7 | 4 | 4 wide, 2 down | Down toward the bank |
| 8 | 4 | the bank, 1 down | Out |

Beside hop 5, under the safe line: **a low stone with three beads** (risky
Resin). She drops 2 onto it from the stone before, and gets back up to the
wide stone across a gap of 1, 3 up. A slip there is the water.

## Region 1 rules it keeps
- Widest required gap 4 tiles; smallest landing 3 tiles; one enemy at a
  time.
- Every rise over a gap is 1 or 2; every rise of 3 is a step beside her (or
  across a gap of 1, on the two optional routes). The only ledge catch is
  the way back up from the old landing (4 tiles, optional).
- Every required gap can be made with a plain jump. Kleo's stride (a second
  of unbroken running: a jump of 8.3 tiles) lets a skilled player skip a
  stone: hop 1's stone, for one.
- **No platforms.** Everything she stands on is the road, a bank, a rampart,
  a stone island or a floating island. Nothing moves (rafts and lifts are
  1-4's idea).
- Floating islands on a path sit at different heights, and so do the stones.

## Secrets and Resin
- **Letters (4):** K over the first water and O over the last (on the main
  line's jumps), L on the high path, E behind the false wall.
- **The great secret: Morvath's thorn knot.** It sleeps on a small floating
  island west of the rampart's tower, 6 tiles over the terrace under it: she
  sees it as she climbs, out of reach. The way is from the tower's top,
  **back west** (3 across, 3 up): the one time the level asks her to turn
  round. Its tell is itself, in plain sight.
- **The high path** (a secret route above): from the tower's top, beads arc
  up east to five big floating islands over the long pool (up 2, up 2, down
  1, up 2, down 4): a chest on the second, **a rat on the great island** (24
  tiles), **letter L** on the fourth, and at the end of the fifth **a
  glowing hollow: bonus 1**. Off its end she lands on the far bank's block.
- **The old landing** (hidden under the twist's first floating island): off
  the bank's edge where the road ends, a step in the bank's face (3 down)
  and a stone shelf by the water (4 down); in the island's shadow, **a
  glowing hollow: bonus 2**. The way back up is a 4-tile ledge catch, then 3
  up. Its tell: beads stepping down off the edge (Resin never lies: there
  is ground under them).
- **Both bonus areas are Resin rushes** (the creative lead: "a ton of resin
  where you need to jump and try and get all the resin; if you're able to
  get it all you get a token"). Every bead in time brings out the token,
  and the Resin gathered is hers to keep. Miss one, run out of time or
  fall: no harm, back out, try again.
  - **Bonus 1** (12 s, 20 Resin): five stone pillars over a drop, at
    different heights: three beads along the arc of every hop, one on each
    pillar. The token appears over the last pillar.
  - **Bonus 2** (16 s, 32 Resin): raised ground in four blocks: beads along
    every top, an arc over every hop, and a column of three over three of
    the blocks (a jump on the spot). The token appears over the last block.
- **The false wall:** the end terrace's west face, by the gatehouse (motes
  drift into it): **letter E** in the hollow behind it.
- **Chests (3):** on the first floating island (8), on the high path (6), by
  the gateway (8).
- **Bead trails** arc over every hop. **Risky Resin** on the long pool's low
  stone.
- **Four different tells:** the knot in plain sight, beads arcing up (the
  high path), beads stepping down (the landing), motes into stone (the
  false wall).

## Validation (in engine)
`cd game` then:

```
xvfb-run -a godot --path . --fixed-fps 60 --audio-driver Dummy res://tests/playtest.tscn -- room=l1_2 mode=tour
```

- `mode=tour` (the main line, enemies held still): **ALL PASS**, 46 checks:
  every stub, bank, terrace, stone and floating island, the midway banner
  reached, through the gateway.
- `mode=secrets`: **ALL PASS**: all four letters; all three chests; the
  first floating island out of reach from the road under it; the knot's
  island out of reach from the terrace, reached from the tower's top, and
  the knot woken; the risky Resin taken and the way back up; the high path
  end to end and into bonus 1, all 20 Resin and the token; down onto the
  block; off the bank's edge to the old landing and into bonus 2, all 32
  Resin and the token; back up the ledge catch onto the bank; the false wall
  fades while she is inside and closes when she leaves.
- `mode=stride`: Kleo's stride, measured on this level's road.
- `mode=shots` and `mode=map`, then `python3 tools/stitch_map.py l1_2` and
  `python3 tools/level_poster.py l1_2` for the poster.
- Not yet in `tools/check_room.py` (1-1 isn't either): the walked tours are
  the proof.

## Changed while building it
- The rampart's east side first stepped down straight into the pool, and a
  4-tile block stood across the road on the far bank: both fixed in the plan
  before the first build.
- Bonus 2's entrance was first two low stones out in the water under the
  islands: the terraces left no way down to them or back. It is now the old
  landing in the bank's face.
- In a gather bonus, a bead she was already standing in when the bonus
  started (she walked on through the fade) was never taken. `bonus_zone.gd`
  now gives it to her.

## Changed after the creative lead saw the bonus shots (2026-11)
"Make the bonus level have a ton of resin where you need to jump and try
and get all the resin; if you're able to get it all you get a token." Both
areas are Resin rushes (above): bonus 1's pillar course is now a gather
too. The countdown shows how much is left; winning pays the Resin out.

## Changed after the research and the creative lead's notes (2026-11)
- **The long pool is a chain** (above): its seven stones were near-identical
  hops of 4; now no two are alike, with a rest and risky Resin.
- **The thorn knot** and its island.
- **One checkpoint, at the middle** (the creative lead: "there should be a
  middle point where you get a checkpoint; I don't want lanterns, they look
  bad"): the Guard's banner at x 220. Checkpoints 1 and 3 are gone.
- The risky stone was first 2 wide with a tile of water before it: stepping
  off the edge dropped her straight into that tile. It now stands against
  the stone she steps from, 3 wide.

## Open for the review
- **The layout as a whole:** is hopping stones, then floating islands, the
  right second level, and is 440 tiles the right length for it?
- **One checkpoint:** a fall in the long pool now sends her back to the
  start (112 tiles). Too harsh for region 1, or right?
- **The twist's six floating islands** still go up 2, down 2 like a
  metronome. They want the pool's treatment next.
- **The knot's jump** (3 across, 3 up) is the hardest in the level. Right
  for the great secret?
- **The old landing** is only mildly hidden. Hide it more, or keep it as the
  easy find?
- **Enemies:** a Mossback on the road, a rat on each great island. The
  roster's bat or toad could take a place here once they are built.
