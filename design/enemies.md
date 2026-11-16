# Enemies (the creative lead's roster)

The creative lead's enemy mockups replace my first proposal (the Thornhound,
a Blight-touched hound I drew as a stand-in): "I didn't like the enemy you
proposed I actually have enemy mockups". Source:
`docs/mockups/platformer/enemies/enemy_roster_02_with_bat.png` (original in
`art/source/enemies/`). `tools/make_enemies.py` cuts each creature to game
scale (8:1, the image's own palette, nothing redrawn) into
`game/assets/characters/roster/`. They are single poses until each gets an
animation sheet (Book 3); the game acts out a one-frame creature's moves by
squash, stretch and lean (`Lunger._pose`).

The palette is all purples, teals, mosses and bark: no red, as the colour
language asks.

## The roster

Working names (the creative lead names them), and the role each could play.
**Roles marked "proposed" are mine, for the creative lead to confirm.**

| # | Working name | Looks like | Role (proposed) | Region (proposed) |
|---|---|---|---|---|
| 1 | bat | A purple-winged bat, teal body, fangs | Flier: hangs, then swoops at her in an arc and rises away | 1 |
| 2 | hood_knife | A small teal hood, knife, glowing eye | Walker that stabs: the lunge, short and quick | 2 |
| 3 | skull_shaman | A skull-masked hood with a skull staff | Caster: keeps its distance and throws a slow curse orb (the Ward parries it back) | 2 |
| 4 | cap_crawler | A crawler under a mossy mushroom cap | Gentle grazer: ambles, shoves; its cap shrugs off blows from above | 1 (could replace Lost Keep's Mossback) |
| 5 | sack_thief | A hooded thief with a hook and a sack | Snatches beads of Resin and runs: catch it to get them back | 2 |
| 6 | spineback | A spiked shell on many legs | Spikes up: no landing on it; rolls at her along its floor | 3 |
| 7 | stone_golem | A stone golem with a great fist | Heavy: the sword rings off; a thrown crate or the Ironbark Ward's bash breaks it (Region 2 opens with the Ward) | 2 |
| 8 | moss_blob | A purple blob crowned with moss balls | Lurker: lies still as a mossy rock, then lunges up when she is near | 1 |
| 9 | spiked_toad | A teal toad with a spiked back | Hopper: leaps toward her in arcs, a shockwave where it lands | 1 |
| 10 | rat | A ragged rat with a bat-like cloak | **In 1-1 now:** the lunger (notices, winds up, lunges, flinches) | 1 |
| 11 | gourd_chomper | A gourd with a fanged mouth, a leaf cap | Rooted: snaps at her when she passes in front; a crate shuts it | 1 |
| 12 | chained_wraith | A ragged teal hood trailing chains | Floats through walls, slow and relentless, toward her | 4+ |

**Lore check:** the small hooded figures (2, 3, 5, 12) must never read as
Rootlings: Kleo never kills a Rootling. Proposed: they are cloth and bone
animated by the Blight (empty hoods, a glowing eye), not people.

## In the game now
- **The lunger** (`scripts/world/lunger.gd`, `_lunger` in
  `level_builder.gd`) takes any roster sprite; 1-1 and the systems arena use
  the rat. With an animation sheet (10 frames: walk 0-3, notice, wind-up,
  lunge, land, flinch, down) it plays the frames instead.
- **The Mossback** (Lost Keep's) still grazes in 1-1 until the roster's
  grazer is chosen.
