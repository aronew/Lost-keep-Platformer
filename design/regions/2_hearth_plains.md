# Region 2: the Hearth-Plains (a plan, for the creative lead's review)

Planned to `design/rulebook.md` §4 (six levels, a bonus level, the boss),
after the creative lead's brief: "harder challenges, secrets, moving
platforms, puzzles, and any other ideas we can come up with to make a truly
great platformer". **Everything here is proposed** except what
`design/game-structure.md` already fixed (the biome, the ability, the boss,
the reward). One stop is built: **2-2 Millers' Row**, as a blockout.

> **Changed on `main` while this was planned** (the creative lead,
> `design/game-structure.md` §4): bosses unlock **power-ups, as Mario's**,
> not permanent abilities. So in this plan **the Ward is a power-up**:
> found in 2-1 and later levels, held one at a time, lost to a hit, and
> **never needed**. Everything below that uses it is an optional answer:
> a hay wall it bashes hides Resin or a short cut, never the only way; the
> shaman's orb can be dodged as well as parried back; the golem can be
> gone round. 2-2 Millers' Row does not use it at all. **Which power-up
> the Silk Mother unlocks is open:** `game-structure.md`'s regions table
> says Barkgrip, its power-up table says Emberwick.

## The region in one paragraph

Golden fields at late afternoon, silk orchards, windmills, Rootling
villages, hay barns. And nobody in them. Kleo follows the trail of the
missing out of the forest into farmland where the carts stand loaded in the
road, the mills turn with no one at the brake or stand still where a miller
was taken, and silk hangs on the fences. The Silk Mother, the plains'
great silk-spinner, has been twisted by the Blight and is cocooning her own
people "to keep them safe". The region is bright and wide where region 1
was close and green; its dread comes from emptiness, not from the dark.

## What the region owns (rulebook §4.4)

| | |
|---|---|
| **The ability in hand** | **The Ironbark Ward**, her captain's shield, won from the fallen warden. A weapon and a move at once (C9): a **parry** (about 8 frames: a parried shot flies back) and a **bash-dash** (3 tiles along the ground: it breaks hay and bark-plate, slips under a closing gate, and keeps her stride). Her frames already hold a `ward` animation |
| **The machine** | **The mill.** A windmill's sails carry hoist cradles round; she rides them. A **bell** wakes a sleeping mill; a **wind vane** turns one round. *Built* (`windmill.gd`, `mill_bell.gd`) |
| **The second toy** | **Silk.** Strung between orchard trees it is a trampoline (bounce silk); struck at an anchor, a strand shoots across to the next anchor and she walks it (her own bridges) |
| **The hazard** | **The bramble hedge**: the fields' hedgerows grown tall and thorned. A hit, never a death by itself; the danger is what it knocks her into |
| **The ride** | **The hay cart**: it rolls once she is aboard, and the level comes at her |
| **New creatures** (from the creative lead's roster, roles proposed in `design/enemies.md`) | **the hood** (a walker that stabs: the lunger, short and quick), **the sack thief** (snatches Resin and runs), **the skull shaman** (throws a slow orb: the Ward's parry sends it back), **the stone golem** (the sword rings off: the Ward's bash breaks it): four, each arriving alone |
| **The numbers** (P6) | Widest gap 5, smallest landing 2, never more than 3 s to the next chance, enemies in pairs |
| **Skeletons** (A7) | Road, road with a yard, climb, descent, chase, road: five kinds, none twice running |

## Where the ideas came from

The creative lead attached six hand-drawn level maps (late Donkey Kong
Country 2, by the look of them) "to pull from for ideas". What each one
does well, and where its *idea* lands here. No level of theirs is copied:
the layouts, machines and names below are this game's own.

| The sheet | What makes it work | What we take | Where |
|---|---|---|---|
| A tall tower climbed in three columns, a hazard rising from below | Pressure without a creature; the level folds so a climb reads on one screen | A climb that folds back and forth, with rests; pressure saved for region 4, whose rule is "water rises on a clock" | 2-3, calm on purpose (P1's breath) |
| A sky of launchers, fired one to the next | The player does almost nothing but time one press, and it is thrilling; launchers aim, turn and move | Machines that hand her on with no ground between; a rhythm a flowing player never breaks (A14) | 2-2's twin mills and its last three mills; silk strands in the bonus level |
| A wood crossed on platforms the player makes | The player builds their own path, so every crossing is their own | Silk strands she strings by striking an anchor | 2-6, and pushed to its limit in the bonus level |
| A maze of thorns with a way in, a way round and a hidden way through | A maze in a platformer works when the walls are the hazard and the camera shows the next turn | The bramble hedges as a maze crossed on carts, with vanes at the junctions | 2-4 |
| A level that turns into a chase half way | A known level made new by being run, not walked | The harvest machine at her heels through the wheat | 2-5 |
| One level in five sections, each with its own toy | A gauntlet that never repeats a section | Everything the region taught, in the order it was taught | 2-6 |

## The eight stops

| Stop | Name | Job (rulebook §4.1) | The idea, in a phrase | Hardness | Skeleton | New |
|---|---|---|---|---|---|---|
| 2-1 | **The Golden Road** | Arrival | The Ward: bash through hay, parry what is thrown | 3 | Road | The hood, alone; bounce silk, once |
| 2-2 | **Millers' Row** | The machine | The turning mill: ride it, wake it, turn it round | 5 | Road, with yards | Mills, bells, vanes; the first puzzles. *Built as a blockout* |
| 2-3 | **The Great Mill** | The climb | Up through the mill's works: cogs, hoists, chutes | 4 | Climb | The sack thief; the boss's orchard, seen from the cap |
| 2-4 | **The Thorn Hedges** | The hazard | A maze of bramble, crossed by cart | 6 | Descent, then road | The skull shaman; the first pair of hoods; the cart |
| 2-5 | **The Harvest Run** | The remix | The reaper is behind her: run | 7 | Chase | The stone golem, once; mixed pairs. **Hides the exit** |
| 2-6 | **Silkfall** | The gauntlet | The orchard, webbed over: everything, in order | 8 | Road | Silk strands; the locked arena; the boss's door |
| 2-? | **The Loom Loft** | The bonus level | Nothing but silk: string your own way across | 9 to 10 | Road, no ground | A wick, the seventh knot |
| 2-B | **The Silk Mother** | The boss | The exam | 8 | Arena | Barkgrip |

### 2-1 The Golden Road (arrival)
- **Teach:** a hay bale across the road, a bead visible through it. The
  bash-dash goes through. Then three bales in a row: the bash keeps her
  stride (the first taste of "speed survives a swing", C3).
- **Test:** a farm's seed-flinger (a machine, not a creature: P3) lobs a
  slow sack; the Ward's parry sends it back and it breaks the hay wall
  that blocks the road. Parry is taught on a thing that cannot hurt much
  and cannot move.
- **Twist:** the first hood, alone, on flat ground with 12 tiles to fight
  in; then a low gate closing: the bash-dash slips under.
- **Finish:** bales, a gap of 5 with a bale on the far side (bash on
  landing), bounce silk between two orchard trees over the road, the
  village gate.
- **The region's secret kind, shown openly** (S4): a hay wall in a barn's
  side with Resin plain to see behind it.
- **Foreshadowing** (P5): carts left loaded in the road; silk on the
  fences.

### 2-2 Millers' Row (the machine) · built
`design/levels/2-2_millers_row.md`.

### 2-3 The Great Mill (the climb)
- Inside the mill whose door ends 2-2: 2 screens wide, 5 high, folded so
  each floor is crossed the other way (the tower sheet).
- **The idea:** the mill's works. Cogwheels (small mills turning on their
  sides: the same cradles, climbed like a slow ladder), sack hoists that
  wait for her, grain chutes that carry her down a floor if she slips
  (a fall costs ten seconds, never a flame: A11).
- **The sack thief** lives here: it snatches a line of beads and climbs.
  Catching it is the level's dare; it never takes a letter or a token.
- **Calm on purpose:** no pits, hardness 4. The region breathes here.
- **From the cap:** the whole plain, and far off the orchard hung white
  with silk (the boss's place: P5).
- **The knot** (proposed): the mill's bell is at the bottom. Rung from the
  top by a sack dropped down the hoist shaft, it starts a cog that was
  scenery all the way up.

### 2-4 The Thorn Hedges (the hazard)
- A hedge maze, entered from above (a descent), crossed on **hay carts**:
  a cart rolls when she steps on, and she hops the low brambles and ducks
  off for the high ones.
- **Vanes at the junctions** set which way a cart's track turns: the
  region's two-step puzzle (A8: two steps from region 3, one here, so
  each junction is one vane, one choice, both ways in sight).
- **The skull shaman** arrives alone on a hedge top: its orb, parried
  back, burns a way through bramble. Then the first pair of hoods.
- **Fairness** (E13): hedges are a hit; no hedge stands over a pit before
  the banner.
- **The knot** (proposed): the one junction where the *wrong* turn, into
  a dead end of bramble, is right: a shaman's orb parried there opens it.

### 2-5 The Harvest Run (the remix)
- **The set piece:** a Carapax reaper, the Vexari's harvest machine,
  comes through the wheat behind her. The first sight of what is taking
  people: "they harvest more than wheat." It is the screen's left edge;
  it never speeds up, and it is never faster than a plain run (K2).
- **The remix:** the Ward's bash through bales (to keep her stride),
  mills in step (2-2's finish, now the only way over the ditches),
  stepping stones over the irrigation ponds (region 1's 1-2).
- **The stone golem**, once: in her way, the sword rings off, the bash
  breaks it.
- **The hidden exit** (S9): where everyone runs, hide. A root cellar's
  door, seen in the first minute before the reaper appears (the far
  glimpse) and passed again at a run (the near tell: Resin stepping down
  into it). Duck in and the reaper goes by overhead; its wake, the
  stubble it leaves, is the road to the Loom Loft.

### 2-6 Silkfall (the gauntlet)
- The silk orchard at dusk, webbed from tree to tree. Sections in the
  order the region taught them: hay and gates, a seed-flinger now flinging
  silk, mills wrapped in web (their bells cocooned: cut them free), a
  cart through hedges, a short run from a web that closes behind her.
- **Silk strands:** strike an anchor and a strand shoots across to the
  next anchor: a bridge of her own making, for a few seconds.
- **One arena locks:** two hoods and a shaman among hanging cocoons.
- **Ends at the weaving barn's door.**

### 2-? The Loom Loft (the bonus level)
The barn's rafters: no ground at all. Bounce silk and strands she strings
herself, each for a few seconds; two to three minutes, no banner. A wick
and the region's seventh knot at the end.

### 2-B The Silk Mother (the boss), to rulebook §3.3
- **Approach** (B1): the weaving barn, quiet. Cocoons hang in rows: the
  missing. Her loom's threads hum. One mill wheel turns slowly in the
  rafters. The banner stands at the inner door (B2).
- **Arena** (B3): two screens of barn floor; three patches of bounce silk;
  the rafters' mill with four cradles; a bell on the west wall.
- **Phase 1, the Ward** (2-1, 2-4): she hangs above and spits slow silk
  bolts. Parried back, three bolts drop her to the floor: the opening.
- **Phase 2, the mill** (2-2, 2-3): she walks the floor, legs sweeping
  (0.6 s tell, a leg raised: T2). Bounce silk clears the sweep; a cradle
  carries Kleo above her back; a down strike on the spinneret is the
  opening. She webs the mill still: the bell wakes it.
- **Phase 3, everything** (2-5, 2-6): she spins walls of silk across the
  floor and comes behind them. The bash-dash breaks a wall; a strand
  struck at the right anchor trips her: the opening.
- **Nine openings** (B5), each a full combo. On three flames it can be
  done; one amber sap falls at each phase change for a player on their
  last flame (B7).
- **The reward** (B8): the great cocoon opens and the Ironbark smith
  steps out. In the arena, with the barn's timber walls all round, he
  gives her **Barkgrip**; the way out is a wall jump up the barn's inside
  to the cap, with nothing to fall into.
- **Then the Refuge** (B9): the plains' people walk in, and the Rootling
  kitchen opens. **Never call her the Spider Matriarch.**

## The curve

| | 2-1 | 2-2 | 2-3 | 2-4 | 2-5 | 2-6 | ? | B |
|---|---|---|---|---|---|---|---|---|
| Hardness (P1) | 3 | 5 | 4 | 6 | 7 | 8 | 9+ | 8 |
| Widest gap | 5 (over ground) | 5 | 4 | 5 | 5 | 5 | 5 | n/a |
| Smallest landing | 3 | 2 | 2 | 2 | 2 | 2 | 2, for a few seconds | n/a |
| Creatures | 1 | 1 and a known pair | 1, running away | a pair | mixed pairs, an elite | everything | none | the boss |

## What the region needs built

| Thing | State |
|---|---|
| Mills, bells, vanes | **Built**, proven by 2-2's tours |
| A crate that comes back after a missed throw | **Built** (`Carriable.returns`) |
| A pair that takes turns | **Built** (`Lunger._may_wind_up`) |
| The Ironbark Ward (parry, bash-dash) | Not built; her `ward` frames exist. Needs the stride cut decided first (rulebook, finding 1) |
| Bounce silk, silk strands | Not built |
| The hay cart | Not built (a `MovingPlatform` that waits for her is most of it) |
| The seed-flinger, the sack thief, the shaman, the golem | Not built |
| The reaper | Not built |
| The region's look | No mockups yet; the blockout stands in. The map page is a stand-in drawn in code |

## Open for the creative lead
1. **The region as planned:** are these the right six ideas, in the right
   order?
2. **Build order.** I built 2-2 first because it is the one level of the
   region that stands without the Ward, and it is the moving-platform and
   puzzle level the brief asked for. 2-1 needs the Ward.
3. **The second toy:** silk as trampoline and as strands she strings
   herself. Or should silk stay the Silk Mother's alone?
4. **The reaper** brings a Carapax into region 2, three regions before the
   Foundry. A good early shock, or too soon?
5. **The roster's roles** for region 2 (hood, thief, shaman, golem).
6. **The Silk Mother's power-up:** Barkgrip (the regions table) or
   Emberwick (the power-up table)? Emberwick burning silk would make her
   fight its first lesson.
