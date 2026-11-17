# Lost Keep: Platformer (working title)

A side-scrolling, **level-based action platformer** in **Godot 4.7.2**, in
premium pixel art. Mostly horizontal levels in the manner of Donkey Kong
Country: running, jumping, fighting, platforming, hazards and pits, with
secrets and Resin hidden along the way. Some levels climb (about 2 screens
wide and 4 to 5 high). Seven regions, each a biome, each a run of levels that
ends in a boss. It is **not a Metroidvania**: no interconnected map, no
backtracking, no ability-gated locks between levels.

The bar is top-tier, AAA presentation: the world must look natural, real and
lived in, and every animation must feel great, never generic.

It reuses the story, characters, art and engine of the creative lead's
earlier game, **Lost Keep** (GitHub `aronew/Lostkeep`, branch
`claude/world-designer`). **Lost Keep is read only:** copy from it, never
change it. In a cloud session it can be cloned beside this repo:
`GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 --branch claude/world-designer https://github.com/aronew/lostkeep /home/user/aronew/lostkeep`.

## Start here: where the project stands (2026-11)

**What we are doing.** Building region 1 level by level, to the methods of
Donkey Kong Country 1 to 3 and Super Mario. The creative lead asked for
those games to be studied and their methods put into this one; the study is
`design/research/platformer-fun.md` (sourced, with what each finding means
here), and its rules now live in `design/game-structure.md` §5. **Read the
research before designing or changing a level.**

**The loop, as it works today.** The game opens on **the world map**. Kleo
walks to a stop and enters a level; the level has four beats on one idea,
one **midway banner** (the only checkpoint), four **letters**, two **bonus
areas** (Resin rushes), and one **thorn knot** (the great secret). Its end
marks it done, saves, and returns to the map, which shows what is found and
what is missing in every level.

**State of each piece.**
| Piece | State |
|---|---|
| 1-1 The Overgrown Ruins | Playable, dressed in the dusk kit under daylight. Waiting for Book 4's bright-day art and the creative lead's play |
| 1-2 The Gate Road | A **blockout**, awaiting review. No art until it is approved |
| 1-3 to 1-5, 1-S, 1-B | Not started (stops on the map, dim) |
| World map, save file | Built, on the creative lead's painted region map ("Flooded Sanctuary") |
| Kleo's stride | Built; untuned by play |
| Stand-in sprites | Letters, token, thorn knot, banner (`tools/make_standins.py`) |

**What the creative lead has decided in review** (binding; details in
"Lessons" below): bright and readable; hardly any platforms; letters, not
cocoons; bonus areas are Resin rushes; **one checkpoint at the middle,
never a lantern**; blockout first, art last.

**The creative lead has played it** (2026-11, after the merge to `main`):
- **"1 checkpoint is perfect."** Decided: one, at the middle.
- **"The jumps were easy to do", and "region 1 should be easy."** Decided:
  region 1 keeps its easy jumps (gaps of 4 at most, landings of 3 or more).
- **"I was surprised that there was a boost in running"; "the boost is
  cool."** Decided: Kleo's stride stays. Levels are still designed for the
  plain jump; the stride is the skilled player's shortcut.
The knots' hiding places and the map's look have not been commented on.

**What to do next, in order.**
1. Take the creative lead's review of the 1-2 blockout and of this
   session's additions (the questions are at the end of
   `design/levels/1-2_gate_road.md`).
2. Give 1-2's twist the chain treatment its long pool got
   (`design/levels/ratings.md` says why).
3. When Book 4's sheets arrive: process, place, judge in the game (1-1).
4. 1-2's art pass once its layout is approved; then 1-3, blockout first.
5. Convert 1-1's two bonus areas to Resin rushes if the creative lead wants.

**Before anything runs:** install Godot 4.7.2 and import (see "Open items").
In a cloud session, the `lost-keep-platformer` environment does both at
start.

## Read before working

| File | What it holds |
|---|---|
| `design/game-structure.md` | **The game's structure:** regions, levels, bosses, abilities, how a level is laid out, checkpoints, Resin, the hub |
| `design/rooms/` | Specs of the three Lost Keep surface rooms that came over (IB-01, IB-03, IB-04), with their validation |
| `design/levels/` | One spec per level, with its validation (1-1; 1-2, a blockout) |
| `design/research/platformer-fun.md` | **The research:** what makes 2D platformers fun (DKC 1 to 3, Super Mario), sourced, with what each finding means here and which are built |
| `design/levels/ratings.md` | The levels' ratings board (×, △, ○, ◎) and the checklist every level is held to |
| `design/enemies.md` | The creative lead's enemy roster: names, proposed roles, what is in the game |
| `docs/mockups/platformer/bright_day/` | **The target look of region 1 now:** six bright daytime mockups (orange earth, grey ruin stone, green grass, great trees, clear water, blue sky) |
| `docs/mockups/platformer/outdoor_level_1_mockup.webp` | Level 1-1's first mockup (its layout; the look is now `bright_day/`) |
| `docs/mockups/platformer/natural_traversal/` | The creative lead's DKC-style traversal mockups: natural land, logs and roots over water, terraces, crates |
| `docs/mockups/platformer/flooded_ruins/` | Nine more level mockups: flooded ruins, stone pillars in water, ridge runs, climbs |
| `docs/mockups/platformer/enemies/` | The enemy roster (12 creatures) |
| `docs/mockups/ironbark_surface/` | The "Moonlit" mockups behind Lost Keep's surface look |
| `docs/art-production/*-prompt-book.html` | Copy-ready image prompts: Book 1 Ironbark and Book 2 Kleo (Lost Keep's, references in `lostkeep-attach/`), Book 3 the Ironbark Wilds (the dusk kit, delivered), **Book 4 Ironbark by Day** (region 1's bright-day kit, after `bright_day/`; references in `platformer-attach/`) |
| `art/source/ironbark/REVIEW.md` | The state of the generated Ironbark art |

The design docs are canon. If a decision changes, update the doc in the same
commit.

---

## The lore (carried over from Lost Keep)

### The world
- **Vaelora**, a world with **three moons**. Their alignment, the **Triad
  Eclipse**, frames its history.
- **The Sovereign Prism** is Vaelora's living crystalline heart and life
  source: the bond between its people and the natural order.

### The mythic past
- **The Oru'Vex**, radiant extradimensional architects, descended during a
  Triad Eclipse and raised the **Spire of the Sovereign Prism** around it.
- **The Schism of Light:** seeking perfection, they tried to burn away their
  flaws in the Prism's core. It fractured, and each of them was cleaved into
  two tethered beings: the rapacious, avian-mantis **Vexari** and the stoic,
  six-limbed **Orun**.
- **Morvath the World-Root**, the thorny, one-eyed embodiment of Vaelora's
  crust and stars, retreated to her **Observatory** and entrusted the world to
  the **Lirien**.

### The peoples
- **Lirien:** graceful, wing-cloaked mortals in **seven Kindreds**. All share
  one ancestry and the ability to **meld memories**. Their wings lie dormant
  (the Vexari's harvesting drains them).
- **Rootlings:** small, round, cheerful humanoids who farm, cook, sing and
  dance in close-knit villages; the most innocent people in Vaelora, which is
  why their harvesting must land as horror. **Kleo never kills a Rootling**,
  and a Rootling is never an enemy.
- **Vexari:** decaying lords who rule from the Spire as the revered
  "Shepherds of the Prism".
- **Orun:** the Vexari's tethered other halves; each Vexari is linked to one.

### The Seven Kindreds
| Kindred | People | Role |
|---|---|---|
| High-Spire | Aetheri | Scholars. Their **High Voice** leads all the Voices and is manipulated by the Vexari. Vesper's people |
| Ironbark | Vanguard | Martial guardians. **Kleo's people**; home of the Lost Keep |
| Deep-Glow | Lumen | Cave-dwellers who make their own light. Sora's people |
| Tide-Weaver | Nautil | Water folk |
| Fen-Stalker | Mire-Kin | Swamp hunters of the Thornveil forest, scorned as "primitive" |
| Hearth-Plains | Loam-Born | Farmers and silk-growers, neighbours of the Rootlings |
| Dusk-Drifter | Ash-Walker | Wanderers of the ash wastes, masters of fire |

Each Kindred is governed by a **Voice** (a Sovereign Matriarch); all answer
to the **High Voice**. **The Manufactured Divide:** the Vexari stoke pride and
prejudice between the Kindreds so they never unite or notice their villagers
vanishing. Kleo starts distrusted outside Ironbark.

### The crime: Anima and the Blight-Tide
1. **The Alchemist**, a Vexari, experimented on the Prism and discovered
   **essence extraction**.
2. The Vexari harvest **Anima** (pure resonant life-force) from captive Lirien
   and Rootlings in subterranean **vats** and consume it to stay young.
3. The abuse destabilises the Prism, and the **Blight-Tide** seeps out of it:
   plants twist, animals mutate, creatures are infected, Lirien included.
4. The Vexari try to **weaponise** the Blight; it threatens everyone, the
   Vexari too.
5. They build the **Carapax**, shell-forged automatons, to purge rebellion.

### The story
- People keep disappearing from the Ironbark Guard's post. Kleo goes looking.
- The missing are in **cocoons**, in **vats**, or turned by the Blight. Most
  can be **rescued**: each rescue sends someone to **the Refuge** (the hub),
  where they open a service and the Kindreds slowly learn to live together.
- **Sora** (Deep-Glow) and **Vesper** (High-Spire) are among the missing.
  Freeing Vesper triggers the forbidden **memory-meld**, **the Reveal**: the
  "Shepherds" are harvesters. The survivors rename the hub the
  **Memory-Meld Refuge** (it is just "the Refuge" until then).
- **The Lost Keep** is the Ironbark Guard's fortress: the first place lost,
  the last place taken back.

### Named characters and bosses
- **Kleo:** young Lirien of the Ironbark Guard, in **short chibi
  proportions**: a big rounded head about half her height, short legs, and
  plain solid dark vertical-rectangle eyes. Navy hair in a long high ponytail,
  a small brown leather jerkin with bronze fastenings, a teal neck accent and
  a gold collar clasp, a short dark cloak lined in red (her folded, dormant
  wings), a short silver sword in her right hand, and a brass lantern at her
  left hip. She casts **teal Anima magic**. Later she wears a wide-brimmed hat
  and long coat.
- **Sora, Vesper:** allies freed mid-game. **Morvath:** mentor, tests Kleo.
- **Bosses:** the Keep's fallen warden (an armoured giant on a throne;
  Ironbark), the Silk Mother (Hearth-Plains: their great silk-spinner,
  twisted by the Blight, who cocoons villagers to "protect" them; **never call
  her the Spider Matriarch**), the Cinder Warden (Dusk-Drifter), the Thornveil
  Reaper (Fen-Stalker: a skeleton fused into a tree, burning with stolen
  Anima), the Carapax Prototype (the Foundry), a Vexari Shepherd (the Spire),
  the Alchemist (the Anima Vats). Which region each ends is in
  `design/game-structure.md`.

### Colour language (canon, never break it)
| Thing | Colour |
|---|---|
| Sovereign Prism and its shards | Icy blue `#9FE6F5` / `#3A7FB0` |
| **The Blight** | Crimson tendrils `#8E1E3A` / `#C2385A` |
| Anima: Kleo's magic, life-force, vats | Teal `#3FE0C8` |
| Morvath's thorn knots | Pale bark `#B8A58A` with an amber-gold eye. **Never red** |
| Warm safety: lanterns, checkpoints, the Refuge | Amber `#F2B04A` |
| Void: the inside of every solid mass | `#0B0812` |

**Red is no longer reserved** (the creative lead dropped the rule, 2026-11):
banners and mushroom caps may be red, as in their mockups. The Blight keeps
its crimson tendrils; health stays amber lantern flames.

---

## Project layout

Lost Keep's folder layout is kept so its tools still work.

```
CLAUDE.md                 this file
design/                   game-structure.md (the plan), levels/ (level specs),
                          rooms/ (the carried-over rooms' specs)
docs/mockups/             the creative lead's mockups (platformer/ is this game's)
docs/art-production/      prompt books + reference images (lostkeep-attach/)
docs/rooms/               review images of the carried-over rooms
art/source/               the generator's sheets, unchanged (ironbark/, kleo/)
tools/                    Python: art processing, map and room checks
game/                     the Godot project
  project.godot           640x360, integer scale, GL Compatibility; autoload Game;
                          the main scene (Play) is the world map
  scripts/player/kleo.gd  Kleo's controller and tuning
  scripts/core/           game.gd (the Game autoload), camera_rig.gd
  scripts/fx/             dust, arcs, sparks, debris
  scripts/world/          room, room_exit, breakable, pickup, interactable,
                          secret_cover, lantern_light, mossback, moat_water,
                          terrain_skin, terrain_material, prism_shrine, stranger,
                          back_wall, guard_lift, practice_post, winch;
                          the platformer's systems: checkpoint, hazard_area,
                          lunger, chest, carriable (+ carry_handle),
                          cracked_wall, moving_platform, letter,
                          bonus_zone, bonus_door, bonus_token, level_end,
                          thorn_knot
  scripts/ui/             world_map.gd (the map: stops, records, travel)
  scenes/ui/              world_map.tscn (the game opens on it)
  shaders/                terrain fill, water, fog, glow, vignette, hit flash
  scenes/player/          kleo.tscn and her frames
  scenes/rooms/           the carried-over rooms (built by their builders)
  scenes/levels/          the levels and the systems arena (built by theirs;
                          don't hand-edit a scene you will rebuild)
  scenes/world/           the blockout tileset, terrain materials
  tools/                  room_builder.gd (shared base), surface_builder.gd,
                          level_builder.gd (the systems and the blockout look),
                          build_l1_1.gd (level 1-1), build_l1_2.gd (level 1-2's
                          blockout), build_systems.gd (the
                          systems arena), build_test_room.gd (IB-01),
                          build_ib03.gd, build_ib04.gd
  tests/                  playtest.gd/.tscn (scripted play + captures), framelog
  assets/                 characters (kleo, mossback, stranger, roster/),
                          items (resin, chest, letters, token), ui (flames,
                          letter icons), fx,
                          world (blockout tiles), environment/ironbark
```

**What came over from Lost Keep and what didn't.** Only the outdoor
(Ironbark surface) set: islands, `cliffs_and_ruins`, `surface_*`, `props_*`,
`landmark_*`, `parallax/`, the earth terrain, `ironbark_*`, and the
`fg_forest_*` bands. The crypt art (`ch_*`, `cy_*`, `sh_*`, `oc_*`,
`crypt_*`, `keep_*`, `fg_crypt_*`), the crypt rooms (IB-02, IB-05 to IB-09),
the lock-and-key registry, the world map tools and the Metroidvania design
docs stayed behind. **Exceptions the surface rooms need:** `sh_flora.png`
(the hanging ivy and roots under surface ceilings), `keep_timber_kit.png` (the
log and the lift's timber), `gate_bark_plate.png` and
`gate_silk_and_cocoon.png` (props in IB-01), the `stone_*` terrain (the
builder base loads it), and the scripts `back_wall`, `guard_lift`,
`practice_post` and `winch`. IB-01's hall door led to the crypts and now
leads nowhere. `room_builder.gd` still holds the crypt helpers (CY, SH, CH,
OC); they are unused here and their art is absent, so calling one fails.

The carried-over rooms are **IB-03, the Ruin Gardens**,
**IB-04, the Gate Road**, and **IB-01, the Lantern Clearing**, joined
IB-03 → IB-04 → IB-01. They stay as references and as the raw material of
the first levels until those are built.

---

## The systems (how play works)

All are tried in the **systems arena** (`scenes/levels/systems_arena.tscn`,
`room=sys mode=systems`: 26 checks) and placed by helpers in
`game/tools/level_builder.gd`.

- **Health is lantern flames** (`Game.health`, amber, top left; 3 to start).
  A hit costs one (`Kleo.hurt(dir, heavy, damage)`), then about a second of
  invulnerability. **A hazard** (`Kleo.hazard(kind)`: a pit, deep water)
  costs one and sends her back to the last checkpoint (`Game.respawn`).
  **Thorns are a hit**, not a hazard: a flame, and they throw her back out
  the way she came (`hazard_area.gd`; the creative lead "had no idea why I
  was dying" when they sent her back). **The last flame lost is a defeat**: she falls
  (`State.DOWN`, the death animation) and comes back at the checkpoint with
  her flames refilled. No lives, no game over. A fall below the level's
  bottom edge is a pit (`Room._physics_process`).
- **The checkpoint** (`checkpoint.gd`, `_checkpoint`): **one a level, at
  its middle, and not a lantern** (the creative lead: "there should be a
  middle point where you get a checkpoint; I don't want lanterns, they look
  bad"). It is a Guard's banner on a pole (`items/banner.png`, a stand-in):
  furled until she passes, then flying; it refills her flames and **banks
  her Resin**. Resin taken since the last checkpoint is at risk: a fall puts
  those beads back where they hung (`Pickup.restore`, `Game.take_resin`).
  The level's start counts as a checkpoint.
- **The lunger** (`lunger.gd`, `_lunger(x, floor, left, right, sprite)`):
  any creature from the creative lead's roster (`design/enemies.md`; 1-1 uses
  the rat). Patrols its stretch, notices her (stops, rears), stalks, winds up
  (crouch and shiver, 0.5 s), lunges (a heavy hit), lands in a skid open to a
  counter; struck, it flinches and its wind-up breaks. 4 sword hits (a
  finisher counts 2), or one thrown crate. It never leaves `[left_x,
  right_x]`. A one-frame roster sprite acts its moves out by squash, stretch
  and lean (`_pose`); a 10-frame sheet plays its frames. (My first
  "Thornhound" was replaced: the creative lead has their own enemies.) The
  Mossback still ambles and shoves (a flame per shove), then stops and turns
  away.
- **Chests** (`chest.gd`, `_chest`): strike one and it spills its Resin in an
  arc (`Pickup.launch`); beads bounce once and hang where they settle.
- **Carry and throw** (`carriable.gd`, `_crate`): interact lifts a crate
  overhead (`Kleo.held`; slower, lower jump, no ledge catch); attack throws
  it flat and fast (`throw_velocity`, about 9 tiles); down + attack sets it
  down. It smashes on what it meets and strikes what it hits
  (`"attack": "throw"`). Used crates come back when she respawns. Kleo's
  carry frames are the kit's C2 (`tools/make_kleo_carry.py` → `carry.png`;
  animations `carry_lift/idle/run/air/throw/set`); the crate rests where the
  kit's green guide box was in each frame (`Kleo.CARRY_REST`), behind her.
- **Cracked walls** (`cracked_wall.gd`, `_cracked_wall`): solid; the sword
  rings off; a thrown crate breaks them open. Not the way into bonus areas.
- **Bonus areas** (tokens open each region's secret level; bosses free the
  captives to the Refuge: `design/game-structure.md` §5) (`bonus_zone.gd` + `bonus_door.gd` + `bonus_token.gd`;
  `_bonus_zone`, `_bonus_door`): another zone beside the level, out of its
  view (the room is wider than the level; `Room.main_area` is the level and
  `Room.set_area` moves the camera's bounds and the pit edge to a zone while
  she is in it). Its hidden way in is a hollow glowing with Anima, found by
  exploring; walking in fades her there. "gather": beads light, a countdown
  (top centre), all of them brings out the token. "course": a run of jumps
  to the token. The token is the prize (`Game.take_token`); then back out
  beside the entrance. Out of time or a fall: no harm, back out, try again.
  Won stays won (the entrance says so). Two per level. **A Resin rush**
  (the creative lead's, 1-2's two): a gather with a ton of beads along the
  arcs of its jumps (`_arc_pts` in `build_l1_2.gd`); the countdown shows how
  many are left, and winning pays the Resin out (`Game.add_currency`).
- **Moving platforms** (`moving_platform.gd`, `_mover`): one-way timber on
  layer 7, eased in and out of each stop, pausing at the ends; optionally
  waiting for her to step on. Use only for something that really moves (a
  raft, a lift).
- **Stacked crates** (`_box_stack`): solid boxes, 2 tiles each, climbed like
  steps (DKC's raised ground); they can't be carried.
- **Letters** (`letter.gd`, `_letter`): K-L-E-O, as DKC's K-O-N-G, four per
  level; touching one takes it (`Game.take_letter`; the HUD's letters, top
  right); all four is a burst of Resin. (They replace the cocoons: the
  creative lead found rescuing from cocoons "dumb".)
- **The thorn knot** (`thorn_knot.gd`, `_knot`): each level's one great
  secret (DKC2's DK coin): one of Morvath's knots, asleep, hidden with more
  cunning than anything else; touching it wakes it for good
  (`Game.take_knot`; the HUD's icon, top right). 1-1: behind bonus 1's
  hollow, which lets her by only once the bonus is won. 1-2: on an island
  back west of the rampart's tower, the one time she must turn back.
- **Kleo's stride** (`kleo.gd`: `stride_after`, `stride_speed`): a second of
  unbroken running and she runs at 182 px/s (140 plain) and jumps 8.3 tiles
  (6.4 plain). It holds through jumps while she keeps moving; stopping,
  turning, a hit or a swing ends it. Length, never height. **Design every
  required gap for the plain jump**; the stride is the skilled player's
  shortcut. `room=l1_2 mode=stride` measures it.
- **The level's end** (`level_end.gd`, `_level_end`): she walks on through,
  the view dims, the tally shows (Resin, letters, tokens, the knot), the
  level is marked done and saved, and she is back on the world map
  (`Game.finish_level`).
- **The world map and the save** (`scripts/ui/world_map.gd`, `Game.LEVELS`):
  the game opens on **the creative lead's painted region map**
  (`art/source/maps/region1_flooded_sanctuary.png`, reduced to 640 x 360 by
  `tools/make_region_map.py` → `assets/ui/region1_map.png`). Its numbered
  pads are the stops: 1 to 5 are 1-1 to 1-5, 6 (the skull gate) is the boss
  1-B, "?" (the grotto) is the secret level 1-S, off the path from pad 3.
  Kleo travels pad to pad along the painting's dotted paths (`PADS`, `PATHS`
  in the script, in painting px): left and right on the main path, down from
  pad 3 to the grotto; jump enters; F4 opens every built stop for a review.
  A stop opens when the one it follows is done (`after` in `Game.LEVELS`,
  else the one before). The plate under the title counts the stops cleared;
  the bottom plate names her stop; over it is that level's record: letters,
  tokens, knot, found or missing. **The painting has two texts painted in**
  ("0/6 levels completed", "1 · Lantern Refuge"): the script covers those
  two plates and rewrites them. (Its first version also had a Kleo painted
  at pad 1; the creative lead sent a second without her, which is the one
  in use.) `Game.keeper()`
  names the flags that are saved (`user://save.json`): each level's done
  mark, letters, tokens and knot, plus the Resin. Everything else a level
  remembers is wiped by `Game.enter_level`. Esc leaves a level for the map.
  **A new level needs an entry in `Game.LEVELS`.** `room=map mode=map` tests
  it.
- **The art for the systems** comes from the creative lead's Book 3 kit
  (`tools/make_wilds.py`): the chest (3 frames), the HUD lanterns, the Resin
  drop (6 turning frames), the cracked wall and its rubble, the brambles,
  Kleo's carry frames. The letters, the token and the letter icons are
  stand-ins (`tools/make_standins.py`) until Book 4.

## How a level is built in Godot

Levels are built the way Lost Keep built rooms (the builders still say
"room"; a level is a long room, a Room with `is_level` set). A level's
builder extends `level_builder.gd` and calls `_level_begin(node, title)`,
its pieces, then `_level_finish()`.

**Daylight** (`daylight = true`, `_daylight()` in `level_builder.gd`): the
creative lead found the dusk pass "super dark", the creatures and thorns
impossible to see. A level is lit as bright day: no dusk tint, no vignette,
a blue sky (a gradient until Book 4's), the backdrops lifted and hazy, the
water's paint and the masses' depth lifted (`paint_tint`, the skin's
`void_color`), lanterns faint, and a rim of sky light along the tops of
everything that hurts (`hit_flash.gdshader`'s `rim`: creatures, thorns).
The dusk kit below is a stopgap under it until the bright-day kit (Book 4,
after `docs/mockups/platformer/bright_day/`) arrives. By day the stone
settles into the masses' deep plum (`DAY_DEPTH`) over `RUIN_FADE_DAY` (5)
tiles: the stopgap fill repeats too plainly to show deep ("all these
repetitive tiles on the wall look really weird"); Book 4's D3 is a real fill.
(A shader on the skin's bands darkened them, even one that changed nothing:
leave the skin's edges on the default material.)

**The look of a level (the art pass), after the creative lead's mockups:**
- **Ruin stone** everywhere (`_ruin_material()`: Book 3's W1 and W2 cut by
  `make_wilds.py` into `wilds/terrain/`): bands that fade into the dark at
  every edge, and blocks inside each mass that fade with depth over
  `RUIN_FADE` tiles (the mockups' masses are stone all through, not black).
  The fill is a stopgap course cut from the top band; Book 3 should ask for a
  proper fill.
- **Still water under everything** (`_water_foreground(surface_y, spans)`):
  one level-wide water two tiles under the main walking line, painted with
  the creative lead's water (`water_paint.png`) and lightly reflecting the
  world above; pits and gaps are this water. A mass that stands on the bed
  (1-1's hill) breaks the span, and its face runs on under the water
  (`_face_under_water`). Sunken stone, rubble and reeds under the surface
  (`_underwater`, tinted).
- **The foreground** (`_level_foreground()`): the creative lead's teal fern
  band and plum stone band along the bottom of the view, in their own
  colours, placed in the world (scroll 1.25 / 1.08), anchored so their feet
  sit on the screen's bottom when Kleo stands on `main_floor`, and kept under
  it. This replaces Lost Keep's single black band in the levels.
- **Backdrops:** the Triad sky with small moons (B2), the far aqueduct layer
  (B1, scroll 0.25), the far and mid forest.
- **Kit art is taken from the generator's raw sheets** (`art/source/wilds/`)
  and reduced by `process_art.py`'s method. The kit's own "native" exports
  were rebuilt and snapped to 40 colours by a script: not used (the process
  Lost Keep's review rejected).

**Blockout first:** with `blockout = true` (the default) a level shows its
black box (the skin off: `skin_visible = false`) on a flat pale sky, no
vignette, with the real or stand-in sprites of everything that acts, muted
backdrop shapes for what holds each piece up (`_backdrop_tree`), and labels
for each beat (`_label`). A false wall's cover is plain rock in a blockout.
Set `blockout = false` once the layout is approved, and dress it.

- **From a plan, in tiles** (a tile is 16 px; base resolution 640×360,
  integer-scaled): rock rectangles, spaces carved out, masses put back,
  materials, the skin's skip regions, props, lights, machines.
  `game/tools/room_builder.gd` is the shared base (the tileset, materials,
  back walls, terrain, and helpers `_door`, `_lift`, `_water`, `_breakable`,
  `_light`, `_fog`, `_edge_shades`, `_false_wall`, `_pickup`,
  `_resin_cache`, `_mossback`); `surface_builder.gd` adds the outdoor look
  (`_surface_begin` / `_surface_finish`: backdrops, moonlight, canopy;
  `_island`, `_flight` stairs, `_log`). Each level gets its own builder on
  top, holding its plan and dressing, and saves an ordinary scene:
  `godot --headless --path game --script res://tools/build_ib03.gd`.
  Re-running a builder overwrites the scene: make lasting changes in the plan.
  New PNGs need `godot --headless --path game --import` before a builder can
  load them.
- **The terrain:** two TileMapLayers are the collision (atlas column 0 earth,
  1 stone). `Solid` is the rock; `Masses` holds masses put back into spaces
  (islands, shelves), each painted as an object of its own. `TerrainSkin`
  paints bands along every exposed edge (tops, walls, undersides, corners).
  **The shadow rule:** a mass is the nearest thing to the camera, so it
  shadows to black (`#0B0812`) toward its centre and only its edges get art.
- **Painted islands** are `_island(kind, tile_x, row, tiles)` over a one-tile
  mass that is also in SKIP; the checker can't see non-tile collision, so list
  logs and island tiles under `seals` in `tools/check_room.py`.
- **One-way platforms** are on physics layer 7 (`one_way`); Kleo drops
  through with down + jump. Anything her sword can hit has an Area2D on layer
  3 whose parent has `take_hit(hit) -> bool`. Pots, barrels and crates are
  `Breakable` and drop Resin once.
- **Doors** (`_door`) make a marker where Kleo arrives and a `RoomExit` strip
  at the edge; walking in calls `Game.go_to`. What a level remembers goes in
  `Game.flags` (F5 clears them). There is no save file yet.
- **Secrets:** a false wall (`_false_wall`, `secret_cover.gd`) has no
  collision; it **fades while Kleo is inside and closes again when she
  leaves**. From outside, the level's stone runs on unbroken. Always give it a
  tell (`_draught`: motes drifting into the stone; moss) and a reward.
- **Resin** (`_pickup`, `_resin_cache`): beads that hang and bob, drift to
  Kleo when near, and add to `Game.currency` (the counter at top left).
- **The camera** (`camera_rig.gd`) **never moves on its own, never runs
  ahead of Kleo, and ignores jumps**: a small window she moves in, no
  look-ahead, a fixed height that ignores jumps, an eased approach to the
  level's edges, whole-pixel physics-tick updates.
  `python3 tools/camera_report.py <camera.csv>`: keep `slide` and `wobble` at
  0, `edge brake` above 50 px.
- **Hit-stop** (`Game.hitstop`) ends on the real clock, checked every frame,
  capped at 0.12 s. Never end a time-scale change from a timer.
- **Parallax:** `Parallax2D` sky 0.05, far 0.15, mid 0.35, ruins 0.72,
  playfield 1.0; `CanvasModulate`, `PointLight2D` lanterns, fog, vignette.
- **The foreground is ONE black silhouette band** along the bottom of the view
  (plants and bushes outdoors: the `fg_forest_bottom_a/b` bands),
  `_fg_bands()` in `room_builder.gd`: placed in the world, scrolling a little
  faster than the level (1.25 sideways, 1.08 up and down), kept under every
  floor (`FG_FEET`) so it never hides the floor Kleo walks on.
- **Lights** don't light the fog, haze or backdrops (light mask 2,
  `LIGHT_MASK_AIR`); falloff is smooth (`_soft_light_texture()`), glows are
  dithered additive discs (`shaders/glow.gdshader`, `_warm_glow()`).
- **Debug keys:** F1 black-box view, F2 overlay, F3 slow motion, F5 restart,
  H a heavy hit. **Controls:** move A/D or arrows; jump Space/Z/K; attack left
  click or X/J; interact E/C or up; spell right click or V/L (reserved).

### Kleo's movement envelope (measured; design every gap against it)
| Move | Measured | Design rule |
|---|---|---|
| Standing jump (held) | 54 px = **3.37 tiles** | Clears a 3-tile mass, never a 4 |
| Tapped jump | 10 px = 0.65 tiles | |
| Running jump | 100 px = **6.27 tiles** | Gaps up to 5 for the cautious player; 7+ can't be crossed |
| Ledge catch | up to 84 px = **5.25 tiles** above the floor | 4–5 tile walls need a ledge catch |
| Run speed | 140 px/s = 8.75 tiles/s | |
| Hard landing | falls over 120 px (7.5 tiles) | |
| Body | 28 px tall; collision 10 × 26 px | |

A small island over water where the jump is the lesson: about 56 px of gap
and 48 px to land on (a standing-run-up jump is about 95 px long). **Every gap
meant for dropping through is 2 tiles wide** (she runs straight over one).
**Small ledges stand beside what they lead to, never over it** (she bumps her
head).

---

## Branches
Work happens on feature branches (Claude's: `claude/...`); the creative lead
merges finished work into `main`, which holds the current game. The current
working branch is `claude/region-1-levels` (from `main`, 2026-11; the first
branch, `claude/platformer-game-setup-oatrq2`, is merged and finished).

## How to test (use a virtual display in the cloud)

```
cd game
xvfb-run -a godot --path . --fixed-fps 60 --audio-driver Dummy res://tests/playtest.tscn -- room=ib03 mode=tour
```

- Levels: `l1_1` and `l1_2` (`mode=tour`: the main line; `mode=secrets`:
  every secret, letter, bonus area and chest; `shots`; `map`) and `sys`, the systems arena
  (`mode=systems`; run it with `--max-fps 60` too). Rooms: `ib01`
  (default), `ib03`, `ib04`. Output: `game/tests/out/<room>/<mode>/`.
- **Pictures for a blockout review:** `mode=shots` (one in-game shot per
  beat), then `mode=map`, `python3 tools/stitch_map.py l1_1` and
  `python3 tools/level_poster.py l1_1` (the whole level folded into four
  strips, with the walked routes: amber the main line, teal the secrets;
  `room_art` instead of `room_routes` previews the earth skin on it). Copy
  the ones to show into `docs/levels/<level>/`.
- `mode=tour` (the main line, scripted), `upper` (optional lines, ways back),
  `doors`, `enemy` (the Mossback), `shots` (screenshots, art and black box),
  `map` (the whole level), `measure` (Kleo's numbers), `edge`, `click`,
  `props` and `hitstop`.
- Run `props`, `hitstop` and `enemy` **without** `--fixed-fps` (use
  `--max-fps 60`): timing bugs only show with real frame times.
- Then `python3 tools/stitch_map.py ib03` (map images and walked routes),
  `python3 tools/check_room.py ib03` (floors, steps, mass thickness, exits,
  coverage, traps) and `python3 tools/blockout_map.py ib03` (a labelled
  black-box map for blockout reviews).
- The map and save: `room=map mode=map`. Kleo's stride: `room=l1_2
  mode=stride`.
- A new level needs an entry in `Game.LEVELS`, in `ROOMS` in `game/tests/playtest.gd` and
  `tools/check_room.py`, its scripted lines, and its routes in
  `stitch_map.py`.
- After any change to shared code (the builder, Kleo, the camera, `Game`),
  run every level's tour again: all must keep passing.

## Art pipeline
1. **Prompt books:** `docs/art-production/*-prompt-book.html`, references in
   `docs/art-production/lostkeep-attach/` (A to Z and beyond) and
   `platformer-attach/` (M mockups, N traversal mockups, G game shots, K
   kit sheets). **Book 3** (`platformer-region1-prompt-book.html`) is built
   from `docs/art-production/src/` (`book3_body.html`, `book3_cards.js`)
   with Book 1's stylesheet: edit those and reassemble (the Python in the
   commit that made it: Book 1's head up to `</style>`, the body, the
   script). Published at https://claude.ai/artifact/7mMMdvZHpnai3CM4TWMLuK:
   republish from the assembled file with its `platformer-attach/` and the
   three `lostkeep-attach/` images it uses (A, B, Z). **Book 4**
   (`platformer-region1-day-prompt-book.html`, the bright-day kit) is built
   the same way from `src/book4_body.html` and `src/book4_cards.js`;
   published at https://claude.ai/artifact/9pZX52xTvGUX47A4TX8Epd with
   `platformer-attach/` D1 to D6 (the mockups) and G8.
2. **The creative lead generates sheets.** Unchanged originals go in
   `art/source/<region>/`.
3. **Processing:** reduce to true pixel scale only. `tools/process_art.py`
   (sheets), `tools/process_sprites.py art/source/kleo
   game/assets/characters/kleo` (Kleo's 64 × 64 frame strips, anchor x 32,
   y 56), `tools/make_fg_bands.py` (the foreground bands, 3:1),
   `tools/make_terrain.py` (terrain bands, min-error seams, never a dithered
   crossfade). Generator IDs: S1–S5 are L1–L5, D1–D4 PR1–PR4, G1–G4 GT1–GT4.
4. **Take art exactly as the generator made it.** Never rebuild it or
   colour-snap it with another tool (a rebuilt, hex-snapped export was
   rejected in Lost Keep).
5. **Judge art in the game,** not on its own.

---

## Lessons from the creative lead's reviews (binding)

- **Top-tier, AAA presentation.** Natural, real, lived in; every animation
  feels great, never generic.
- **Blockout first, art last.** Get one level approved before repeating a
  method. Show black-box pictures (`blockout_map.py`) for blockout reviews:
  the in-game box view is too dark to read in a picture.
- **Floors and walking lines are flat and straight.** Ceilings, undersides and
  mass edges must NOT be straight blocks: give them breaks, hanging wedges,
  moss and roots.
- **Foreground: ONE black silhouette band** along the bottom of the view
  (plants and bushes outdoors), placed in the world, scrolling a little faster
  than the level. Not many stacked layers, never small scattered pieces, never
  pieces pinned to the screen, never pixel art blown up 2x or more (mismatched
  pixels look wrong). It must never hide the floor Kleo walks on. Big black
  shapes read as holes.
- **Lights** light the level, not the fog or backdrops (amber light on teal
  fog makes ugly green discs). Glows fade smoothly, never in rings, and are
  never painted into the art.
- **Take art exactly as the generator made it**; judge it in the game.
- **Secrets:** a false wall fades while Kleo is inside and closes again when
  she leaves.
- **The camera** never moves on its own, never runs ahead of Kleo, and
  ignores jumps.
- **Colour:** the Prism is icy blue, Anima is teal, warm safety is amber.
  (Red is no longer reserved for the Blight: the creative lead dropped it.)
- **Bright and readable** (the creative lead, on the dusk art pass): the
  game must look like the mockups, bright and fun, never "super dark". Every
  hazard and creature must be seen at a glance: if Kleo is hurt, the player
  must know by what. Later regions may go darker ("we can go from a brighter
  setting to a darker setting in later regions"), but stay readable.
- **No visibly repeating texture** across a mass: a fill must be a real,
  varied tile.
- **Floating islands on a path sit at different heights** so a run doesn't
  feel straight; vary heights around the big pieces rather than swapping them
  for small ones.
- **Hardly any platforms** (the creative lead, after Donkey Kong Country).
  Height comes from the environment: raised ground, wall terraces, stacked
  crates (`_box_stack`), stone pillars and islands in water, big floating
  islands. Anything else she stands on is something real (a fallen log, a
  root bridge, a treetop, a raft). Never a ladder of floating planks.
- **Floating platforms are painted pieces, never floor tiles.**
- **No straight seams or hard light/dark lines inside a mass:** stone fades
  into the dark gradually.

- **From the research** (`design/research/platformer-fun.md`; the rules are
  in `design/game-structure.md` §5; the levels' marks in
  `design/levels/ratings.md`): one idea a level in four beats; **inside a
  beat a chain, no two challenges in a row the same**, with one rest;
  **Resin never lies** (a bead over a drop means ground below) and some of
  it is a dare; every secret has a tell and a level's tells differ; one
  great secret a level; the map keeps score.
- **One checkpoint a level, at the middle, never a lantern** (the creative
  lead): a banner for now.
- **Bonus areas are Resin rushes** (the creative lead): a ton of Resin along
  the jumps; all of it wins the token.

## Open items
- **Level 1-1: lit as bright day, letters and two bonus areas in, awaiting
  the creative lead's play** (`design/levels/1-1_overgrown_ruins.md`,
  pictures in `docs/levels/1-1/art_pass/`). Its art is still Book 3's dusk
  kit under daylight; **Book 4** (`platformer-region1-day-prompt-book.html`)
  asks for the bright-day kit after the six `bright_day/` mockups. As its
  sheets arrive: process them, place them, judge in the game.
- **Level 1-2, The Gate Road: a blockout, awaiting the creative lead's
  review** (`design/levels/1-2_gate_road.md`, pictures in
  `docs/levels/1-2/blockout/`): hopping over water, stone islands then the
  big floating islands. No art until the layout is approved. It opens on
  the map once 1-1 is done (F4 on the map opens it at once).
- Godot isn't in the cloud image: a session installs 4.7.2 from the
  engine's GitHub release (`Godot_v4.7.2-stable_linux.x86_64.zip`) and runs
  `godot --headless --path game --import` once before anything else.
- In the art pass: `_tint_surface_kit` skips sprites with the `no_tint` meta
  (SF9's leaves and trunks keep their greens); a level lowers the sky to
  y -50 so the moons sit whole; the full-level map leaves out the parallax
  layers, so judge the look in `mode=shots`.
- **The region map, awaiting the creative lead's word:** the region's name (the map says "Flooded
  Sanctuary", the design docs "The Ironbark Wilds") and level 1's (the map
  says "Lantern Refuge", the docs "The Overgrown Ruins"): the game shows the
  docs' level names for now; the map's dusk look against region 1's
  bright-day look; and that the map draws the secret's path from pad 3 (the
  docs hide its exit in 1-4 or 1-5).
- **Awaiting the creative lead's word:** the thorn knots' hiding places and
  the banner stand-in. What waking every knot does is undecided.
- 1-1's two bonus areas are still the old kinds (12 beads; a course), not
  Resin rushes.
