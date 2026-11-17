# Lost Keep: Platformer (working title)

A side-scrolling, **level-based action platformer** in **Godot 4.7.2**, in
premium pixel art. Mostly horizontal levels in the manner of Donkey Kong
Country: running, jumping, fighting, platforming, hazards and pits, with
secrets and Resin hidden along the way. Some levels climb (about 2 screens
wide and 4 to 5 high). Seven regions, each a biome: **six regular levels, a
bonus level, and a boss as its last level** (the creative lead, 2026-11; it
was five). It is **not a Metroidvania**: no interconnected map, no
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

**The rulebook** (`design/rulebook.md`, asked for by the creative lead:
"TRIPLE A TOP TIER in every way"): the game loop, the economy, the golden
rules of movement and combat, how levels and secrets are built, how a boss
is staged, the six-level template, and **an audit of the game against all
of it**. Every rule has a code (M, E, P, K, C, T, R, A, S, B); level specs
cite them. Its §4.3 is the checklist a level must pass before it is shown.
**Read it before designing a level, a creature or a boss.**

**Region 2 has begun.** `design/regions/2_hearth_plains.md` plans its eight
stops; **2-2 Millers' Row** is built as a blockout (windmills whose cradles
she rides; bells and wind vanes as the puzzles).

**The loop, as it works today.** The game opens on **the world map**. Kleo
walks to a stop and enters a level; the level has four beats on one idea,
one **midway banner** (the only checkpoint), four **letters**, two **bonus
areas** (Resin rushes), and one **thorn knot** (the great secret). Its end
marks it done, saves, and returns to the map, which shows what is found and
what is missing in every level.

**State of each piece.**
| Piece | State |
|---|---|
| 1-1 Lantern Refuge (first called The Overgrown Ruins; files and node keep that name) | Playable, dressed in the Sunlit Woodland day kit (Book 4, delivered; see "The day kit" below) |
| 1-2 The Gate Road | First art pass in the Flooded Sanctuary kit (Book 5; see "The sanctuary kit" below). Its layout predates the mockups' shapes |
| 1-3 The Ruin Gardens | A **blockout**, awaiting review: the vertical level, three legs up the hill; hides the secret exit |
| 1-4 The Aqueduct | A **blockout**, awaiting review: rafts and lifts that all run on their own (timed jumps and steps) |
| 1-5 The Lantern Clearing | A **blockout**, awaiting review: the gauntlet |
| 1-S The Hollow Oak | A **blockout**, awaiting review: the secret level, a harder climb. Its extra-flame reward isn't built |
| 1-B The Keep Gate | A **blockout** of the approach and the arena. **The boss is not built** (no design, art or code): the arena is empty and the way out open |
| Region 1's sixth level | Not planned yet: the six-level template (`design/rulebook.md` §4.1) asks for a remix level between 1-4 and 1-5 |
| 2-2 Millers' Row | A **blockout**, awaiting review: 14 mills, three puzzles, both tours pass |
| 2-1, 2-3 to 2-6, 2-?, 2-B | Planned (`design/regions/2_hearth_plains.md`); not started |
| The rulebook | Written; its proposals await the creative lead (wicks, the bonus level's two doors, the stride cut) |
| World map, save file | Built, on the creative lead's painted region map ("Flooded Sanctuary") |
| Kleo's stride | Built; untuned by play |
| Stand-in sprites | Thorn knot, the blockout banner, the power-up pickup (`tools/make_standins.py`); letters, token and HUD icons come from the day kit |

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
- **"They shouldn't wait, they should be moving back and forth ... you need
  to time jumps properly"; "make the lifts move on their own too."**
  Decided: rafts and lifts all run on their own (1-4, 1-5).
- **"Use the map names and follow the map."** Decided: region 1 is
  **Flooded Sanctuary** and level 1-1 is **Lantern Refuge**, as the creative
  lead's region map has them; and the secret level is reached off pad 3, so
  region 1's hidden exit goes in 1-3.
The knots' hiding places have not been commented on.

**What to do next, in order.**
0. Take the creative lead's word on **the rulebook's proposals and audit**
   (`design/rulebook.md` §5: the order I would fix things in), on **region
   2's plan**, and on **the 2-2 blockout** (questions at the end of
   `design/levels/2-2_millers_row.md`). The audit's first finding is the
   one that changes levels: **a swing ends her stride** (the stride cut).
1. Take the creative lead's review of the six blockouts (1-2 to 1-5, 1-S,
   1-B): each spec in `design/levels/` ends with its open questions, and
   `design/levels/ratings.md` says what would raise each. **None has been
   played by a person:** the scripted tests prove the jumps, not the fun.
2. The boss: the Keep's fallen warden needs a design from the creative lead
   (attacks, how he is hurt, phases) and art before 1-B is more than a room.
3. Decide which look 1-3 onward take (day kit or sanctuary kit), then art
   passes a level at a time as each layout is approved.
4. Small things owed: 1-2's twist wants the chain treatment its long pool
   got; 1-1's two bonus areas are still the old kinds; the secret level's
   extra flame isn't built.

**Before anything runs:** install Godot 4.7.2 and import (see "Open items").
In a cloud session, the `lost-keep-platformer` environment does both at
start.

## Read before working

| File | What it holds |
|---|---|
| `design/rulebook.md` | **The rulebook:** the macro loop and economy, the golden rules of movement and combat (with Kleo's measured frame data), telegraphs and fairness, reading the screen, level architecture, the psychology of secrets, boss staging, the six-level template and its checklists, and **the audit** |
| `design/regions/` | One plan per region (region 2, the Hearth-Plains: eight stops, where each idea came from, what must be built) |
| `design/game-structure.md` | **The game's structure:** regions, levels, bosses, abilities, how a level is laid out, checkpoints, Resin, the hub |
| `design/rooms/` | Specs of the three Lost Keep surface rooms that came over (IB-01, IB-03, IB-04), with their validation |
| `design/levels/` | One spec per level, with its validation and its open questions (1-1 dressed; 1-2 to 1-5, 1-S, 1-B and 2-2 blockouts) |
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
  scripts/core/           game.gd (the Game autoload), sfx.gd (the Sfx autoload:
                          sounds), camera_rig.gd
  scripts/fx/             dust, arcs, sparks, debris
  scripts/world/          room, room_exit, breakable, pickup, interactable,
                          secret_cover, lantern_light, mossback, moat_water,
                          terrain_skin, terrain_material, prism_shrine, stranger,
                          back_wall, guard_lift, practice_post, winch;
                          the platformer's systems: checkpoint, hazard_area,
                          lunger, chest, carriable (+ carry_handle),
                          cracked_wall, moving_platform, letter,
                          bonus_zone, bonus_door, bonus_token, level_end,
                          thorn_knot; region 2's: windmill, mill_bell
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
                          blockout), build_l1_3.gd, build_l1_4.gd,
                          build_l1_5.gd, build_l1_s.gd, build_l1_b.gd (the
                          other blockouts, planned from pieces),
                          build_l2_2.gd (level 2-2's blockout),
                          build_systems.gd (the
                          systems arena), build_test_room.gd (IB-01),
                          build_ib03.gd, build_ib04.gd
  tests/                  playtest.gd/.tscn (scripted play + captures), framelog,
                          checks.gd/.tscn (sounds, pause, getting up after a blow)
  assets/                 audio (sfx/, voice/: see "Sound"),
                          characters (kleo, mossback, stranger, roster/),
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
- **A heavy blow** (a lunge, thorns: the knockback) no longer holds her for
  its whole 0.8 s get-up: from the slide on (`KNOCK_GET_UP`), moving or
  jumping gets her up; and whenever she has her feet back she is safe for
  `safe_after_hit` (0.6 s) more. Before, she was safe for 0.09 s after
  regaining control. `tests/checks.tscn` measures it.
- **Sound** (`scripts/core/sfx.gd`, autoload `Sfx`: `Sfx.play("jump")`,
  `Sfx.resin()`): the creative lead's sound effects from their MetroidVania
  project (`aronew/MetroidVania`, `game/assets/audio`: **only the `.ogg`
  files came over**, 118 effects and 8 voice clips, made with ElevenLabs).
  `CUES` in `sfx.gd` maps each of this game's events to one of that set's
  sounds: random takes, never the same twice running, a little pitch drift;
  Resin climbs in pitch bead after bead. **The cues were chosen by name, not
  by ear** (a cloud session can't listen): judge them in the game and change
  the table. Not there yet: music, ambience, water, UI sounds.
  **Kleo's voice** (`Sfx.voice`, the `VOICE` table): the set's wordless
  shouts, which the creative lead says are not gender-specific (measured
  pitch about 300 to 470 Hz). A "hut" on about half her light swings,
  always on the third and the finisher, sometimes on a ledge climb and a
  throw; one throat, so a new shout cuts off the last. `vo_resonant` (a
  spell's shout) waits for her spells.
- **Pause** (`game.gd`): Esc, P or Start pauses a level: Resume, or Back to
  the map, which asks once more. (Esc used to leave the level at once.) The
  press that closes the menu is not also a jump (`Game.just_resumed`).
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
- **Power-ups** (`power_up.gd`, `_power_up(pos, kind)`; `Game.power`,
  `Game.set_power`): as Mario's (the creative lead's choice over permanent
  abilities): found in a level, one held at a time (its icon by the Resin
  count), and **a hit costs the power instead of a flame** (`Kleo.hurt`); a
  defeat loses it; it returns where it hung on a respawn. Built: **the
  Anima Spark** (`anima_bolt.gd`): the spell button (V, L, right click)
  looses a teal bolt that strikes what a sword strikes. One hangs before
  1-1's first rat. Its pickup art is a stand-in. The other kinds and what
  each boss unlocks: `design/game-structure.md` §4.
- **The thorn knot** (`thorn_knot.gd`, `_knot`): each level's one great
  secret (DKC2's DK coin): one of Morvath's knots, asleep, hidden with more
  cunning than anything else; touching it wakes it for good
  (`Game.take_knot`; the HUD's icon, top right). (1-3 to 1-S: their specs.) 1-1: behind bonus 1's
  hollow, which lets her by only once the bonus is won. 1-2: on an island
  back west of the rampart's tower, the one time she must turn back.
- **Kleo's stride** (`kleo.gd`: `stride_after`, `stride_speed`): a second of
  unbroken running and she runs at 182 px/s (140 plain) and jumps 8.3 tiles
  (6.4 plain). It holds through jumps while she keeps moving; stopping,
  turning, a hit or a swing ends it. Length, never height. **Design every
  required gap for the plain jump**; the stride is the skilled player's
  shortcut. `room=l1_2 mode=stride` measures it.
- **Windmills** (`windmill.gd`, `_windmill(centre, radius, arms, period,
  turn, start_deg, cradle_w, running)`; region 2's machine): the sails
  turn and a hoist cradle hangs from each arm's tip, level as a Ferris
  wheel's. Each cradle is a one-way `AnimatableBody2D` on layer 7 whose top
  travels a circle of `radius` round the node; `turn` 1 is clockwise on
  screen (the top moves right). She rides them: up and over, or down and
  under. **A mill is a loop**: staying on brings her round again, so a
  missed landing costs seconds, never a flame. It eases into every change
  (`spin_time`). A faint ring marks the cradles' path. `_mill_tower` draws
  its tower in the blockout's backdrop. **Geometry to keep:** a cradle 3
  tiles wide wants its centre on a half tile, 2 wide on a whole tile, so
  its ends meet the grid at 3 and 9 o'clock; leave 2 tiles of air above the
  whole circle and no solid tile inside its bounds (a rider is pushed off
  by anything solid, and squeezed by anything above a rising cradle); a
  one-way branch may hang over a mill's top (she jumps up through it).
  Mills of one `period` and four arms hand her on with no waiting
  (rulebook A14).
- **Bells and wind vanes** (`mill_bell.gd`, `_mill_bell(pos, mills, kind)`):
  struck by the sword or a thrown crate (layer 3, `take_hit`). **A bell
  wakes** a sleeping mill (`Windmill.wake`; `running = false` builds one
  asleep, its sails furled). **A vane turns** its mill the other way
  (`Windmill.reverse`); its arrow shows which way the top moves. One
  meaning each, everywhere. A dotted rope runs from each to its mill, and
  one strike makes one change (0.9 s before the next).
- **A crate that comes back** (`Carriable.returns`, seconds): for a crate a
  puzzle needs. **A wide thicket** throws her one way
  (`HazardArea.push_dir`), so a hit never knocks her deeper in.
- **A pair takes turns** (`Lunger._may_wind_up`, rulebook T8): only one
  lunger near her winds up or strikes at a time; the other waits 0.4 s
  after the first has landed. Every new creature must take the same turn.
- **A jump from a rising platform keeps its lift**; from a falling one it
  is never weaker (`kleo.gd`: `platform_on_leave`, upward only; rulebook
  K4).
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
  else the one before); the grotto also `needs` the flag `l13_secret_exit`,
  set by leaving 1-3 through its secret exit (`_level_end(..., secret_flag)`). The plate under the title counts the stops cleared;
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
  it. **Each region has a page** (`region` in `Game.LEVELS`, 1 unless
  given): region 1's is the painting; **region 2's is a stand-in drawn in
  the script** (`R2_PADS`, `_draw_plains`) until the creative lead paints
  one. **Tab turns the page; F4 opens every built stop** and stays on while
  the game runs. To play 2-2: F4, Tab, jump.
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

**A level planned from pieces** (1-3 onward; `level_builder.gd`):
`plan_leg(edge, row, dir, pieces, kind)` takes a list of pieces, each
`[gap, width, rise]` (tiles): the next thing she stands on. It makes the
collision (before `_level_begin`) **and** the moves of the scripted tour
from the same list, so the two can't disagree: no gap is a step beside her
(3 up at most), a gap is a hop (4 across and 2 up at most in region 1).
Kinds: `solid` (ground, the gap a sunken bed), `stone` (an island in water),
`float` / `float2` (a floating island 3 or 2 thick), `none` (ground already
there). `_place_arcs` hangs beads over every hop. `plan_rush` /
`_place_rush` do the same for a Resin rush bonus area (pillars or blocks).
The builder fills `tour`, `extras` (the secrets' moves) and `shots`; they
are saved on the scene as metadata, and `playtest.gd`'s `_run_moves` plays
them (`rise`, `hop`, `off`, `walk`, `jump`, `ride` a mover, `place`,
`into_zone`, `zone_clear`, `token`, `letter`, `knot`, `chest`, `interact`,
`held`, `cracked`, `floor`, `banner`, `end`). A new level built this way
needs no test code of its own: `room=<id> mode=tour` and `mode=secrets`
just work once it is in `ROOMS`.

**A vertical level** (1-3, 1-S) climbs in legs that zigzag; **no leg may
hang less than 6 rows over a spot she jumps from on the leg below** (a full
jump needs 82 px), and the first piece after a turn is `float2`. A fall
lands her on the leg below: no pits.

**Movers** (1-4, 1-5). **Rafts run back and forth on their own** (the
creative lead: "they shouldn't wait, they should be moving back and forth
... you need to time jumps properly"): `_raft(x, row, run, speed)` in those
builders, no `wait_for_rider`, a 1 s rest at each end, level with the banks
but **stopping two tiles short of each**, so she times a jump on and a jump
off. **Lifts run on their own too** (the creative lead: "make the lifts
move on their own too"): `_run_lift(x, row, rise, speed, phase, rest)`,
resting beside the floor at each end (step on, step off); one on dry ground
rests a row up (a hop on). **Movers that hand her on keep one time:** give
them the same run time and rest, and set them apart with `phase` (1-4's two
rafts and the lift past them; 1-5's high raft and its lift). They stay in
step because `moving_platform.gd` counts every run and rest in whole ticks
of game time (`_leg_ticks`, `rest_ticks`); count game time, never raw
physics ticks, or a hit-stop throws the rider off. A mover never stays at an
end, so what she steps or jumps onto there must be within reach while it
rests. Nothing in the levels waits for her now (`wait_for_rider` is still
there, and the systems arena uses it). The tests' moves: `board` (a timed
jump on as it arrives), `step_on` (a timed walk on), `await_mover`,
`ride_end`, `leap` (off at once). **Known, small:** a hit-stop while she
rides shifts her along the mover (under 2 px with real frame times; up to
18 px under `--fixed-fps`, a test artifact).

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
- **Debug keys** (debug builds only; an exported game ignores them, and F4
  on the map): F1 black-box view, F2 overlay, F3 slow motion, F5 restart,
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
working branches are `claude/region-1-levels` (the region's levels, the map,
the movers) and `claude/platformer-game-setup-oatrq2` (the art kits and
power-ups); two sessions worked on them at once. **Before starting, merge
`origin/main` into your branch**, so the two don't drift into conflicts the
creative lead can't merge (they did once, in `level_builder.gd`'s
`_level_end`).
Region 2's work (the rulebook, the region's plan, the 2-2 blockout) is on
`claude/happy-feynman-8zne0m`.

## How to test (use a virtual display in the cloud)

```
cd game
xvfb-run -a godot --path . --fixed-fps 60 --audio-driver Dummy res://tests/playtest.tscn -- room=ib03 mode=tour
```

- The shell (sounds, pause, getting up after a blow):
  `res://tests/checks.tscn` in place of the playtest scene (no arguments).
- Levels: `l1_1`, `l1_2`, `l1_3`, `l1_4`, `l1_5`, `l1_s`, `l1_b`, `l2_2`
  (`mode=tour`: the main line; `mode=secrets`: every secret, letter, bonus
  area and chest (not `l1_b`: it has none); `shots`; `map`; `l2_2` also
  `knot`, its great secret alone) and `sys`, the systems arena
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
- **`nocap=1`** runs a tour without saving a frame every other tick: about
  twice as fast, and the routes and results are still written. Use it
  while working; drop it for the film.
- **A tour's frames are game frames.** A hit-stop ends on the real clock,
  so `_step` waits it out: count frames, never hit-stops. A rider is known
  by where she stands (`_ride`), not by a collision report.
- **Riding in a tour** (`playtest.gd`, level 2-2's helpers): `_await_cradle`
  (wait for a cradle between two angles), `_onto`, `_ride`, `_alight`,
  `_over` (a whole crossing), `_hand_over` (cradle to cradle), `_leap`.
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

## The day kit (the Sunlit Woodland kit, Book 4, delivered)
`art/source/day/` holds it unchanged; `tools/make_day.py` runs the kit's own
`export_kit.py` on its `sources/` with averaged downscales and each sheet's
own colours (the kit's export dropped pixels and snapped every colour to
fixed ramps: red trunks, blue leaves), and checks the result against the
kit's `atlas.json`. Output: `game/assets/environment/day/` (the native
sheets, `terrain/day_*`, `fg_day_bottom_a/b`, `day_atlas.json`) and the
letters, token and HUD icon strips. In `level_builder.gd`: `_day(name)` looks
a piece up in the atlas, `_day_sprite` / `_day_ground` place one,
`_day_material()` is the ground (earth all the way in, `DAY_EARTH_DEEP`),
`_day_backdrops()` the sky and forests; checkpoints, crates, thorns, bonus
hollows and the end doorway use the kit by day. 1-1 is dressed by
`_dress_day()`; its treetop crowns are whole trees standing on the hill
(walkways on rows 20 and 21: higher, their trunks ended in the air and the
creative lead saw "the trees floating"); its stall is gone (it "looks out of place with the new tile
set"): the slab is an earth terrace on earth piers (`DAY_PIERS`), which the
creative lead approved ("the slab looks good like that").
`docs/mockups/platformer/world_map/` holds the creative lead's map mockup
(a map screen for each region's levels).

## The sanctuary kit (Book 5, delivered; first pass in 1-2)
`art/source/sanctuary/F1..F16` holds the generator's 16 sheets unchanged;
`tools/make_sanctuary.py` reduces them (averaged, each sheet's own colours)
into `game/assets/environment/sanctuary/` with `sanct_pieces.json` (every
piece's rectangle). In `level_builder.gd`, `kit = "sanctuary"` gives a level
the stone (`_sanct_material()`: top, underside, wall, fill; the kit's corner
pieces came back in other shapes and are not used), the cavern light and
ruins backdrops, the water (lifted: `SANCT_WATER_LIFT`) and the foreground
band. **1-2 is dressed in it** (`_dress()` in `build_l1_2.gd`): the lantern
hut at the start, the doorway at the end, an arch under the first floating
island, archways and pillars, the banner, the thorn bed, barrels, the
cavern roof along the level's top, drowned stone, water plants and lily pads.
**The look test** (`tools/build_look_s4.gd` → `scenes/levels/look_s4.tscn`;
picture: `docs/levels/look/s4_mockup_over_game.png`): after "still looks
nothing like my mock up; that ceiling looks terrible", the mockup S4 was
rebuilt shape for shape as one screen and judged beside the mockup. What it
taught, now in the kit's look: **the cavern roof is real rock along the top
of the room** (the skin hangs its underside), never a pinned or parallax
band; **the distance is far darker than the sheets came** (Sky, Far and Mid
modulated to deep teal); the water darker; dark ruins stand in the water
behind the play (`_sanct_midground`), lanterns glow (`_sanct_glow`), a light
vignette. **The stone is piles, not walls** ("they look nothing like the
natural stone in the mockups"): lit boulders at the edges and deep shadow
inside (the fill fades in 2 tiles to `SANCT_STONE_DEEP`), masses stepped one
block at a time, never tall boxes, rubble and ferns at their feet. **The
foreground is two layers** (the creative lead's): a lit band of real plants
in their own colours just in front of the play (scroll 1.12, raised 20 px
with `fg_raise` so it shows), and nearest the camera a lower band of
silhouette plants (Lost Keep's black forest band, scroll 1.45, sunk 22 px). Drowned stone
stands on the bed (`_sanct_bed`), never mid-water. **A level looks like a
mockup only if its shapes are the mockup's:** build sanctuary levels from the mockups' shapes (thick masses
stepping into water a tile below the low ground, a rock roof), then dress.
1-2's layout predates this and still reads as a low road of hops.
`_sanct(name)` looks a piece up (`SANCT`), `_sanct_ground` stands one on a
floor. **Plants are placed by hand, never by rule:** `_sanct_plant(piece,
tile x, row)` places one only on flat ground under its whole width, and the
old scatter pass (`_detail_kind`) is off for daylight levels (the creative
lead: "no weird plant placements; some of them are hanging off edges and
are in odd places"; "the mockups are the goal for the look"). Not used yet:
the islands and pillars (F5; 1-2's are tile masses in the stone), the log
and root (F6), the steps. The bonus hollows are still the day kit's.
Pictures: `docs/levels/1-2/art_pass/`.

## 1-2's look: the Flooded Sanctuary (Book 5)
The creative lead: 1-2 keeps the flooded-ruins look ("the old tile set"),
"but I think we need new tiles for it". Its four mockups are in
`docs/mockups/platformer/flooded_sanctuary/` (S1 to S4). **Book 5**
(`docs/art-production/platformer-sanctuary-prompt-book.html`, from
`src/book5_body.html` and `src/book5_cards.js`; published at
https://claude.ai/artifact/GwreeWZdoTHN9VwW37f2Ja with `platformer-attach/`
S1 to S4 and G8) asks for that kit in 16 sheets: stone that is stone all the
way in, a real fill, readable. 1-1 stays the Sunlit Woodland. Which look 1-3
onward take is undecided. When the kit arrives, process it as
`tools/make_day.py` does the day kit (from its sources, its own colours).

## Open items (region 2 and the rulebook)
- **Level 2-2, Millers' Row: a blockout, awaiting the creative lead's
  review** (`design/levels/2-2_millers_row.md`, pictures in
  `docs/levels/2-2/blockout/`). No art: there are no region 2 mockups yet.
  Its hood is the roster's `hood_knife` as a lunger.
- **The mills are not in the systems arena**; 2-2's two tours are their
  proof. Add a mill, a bell and a vane to the arena when it is next
  rebuilt.
- **The rulebook's proposals await the creative lead:** wicks (E3), the
  bonus level's two doors (S9), Resin paid once (E8), knots opening
  Morvath's Observatory (E7), the stride cut and a jump out of a hit that
  lands (C3, C4).
- **Six levels a region:** region 1 needs a sixth level (its remix), and
  its painted map a seventh pad, or the boss through level 6's gate.
  `Game.LEVELS` still lists region 1 as five, a secret and a boss.
- **There is no sound in the game at all** (rulebook R12).
- **Region 2's map page is a stand-in** drawn in code.
- **IB-04's room tour** (`room=ib04 mode=tour`) reports "0 of 7 jumps
  landed" on the pool's low path, on `main` as it was merged too: an old
  fault in the carried-over room's scripted route, not in the level code.

## Open items
- **From the audit (2026-11), done:** sound effects, the heavy-blow fix, the
  pause menu, debug keys out of exported builds. (The dusk kit's dark
  floor plants, which read as holes and hid Kleo's feet, are gone by day:
  main turned the whole detail pass off in daylight levels.)
- **From the audit, open:** the creatures are one drawing squashed and
  leaned in code (they need frames from the creative lead); no music or
  ambience; the sound cues need the creative lead's ear; the audio's rights
  log in the MetroidVania repo still says "to confirm: which paid plan".
- **Physics interpolation is off, on purpose.** Measured at a 144 Hz
  display: without it the world stands still on 87 frames of 150 and then
  jumps 2 to 3 px (judder); with it the world moves 1 px a frame, but Kleo
  flickers 1 px against the world three times as often (42 changes in 150
  frames against 14), with the camera rounded or not. That breaks the
  camera rule (she never shimmers against the world), so it stays off until
  there is a way to have both. At 60 Hz there is no difference either way.
- **Level 1-1: lit as bright day, letters and two bonus areas in, awaiting
  the creative lead's play** (`design/levels/1-1_overgrown_ruins.md`,
  pictures in `docs/levels/1-1/art_pass/`). Its art is still Book 3's dusk
  kit under daylight; **Book 4** (`platformer-region1-day-prompt-book.html`)
  asks for the bright-day kit after the six `bright_day/` mockups. As its
  sheets arrive: process them, place them, judge in the game.
- **Levels 1-3, 1-4, 1-5, 1-S and 1-B: blockouts, awaiting the creative
  lead's review** (their specs in `design/levels/`, pictures in
  `docs/levels/<level>/blockout/`). F4 on the map opens them all at once.
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
- **Asked, not yet answered:** the map is dusk (dark teal and purple) while
  region 1's levels are bright day by the creative lead's earlier decision.
  "Follow the map" was taken to mean its names and its paths, **not** a
  change of the levels' look: don't darken the levels on it.
- **Awaiting the creative lead's word:** the thorn knots' hiding places and
  the banner stand-in. What waking every knot does is undecided.
- 1-1's two bonus areas are still the old kinds (12 beads; a course), not
  Resin rushes.
