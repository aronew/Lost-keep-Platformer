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

## The four beats

| Beat | Tiles | What happens |
|---|---|---|
| **TEACH** | 0–112 | **Three broken wall stubs on the road** (2 up, then two hops of 4): the level's hop, first over dry ground where a miss costs nothing. A pot, a **Mossback**. **The first water**: two wide stone islands (5 and 4 tiles, gaps of 4; **letter K** over the second hop). Two banks (3 up, 2 up) to **the first floating island**, over dry ground (a chest on it); off its far end to the road. |
| **TEST** | 112–220 | **Checkpoint 1.** **The old rampart** across the road: three terraces up (3 each) to the tower's top, down two big steps. **The long pool** (60 tiles): **seven small stone islands** at different heights (3 to 5 tiles wide, gaps of 4, rises and drops of 1 or 2). Over it, **the high path** (secret, below). A block on the far bank (3 up). |
| **TWIST** | 220–322 | **Checkpoint 2.** Two terraces up, and **the road ends**: 84 tiles of open water with nothing standing in it. **The floating islands are the only way**: six of them at different heights (up 2, down 2, up 2, down 2, up 2, down 3; gaps of 4), with **a rat on the great island** (26 tiles: room to fight). |
| **FINISH** | 322–440 | **Checkpoint 3.** A thorn bed, then both kinds at a run: two stones climbing out of the water (up 1, up 2), two floating islands (up 2, up 2; **letter O** over the jump onto the first), down to a stone pillar (3 down), the bank, and **the gatehouse**: a terrace, the gate's ledge, the last chest, the gateway. |

## Region 1 rules it keeps
- Widest required gap 4 tiles; smallest landing 3 tiles; one enemy at a
  time; 3 checkpoints, each before the hard part.
- Every gap is 4. Every rise over a gap is 1 or 2; every rise of 3 is a step
  beside her. The only ledge catch is the way back up from the old landing
  (4 tiles, optional).
- **No platforms.** Everything she stands on is the road, a bank, a rampart,
  a stone island or a floating island. Nothing moves (rafts and lifts are
  1-4's idea).
- Floating islands on a path sit at different heights, and so do the stones.

## Secrets and Resin
- **Letters (4):** K over the first water and O over the last (on the main
  line's jumps), L on the high path, E behind the false wall.
- **The high path** (a secret route above): from the tower's top, beads arc
  up to five big floating islands over the long pool (up 2, up 2, down 1, up
  2, down 4): a chest on the second, **a rat on the great island** (24
  tiles), **letter L** on the fourth, and at the end of the fifth **a
  glowing hollow: bonus 1**. Off its end she lands on the far bank's block.
- **Bonus 1, "course"** (10 s): five stone pillars over a drop, at different
  heights, to the token.
- **The old landing** (hidden under the twist's first floating island): off
  the bank's edge where the road ends, a step in the bank's face (3 down)
  and a stone shelf by the water (4 down); in the island's shadow, **a
  glowing hollow: bonus 2**. The way back up is a 4-tile ledge catch, then 3
  up. Its tell: beads stepping down off the edge.
- **Bonus 2, "gather"** (12 s): twelve beads along and over raised ground;
  the token appears over the last block.
- **The false wall:** the end terrace's west face, by the gatehouse (motes
  drift into it): **letter E** in the hollow behind it.
- **Chests (3):** on the first floating island (8), on the high path (6), by
  the gateway (8).
- **Bead trails** arc over every hop.

## Validation (in engine)
`cd game` then:

```
xvfb-run -a godot --path . --fixed-fps 60 --audio-driver Dummy res://tests/playtest.tscn -- room=l1_2 mode=tour
```

- `mode=tour` (the main line, enemies held still): **ALL PASS**, 45 checks:
  every stub, bank, terrace, stone and floating island, all three
  checkpoints lit, through the gateway; 59 Resin on the main line.
- `mode=secrets`: **ALL PASS**, 32 checks: all four letters; all three
  chests; the first floating island out of reach from the road under it;
  the high path end to end and into bonus 1; its pillars crossed with 3.8 s
  to spare and the token won; back out beside the hollow and down onto the
  block; off the bank's edge to the old landing and into bonus 2; every bead
  gathered with 6.1 s to spare and the token won; back up the ledge catch
  onto the bank; the false wall fades while she is inside and closes when
  she leaves.
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

## Open for the review
- **The layout as a whole:** is hopping stones, then floating islands, the
  right second level, and is 440 tiles the right length for it?
- **The high path's tell:** only beads arcing up from the tower's top. Is
  that enough, or too plain?
- **The old landing:** it is only mildly hidden (beads step down off the
  edge). Hide it more, or keep it as the easy find?
- **The bonus areas** reuse 1-1's two kinds with new layouts. A third kind
  can wait for a later level.
- **Enemies:** a Mossback on the road, a rat on each great island. The
  roster's bat or toad could take a place here once they are built.
