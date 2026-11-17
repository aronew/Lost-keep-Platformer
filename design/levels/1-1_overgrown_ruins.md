# 1-1 Lantern Refuge (bright day; letters and bonus areas in)

First called The Overgrown Ruins; renamed after the creative lead's region
map (2026-11). This file, the builder, the scene and the level's node keep
the old name.

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
- 440 × 40 tiles (7,040 × 640 px): about 11 screens long and 1.8 high (40
  rows so the view holds the water under the walking line). The room is 540
  wide: its two bonus areas lie beside the level (x 452–536), out of its
  view; the camera holds to the level (`MAIN`) unless she is in one.
- The walking line is row 30 (y 480) unless a beat lifts it; the canopy
  route runs at rows 14 to 16.
- Start at x 5. The arched doorway out is at x 428, on the end ledge (row 24).

## The four beats

| Beat | Tiles | What happens |
|---|---|---|
| **TEACH** | 0–94 | Stone terraces (2 up each) onto **the stall on arches** (a crate to carry, a pot), a **nook** under the arches (a pot, 3 beads), a **Mossback** (7 hits, or one thrown crate), **the water pit and the mushroom island** (two gaps of 4; **letter K** over the island), and **the chest on a high ledge** (a 5-tile ledge catch onto a ruin block). |
| **TEST** | 94–200 | Wall terraces (3 up, 3 up) to the plateau and **the first rat**, on flat ground with room to fight. **A fallen log** over a ravine. A gap of 4 up 2 to a ruin mass, then down its steps. The step's east face is **a false wall** (**letter L** in the hollow behind it). |
| **TWIST** | 200–340 | **The midway banner** (the level's one checkpoint). **A crate** (to throw at the rat). The hill's foot is **a false wall** (motes drift into it): a tunnel drops into **a hidden cave** under the hill, and at its end **a glowing hollow takes her to bonus 1** (gather 12 beads over raised ground in 12 s; the token appears over the last block). Up on the hill, **a root bank with a crate and a stack of two crates** on it: from the stack's top **the treetop route** is in reach (four treetops at different heights, 8 tiles over the hill so only the crates reach them; gaps of 4, beads all the way, **letter E** on the third; at its end **a hollow in the last crown takes her to bonus 2**: a course of four small pillars over a drop to the token, 10 s). On the hill, **the second rat**. Then **the islands at different heights** across the second water (2 up, 2 up, 3 down, 2 up, 3 down; gaps of 4). |
| **FINISH** | 340–440 | A Mossback, **a pit** (4), **a thorn bed** (a hit: it throws her back), a pit with a step up beyond it (**letter O** over it, on the jump), terraces up to the end ledge, **the last chest**, and **the arched doorway**. |

## Region 1 rules it keeps
- Widest required gap 4 tiles (a standing jump does it); smallest landing 3
  tiles; one enemy at a time; 3 checkpoints, each before the hard part.
- Every gap is 4; every rise is 2 or 3 (a standing jump), except the chest
  block's 5 (a ledge catch, taught on safe ground) and the bonus room's way
  out (a 4-tile catch).
- Floating and moving platforms: none here (moving platforms are 1-4's idea).
  Hardly any platforms (the creative lead, after DKC): height comes from
  terraces, a root bank and a stack of crates; the only things she stands on
  that aren't ground are the fallen log and the treetops. (A first version
  climbed four floating branches up the great tree; replaced.)

## Secrets and Resin
- **Letters (4):** K over the mushroom island and O over the last pit (on
  the main line's jumps), L behind the false wall, E on the treetops.
- **Bonus areas (2), a token each:** 1 "gather", through the hill's false
  wall and hidden cave; 2 "course", at the treetops' end.
- **Chests (2):** on the ruin block (8), by the doorway (8). **Caches:** the
  nook (3), the false wall's hollow (2), the hidden cave (3).
- **Bead trails** show every jump (arcs over each gap) and lead up the
  great tree: about 60 beads in all.
- **Tells:** motes drifting into both false walls; beads climbing the crates;
  a faint teal glow and motes at each bonus entrance.

## Validation (in engine)
`cd game` then:

```
xvfb-run -a godot --path . --fixed-fps 60 --audio-driver Dummy res://tests/playtest.tscn -- room=l1_1 mode=tour
```

- `mode=tour` (the main line, enemies held still): **ALL PASS**: every
  terrace, jump, ledge catch, gap and island, all three checkpoints lit,
  through the doorway; 43 Resin on the main line.
- `mode=secrets`: **ALL PASS**: all four letters (K and O on the main line's
  jumps, L behind the false wall, E on the treetops); both chests; the false
  wall fades while she is inside and closes when she leaves; through the
  hill's false wall into the hidden cave, over its blocks to the glowing
  hollow; bonus 1 gathered block to block in time and its token won; back
  out in the cave, over the blocks and up the 4-tile catch; the crates up to
  the treetops (and the treetops out of reach without them); bonus 2's
  pillars crossed with time to spare and its token won; back out on the
  last treetop, whose hollow, won, lets her by.
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
  root bank and crate stack on the hill; the treetop route on SF9's leaf band, whose top is flat, over
  twisted trunks with vines; lanterns in the bonus room; flowers on the
  islands.
- **FINISH:** a ruin by the pits, a lantern post up the terraces, and the
  arched doorway with its lantern as the level's end (the mockup's).
- **Stand-ins then** (all but Kleo's carry pose since replaced by the kit,
  below): the enemy, the chest, the cracked wall, the thorns, the HUD, the
  log.

**Book 3** (`docs/art-production/platformer-region1-prompt-book.html`,
published at https://claude.ai/artifact/7mMMdvZHpnai3CM4TWMLuK) asks for
all of it: W1 to W7 (ruin stone, the stall on arches cut to the collision,
the islands, the log and root bridge, treetops), T1 to T5
(chest, cracked wall, brambles, non-red mushrooms, HUD), C1 and C2 (a
first enemy, since replaced by the creative lead's roster; Kleo carrying), B1 and B2 (the far aqueduct, a sky with smaller
moons). Pilot: W1, W3, C1.

## The art pass, second: the creative lead's kit, water and foreground
- **The kit (Book 3) is in,** from the generator's raw sheets (the kit's
  script-normalized exports were set aside): the stall on its arches (W3,
  with exact pier collision), the five islands (W4; masses resized to the
  paintings, gaps kept at 4: the mushroom island is 5 wide, the stepping
  islands 4, 4, 4 and 3, and the second water now 35 wide), the fallen
  trunk (W5; the ravine narrowed to 9 tiles, the plateau grown to meet it),
  the treetops (W7: four walkways on three trees, 7, 8, 6 and 7 tiles), the
  chest, the cracked wall and its rubble, the brambles, the flora (violet and
  amber mushrooms), the HUD, the Triad sky and the far aqueduct.
- **Ruin stone** on every mass, its blocks fading with depth.
- **Water under everything,** two tiles below the walking line (WATER_Y
  512); the level is 40 rows tall so the view holds a band of it. The pits,
  the ravine and the gaps are this water. The hill (with the bonus cave)
  stands on the bed; its faces run down under the surface.
- **The foreground** is the creative lead's fern and stone bands.
- **The rat** (from the creative lead's roster) is the enemy that fights,
  twice: on the plateau and on the hill.
- Tour and secrets still ALL PASS; the camera shows no slide or wobble.

## Changed after the creative lead played it (2026-11)
"It still was playing" the old room from Play (fixed: Play opens 1-1), then:
"the game is super dark, I couldn't see the spikes so I had no idea why I
was dying, I think the cocoons to save people is dumb, the bonus areas are
dumb with the throwing the crates ... the grab animations isn't in it ...
the lighting in the game makes it almost impossible to see the creatures."
- **Bright day** (`_daylight()`): no dusk tint or vignette, a blue sky, the
  water and the masses lifted, a sky-light rim on the creatures and thorns.
  The bright-day kit (Book 4, after the six `bright_day/` mockups) replaces
  the dusk kit as it arrives.
- **Thorns** drawn across their whole bed, in front of the plants (they only
  drew two small ends at the bed's middle), and **a hit** that throws her
  back out, not a trip back to the checkpoint.
- **Kleo's carry frames** (the kit's C2): she lifts, holds, runs and throws
  with the crate in her hands.
- **Cocoons → letters K-L-E-O**; **the cracked-wall bonus room → two bonus
  areas** behind hidden entrances, each won for a token. The crate stays (one,
  to throw at the rat); the cracked wall is gone from 1-1.

## Changed after the research and the creative lead's notes (2026-11)
- **One checkpoint, at the middle** (the creative lead: "there should be a
  middle point where you get a checkpoint; I don't want lanterns"): the
  Guard's banner at x 196, where checkpoint 2 stood. Checkpoints 1 and 3 are
  gone. The four beats stand; they are no longer opened by checkpoints.
- **The great secret: Morvath's thorn knot,** asleep in the dark at the end
  of the hidden cave, behind bonus 1's glowing hollow (a secret within a
  secret). The hollow takes her to the bonus every time she walks in; only
  once the bonus is won does it let her by, to the knot.
- **Kleo's stride** (a second of unbroken running: faster, a longer jump)
  applies here as everywhere. No secret here is reached by it alone.
- The level opens from **the world map** and its end leads back there; the
  map shows its letters, tokens and knot, found or missing.
- Tour and secrets ALL PASS with these in (the secrets run wakes the knot).

## Open for the review
- The first art pass, in the game (`docs/levels/1-1/art_pass/`).
- The blockout review's questions (length, the canopy's tell, the bonus
  timer, a moving platform) were approved with the layout as built.
