# What makes a 2D platformer fun: research notes

Research for Lost Keep: Platformer, asked for by the creative lead (2026-11):
what makes side-scrolling platformers fun, challenging and worth exploring,
with Donkey Kong Country 1, 2 and 3 and the Super Mario games as the models.

**How to read this.** Each claim is marked by where it comes from:
- **[source]** a designer's own words or a published analysis, linked at the
  end.
- **[games]** how the games themselves are built (wiki-checked facts).
- **[mine]** my own reading, or what I think it means for our game.

Several pages I wanted would not open (the Medium study of Jungle Hijinxs,
Retro Gamer's DKC2 feature, the Tuts+ series on Super Mario World's method,
the full Eurogamer 1-1 video). Where I lean on them it is through other
sites' summaries, and I say so. Nothing here was play-tested: these are
ideas to try, not findings about our game.

---

## 1. The short version

Ten things the great ones share, most important first.

1. **Moving is fun before there is a level.** The character's run and jump
   feel good on a flat floor. Everything else is built on that.
2. **One idea per level, played in four steps:** shown safely, tested with a
   cost, turned, then finished with a flourish.
3. **The level teaches; no text does.** The first enemy, the first pit and
   the first secret are each placed so that the player works them out.
4. **Two games in one.** Getting to the end is easy enough for anyone;
   finding everything is the real challenge, for those who want it.
5. **Pickups are the designer talking to the player.** They show the line of
   a jump, mark safe drops and point at secrets, and they never lie.
6. **Secrets are fair.** They are meant to be found: a clue, a pattern, a
   reward. The best ones turn the player's own assumptions against them.
7. **Flow for the skilled.** With the right timing the obstacles line up, so
   a good player never has to stop.
8. **Tension and release.** Hard stretches are followed by calm ones;
   checkpoints sit before the hard part.
9. **Surprise.** Every level has something the last one didn't.
10. **Kindness in the controls, firmness in the level.** Inputs are forgiven
    by a few frames; the challenge itself is not watered down.

---

## 2. The feel of the character

- **Forgiveness the player never sees** [source: Maddy Thorson on Celeste].
  A jump still works a moment after leaving a ledge (coyote time). A jump
  pressed just before landing fires on landing (buffering). Gravity is
  halved at the top of a held jump, giving time to aim the landing. A head
  that clips a corner is nudged round it. Thorson's point: the game is very
  hard, and these make it feel kind.
- **Weight and momentum** [games]. Mario accelerates and skids; holding run
  changes every jump. Donkey Kong's roll carries speed, and jumping out of a
  roll, even just past a ledge, goes farther than a plain jump. Both give a
  skilled player a faster, riskier way to do the same thing.
- **The movement came first** [source, secondhand]. Coverage of Miyamoto and
  Tezuka on World 1-1 says the level was tuned to Mario's momentum, and that
  1-1 was among the last levels made, once the team knew what was fun.
- **Small details add up** [source: Kooiker on DKC]. A landing sound that
  gives weight, a platform that dips when landed on: players judge the game
  by the sum of things they never consciously notice.

**For us** [mine]. Kleo already has a variable jump, coyote time (0.1 s), a
jump buffer (0.12 s) and lighter gravity at the top of a held jump. What she
lacks is corner correction, and anything like DKC's roll: **a fast move that
rewards skill and carries momentum into a jump.** Her combo steps forward
with every hit, which could be that move if a jump out of it kept the speed.
Worth a prototype before more levels are built round her current envelope.

---

## 3. How a level teaches and builds

- **Four steps** [source: Koichi Hayashida, via Game Maker's Toolkit and
  Kotaku]. Mario's levels since Galaxy 2 introduce one idea where failing is
  safe, remove the safety net, expand it, then twist it, and are done.
  Hayashida: "we would start with a very clear concept on a stage and it
  would be maintained through." Then the idea is thrown away and the next
  level has a new one.
- **Teach by placement** [source: Miyamoto and Tezuka on 1-1; Koncewicz on
  Super Mario Bros. 3].
  - The first enemy was going to be a Koopa. It needed two skills at once,
    so the Goomba was invented: one jump beats it.
  - Tezuka: new players usually fall in the first pit, "but they learn from
    it." The two gaps later in 1-1 are there to teach the running jump.
  - A "?" is a universal invitation. A plant coming out of a pipe says pipes
    can be used. Enemies dropping from above say there is something up
    there.
  - New things are met first in a safe spot: the tiny Goombas that slow
    Mario appear first where nothing else threatens.
  - Set a pattern, then break it once: it makes a level feel new.
- **Challenges in a chain** [source, secondhand: Holleman's study of Super
  Mario World]. A level is a run of small challenges on one theme. Each is
  either an *evolution* (the same thing, harder: a wider gap) or an
  *expansion* (the same thing, with more: a second enemy). The run rises,
  with short rests.
- **Several ideas, combined** [source, secondhand: Game Maker's Toolkit on
  Tropical Freeze]. Retro Studios' DKC levels introduce more than one idea
  and spend the level combining them. This is the step beyond one idea a
  level, and probably one for later regions.
- **Rate every level, remake the weakest** [source: Iwata Asks, DKC
  Returns]. The team kept a whiteboard with every level marked ×, △, ○ or
  ◎, and reworked levels until all had ◎. A level rated the most fun early
  on was the least fun once the others improved, and was remade.

**For us** [mine]. Our four beats (teach, test, twist, finish) are this
structure, so the bones are right. The gaps:
- **1-1 teaches too many things** (jump, ledge catch, combo, crate, water,
  chest, false wall). That is right for a first level, but its beats don't
  share one idea. 1-2 does (hopping over water).
- **We have no chain within a beat.** 1-2's long pool is seven hops of the
  same size. Hayashida and Holleman would make hop 4 different from hop 1:
  a narrower stone, then a moving one, then one with an enemy on it.
- **A ratings board** for our levels costs nothing and would have caught
  that.

---

## 4. Donkey Kong Country 1, 2 and 3

### DKC 1: flow
- **The model was Super Mario Bros. 3** [source, via the Mario wiki and
  Wikipedia]. Gregg Mayles wanted its structure with levels that flow: if
  the player has the timing, the obstacles line up and a skilled player
  moves through without stopping.
- **A clean screen** [source]. Almost no HUD. The second Kong is the health
  bar: it is Mario's big-and-small in another form.
- **Levels built round a mechanic** [games]: mine carts, barrel cannons,
  ropes that slide, lights that go out, a fuel platform.
- **Planned on Post-it notes** [source]: beats that can be reordered before
  anything is built.
- **67 bonus rooms** [games], two or three a level, behind walls broken with
  a barrel or an animal, or inside barrels. Many are just a room of prizes;
  entering is what counts. Six kinds of game.
- **Its flaw** [source: Sirlin]. Any pit might hide a secret or might kill.
  That teaches the player to jump in pits, which is no fun.

### DKC 2: exploration
- **A deliberate change** [source: Mayles, via Retro Gamer and the Mario
  wiki]. A second game of speed-run levels would have been the same game, so
  2 turned to exploration.
- **Tiers of secrets** [source: Sirlin]. Each level has one great secret
  (the DK coin), one to three bonus rooms, and small prizes. The map shows
  what is found and what is missing, level by level. Cranky taunts that you
  will never find them all.
- **Bonus rooms are a short timed test** [games], three kinds: collect every
  star, destroy every enemy, reach the token. Each pays a Kremkoin; 15
  Kremkoins open one level of the Lost World, 75 in all.
- **Bananas never lie** [source: Sirlin]. A banana over a pit means the pit
  is safe. One banana out of reach marks a secret. Bananas in the shape of
  an arrow point at something real. He calls them "a character ... trying to
  help you at all times."
- **Rules trained, then broken once** [source: Sirlin]. Ten levels start on
  the left and scroll right; then one hides its DK coin just left of the
  start. Bonus rooms never hold secrets; then one does.
- **Fair secrets** [source: Sirlin]. They are "meant to be found": hidden
  long enough to feel earned, with enough clues to get there. He guesses the
  whole system was about 5% of the work and the difference between "a C-
  game and an A+ game."
- **Animals with levels of their own** [source: Arc Rose]. In 1 the animals
  were a bonus. In 2 each changes how a level plays: the spider's webs make
  platforms, the parrot flies through brambles, the snake climbs.
- **Themes rationed** [source: fan analysis]. Thirteen level themes, each
  used three times, never more than twice running.
- **Difficulty that climbs** [source: Arc Rose]. Steadily, with a few
  really hard levels for a sense of achievement, and failures that feel
  like the player's own.

### DKC 3: the cautionary tale
- **What worked** [source: Retronauts, Retroware]. One strong gimmick a
  level keeps the player curious. The overworld is a place to explore, with
  hidden caves, not a menu.
- **What didn't** [source: Retronauts]. The bonus games are dull (collect
  green bananas in a small room). The DK coins are all held by the same
  enemy with the same trick, so the hunt stopped being clever. Some
  gimmicks are chores. The secrets were "more ingenious" before.
- **Bonus entrances became barrels only** [games]: no more breakable walls.

**The lesson of the three** [mine]. 1 found the feel, 2 found the hunt, 3
shows that a formula repeated without new cleverness goes flat. The hunt is
what people remember.

---

## 5. Super Mario

- **Play your own difficulty** [source: Miyamoto]. "The best method is when
  the player can adjust the difficulty himself while playing." Super Mario
  World's switch palaces fill in blocks across the game: find them and it
  gets easier. He also wanted "a game that isn't simply about reaching the
  end of the level."
- **Power-ups are health and a toy at once** [games]. A hit costs the
  power, not the life. Losing the cape or the fire hurts more than losing a
  heart, and getting it back is a small goal inside every level.
- **Secret exits change the map** [games; source: Lewis]. In Super Mario
  World a second exit opens a new road. Hidden levels show as silhouettes
  once their neighbours are cleared. Star Road links the secrets into a
  network, and beyond it the Special Zone holds the eight hardest levels,
  with no checkpoints: the prize for curiosity is more game.
- **Warps reward knowledge** [games]. Warp zones and whistles let those who
  know skip ahead.
- **Short levels, constant novelty** [source: Koncewicz]. Super Mario
  Bros. 3's levels are brief and each has its own trick: a sun that
  attacks, a level played at a run, coins that turn into a bridge.
- **A warning** [source: Lewis]. Super Mario World's cape lets a player fly
  over whole levels, and its skies are empty. A power that skips the level
  design undoes it.
- **A world full of secrets, again** [source: the Wonder team at GDC 2024].
  Wonder began as a return to the first game's secret-filled world. The
  whole team, first-years included, pitched surprises on sticky notes, over
  2,000, each one sayable in a single phrase. Good ideas that didn't fit
  were reused elsewhere, never thrown away.

---

## 6. Secrets, bonuses and curiosity

Put together, the rules for a good secret:

1. **It is meant to be found.** A clue, always: a pickup out of place, a
   path that "just looks right", a gap in a pattern.
2. **The currency tells the truth.** If beads lead over an edge, there is
   ground there. Never a bead over a death.
3. **Tiers.** Small finds often, bigger ones rarely, one great one a level.
4. **The game keeps score, per level.** Players hunt what they can see is
   missing.
5. **The prize is more game.** New levels beat a number going up.
6. **Train a habit, then break it once.** The best secrets hide behind what
   the player has stopped checking.
7. **Searching is never punished.** Hazards can be passed at a run; looking
   round costs time, not lives.
8. **A bonus is short, clear and can be tried again.** One screen, one
   goal, a clock.

**For us** [mine].
- We keep score (letters, tokens) but only on the level's end tally. **A
  per-level record on a map** is what makes the hunt.
- We have two tiers (Resin; letters and tokens). **We lack the one great
  secret per level**, DKC2's DK coin: one thing, hidden with real cunning.
- **Our beads must never lie.** They mostly mark jumps already. Make it a
  rule: a bead over a drop means safe ground below.
- Our tells are the same three each time (motes into a wall, beads, a
  glow). DKC3 shows where one trick repeated leads.
- 1-2's hidden landing is found by beads stepping off an edge. Good. Its
  high path is found the same way. Two different tells would be better.
- The Resin rush the creative lead asked for is DKC2's "collect the stars":
  the kind that has aged best.

---

## 7. Challenge and pacing

- **Hard is fine; unfair is not** [source: Tanabe on DKC Returns]. The team
  kept Returns hard on purpose and added a guide for stuck players. Almost
  nobody used it: "players want to clear levels by themselves in the end."
  Tropical Freeze added help without lowering the difficulty.
- **Tension and release** [source: level design guides]. A level hard from
  end to end is exhausting. Alternate.
- **Checkpoints and health** [source: Yacht Club Games]. Health goes near
  checkpoints, since a checkpoint marks a hard stretch just cleared, and
  slightly off the path. A player should never want to die to refill.
- **Pickups as difficulty** [source: Yacht Club]. Optional gems in awkward
  spots are a hard mode the player opts into, one jump at a time. Use many
  early as breadcrumbs, fewer later.
- **Expect first drafts to be too hard** [source: Yacht Club]. Ease spikes
  late, kindly.
- **Clarity** [source: Yacht Club]. Everything in a room serves its
  purpose: no stray enemies, no misleading pickups, no fake secrets.
- **Shortcuts for the skilled** [source: Yacht Club; Kooiker]. A platform a
  tile higher lets an expert skip a section, in plain sight of what they
  skipped.

**For us** [mine]. Our rules already match most of this (checkpoints before
the hard part; no lives; Resin at risk until banked). Two gaps: **every
required gap in region 1 is the same 4 tiles**, which is safe but flat, and
**nothing rewards a skilled player with speed**. Risky Resin beside the safe
line would give the first for free.

---

## 8. The core loop

What the player does over and over, at three sizes [mine, from the above]:

- **Seconds:** see an obstacle, read it, time it, feel the landing. This is
  the jump, the hit, the pickup sound. It has to be good a thousand times.
- **Minutes (a level):** meet an idea, master it, be surprised by it, reach
  the end; notice two things you couldn't reach.
- **Hours (the game):** new places, a new ability, a map filling in, a
  count of things still missing that pulls you back.

DKC2 and Super Mario World are loved because all three sizes work and feed
each other: a good jump makes exploring cheap, exploring fills the map, the
map opens harder levels that ask for better jumps.

**For us** [mine]. Seconds: in decent shape, untested by anyone but the
creative lead. Minutes: the structure is there. Hours: **nothing yet**: no
map, no record, no secret level. That is the biggest missing piece, and it
is the one that makes secrets matter.

---

## 9. What I would do next, in order

**Status (2026-11):** the creative lead said to implement all of it. What
was built, and where the rule now lives:

| # | Suggestion | Built? |
|---|---|---|
| 1 | World map with a per-level record | Yes, with a save file (`scripts/ui/world_map.gd`, `Game.LEVELS`); a stand-in look |
| 2 | One great secret per level | Yes: Morvath's thorn knot (`thorn_knot.gd`), in 1-1 and 1-2 |
| 3 | The bead rule | Written into `design/game-structure.md` §5; both levels keep it |
| 4 | A momentum move | Yes: Kleo's stride (`kleo.gd`). Not a new button: speed for running on without stopping. Untuned by play |
| 5 | Vary the chain in 1-2 | The long pool, yes, with a rest and risky Resin. The twist's islands, not yet |
| 6 | More kinds of tell; a habit broken once | 1-2 has four different tells; its knot is the one time she must go back west |
| 7 | A ratings board | `design/levels/ratings.md` |

Not built: corner correction on jumps; a third kind of bonus game; any of
the later-region ideas (combining several ideas a level).

The suggestions as first written [mine]:

1. **A world map with a per-level record** (letters, tokens, the great
   secret, each shown found or missing). It turns everything already built
   into a hunt.
2. **One great secret per level**, beyond letters and tokens, hidden with
   more cunning than anything else in it.
3. **The bead rule:** beads never lie. Write it into the design doc and
   check both levels against it.
4. **A skill move with momentum** for Kleo, prototyped in the systems
   arena, before more levels fix her envelope.
5. **Vary the chain inside each beat** of 1-2 before its art pass: no two
   hops the same, and risky Resin beside the safe line.
6. **More kinds of tell** for secrets, and one trained habit broken once in
   region 1.
7. **A ratings board** for levels (×, △, ○, ◎), with the weakest remade.

---

## Sources

Designers' own words:
- Maddy Thorson, "Celeste & Forgiveness":
  https://maddymakesgames.com/articles/celeste_and_forgiveness/index.html
- Iwata Asks, Donkey Kong Country Returns, "A Meeting at 5 AM":
  https://www.nintendo.com/en-gb/Iwata-Asks/Iwata-Asks-Donkey-Kong-Country-Returns/Iwata-Asks-Donkey-Kong-Country-Returns/3-A-Meeting-at-5-AM/3-A-Meeting-at-5-AM-212413.html
- Kensuke Tanabe and Michael Kelbaugh on difficulty (Game Developer):
  https://gamedeveloper.com/design/-i-donkey-kong-country-i-collaborators-talk-difficulty-surprises
- Miyamoto on action game design and difficulty (Game Developer):
  https://gamedeveloper.com/design/miyamoto-on-action-game-design-and-difficulty
- Miyamoto and Tezuka on World 1-1 (coverage of the Eurogamer video):
  https://hothardware.com/news/gaming-legend-shigeru-miyamoto-explains-design-philosophy-behind-super-mario-bros-world-1-1
- The Super Mario Bros. Wonder team at GDC 2024 (Game Developer):
  https://www.gamedeveloper.com/design/how-the-japanese-idea-of-mottainai-shaped-super-mario-bros-wonder
- Yacht Club Games, Specter of Torment level design deep dive, part 3:
  https://www.yachtclubgames.com/blog/specter-of-torment-level-design-deep-dive-3-5

Analyses:
- David Sirlin, "The Secrets of Donkey Kong Country 2":
  https://www.sirlin.net/articles/the-secrets-of-donkey-kong-country-2
- Kotaku on Hayashida's four steps (after Game Maker's Toolkit):
  https://kotaku.com/what-made-super-mario-3d-world-so-great-1691916400
- Radek Koncewicz, "Super Mario Bros. 3 Level Design Lessons", part 1:
  https://gamedev.net/tutorials/game-design/game-design-and-theory/super-mario-bros-3-level-design-lessons-part-1-r4682
- Lewis, "Touring Super Mario World in 2014" (Game Developer):
  https://gamedeveloper.com/design/touring-super-mario-world-in-2014
- Arc Rose Studios, "Why Donkey Kong Country 2 is the Perfect 2D
  Platformer":
  https://arcrosestudios.blogspot.com/2014/10/why-donkey-kong-country-2-is-perfect-2d.html
- Retronauts, "Re(?)Considered: Donkey Kong Country 3":
  https://retronauts.com/article/1514/reconsidered-donkey-kong-country-3-dixie-kongs-double-trouble
- Retroware, "Donkey Kong Country 3: How a Map Makes All the Difference":
  https://articles.retroware.com/2021/07/30/donkey-kong-country-3-how-a-map-makes-all-the-difference/
- Donald Kooiker, "Extra Loops: Donkey Kong Country" (Game Developer):
  https://www.gamedeveloper.com/design/extra-loops---donkey-kong-country
- Game Maker's Toolkit on Tropical Freeze (summary):
  https://mynintendonews.com/2017/06/16/game-makers-toolkit-delves-into-the-level-design-of-donkey-kong-country/

Facts about the games:
- Bonus rooms in DKC 1, 2 and 3: https://www.mariowiki.com/Bonus_room
- Donkey Kong Country, development: https://www.mariowiki.com/Donkey_Kong_Country
- Kremkoins: https://www.mariowiki.com/Kremkoin
- Secret exits and the Special Zone: https://www.mariowiki.com/Secret_exit,
  https://www.mariowiki.com/Special_Zone

Wanted but not readable from here (worth the creative lead's own time):
- "Designing Donkey Kong Country" (a study of Jungle Hijinxs with its
  designer): https://medium.com/super-jump/designing-donkey-kong-country-515cc8525328
- Game Maker's Toolkit, "Donkey Kong Country: Tropical Freeze - Mario's
  Level Design, Evolved": https://www.youtube.com/watch?v=JqHcE6B4OP4
- Patrick Holleman, *Reverse Design: Super Mario World* (book).
