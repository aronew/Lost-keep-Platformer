# 1-1 The Overgrown Ruins (blockout approved; first art pass in)

Builder: `game/tools/build_l1_1.gd` → `game/scenes/levels/l1_1_overgrown_ruins.tscn`.
Pictures: `docs/levels/1-1/blockout/` (the approved blockout: the poster and
in-game shots) and `docs/levels/1-1/art_pass/` (the first art pass: in-game
shots of every beat, and a poster of the dressing without the backdrops).

**Looks to match:** `docs/mockups/platformer/outdoor_level_1_mockup.webp` (the
stall on stone arches, the water pit and its mushroom island, the chest on a
high ledge, the arched doorway out, the aqueduct far off) and
`docs/mockups/platformer/natural_traversal/` (log and root bridges over
water, stepped stone terraces, crates, lanterns in tree hollows, islands at
different heights). **Feel to match:** Donkey Kong Country: land and wall
terraces, a secret route over the treetops, a crate thrown through a cracked
wall into a bonus game, and nothing out of place.

## Size and shape
- 440 × 36 tiles (7,040 × 576 px): about 11 screens long and 1.6 high.
- The walking line is row 30 (y 480) unless a beat lifts it; the canopy
  route runs at rows 14 to 16.
- Start at x 5. The arched doorway out is at x 428, on the end ledge (row 24).

## The four beats

| Beat | Tiles | What happens |
|---|---|---|
| **TEACH** | 0–94 | Stone terraces (2 up each) onto **the stall on arches** (a crate to carry, a pot), a **nook** under the arches (a pot, 3 beads), a **Mossback** (7 hits, or one thrown crate), **the water pit and the mushroom island** (two gaps of 4), and **the chest on a high ledge** (a 5-tile ledge catch onto a ruin block). |
| **TEST** | 94–200 | **Checkpoint 1.** Wall terraces (3 up, 3 up) to the plateau and **the first Thornhound**, on flat ground with room to fight. **A fallen log** over a ravine. A gap of 4 up 2 to a ruin mass, then down its steps. The step's east face is **a false wall** (cocoon 1). |
| **TWIST** | 200–340 | **Checkpoint 2. Two crates.** Carry one to the hill's foot and throw it at **the cracked wall**: a tunnel drops into **the bonus room** under the hill (gather 12 beads in 14 s → cocoon 2 and a spill of Resin). Or climb **the great tree's branches** to **the canopy route** over the hill (five treetops at different heights, gaps of 4, beads all the way, cocoon 3 at its end). On the hill, **the second Thornhound**. Then **the islands at different heights** across the second water (2 up, 2 up, 3 down, 2 up, 3 down; gaps of 4). |
| **FINISH** | 340–440 | **Checkpoint 3.** A Mossback, **a pit** (4), **a thorn bed**, a pit with a step up beyond it, terraces up to the end ledge, **the last chest**, and **the arched doorway**. |

## Region 1 rules it keeps
- Widest required gap 4 tiles (a standing jump does it); smallest landing 3
  tiles; one enemy at a time; 3 checkpoints, each before the hard part.
- Every gap is 4; every rise is 2 or 3 (a standing jump), except the chest
  block's 5 (a ledge catch, taught on safe ground) and the bonus room's way
  out (a 4-tile catch).
- Floating and moving platforms: none here (moving platforms are 1-4's idea).
  The branches and canopy are one-way timber, as in the mockups' logs.

## Secrets and Resin
- **Cocoons (3):** 1 behind the false wall (Wren, a Rootling baker), 2 the
  bonus room's prize (Oren, an Ironbark scout), 3 at the canopy's end
  (Ysolde, a Hearth-Plains weaver).
- **Chests (2):** on the ruin block (8), by the doorway (8). **Caches:** the
  nook (3), the false wall's hollow (2). **The bonus room:** 10 Resin.
- **Bead trails** show every jump (arcs over each gap) and lead up the
  great tree: about 60 beads in all.
- **Tells:** motes drifting into the false wall; beads climbing the tree; the
  cracked wall's pale, cracked stone.

## Validation (in engine)
`cd game` then:

```
xvfb-run -a godot --path . --fixed-fps 60 --audio-driver Dummy res://tests/playtest.tscn -- room=l1_1 mode=tour
```

- `mode=tour` (the main line, enemies held still): **ALL PASS**, 28 checks:
  every terrace, jump, ledge catch, gap and island, all three checkpoints
  lit, through the doorway; 37 Resin on the main line.
- `mode=secrets`: **ALL PASS**, 25 checks: both chests; the false wall fades
  while she is inside and closes when she leaves; a crate lifted, carried and
  thrown breaks the cracked wall; the bonus game won with about 8 s to spare;
  back out over the blocks and up the 4-tile catch; the branch ladder, the
  five canopy jumps; all 3 cocoons freed.
- `mode=shots` (in-game blockout pictures of each beat) and `mode=map`, then
  `python3 tools/stitch_map.py l1_1` and
  `python3 tools/level_poster.py l1_1` for the poster.

## Changed during the blockout
- The bonus room's two ledges were slabs two tiles over its floor: she bumped
  her head jumping onto them (the "never over it" rule). They are now stone
  blocks rising from the floor.
- The throw was too short and too high to reach a crack at floor level; it
  is now flat and fast (about 9 tiles), as in DKC.

## The art pass (first)
Approved by the creative lead ("Approved, start the art pass for 1-1").
`blockout = false` in the builder; `_dress()` places the Ironbark surface kit
(Book 1). Tour and secrets still ALL PASS after it; the camera shows no slide
or wobble.

- **Backdrops:** the purple dusk sky with the three moons (lowered so they
  sit whole on screen), the far forest, the teal mid forest; fog, light
  shafts, fireflies; the black plant band along the bottom.
- **Terrain:** Book 1's earth on every mass (the ruin stone W1, W2 will take
  the built ruins).
- **TEACH:** the arch she came through; the stall: the timber frame, barrels,
  a lantern post, lanterns hanging in both arches, moss drapes under the
  slab; ferns and grass; lilies and reeds round the water pit; flowers on the
  mushroom island (no red mushrooms: the kit's are red); a small ruined arch
  framing the chest on the ruin block.
- **TEST:** an arcade and a tracery ruin with its lantern on the plateau; a
  broken aqueduct arch spilling two falls into the ravine under the log;
  a ruined door on the ruin mass; ivy over the false wall's face (its tell,
  with the draught).
- **TWIST:** the Great Ironbark (with Morvath's closed-eye knots) behind the
  branch ladder; the canopy route on SF9's leaf band, whose top is flat, over
  twisted trunks with vines; lanterns in the bonus room; flowers on the
  islands.
- **FINISH:** a ruin by the pits, a lantern post up the terraces, and the
  arched doorway with its lantern as the level's end (the mockup's).
- **Stand-ins still:** the Thornhound, the chest, the cracked wall (SF11's
  pier stone with a drawn crack), the thorns, the HUD, Kleo's carry pose,
  the branch walkways (plank timber), the log (plank timber).

**Book 3** (`docs/art-production/platformer-region1-prompt-book.html`,
published at https://claude.ai/artifact/7mMMdvZHpnai3CM4TWMLuK) asks for
all of it: W1 to W7 (ruin stone, the stall on arches cut to the collision,
the islands, the log and root bridge, branch walkways, treetops), T1 to T5
(chest, cracked wall, brambles, non-red mushrooms, HUD), C1 and C2 (the
Thornhound, Kleo carrying), B1 and B2 (the far aqueduct, a sky with smaller
moons). Pilot: W1, W3, C1.

## Open for the review
- The first art pass, in the game (`docs/levels/1-1/art_pass/`).
- The blockout review's questions (length, the canopy's tell, the bonus
  timer, a moving platform) were approved with the layout as built.
