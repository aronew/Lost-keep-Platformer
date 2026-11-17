# The Rulebook: game loop, golden rules, level architecture (v1)

Asked for by the creative lead (2026-11): "a comprehensive blueprint and
rulebook" for the game loop, the macro-structure and the stage design rules,
with the bar set at "TRIPLE A TOP TIER in every way".

**What this is.** One place that says how the whole game fits together and
what every level, enemy and boss is held to, and an **audit** of the game as
it stands against those rules. It sits on top of
`design/game-structure.md` (the plan) and
`design/research/platformer-fun.md` (the sources).

**How to read it.**
- Every rule has a code (`M` macro, `E` economy, `P` pacing, `K` Kleo's
  moves, `C` combat, `T` telegraphs, `R` readability, `A` architecture, `S`
  secrets, `B` bosses). Level specs and reviews cite the code.
- **[decided]** the creative lead's own decision. **[built]** in the game
  and measured. **[proposed]** mine: it stands until the creative lead
  overrules it. Numbers marked *first pass* are to be tuned by play.
- Audit marks: ✅ built and meets the rule · ⚠ built, but breaks or only
  half meets it · ⬜ not built yet.

**Changed by this document** (the creative lead's message): a region is now
**six regular levels, one bonus level, and the boss as its last level**:
eight stops, 56 in all. It was five, one and one.

---

## 0. What the game is, in four pillars

Everything below serves these. A rule that fights a pillar is wrong.

1. **Moving is the fun.** Run, jump and stride feel good on a flat floor
   before any level exists. [built]
2. **The sword is a way of moving, not a way of stopping.** This is the
   game's own place among platformers: Donkey Kong Country's flow, with a
   real blade. Every swing carries her forward; a skilled player fights
   without ever standing still. (The biggest gap today: §2.2, C3.)
3. **Two games in one.** Reaching the end is for everyone. Finding
   everything is the real game, and the map keeps score. [built]
4. **One idea, fully played.** Each level owns one idea and throws it away
   at the end. Each region owns one ability, one machine, one hazard.

The closest relative in structure is Castlevania: Order of Ecclesia: a map
of discrete stages, each a tight action level with things hidden in it, and
a village that fills up with the people you rescue and what they sell. Ours
differs in three ways: the levels are built for flow (DKC), nothing is
gated behind a later ability, and the sword never grows stronger, so skill
is the only thing that scales.

---

# PART 1. THE MACRO LOOP AND THE PROGRESSION ECOSYSTEM

## 1.1 The three loops

| Loop | Length | What the player does | What keeps them in it |
|---|---|---|---|
| **The jump** | 1 to 5 s | See, read, time, land. A swing, a hop, a bead taken | Feel: weight, sound, forgiveness. It must be good ten thousand times |
| **The level** | 5 to 8 min | Meet one idea; learn it, be tested, be surprised; reach the end; notice two things out of reach | Curiosity (what is the idea?) and the hunt (what did I miss?) |
| **The region** | 60 to 80 min | Six ideas, a hidden level, a boss; a new ability | A map filling in, a count of what is missing, the Refuge growing |
| **The game** | 9 to 11 h (14+ with everything) | Seven regions, seven abilities, the Reveal, the Prism | Story, and the next ability changing how she moves |

**M1. Each loop feeds the next.** A good jump makes exploring cheap.
Exploring fills the map. The map opens harder levels that ask for better
jumps. If any link is weak the others go slack: that is why the audit
starts with feel.

## 1.2 The stage loop, step by step

```
THE MAP (a region's page)
  │  walk to an open stop, press jump                       (M2: two presses)
  ▼
A LEVEL ── teach ▸ test ▸ [banner] ▸ twist ▸ finish ── the gate
  │   a fall or a defeat: back at the banner in ~1.2 s      (M3)
  ▼
THE TALLY  Resin · K-L-E-O · tokens · knot · (the second exit)   3 s, skippable
  ▼
THE MAP   the stop is ringed · its record shows what is missing · the next
          stop opens along the dotted path                  (M4: the hook)
  │
  ├─ levels 1 ▸ 2 ▸ 3 ▸ 4 ▸ 5 ▸ 6 open in order
  ├─ THE BONUS LEVEL "?" opens by tokens, or by the hidden exit   (S9)
  └─ THE BOSS (the region's level 7) opens when level 6 is done
        ▼
     THE ABILITY, given in the arena and used at once to leave it   (B8)
        ▼
     THE REFUGE: the captives arrive, a stall opens, Resin is spent  (E)
        ▼
     the next region's page opens on the map
```

- **M2. Two presses from the map to play; one from the tally to the map.**
  No menus between levels. ✅ (the map opens the game; jump enters.)
- **M3. A death costs seconds, never minutes of menus.** Death to control
  in 1.5 s or less. ✅ measured about 1.2 s (0.35 s fall, 0.3 s fade out,
  0.15 s, 0.35 s fade in).
- **M4. The tally ends on a hook.** The last thing the player sees after a
  level is what just opened and what is still missing here. ⚠ the tally
  shows what was found, then cuts to the map; the next stop does not yet
  visibly open, and nothing celebrates a level's full record.
- **M5. One checkpoint a level, at its middle.** [decided] ✅
- **M6. No lives, no game over.** Resin taken since the banner is what a
  fall puts at risk. [decided] ✅
- **M7. Any cleared level can be replayed from the map at once,** and a
  replay keeps what was found (letters, tokens, the knot). ✅
- **M8. Nothing is ever gated behind a later ability.** Everything in a
  level can be found the first time it is played. [decided] ✅
- **M9. A region is eight stops:** levels 1 to 6, the bonus level, the
  boss. [decided] ⚠ the docs, the save list and region 1's painted map were
  built for five levels. Fixed in the docs here; see the audit for the map.

## 1.3 What the player collects, and what each thing is for

Every collectible has exactly one job. If two do the same job, one goes.

| Thing | How many | Its one job | Where it pays off |
|---|---|---|---|
| **Resin** (beads, chests) | about 60 on a level's main line, about 100 more off it | The designer's voice (it shows jumps, marks safe drops, points at secrets) and the currency | The Refuge's stalls |
| **Letters K-L-E-O** | 4 a level | The *attention* test: two on the line, two off it | 25 Resin now; the level's gold mark on the map [proposed] |
| **Bonus tokens** | 2 a level, 12 a region | The *skill* test: a short timed Resin rush | They open the region's bonus level (E6) [decided] |
| **Morvath's thorn knot** | 1 a level | The *cunning* test: the one great secret | Morvath's Observatory, after the story (E7) [proposed] |
| **The hidden exit** | 1 a region, in level 4 or 5 | The region's best-kept secret | The bonus level, at once and for nothing (S9) |
| **Wicks** | 1 in each bonus level, 3 for sale | Health, slowly | Two wicks make a lantern flame (E3) [proposed] |
| **Abilities** | 1 a region, from its boss | How she moves from then on | The next region is built round it [decided] |

## 1.4 Risk, reward and the economy

The question was how secrets, currency and upgrades feed power forward
"without breaking balancing". The answer is to be strict about which kinds
of power exist at all.

- **E1. Three kinds of power, and only three.**
  1. **Abilities**: fixed by the story. Every player has the same ones at
     the same point. They widen what she can do, never how hard she hits.
  2. **Flames** (health): the only thing secrets and Resin can raise, and
     slowly, under a ceiling (E3, E4).
  3. **The player's own skill and knowledge.**
- **E2. The sword never gets stronger.** A swing is worth 1, the overhead
  2, the finisher 3, in region 1 and in region 7. Enemy health is counted
  in swings and stays honest for the whole game. Nothing sold or found
  changes damage, speed or jump. [proposed, and already true]
- **E3. Flames come in wicks.** Kleo starts with 3 flames and can reach 8.
  **Two wicks make one flame.** There are ten wicks: one at the end of
  each region's bonus level (seven), and three sold by the healer, one
  after regions 1, 3 and 5 each. [proposed]
  *Why:* the docs say both "one flame from each secret level" and "four
  for sale" and "8 in all": 3 + 7 + 4 is 14. Wicks keep all three
  intentions and make the sums work.
- **E4. Design for the floor, tune for the middle, cap the ceiling.**
  Every level and boss can be finished on **3 flames** (a player who found
  nothing). It is tuned to feel right at the **expected** count. The
  **ceiling** is all a player can possibly hold on arrival:

  | Entering region | 1 | 2 | 3 | 4 | 5 | 6 | 7 | the finale |
  |---|---|---|---|---|---|---|---|---|
  | Floor | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
  | Expected | 3 | 3 | 4 | 4 | 5 | 5 | 6 | 6 |
  | Ceiling | 3 | 4 | 4 | 5 | 6 | 7 | 7 | 8 |

  The gap between the most and the least a player can have never passes
  about two to one, so no boss has to be built for two different games.
- **E5. Damage scales, health barely does.** Regions 1 to 4: everything
  costs one flame. From region 5, attacks with a long tell (0.7 s or more)
  cost two. A full lantern stays worth having without making early
  enemies harmless. [proposed]
- **E6. Tokens open the bonus level.** 12 tokens a region; **8 open its
  bonus level** (a player need not be perfect). The hidden exit opens it
  for nothing (S9). All 12: the stop's garland on the map. [decided that
  tokens open it; the count is first pass]
- **E7. Knots lead beyond the story.** Each region's knots (six, and a
  seventh in its bonus level) wake one of seven seals on Morvath's
  Observatory: the game's last, hardest stops, after the ending. The
  prize for cunning is more game, as Super Mario World's Special Zone.
  [proposed: what the knots do is still open]
- **E8. Resin is paid once.** A level pays out only what beats the best
  haul made in it before. Replaying to hunt is welcome; replaying to farm
  pays nothing. ⚠ today a replay pays in full, so 1-1 can be farmed.
- **E9. Resin buys comfort, help and beauty; never the ending.** [decided]
  Its only brushes with power are wicks (capped, E3) and a meal.
- **E10. The meal is the difficulty setting.** The Rootling kitchen sells
  one extra flame for one level. A stuck player buys their own easy mode,
  one level at a time, with Resin they earned by playing (Miyamoto: "the
  player can adjust the difficulty himself while playing").
- **E11. More to buy than Resin to buy it.** Sinks total about 1.3 times
  everything a thorough player earns, and power is under a fifth of it.
  The player chooses; nobody finishes with a useless pile.

  First-pass numbers (to be tuned once the Refuge exists):

  | In (a whole game) | Resin | | Out (the Refuge) | Resin |
  |---|---|---|---|---|
  | Main lines, 42 levels | about 2,500 | | Wicks: 200, 400, 700 | 1,300 |
  | Off the line, chests, rushes, letters | about 4,200 | | Meals, 25 a level | about 400 |
  | Bonus levels, 7 | about 700 | | Map-maker's hints, 15 each | about 300 |
  | | | | The tailor, 6 looks | about 1,800 |
  | | | | The builders, 10 works | about 4,000 |
  | | | | The archivist, 30 pieces | about 1,200 |
  | **A thorough player** | **about 7,400** | | **Everything** | **about 9,000** |

- **E12. Risk is always chosen.** Resin since the banner is lost on a fall
  (it goes back where it hung). Risky Resin sits beside the safe line,
  never on it. The dare is the player's own. [built] ✅
- **E13. No double punishment by surprise.** One mistake costs one flame.
  Where a hit can knock her into a pit (thorns over a drop), the level
  shows both before she commits, and it is after the banner. ⚠ nothing
  checks this yet; it is in the checklist (§4.3).

## 1.5 Pacing six levels

- **P1. Difficulty climbs as a saw, not a ramp.** A region's levels go
  3, 5, 4, 6, 7, 8 on a scale of ten, then the bonus level at 9 or 10 and
  the boss at 8. Level 3 is a deliberate breath. Two hard levels never sit
  side by side without a change of pace between them.
- **P2. Regions overlap.** A region's first level is about as hard as the
  last region's third. The new ability makes it feel easier than it is.
- **P3. One new creature a level, at most, and it arrives alone.** First
  where failing costs nothing; then with the level's idea; then with a
  second creature. A region introduces three to four creatures:

  | Level | Creatures |
  |---|---|
  | 1 | The region's first new creature, alone, on flat ground |
  | 2 | The same one beside the machine; a creature from the last region |
  | 3 | The second new creature (often a flier or a climber, for the climb) |
  | 4 | The third; the first **pair** (two of a kind) |
  | 5 | Mixed pairs (two kinds whose attacks interlock); the elite, once |
  | 6 | Everything, in the order it was taught; one arena that locks |

- **P4. The hazard is seen before it is met.** The region's signature
  hazard is in the backdrop of level 1, on the edge of level 2, and the
  subject of level 4.
- **P5. The boss is foreshadowed three times:** a sign of it in level 1
  (its work), a glimpse in level 3 (far off, from the climb's top), its
  aftermath in level 5. Level 6 ends at its door.
- **P6. The hard numbers** (from `game-structure.md` §3, with timing rules
  added for things that move):

  | Region | Widest gap | Smallest landing | Longest wait for the next chance | Enemies |
  |---|---|---|---|---|
  | 1 | 4 | 3 | nothing moves on the main line | one at a time |
  | 2 | 5 | 2 | 3 s | pairs |
  | 3 | 6 | 2 | 3 s; hazards on a clock | ranged added |
  | 4 | running jump into a wall jump | 2, sinking | 2.5 s | mixed groups |
  | 5 | glides of 12+ | 1 | 2.5 s; machines in sequence | armoured |
  | 6 | grapple chains | knots only | 2 s | fliers |
  | 7 | everything chained | 1 | 2 s | everything |

- **P7. The three-second rule.** A player who just misses a moving thing
  is never left waiting more than the table's time for the next chance.
  Waiting is not difficulty.
- **P8. Tension, then release.** Inside a level: one rest in every beat.
  Inside a region: level 3. After a boss: the Refuge.

---

# PART 2. THE GOLDEN RULES OF MOVEMENT AND COMBAT

## 2.1 Kleo's movement (measured in the game)

| | Value | |
|---|---|---|
| Run | 140 px/s (8.75 tiles/s); full speed in 0.08 s | ✅ |
| Stride (a second of unbroken running) | 182 px/s; a jump of 8.3 tiles against 6.4 | ✅ "the boost is cool" |
| Jump | 3.37 tiles high held, 0.65 tapped; 6.27 tiles long | ✅ |
| Coyote time | 0.10 s | ✅ |
| Jump buffer | 0.12 s | ✅ |
| Hang at the top of a held jump | gravity × 0.55 under 40 px/s | ✅ |
| Ledge catch | up to 5.25 tiles | ✅ |
| Corner correction (a head that clips a corner is nudged round it) | none | ⬜ |
| Attack buffer | 0.22 s | ✅ |

- **K1. Forgive the input, never the level.** Coyote time, buffers, hang
  time and corner correction are invisible kindness. The gap itself is
  never made easier in secret.
- **K2. Every required jump is made with the plain jump.** The stride is
  the skilled player's shortcut. [decided]
- **K3. Height is sacred.** No move, pickup or trick adds jump height
  except an ability the story gives. Speed adds length only. This is what
  lets "out of reach" mean something for the whole game.
- **K4. Momentum from machines is kept.** A jump from a rising platform
  goes higher; a jump from a falling one is never weaker. [built with the
  mills: `platform_on_leave`, upward only.]

## 2.2 How the sword and the feet work together

Measured from `kleo.gd` and her frames (24 frames a second unless marked):

| Attack | Starts hitting | Active | Next hit from | Free to move from | Step | Worth |
|---|---|---|---|---|---|---|
| 1 swipe | 125 ms | 125 ms | 250 ms | 333 ms | 190 px/s, about 1 tile | 1 |
| 2 swipe back | 125 ms | 83 ms | 250 ms | 333 ms | 190 px/s | 1 |
| 3 overhead (22 fps) | 227 ms | 91 ms | 364 ms | 409 ms | 240 px/s | 2 |
| 4 spinning slam | 83 ms, then 292 ms, 500 ms | three windows | end | 583 ms | leaps 250 px/s | 3 |
| Up strike (22 fps) | 45 ms | 91 ms | n/a | 136 ms | none | 1 |
| Air strike | 42 ms | 42 ms | n/a | 125 ms | keeps 60% air control | 1 |
| Down strike (22 fps) | 45 ms | 91 ms | n/a | 136 ms | **pogo**: bounces 2.8 tiles off what it hits | 1 |

- **C1. Every swing moves her.** ✅ Each ground hit steps forward about a
  tile. Fighting advances her through the level; it never roots her.
- **C2. No swing traps her.** ✅ A third of a second after a swipe starts
  she can run or jump out of it; the next hit can be buffered 0.22 s
  early; mashing through a long wind-up still chains.
- **C3. Speed survives a swing.** ⬜ **The game's biggest gap.** Today any
  swing ends her stride, and a ground swing brakes her at 900 px/s². The
  two best things she does cancel each other, so a flowing player must
  choose between running and fighting. **Proposed: the stride cut.**
  Attack while striding and she slashes on the run: one hit worth 1, no
  brake, the stride kept. A weak creature in her way is cut down without
  breaking step (Donkey Kong rolling through a Kremling). Miss the
  timing and she runs into it. This single move is what turns "a
  platformer with a sword" into this game.
- **C4. A hit that lands frees her.** ⬜ Proposed: when a swing connects,
  a jump comes out at once, without waiting for the cancel frame. Landing
  a hit is rewarded with movement; whiffing is punished with recovery.
- **C5. The air strike never stalls her.** ✅ It keeps her arc. Air time
  is the level designer's to give, not the sword's.
- **C6. The down strike is a jump she earns.** ✅ built; ⬜ not yet used
  by a level. The pogo off a creature, a bell or a lantern post is the
  optional skilled route over a gap. Never required before region 3.
- **C7. Hit-stop sells the hit and never eats an input.** ✅ 45 to 110 ms
  by weight, capped at 120 ms, ended on the real clock; buffers run
  through it.
- **C8. One combo, one kill.** ✅ A standard creature takes four hits:
  three swings and the start of the finisher. Fodder takes one or two.
  Elites take two combos **and** a trick (a shell to break, a guard to
  open); health alone is never the difficulty.
- **C9. Each ability is both a weapon and a move.** The Ward's bash-dash
  crosses three tiles and breaks hay; Barkgrip is a wall jump and a
  plunging strike; Emberwick burns bramble and creatures alike. An
  ability that is only a key is a Metroidvania's, and not ours.
- **C10. Knockback is short and never into a death she couldn't see.**
  Hers: about 1.5 tiles for a light hit, 3 for a heavy one, 0.9 s of
  invulnerability, control back in half a second. ✅ numbers; ⚠ nothing
  yet keeps a lunging creature's stretch four tiles clear of a pit edge
  (§4.3).

## 2.3 Telegraphs and fairness

The first fighting creature (the lunger, the roster's rat) is the model.
Measured: notices 0.38 s · stalks · winds up 0.5 s (a crouch, a shiver
from 40%, a flash from 50%) · lunges 230 px/s · skids open for 0.6 s ·
waits 0.5 s before it may wind up again. Struck, it flinches 0.34 s and
its wind-up breaks.

- **T1. Every attack has four parts, and each can be seen:** notice,
  wind-up, strike, recovery. ✅
- **T2. The wind-up is never shorter than the table.** Human reaction to
  an expected cue is about a quarter of a second; nothing in the game
  goes under 0.3 s.

  | Regions | Standard creature | Elite, boss | Recovery (the punish window) |
  |---|---|---|---|
  | 1 and 2 | 0.5 s | 0.6 s | at least the wind-up |
  | 3 and 4 | 0.4 s | 0.5 s | at least 0.4 s |
  | 5 to 7 | 0.3 s | 0.4 s | at least 0.3 s |

- **T3. A tell is a change of shape, with a flash and a sound.** Never
  colour alone, never a flash alone. It must read in a silhouette, at
  arm's length from the screen. ✅ shape and flash; ⬜ sound.
- **T4. It hurts only while it strikes.** A creature that is walking,
  winding up or recovering does not burn her on contact, unless contact
  *is* its attack and it looks it (spikes). Being brushed by a resting
  rat is not a hit. ⚠ today the lunger burns her on contact in every
  state but its flinch (`_touch_kleo`): a walking rat hurts as much as a
  lunging one, only less hard. To be changed with the next creatures.
- **T5. Hitboxes favour the player, both ways.** Her body is smaller than
  her sprite (10 × 26 px inside a 28 px figure) ✅. Her blade's box is
  bigger than the blade (38 × 30 px) ✅. A creature's body that can be hit
  is nearly all of it ✅; the part of it that hurts is about half ✅.
  Hazards hurt over less than they are drawn (thorns: 2 px in from each
  side) ✅.
- **T6. Struck, a creature answers at once:** white flash, hit-stop, a
  spark, a flinch. A hit that changes nothing on screen did not happen. ✅
- **T7. Interrupts are real.** Hitting a standard creature in its wind-up
  breaks the attack. Aggression is a defence. Elites and bosses show
  armour when they can't be interrupted. ✅ for the lunger.
- **T8. One strike at a time.** In a pair, only one creature may be
  winding up or striking; the other waits at least 0.4 s. Two tells at
  once cannot be read. ⚠ built with this document for the lunger
  (`Lunger._may_wind_up`); every new creature must take the same turn.
- **T9. Nothing attacks from off the screen,** and nothing wakes until it
  is on it. ✅ (the lunger sees 150 px; half the view is 320.)
- **T10. No attack without an answer.** For every attack the player has
  at least one of: step out, jump over, strike first, and from region 2
  parry. The design note for a creature names which.
- **T11. A creature is one verb.** Lunges, or shoots, or hops, or
  shields. The verbs combine in pairs; no single creature does three
  things.

## 2.4 Reading the screen

A cheap hit is one the player could not have read. These make sure they
always can.

- **R1. Three bands of value.** The backdrop is pale, hazy and low in
  contrast. The playfield has the full range. The foreground is one dark
  band along the bottom. Nothing that matters is ever drawn in a band
  that isn't the playfield's. ✅ in the day look.
- **R2. What looks solid is solid, exactly.** Collision is the tile grid.
  Art overhangs collision by 2 px at most. Floors are flat and straight
  [decided]; only undersides and edges are ragged.
- **R3. One-way things look thin.** Anything she can jump up through is
  timber, a branch, a cradle: never a slab of ground. [decided: floating
  platforms are painted pieces, never floor tiles.]
- **R4. The layer order is fixed,** back to front: sky · far · mid ·
  backdrop structures (what holds things up) · back walls · terrain ·
  props and machines · pickups · creatures · Kleo · thrown things ·
  water's surface · effects · the foreground band · the HUD. A creature
  is never drawn behind a prop it can strike from.
- **R5. A hazard is known three ways:** its shape (spiked, toothed), a
  rim of light along its top, and its place in the region's hazard
  colours. Brambles look like brambles in every region. ✅ shape and rim.
- **R6. A pit reads as a pit.** A drop whose landing is not on screen is
  a death, unless Resin hangs in it [decided: Resin never lies]. So
  **every safe drop is 7 tiles or less**, or marked with beads: the view
  shows 7.6 tiles below her feet.
- **R7. The foreground never hides the floor she walks on, a creature,
  or a hazard.** [decided] ✅
- **R8. Things that act are lit; things that don't are not.** Pickups
  bob. A switch has a rope to what it works. A bonus hollow glows teal.
  Scenery never glows, bobs or gleams.
- **R9. The colour language is law** (`CLAUDE.md`): Prism icy blue, Blight
  crimson, Anima teal, knots pale bark and amber, safety amber. A level's
  palette may not put a harmless thing in a hazard's colours.
- **R10. Machines are always in sight before they are used.** The camera
  shows a moving thing's whole path, or the path is drawn (the faint ring
  of a mill's cradles). [region 2's rule: "platforms move slowly, in
  sight".]
- **R11. The camera never moves on its own, never runs ahead, and ignores
  jumps.** [decided] ✅ Riding a machine is her moving: the view follows.
- **R12. Sound is half of reading.** Every tell, hit, landing, pickup and
  secret has a sound. ⬜ **The game has no sound at all** (no audio files,
  no player). At this bar it is the largest missing piece after C3.

---

# PART 3. LEVEL ARCHITECTURE AND SECRETS

## 3.1 The shape of a level: spine, ribs and a high road

- **A1. The spine.** One main line from start to gate, 480 to 640 tiles
  (12 to 16 screens; region 1: 10 to 12), always forward. A first-time
  player finishes it in 5 to 8 minutes. It never forks blind: where two
  ways show, Resin marks the spine.
- **A2. The ribs.** Short side loops off the spine (a pocket, a chest, a
  letter). Each **rejoins the spine ahead of where it left**, within two
  screens. A rib that is a dead end costs the walk back and teaches the
  player not to look.
- **A3. The high road.** One long second route a level, over the top (or
  under), a third of the level's length, harder than the spine and richer
  (a letter, a chest, a bonus entrance at its end). It comes down onto
  the spine before the banner or before the gate.
- **A4. Three lanes.** Low (the dare: beads by the hazard), main, high
  (the secret). A screen that uses all three is a great screen.
- **A5. Four beats on one idea:** teach, test, banner, twist, finish.
  [decided] Inside a beat a chain of three to five challenges, **no two
  in a row the same**, with one rest.
- **A6. The thirty-second rule.** Something new at least every thirty
  seconds of play: a new set-up, a creature, a tell, a view. If a level
  has a stretch with nothing to notice, the stretch goes.
- **A7. Six skeletons.** A level is one of: **the road** (horizontal),
  **the climb** (2 screens wide, 4 to 5 high), **the ride** (a machine
  carries her and the level comes at her), **the yard** (a small
  open pocket with a puzzle in a linear level), **the chase**, **the
  descent**. A region uses at least four, and never the same one twice
  running.
- **A8. The yard: puzzles in a stage platformer.** A puzzle lives inside
  two screens: what must change and what changes it are seen together
  (R8's rope). It has one step in region 2, two in regions 3 and 4, three
  later. It is solved by her verbs (strike, carry, throw, ride), never by
  a menu. Failing costs a retry, not a flame. Its answer, once seen,
  takes under twenty seconds to do.
- **A9. A fight needs room.** One creature: 12 flat tiles. A pair: 20.
  A lunging creature's stretch ends 4 tiles short of any pit (C10).
- **A10. Height comes from the land.** [decided] Raised ground, terraces,
  crates, pillars, islands; anything else she stands on is something
  real. A moving platform is a real machine (a raft, a lift, a mill's
  cradle).
- **A11. Climbs rest.** A ledge to stand on every 6 to 8 tiles of height;
  a fall costs ten seconds at most in regions 1 to 3.
- **A12. Walls that break belong to an ability's own region onward.**
  Cracked stone (a thrown crate) from region 1; bark-plate and hay (the
  Ward) from 2; bramble and silk (Emberwick) from 4. Never placed in a
  level played before the ability exists (M8).
- **A13. The level looks like a place.** Every piece has a reason to be
  there [decided: "nothing out of place"]. One landmark a beat, seen
  before it is reached. The gate is the level's last landmark and is
  seen from the finish beat's start.
- **A14. Flow is built in.** In the finish beat, moving things share one
  rhythm, so a player who keeps moving arrives as each arrives. (Mills of
  one period and four arms hand over with no waiting, whenever she
  starts.)
- **A15. Rate it, then remake the weakest.** `design/levels/ratings.md`:
  every level is marked, and no region ships with a level under ○.

## 3.2 The psychology of a secret

A secret is fair when the player, on finding it, thinks "of course", and
on missing it, thinks "I should have seen that".

- **S1. Six tiers, from constant to rare.**

  | Tier | What | A level | An attentive first play finds |
  |---|---|---|---|
  | 1 | Risky Resin (a dare beside the line) | 3 to 5 | most |
  | 2 | Chests, caches | 3 to 4 | about two thirds |
  | 3 | Letters | 4 | 2 to 3 |
  | 4 | Bonus areas | 2 | 1 |
  | 5 | The thorn knot | 1 | one in four |
  | 6 | The hidden exit | 1 a region | one player in three |

- **S2. Every secret has a tell that can be seen from the spine.** No
  unmarked false wall, no leap of faith without Resin, nothing found by
  rubbing along walls. The catalogue of tells:

  | # | The tell | What it says |
  |---|---|---|
  | 1 | A trail of Resin leaving the path | "the ground goes on this way" |
  | 2 | One bead out of reach | "there is a way up here" |
  | 3 | Motes drifting into stone; moss | "this wall is not a wall" |
  | 4 | The thing itself in plain sight, out of reach | "work out how" |
  | 5 | A break in a pattern (the one pillar with no torch) | "look again" |
  | 6 | A glimpse at the edge of the view | "the level is bigger than the path" |
  | 7 | A machine that goes on past where everyone gets off | "stay on" |
  | 8 | A creature that comes out of, or goes into, nowhere | "there is a door" |
  | 9 | Her Lantern pulsing; a hum that swells | "close: within four tiles" |
  | 10 | A tool with nothing to use it on (a crate, no cracked wall) | "carry it further" |
  | 11 | The way back (the one time left is right) | "you assumed" |

- **S3. A level's tells differ.** No tell twice for the same tier in one
  level; no tell more than twice in a level. [decided, from DKC3's
  mistake.]
- **S4. Train, then turn.** A region's first level shows its new kind of
  secret where it can't be missed. By level 4 the same kind is hidden.
  The knot turns a habit the level itself just taught.
- **S5. The best hiding place is an assumption.** Everyone gets off the
  ride at the landing. Everyone uses the crate where it stands. Everyone
  goes right. The knot lives behind one of these.
- **S6. Looking is never punished.** A wrong guess costs time. A secret
  route may be hard; the way *to* its entrance is safe.
- **S7. The Lantern is the last hint.** Within four tiles of a hidden
  letter or entrance her Lantern pulses and hums. Deaf-proof and
  blind-proof: light and sound both. ⬜ in the plan since the first
  draft, not built.
- **S8. The map names what is missing** (letters, tokens, knot, the second
  exit), level by level ✅, and the map-maker sells a line of hint for
  each ⬜.
- **S9. The bonus level and its two doors.**
  - It shows on the region's map as a "?" once level 3 is done: the
    player knows it exists long before they can enter.
  - **The collector's door:** 8 of the region's 12 tokens.
  - **The explorer's door:** the hidden exit in level 4 or 5. Found, it
    opens the bonus level at once, tokens or not, and that level's stop
    wears a second ring.
  - The hidden exit uses the region's machine or ability in its most
    sideways way, and has a two-step tell: a far glimpse early in the
    level, a near tell at the place.
  - The bonus level: two to three minutes, **no banner**, one idea pushed
    past what the region dared, few or no creatures. Its end holds a wick
    and the region's seventh knot.
  [the docs said both "tokens open it" and "a hidden exit leads to it";
  this keeps both. Proposed.]
- **S10. One hundred per cent is always possible on the first visit.**
  [decided: M8.]

## 3.3 The boss: the region's level 7

- **B1. The approach is quiet.** Sixty to ninety seconds with no
  creatures: the boss's work all round her, the region's music thinned to
  one instrument. One last easy use of the region's machine. Dread is
  built by taking things away.
- **B2. The banner stands at the door.** A retry puts her back in the
  fight in five seconds. The approach is walked once.
- **B3. The arena is the region in one room.** A screen and a half to two
  screens wide, a flat floor, and the region's machine in it (a mill's
  cradles, silk to bounce on). The camera holds still. Every edge is in
  view.
- **B4. The boss is the final exam.** Three phases, each asking for what
  two of the six levels taught, with the sword as the answer:
  teach the tell (phase 1), test it with the machine (2), twist it
  (3). Nothing in the fight is new; everything is harder.
- **B5. It is hurt in openings, not ground down.** The boss can be struck
  only in a window the player opens by doing the region's thing right
  (parry the orb back, ride the cradle to its head). Three openings a
  phase. Its health is nine openings, not a bar to chip.
- **B6. Fair, by the numbers.** Wind-ups by T2. Before any attack that
  covers the floor, the safe place is visible. Never more than two
  patterns at once. A pattern is seen alone before it is combined.
- **B7. A fight is two to four minutes, and the floor can win it.** It
  can be beaten on three flames (E4). One amber sap falls at each phase
  change, only for a player on their last flame.
- **B8. The ability is handed over in the arena and used to leave it.**
  The way out is a thirty-second playground for the new move with no way
  to fail. It is the next region's first lesson.
- **B9. Then the Refuge.** The captives walk in; one of them opens a
  stall; two Kindreds who would not share a fire now do. The reward for
  a boss is a changed place, not a number.
- **B10. No runback, no second lantern, no cutscene before a retry.**

---

# PART 4. THE SIX-LEVEL TEMPLATE

## 4.1 What each stop is for

| Stop | Name | Mechanical job | What the player should feel | Hardness | Skeleton | Length |
|---|---|---|---|---|---|---|
| **1** | **Arrival** | The biome and the new ability, each taught where failing is free. The region's first creature, alone. The region's kind of secret, shown in the open | Wonder: "a new place, and look what I can do" | 3 | Road | Short: 4 to 5 min |
| **2** | **The machine** | The region's own moving thing, alone: taught, tested, turned. The first puzzle | Delight: "this is a toy" | 5 | Road, with a yard | 6 min |
| **3** | **The climb** | Height. A change of pace and of shape; the second creature. From the top: the boss's place, far off | Awe, and a breath | 4 | Climb | 5 min |
| **4** | **The hazard** | The region's signature danger, with its creatures at strength and in pairs. The mid-region test of traversal. *May hide the exit* | Tension: "careful now" | 6 | Road or descent | 7 min |
| **5** | **The remix** | Two of the region's ideas joined, plus one from an earlier region; the set piece (a chase, a ride). The elite, once. *Hides the exit if 4 doesn't* | Surprise, then mastery: "I know this, but not like this" | 7 | Ride or chase | 7 min |
| **6** | **The gauntlet** | Everything the region taught, in the order it was taught, without the rests. One arena that locks. Ends at the boss's door | Resolve: "I'm ready" | 8 | Road | 8 min |
| **?** | **The bonus level** | One idea pushed past what the region dared. No banner. A wick and a knot | Pride | 9 to 10 | Any | 2 to 3 min |
| **7** | **The boss** | The exam (§3.3). The ability | Dread, then release | 8 | Arena | Approach 90 s, fight 2 to 4 min |

The slots can trade places where a region's story wants it (region 1's
climb and its machine are levels 3 and 4), but **the hardness curve
(3, 5, 4, 6, 7, 8) and the two rules "level 1 teaches the ability" and
"level 6 ends at the door" do not move.**

How the six came from the five in `game-structure.md`: the old 1 to 4
keep their jobs; **the remix is the new level 5**; the gauntlet moves to 6.

## 4.2 The regions against the template

| | 1 Arrival | 2 Machine | 3 Climb | 4 Hazard | 5 Remix | 6 Gauntlet |
|---|---|---|---|---|---|---|
| **1 Ironbark Wilds** | The Overgrown Ruins ✅ | The Gate Road (blockout) | The Ruin Gardens | The Aqueduct (its machine: raft, lift) | **new, to be named** | The Lantern Clearing |
| **2 Hearth-Plains** | The Golden Road | **Millers' Row** (blockout, this branch) | The Great Mill | The Thorn Hedges | The Harvest Run | Silkfall |

Region 2 in full: `design/regions/2_hearth_plains.md`.

## 4.3 The checklist every level is held to

A level is not shown to the creative lead until all of these are true (it
replaces the shorter list in `design/levels/ratings.md`).

**Shape**
1. One idea, in four beats; the idea can be said in one phrase. (A5)
2. Inside each beat, a chain; no two challenges in a row alike; one rest.
3. A spine that never forks blind; ribs that rejoin ahead; one high road.
   (A1 to A3)
4. Something new every thirty seconds. (A6)
5. Its skeleton differs from the level before. (A7)
6. Something this level has that no level before it had.

**Fairness**
7. Every required gap and landing is within the region's numbers, with
   the plain jump. (P6, K2)
8. Nobody waits more than the region's time for a moving thing. (P7)
9. Every machine's path is in sight before it is used. (R10)
10. Every safe drop is 7 tiles or less, or hung with Resin. (R6)
11. No creature's stretch ends within 4 tiles of a pit; a fight has its
    room. (A9, C10)
12. One mistake, one flame: any hit-then-fall is in plain view and after
    the banner. (E13)
13. One banner, at the middle, on safe ground, before the hard half. (M5)

**The hunt**
14. Four letters (two on the line, two off), two bonus areas, one knot.
15. Every secret has a tell seen from the spine; the level's tells
    differ. (S2, S3)
16. Resin never lies; three to five dares beside the line. (E12)
17. The knot turns a habit the level taught. (S5)

**Proof**
18. A scripted tour walks the whole spine; a second finds every secret.
    Both pass.
19. It has a mark on the ratings board, and a note of what would raise it.

## 4.4 The checklist for a region

1. Six levels, a bonus level, a boss; the hardness curve holds. (P1)
2. One ability, taught in level 1, needed by level 2, mastered by 6, and
   both a weapon and a move. (C9)
3. One machine, one hazard, three to four new creatures, each arriving
   alone. (P3, P4)
4. At least four skeletons; never one twice running. (A7)
5. The boss foreshadowed three times; its fight asks only for what the
   six levels taught. (P5, B4)
6. Twelve tokens, eight open the bonus level; a hidden exit in 4 or 5.
7. The region's first level is no harder than the last region's third.
8. A new look, and a palette that keeps the colour language. (R9)

---

# PART 5. THE AUDIT: THE GAME TODAY AGAINST THE RULEBOOK

## 5.1 What is strong

- The stage loop exists end to end: map, level, banner, tally, save, map,
  with a per-level record. (M2, M3, M5 to M8)
- Kleo's base movement has the invisible kindness the best games have,
  and a momentum move the creative lead liked. (K1, K2)
- The sword already steps her forward and can be cancelled out of
  quickly; hit-stop is careful. (C1, C2, C7)
- The lunger is a properly telegraphed creature with a punish window and
  a real interrupt. (T1, T2, T6, T7)
- Hitboxes already favour the player in both directions. (T5)
- The secret system has tiers, tells, an honest currency and a map that
  keeps score. (S1 to S3, S8)

## 5.2 What breaks a rule, most important first

| # | Finding | Rule | What to do | Size |
|---|---|---|---|---|
| 1 | **The sword and the stride cancel each other.** A swing ends the stride and brakes her | C3, pillar 2 | The stride cut; then a jump out of any hit that lands (C4). Prototype in the systems arena, tune by the creative lead's play | Small to build, large in effect |
| 2 | **There is no sound.** No effects, no music, no player | R12, T3, S7 | A sound pass: about 40 effects (feet, sword, hits, pickups, tells, machines, the map) and a theme a region | Large; needs the creative lead's sources |
| 3 | **Only one creature fights.** Region 1 needs three to four; region 2 needs a caster for the Ward's parry, a heavy for its bash, and pairs | P3, T11 | Build the roster's bat (flier), toad (hopper) and shaman (caster) as their own verbs | Medium each |
| 4 | **Resin can be farmed** by replaying a level, and has nowhere to go: the Refuge isn't built | E8, E11 | Pay only what beats a level's best haul; then the Refuge with two stalls (healer, kitchen) | Small; then large |
| 5 | **The flame sums contradict** (3 + 7 + 4 against a cap of 8) | E3 | Wicks | A decision |
| 6 | **The bonus level has two different doors in the docs** | S9 | Both, as two roads to one door | A decision |
| 7 | **Six levels, not five.** Region 1 has no fifth level yet and its painted map has six pads and a "?": with six levels, a boss and a bonus level it needs seven pads, or the boss lies through level 6's gate at the skull | M9 | The creative lead's word on the map; a name and an idea for region 1's remix level | A decision, then a level |
| 8 | **No boss exists and no boss rules did** | B1 to B10 | Region 1's fallen warden to §3.3, once levels 3 to 6 stand | Large |
| 9 | **Pairs could wind up together** | T8 | A turn-taking rule in `lunger.gd` (built with this document; 2-2's tour watches a pair for ten seconds) | Done |
| 9b | **A creature hurts by touch even when it is only walking** | T4 | Contact hurts in the strike and the skid only; a walking creature shoves | Small |
| 10 | **No corner correction** | K1 | Nudge her round a corner clipped by 4 px or less | Small |
| 11 | **The Lantern's pulse near secrets** was promised and isn't built | S7 | Build it with the sound pass | Small |
| 12 | **The tally doesn't hook.** Nothing shows the next stop opening or celebrates a full record | M4 | The stop opening on the map; a gold mark for a full record | Small |
| 13 | **The down strike's pogo and the up strike are in no level** | C6 | One optional pogo route from region 1's level 4 on | In the levels |
| 14 | **No level checker knows the fairness rules** (pit margins, safe drops, waits) | §4.3 | Extend `tools/check_room.py` to levels: drops, gaps, landings, enemy margins | Medium |
| 15 | **1-1 teaches seven things; 1-1's bonus areas are the old kinds; 1-2's twist is a metronome** | A5, S1 | As already planned in `ratings.md` | In hand |
| 16 | **Nothing helps a player who is stuck** beyond replaying | E10 | The kitchen's meal; later an assist menu (slower game speed, an extra flame) that changes no level | Later |

## 5.3 The order I would do them in

1. **The stride cut and the jump out of a hit** (finding 1). It changes
   how every level should be built, so it comes before more levels.
2. **Two more creatures** (3), so pairs and mixed pairs can be designed.
3. **The creative lead's decisions:** wicks (5), the bonus level's two
   doors (6), region 1's sixth level and the map (7).
4. **Region 2's levels**, to the template, Millers' Row first.
5. **Sound** (2), as soon as there are sources: it is half the feel.
6. **Resin paid once, then the Refuge** (4).
7. **The first boss** (8).

## 5.4 What this document changed in the game and the docs

- `design/game-structure.md` §2 and §5: eight stops a region; the six-level
  template; wicks and the two doors marked as proposed.
- `design/levels/ratings.md`: the checklist is §4.3's.
- `lunger.gd`: a pair takes turns (T8).
- `kleo.gd`: a jump from a rising platform keeps its lift (K4).
- Region 2 planned to the template, and its second level built as a
  blockout: `design/regions/2_hearth_plains.md`,
  `design/levels/2-2_millers_row.md`.
