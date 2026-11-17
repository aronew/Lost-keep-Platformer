# 2-2 Millers' Row (blockout, awaiting the creative lead's review)

Builder: `game/tools/build_l2_2.gd` → `game/scenes/levels/l2_2_millers_row.tscn`
(`blockout = true`: the black box, labels, real or stand-in sprites for
everything that acts; no art until the layout is approved).
Pictures: `docs/levels/2-2/blockout/` (the poster with the walked routes:
amber the main line, teal the secrets; an in-game shot of every beat; the
map's region 2 page).

**To play it:** on the map press **F4** (every built stop opens), then
**Tab** (region 2's page). Kleo stands on stop 2. Jump enters.

**The level's one idea: the turning mill.** A windmill's sails carry hoist
cradles round, level as a Ferris wheel's. She steps on one and is carried:
up and over, or down and under, by which way the mill turns. Region 2's
machine level (`design/rulebook.md` §4.1, stop 2;
`design/regions/2_hearth_plains.md`).

**Why a mill.** It is a moving platform that belongs where it stands, and it
is a **loop**. A player who stays on is never dropped; she is brought round
again. So missing a landing costs seconds, never a flame, and that makes
the machine safe to be curious about. Every secret in the level comes from
asking "what if I stay on?", "what if it turned the other way?", "what if
that one woke?".

## Size and shape
- 530 × 46 tiles (8,480 × 736 px): about 13 screens long and 2 high. The
  room is 638 wide: its two bonus areas lie beside the level (x 542–634).
- The road is row 30. The land rises through the level (the yard at row 24,
  the granary at 22, the midway terrace at 18) and the gorges between are
  pits.
- Start at x 5. The Great Mill's door is at x 516 (it is 2-3's way in).
- **One checkpoint, at the middle** (x 272): the banner on the midway
  terrace, before the mills that must be set.
- **14 mills** on the level, 3 in the bonus areas, one sack hoist.

## The four beats

| Beat | Tiles | What happens |
|---|---|---|
| **TEACH** | 0–80 | **The cart rut**: region 2's gap of 5, first as a dry dip 2 deep. **The first mill, over the road**: a cradle comes along the bottom, 1 above the road; she hops on and it lifts her 6 to the yard. A fall is onto the road. Stay on and it brings her round. The yard: a chest, a Mossback. |
| **TEST** | 80–264 | Mills over the gorge, **a chain of five, no two alike** (below). A pair of rats on the threshing road. The sack hoist is the rest. |
| **TWIST** | 290–446 | After the banner, **mills that must be set**: one asleep, with its bell by the path; one that turns the wrong way, into brambles, with a vane; one asleep whose bell hangs over the gorge, out of the sword's reach, and a crate. Then a plain mill, and beside its landing the old mill, asleep: the great secret. |
| **FINISH** | 446–530 | **Three mills in step**: over, over, and under. They share one rhythm, so each cradle is there as she arrives, whenever she starts (rulebook A14). The Great Mill's steps, a chest, the door. |

### The test's chain
Each is the last one made harder, or the last one with something added:

| # | The mill | Cradles | What is new |
|---|---|---|---|
| 1 | The first gorge: up and over | 4, 3 wide | The first ride over a pit; a cradle every 2.5 s |
| 2 | The great wheel (radius 7) | 3, 3 wide | A longer ride, a wait of 3 s for the next cradle: commit to one |
| 3 | **The rest:** the sack hoist | n/a | It waits for her and lifts her 8 to the granary |
| 4 | The twin mills | 4 and 4 | Cradle to cradle with no ground between (2 across). They turn in step: both are at the middle together |
| 5 | The great wheel, narrow | 3, **2 wide** | Region 2's smallest landing; and the way out is 4 above the hub: she steps off early |

### The twist's chain
| # | The mill | The puzzle (rulebook A8: one step, what changes and what changes it seen together) |
|---|---|---|
| 1 | Asleep (sails furled) | A **bell** on a post beside the path, a rope from it to the mill. A sword strike wakes it. |
| 2 | Turning the wrong way | Its cradles go down into the brambles. A **vane** on the landing turns the wind; then it goes up and over. Ridden the wrong way she is hit once and thrown clear into the lane under the mill: a chest, a second vane, and a cradle back up. No second flame (E13). |
| 3 | Asleep, its bell at its hub over the gorge | The sword can't reach. **A crate** stands on the landing: thrown, it rings the bell. A crate that misses is back in 2.5 s. |
| 4 | A plain mill | The rest before the finish; and the way to the knot (below). |

## Region 2's rules it keeps (rulebook P6, P7)
- Widest required gap 5 (the rut, over ground); over a gorge the widest is
  2. Smallest landing 2 (the narrow cradles).
- **Nobody waits more than 3 s** for the next cradle; mostly 2 to 2.5 s.
- Every cradle moves at 50 to 80 px/s (her run is 140), and every mill's
  whole circle is in view before she boards (a faint ring marks it).
- **A pair of rats takes turns**: never two wind-ups at once (T8). Their
  stretch is 13 tiles of open road. One hood, alone, with 22 tiles to
  fight in (it is region 2's creature, met in 2-1; pairs of it start in
  2-4).
- No creature's stretch ends within 4 tiles of a gorge (A9).
- **No platforms** but the real ones: a mill's cradles, a hoist. Everything
  else she stands on is ground, a branch or a roof.
- A jump from a rising cradle goes a little higher; from a falling one it
  is never weaker (K4).

## Secrets and Resin
- **Letters (4):** K over the top of the first gorge's ride (a hop at the
  top) and O over the last hand-over (on the main line); L on the roof road;
  E behind the false wall.
- **The great secret: Morvath's thorn knot.** Beside the last plain mill's
  landing stands **the old mill**, asleep, its cradles out of reach, and
  over its top a branch with the knot on it, in plain sight. Its bell hangs
  high in the air beyond the top of the plain mill's ride: no sword reaches
  it and nothing stands near it. On the landing before the plain mill is a
  crate with nothing to throw it at. **Carry the crate onto the wheel and
  throw it from the top of the ride.** The old mill wakes; its cradle lifts
  her from the yard to its top, and a jump through the branch reaches the
  knot. (A leap from the cradle and a slash in mid-air rings the bell too:
  the daring answer.)
  It turns the habit the twist just taught, that a crate is thrown from
  where it stands (S5). Its tells: the bell and its rope, the knot itself,
  and a tool with nothing to use it on (S2, tells 4 and 10).
- **The roof road** (the high road, A3): at the top of the second twin
  mill, three beads climb straight up. A jump there goes up through a
  branch (2.75 up) onto five roofs and branches over the upper field and
  the great wheel: **letter L** on the third, and at the end of the fifth
  **a glowing hollow: bonus 1**. Off its end she lands on the midway
  terrace, before the banner.
- **Stay on the ride** (bonus 2): on the great wheel everyone gets off at
  the landing. Beads go on down the arc. Stay on, and five tiles below the
  landing the cliff's foot juts out under it: a cave, **a glowing hollow:
  bonus 2**. The way back is a ledge catch, or the next cradle.
- **Both bonus areas are Resin rushes on the mills.**
  - **Bonus 1** (18 s, 21 Resin): one great wheel over a floor. A ring of
    Resin along its ride, three over its top (a hop there), four along the
    floor. Once round takes it all. The token is on the floor.
  - **Bonus 2** (20 s, 20 Resin): two small mills between ledges over a
    drop: up and over the first, down and under the second, Resin along
    both arcs.
- **The false wall:** the road runs on under the first mill to the yard's
  wall, a dead end (motes drift into it): **letter E** behind it.
- **Chests (4):** the yard, the granary, the bramble lane, the Great Mill's
  steps.
- **Risky Resin:** round the bottom of the first gorge's mill, under the
  hub, over the pit (stay on past the landing: the mill brings her round);
  two beads in the rut; three over the top of the first mill.
- **Five different tells** (S3): beads climbing (the roof road), beads
  going on down the arc (the cave), motes into stone (the false wall), the
  knot and its bell in plain sight, a crate with nothing to throw it at.

## What is new in the game with this level
- **`windmill.gd`, `_windmill()`**: the mill and its cradles; it eases into
  every change, so a rider is never thrown.
- **`mill_bell.gd`, `_mill_bell()`**: the bell (wakes) and the vane (turns),
  struck by the sword or a thrown crate, each with a rope to its mill. One
  meaning each: a bell starts, a vane turns.
- **A crate that comes back** (`Carriable.returns`): a puzzle's crate is
  never a dead end.
- **A wide thicket throws her one way** (`HazardArea.push_dir`): out, never
  deeper in.
- **A pair takes turns** (`Lunger._may_wind_up`, rulebook T8).
- **A jump from a rising platform keeps its lift** (`kleo.gd`, K4).
- **The map has a page a region**; region 2's is a stand-in.

## Validation (in engine)
`cd game` then:

```
xvfb-run -a godot --path . --fixed-fps 60 --audio-driver Dummy res://tests/playtest.tscn -- room=l2_2 mode=tour
```

- `mode=tour` (the main line, enemies held still): **ALL PASS**, 36 checks:
  the rut, the lift to the yard, both gorges, the hoist, the hand-over
  between the twin mills, the narrow cradles and the high landing, the
  banner; the bell struck and the sleeper crossed; the vane struck and the
  wrong-way mill crossed; the crate thrown across the gorge onto the far
  bell; the three mills in step; the door.
- `mode=secrets`: **ALL PASS**, 46 checks: the yard out of reach from the
  road; the false wall and letter E; letter K at the top of the ride; the
  risky Resin round the bottom and the mill bringing her back; staying on
  the great wheel to the cave and bonus 2, all 20 Resin and the token, and
  the ledge catch back up; the roof road end to end, letter L, bonus 1, all
  21 Resin and the token; the wrong way into the brambles costing one flame
  and landing her in the lane, its chest, its vane, and the cradle back up;
  the old mill out of reach asleep, the crate carried onto the wheel and
  thrown from the top, the old mill woken, its cradle, the branch, the
  knot; letter O; all four chests; and the pair of rats taking turns (7
  lunges in 10 s, none overlapping).
- `mode=knot`: the great secret alone.
- `nocap=1` runs a tour without saving frames (about twice as fast).
- `mode=shots` and `mode=map`, then `python3 tools/stitch_map.py l2_2` and
  `python3 tools/level_poster.py l2_2 room_routes 5` for the poster.

## Changed while building it
- **The roof road's last roof hung over the great wheel's landing**, and a
  plain jump onto the landing went up through it and stopped there: the
  main line was caught by a secret. Moved clear (rulebook A1: the spine is
  never blocked by a rib).
- **The bonus wheel's ring had Resin at the top and just past it**, where
  she is in the air taking the three above: two beads no one could take.
  Removed.
- **The map tool clamped the camera to the level**, so bonus areas never
  showed on any poster (1-2's and 1-1's too). Fixed in `playtest.gd`.
- **The scripted player lost count during a hit-stop** (it ends on the
  real clock, so its length in frames changes from run to run): a tour's
  frames are now game frames.

## Open for the review
- **The idea itself:** are cradles on a mill's sails the right machine for
  the Hearth-Plains? (They are a stand-in drawing: timber cradles, canvas
  sails, a tower in the backdrop.)
- **Length:** 14 mills in 530 tiles. Too many of one thing, or right for
  the machine's own level?
- **The pace of a mill:** a turn takes 8 to 10 s. Slower is calmer and
  duller; faster is harder. (Nothing in the game makes a sound yet, and a
  mill's creak and a bell's ring will change how these feel.)
- **The knot** asks for a crate carried onto a moving cradle and thrown
  from its top. Cunning enough, or too much?
- **The wrong-way mill** costs a flame to try. Kind enough?
- **The hood** is the roster's `hood_knife` as a lunger, a stand-in for a
  creature with its own verb.
- **The look:** there are no mockups for region 2 yet.
