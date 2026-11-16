(function () {
  "use strict";

  var KEY = "lostkeep-platformer-book4";
  var state = { rules: true, done: {} };
  try {
    var saved = JSON.parse(localStorage.getItem(KEY) || "{}");
    if (typeof saved.rules === "boolean") state.rules = saved.rules;
    if (saved.done && typeof saved.done === "object") state.done = saved.done;
  } catch (e) { /* storage unavailable: defaults */ }
  function save() {
    try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) { /* not saved */ }
  }

  var AUDIT = [
    ["Earth banks with ruin stone: tops, undersides, walls, corners", "Book 3's purple ruin stone, lit as day", "need", "D1, D2"],
    ["The earth inside every mass", "A strip of Book 3's stone, repeated", "need", "D3"],
    ["Grey ruin stone: steps, walls, arches", "Book 1's purple ruins", "need", "D4"],
    ["Floating islands", "Book 3's purple stone islands", "need", "D5"],
    ["A fallen log and a root bridge", "Book 3's trunk", "need", "D6"],
    ["Stepping stones in a pond", "None yet", "need", "D7"],
    ["Great trees behind the play", "Book 1's teal night forest, lifted", "need", "D8"],
    ["Treetop crowns to walk on", "Book 3's dusk treetops", "need", "D9"],
    ["Clear pond water", "Your dusk water, lifted", "need", "D10"],
    ["Lily pads, reeds, cattails", "Book 1's flora, tinted", "need", "D11"],
    ["The letters K-L-E-O and the bonus token", "Drawn stand-ins", "need", "D12"],
    ["A bonus area's hidden entrance", "A dark arch shape with a glow", "need", "D13"],
    ["Thorns you can see at a glance", "Book 3's brambles, rimmed with light", "need", "D14"],
    ["Lantern posts, benches, banners, crates, signs", "Book 1's kit, at dusk", "need", "D15"],
    ["A day sky", "A plain gradient", "need", "D16"],
    ["The far and mid forest", "Book 1's night forest, lifted", "need", "D17, D18"],
    ["The leafy foreground band", "Your fern and stone bands", "need", "D19"],
    ["Kleo, the chest, the HUD flames, the rat", "Books 2 and 3", "ok", "Kept"],
    ["Fog, light shafts, pollen, glows, the water's ripple", "Code", "code", "Stays code by design"]
  ];

  var PACK = [
    ["D1", "platformer-attach/D1-emerald-ramparts-above-the-ravine.jpg", "Emerald ramparts above the ravine", "Your bright-day mockup: earth banks with stone, great trees, floating islands, a pond. Goes with every card."],
    ["D2", "platformer-attach/D2-emerald-root-ramparts.jpg", "Emerald root ramparts", "Earth terraces on great roots, small floating ledges, a bench and lantern posts."],
    ["D3", "platformer-attach/D3-forest-crossroads.jpg", "Forest crossroads among ruined terraces", "Root-held banks, a fallen log arch over a pit, the doorway and banner."],
    ["D4", "platformer-attach/D4-high-canopy-descent.jpg", "High canopy descent", "Treetop ramparts, a rope of beads, a hanging root bridge."],
    ["D5", "platformer-attach/D5-mossy-woodland-pond.jpg", "Mossy woodland pond ruins", "Stepping stones across a pond, reeds and lilies, ledges on a great tree."],
    ["D6", "platformer-attach/D6-woodland-pond-run.jpg", "Woodland pond run", "A low pond run between earth banks, a great tree's roots as a bridge."],
    ["G8", "platformer-attach/G8-game-daylight.jpg", "In the game today", "1-1 lit as day with the dusk kit still in it: what the new art replaces. Shows Kleo's size."]
  ];

  var SWATCHES = [
    ["Earth", "#A37043"], ["Earth shade", "#915937"], ["Earth deep", "#583640"], ["Stone", "#8C877F"],
    ["Stone shade", "#635853"], ["Grass", "#6C8F5E"], ["Leaf", "#399483"], ["Leaf deep", "#1D5C51"],
    ["Canopy", "#24717D"], ["Far forest", "#84C9AF"], ["Bark", "#6B3A2E"], ["Outline", "#1A2130"],
    ["Water", "#3F86C6"], ["Lantern amber", "#F2B04A"], ["Anima teal", "#3FE0C8"], ["Prism ice", "#9FE6F5"]
  ];

  function rules(card) {
    var scale = card.scale || 8;
    var bg = card.background || "Fully transparent (alpha) PNG. Never paint a checkerboard, paper texture, white or a scene behind the art. If transparency is impossible, use one flat pure blue #0000FF background with no gradient, noise or shadow (never magenta).";
    return [
      "STYLE AND TECHNICAL RULES (they apply to everything in this request)",
      "Project: \"Lost Keep: Platformer\", a 2D side-scrolling action platformer made in Godot 4.7, in premium, top-tier pixel art. These images become game assets, so the technical rules matter as much as the look.",
      "",
      "Look",
      "- High-end pixel art matching the attached mockups D1 to D6 exactly: a bright, sunlit forest of great old trees; orange-brown earth banks with grey ruin stone set into them; thick green grass and moss on every top; clear water; a soft blue-green sky. Bright, warm, fun and inviting. Never dark, never gloomy, never night.",
      "- Pixel scale x" + scale + ": every art pixel is an exact " + scale + " x " + scale + " px square of one flat colour, aligned to a " + scale + " px grid from the top-left corner. No anti-aliasing, no blur, no smooth gradients, no sub-pixel detail, no half-transparent pixels.",
      "- Strict orthographic side view, like a 2D platformer: no perspective, no camera tilt, no visible top surfaces.",
      "- Soft daylight from above, the same on every piece: tops lit, undersides in a cool shade. No cast shadows onto the background, no bloom. Glows are made by the game: paint a lantern's flame and lit glass, never the halo.",
      "- Colour: lanterns are amber #F2B04A with a #FFE59A flame. Anima teal #3FE0C8 is life-force (a bonus entrance's glow). Icy blue #9FE6F5 belongs to the Prism. Red may be used (banners, mushroom caps).",
      "",
      "Canvas",
      "- Exact canvas: " + card.canvas + ".",
      "- Background: " + bg,
      "- No grid lines, frames, borders, labels, numbers, captions, swatches, logos, signatures or watermarks. No text of any kind" + (card.letters ? " other than the letters the request asks for." : "."),
      "- No characters, creatures or people unless the request says so."
    ].join("\n");
  }

  var STYLE_LOCK = [
    "MAKE IT FEEL REAL AND NATURAL (this matters most)",
    "- The world is natural, old and lived in, the way Donkey Kong Country's levels feel: nothing out of place. Worn edges, moss where water runs, roots pushing through earth and stone, repairs made by people who lived here. Nothing clean, symmetrical or freshly made.",
    "- Hand-placed pixels, not a filter over a painting. No two stones, roots or leaves identical. At most five tones per material.",
    "- Match the attached mockups' pixel density and finish, and the game shot G8's pixel size: Kleo there is 28 art pixels tall."
  ].join("\n");

  var SPRITE_RULES = [
    "SHEET RULES",
    "- The canvas is a grid of equal cells, filled left to right, top to bottom, one frame per cell, in the order listed.",
    "- Every frame is centred in its cell and the same size; change only what moves.",
    "- Leave at least one art pixel of clear space inside every cell edge."
  ].join("\n");

  var EARTH = "THE GROUND (match D1 to D6 exactly): orange-brown earth (#A37043, shading to #915937 and #583640), packed and crumbly, with grey ruin stone blocks (#8C877F, shade #635853, worn lighter edges) set into it here and there, half buried; small pebbles and thin roots in the earth; thick bright grass (#6C8F5E with lighter blades) cushioned along every top and hanging over the edge in a ragged lip; tiny white and yellow flowers in the grass.";
  var DEPTH = "DEPTH: the earth stays earth all the way in: no black, no void. Deeper earth is a little darker and cooler (#915937, then #583640), with fewer stones, so a big mass reads as solid ground, never a hole.";
  var WIDE = "3072×1024 px (art 384 × 128 px at x8)";
  var BG = "3072×1440 px (art 768 × 360 px at x4)";

  var CARDS = [
    // ------------------------------------------------------------- terrain
    { id: "D1", group: "terrain", file: "day_earth_bands", title: "Earth and stone: walkable tops and undersides", pilot: true,
      about: "The ground of the whole region: every bank, terrace and ledge she walks on. Band 1 is the top she walks on; band 2 the underside of an overhang.",
      canvas: WIDE, game: "2 bands, 384 × 48 each, repeating", attach: ["D1", "D3", "D6", "G8"],
      text: [
        "TASK: two long horizontal bands of the mockups' ground, on one transparent canvas. Each runs the full width, edge to edge, and its left and right ends join a copy of itself.",
        "",
        EARTH,
        "",
        "BAND 1, a walkable top, from y = 64 to y = 448:",
        "- The walking line: at y = 128 a perfectly straight, perfectly horizontal top edge of earth along the whole width. Her feet stand on it, so it must not dip, bend or break.",
        "- Above the line, y = 64 to 128 only: grass tufts, small ferns and flowers in uneven clumps, overlapping the line slightly.",
        "- Below the line: the grass lip hanging over the edge, then earth with a few half-buried stones, ending in plain mid earth (#915937) at y = 448 that joins the fill (D3).",
        "",
        "BAND 2, an underside, from y = 576 to y = 960:",
        "- The top 128 px plain mid earth (#915937), joining the fill; then the underside: earth in a cool shade, stones and roots, its edge NOT a straight line: it breaks into hanging clods and root tangles, thin roots dangling to y = 960.",
        "",
        DEPTH
      ] },
    { id: "D2", group: "terrain", file: "day_earth_walls_corners", title: "Earth and stone: wall faces and corners",
      about: "The sides of the banks and terraces, and the corners where tops and undersides turn into walls. Must join D1 exactly.",
      canvas: "2048×2048 px (art 256 × 256 px at x8)", game: "1 face band 48 × 256, 4 corners 64 × 64, cut apart", attach: ["D1", "D2", "Your approved D1"],
      text: [
        "TASK: the edges of the same ground as the attached approved D1, on one transparent canvas, matching it exactly.",
        "",
        EARTH,
        "",
        "LAYOUT: the wall face band stands in the LEFT HALF; four corners sit in a 2 × 2 grid of 512 × 512 px cells in the upper RIGHT quarter (a top left, b top right, c bottom left, d bottom right). The lower right quarter stays empty.",
        "",
        "1. A wall face band, top edge to bottom edge, joining a copy of itself top to bottom. The face points RIGHT; its line is at x = 320. Here the mockups set grey ruin stone into the earth: courses of big worn grey blocks along the face, earth and roots between, grass tufts on the ledges of the blocks, ivy hanging. Inward (to the left) the stone gives way to earth (D3's).",
        "2. Four corners, each with the two edges meeting at its cell's centre: a. outer top (the grass lip wraps the corner and spills down the face); b. outer under (the underside's clods and roots turn up into the face); c. inner top; d. inner under.",
        "",
        DEPTH
      ] },
    { id: "D3", group: "terrain", file: "day_earth_fill", title: "Earth fill: inside every mass", pilot: true,
      about: "The inside of every bank and terrace, behind its edges: one even, seamless tile. The game darkens it a little with depth.",
      canvas: "1024×1024 px (art 128 × 128 px at x8)", game: "128 × 128, repeating in both directions", attach: ["D1", "D3", "Your approved D1"],
      background: "Opaque: the earth fills the whole canvas edge to edge.",
      text: [
        "TASK: one square, seamless tile of the mockups' earth, filling the whole canvas.",
        "- It repeats in BOTH directions with no visible seam and no repeating row or column.",
        "- Packed orange-brown earth (#915937 mostly, some #A37043), a few small grey stones and pebbles, thin roots threading through, a few darker crumbs. Calm and even: no grass, no edges, no lit top, no shadow toward any side.",
        "- Mid tones only, so it sits behind the edges from D1 and D2."
      ] },
    { id: "D4", group: "terrain", file: "day_ruin_stone", title: "Grey ruin stone: steps, walls and arches",
      about: "The old masonry in the mockups: stone steps up the banks, a ruined wall with a window, the arched doorway that ends a level, a broken pillar.",
      canvas: "2048×1024 px (art 256 × 128 px at x8)", game: "5 pieces, cut apart", attach: ["D1", "D3", "D5"],
      text: [
        "TASK: five pieces of the mockups' grey ruin stone, spread apart on one transparent canvas (at least 16 art px between pieces).",
        "STONE: big worn grey blocks (#8C877F, shade #635853, light worn edges), dark mortar, moss on every top, ivy and small ferns in the joints, a little earth at their feet.",
        "1. Stone steps, 64 × 48 art px: three steps up, each 16 tall and 16 deep, their tops perfectly flat and level (she walks on them).",
        "2. A ruined wall, 96 × 64: the remains of a building, one small arched window, its top broken and grassed.",
        "3. The arched doorway, 64 × 80: a stone arch, the opening 32 wide and 56 tall, dark inside, a lantern bracket on its right side (lantern unlit; the game adds light), a red banner may hang beside it.",
        "4. A broken pillar, 24 × 56.",
        "5. A low stone ledge, 48 × 16, its top flat: a small terrace step."
      ] },

    // ------------------------------------------------------------- pieces
    { id: "D5", group: "pieces", file: "day_floating_islands", title: "Floating islands", pilot: true,
      about: "The mockups' floating chunks of earth and stone with hanging roots, in four sizes. Each has a flat walking line.",
      canvas: WIDE, game: "4 islands, cut apart", attach: ["D1", "D2", "D4"],
      text: [
        "TASK: four floating islands, side by side with at least 16 art px between them, on one transparent canvas.",
        "",
        EARTH,
        "",
        "Each island: a flat grassy top (its walking line perfectly straight and level, 16 art px below the island's top edge of grass), earth and a few grey stones beneath, tapering to a ragged underside of clods, stones and hanging roots, as in D1 and D2.",
        "- Island A: 48 art px wide, 40 tall.",
        "- Island B: 64 wide, 56 tall.",
        "- Island C: 96 wide, 72 tall.",
        "- Island D: 160 wide, 96 tall: a big one, with a small bush and flowers on top.",
        "The width given is the walking line's width; grass may overhang it by 2 px each side."
      ] },
    { id: "D6", group: "pieces", file: "day_log_root_bridge", title: "A fallen log and a root bridge",
      about: "Things she walks across that the forest made: a mossy fallen log over a gap, and a great root arching over water.",
      canvas: WIDE, game: "2 pieces, cut apart", attach: ["D3", "D6", "D2"],
      text: [
        "TASK: two pieces, side by side, on one transparent canvas.",
        "1. A fallen log, 160 art px long, 32 tall: a great mossy trunk lying flat, bark peeling, a broken branch stub, moss and small ferns along its top. Its walking line is perfectly straight and level, 6 art px below its top edge of moss, along its whole length.",
        "2. A root bridge, 192 long, 64 tall: a great tree root arching from bank to bank, as in D3 and D6. Its top is flat and level enough to walk on: a walking line straight from x = 8 to x = 184, 8 art px below the arch's top; hanging rootlets and moss below."
      ] },
    { id: "D7", group: "pieces", file: "day_stepping_stones", title: "Stepping stones in a pond",
      about: "D5's row of flat stones across the pond: each sits in the water with its top dry.",
      canvas: "2048×512 px (art 256 × 64 px at x8)", game: "3 stones, cut apart", attach: ["D5", "D6"],
      text: [
        "TASK: three flat stepping stones, side by side, on one transparent canvas.",
        "- Each a worn grey-brown stone with moss on its top, its top perfectly flat and level (she stands on it), widths 32, 40 and 48 art px, 24 tall.",
        "- The waterline is 12 art px below the top: below it, paint the stone a little cooler and darker, with a light ripple line where the water meets it."
      ] },

    // ------------------------------------------------------------- trees
    { id: "D8", group: "trees", file: "day_great_trees", title: "Great trees behind the play",
      about: "The mockups' great old trees standing just behind the level: huge trunks, roots gripping the banks, broad crowns. Scenery, not ground.",
      canvas: "3072×2048 px (art 384 × 256 px at x8)", game: "2 trees, cut apart, behind the playfield", attach: ["D1", "D2", "D5"],
      text: [
        "TASK: two great trees, side by side, on one transparent canvas.",
        "- Each about 176 art px wide and 256 tall: a massive reddish-brown trunk (#6B3A2E, lit edges warmer) with deep bark grooves, roots spreading at its foot, branches carrying a broad crown of rich green leaf clusters (#399483, #24717D, highlights lighter), light catching the crown's top.",
        "- One with a lantern hanging from a branch (unlit glass; the game adds light).",
        "- They stand behind the play: no flat tops, nothing that looks walkable."
      ] },
    { id: "D9", group: "trees", file: "day_treetops", title: "Treetop crowns to walk on",
      about: "The secret route over the hill runs across tree crowns. Each crown has a flat walking line inside a natural leafy shape.",
      canvas: WIDE, game: "3 crowns, cut apart", attach: ["D4", "D1"],
      text: [
        "TASK: three tree crowns with their upper trunks, side by side, on one transparent canvas.",
        "- Crown widths 112, 128 and 160 art px; each about 80 tall with 40 px of trunk below.",
        "- Each crown's top is a perfectly flat, level walking line, 12 art px below the topmost leaves, across its middle three quarters: leaves and twigs may poke above it only at its ends.",
        "- Rich green leaf clusters as in D4, lit from above, a few vines hanging."
      ] },

    // ------------------------------------------------------------- water
    { id: "D10", group: "water", file: "day_pond_water", title: "Clear pond water",
      about: "The still water under the level and in its pits: clear, blue, catching the light, as in D5 and D6.",
      canvas: "3072×512 px (art 384 × 64 px at x8)", game: "384 × 64, repeating sideways", attach: ["D5", "D6", "D1"],
      background: "Opaque: the water fills the whole canvas.",
      text: [
        "TASK: one long band of pond water, its left and right ends joining a copy of itself.",
        "- The surface at y = 0: a broken line of light ripples and glints.",
        "- Clear blue (#3F86C6, lighter #8FCDEB near the surface), growing deeper and a little greener toward the bottom, faint pebbles and weed visible in the shallows at the top.",
        "- No reflections painted (the game reflects the world in it), no plants (D11)."
      ] },
    { id: "D11", group: "water", file: "day_pond_plants", title: "Lily pads, reeds and cattails",
      about: "The plants of the pond's edges and surface.",
      canvas: "2048×1024 px (art 256 × 128 px at x8)", game: "8 pieces, cut apart", attach: ["D5", "D6"],
      text: [
        "TASK: eight pond plants, spread apart on one transparent canvas.",
        "- Three lily pad clusters (24 to 40 art px wide, flat on the surface; one with a white flower).",
        "- Three clumps of reeds and cattails (24 to 32 wide, 32 to 48 tall), their feet on a waterline.",
        "- Two clumps of tall grass for the banks."
      ] },

    // ------------------------------------------------------------- things
    { id: "D12", group: "things", file: "day_letters_token", title: "The letters K-L-E-O and the bonus token", pilot: true, letters: true,
      about: "The level's four letters (as DKC's K-O-N-G) and a bonus area's prize, plus their small HUD icons.",
      canvas: "1024×512 px (art 128 × 64 px at x8)", game: "letters 16 × 18, token 4 frames 16 × 16, HUD icons 9 × 11", attach: ["G8", "D1"],
      text: [
        "TASK: on one transparent canvas:",
        "1. Row 1: the four capital letters K, L, E, O, each 16 × 18 art px, solid gold (#F2B04A, lit #FFE59A on top, shade #B8742A), chunky and friendly, with a one-pixel dark outline, spaced 16 apart.",
        "2. Row 2: the bonus token in four turning frames, each 16 × 16: a gold coin with a small icy-blue Prism shard set in its face (#9FE6F5, #3A7FB0): face on, three quarters, edge on, three quarters.",
        "3. Row 3: the HUD icons, each 9 × 11: K, L, E, O in dim plum-grey (not yet found), then K, L, E, O in gold (found)."
      ] },
    { id: "D13", group: "things", file: "day_bonus_hollow", title: "A bonus area's hidden entrance",
      about: "A hollow she walks into to reach a bonus area: in the roots of a great tree, or in a ruin wall. It glows faintly with Anima from inside.",
      canvas: "1024×512 px (art 128 × 64 px at x8)", game: "2 hollows, 48 × 48", attach: ["D1", "D3"],
      text: [
        "TASK: two hollows, side by side, on one transparent canvas.",
        "1. A hollow between a great tree's roots, 48 × 48 art px: an opening 20 wide and 28 tall, its floor flat at the bottom of the piece.",
        "2. A hollow in a broken ruin wall, the same size.",
        "- Inside each: dark, with a faint teal Anima shimmer (#3FE0C8 in a few soft pixels deep inside). No halo or glow painted outside the opening: the game adds the glow."
      ] },
    { id: "D14", group: "things", file: "day_thorns", title: "Thorns you can see at a glance",
      about: "Bramble thorns that hurt. The player must read them as danger instantly, even at a glance.",
      canvas: "2048×512 px (art 256 × 64 px at x8)", game: "a bed 128 × 24 repeating, 2 ends 24 × 24", attach: ["D3", "G8"],
      text: [
        "TASK: on one transparent canvas: a long bed of bramble thorns 128 art px wide and 24 tall whose left and right ends join a copy of itself, and its two ends (24 × 24 each), apart.",
        "- Dark twisted bramble stems with MANY large, sharp, pale thorns (bone #E8DCC0 with a darker base) sticking out in every direction, so the bed bristles. A few red berries may sit in it.",
        "- High contrast against green grass and brown earth: it must never look like a bush or a plant to walk through."
      ] },
    { id: "D15", group: "things", file: "day_props", title: "Lantern posts, benches, banners, crates",
      about: "The lived-in things of the mockups: what people left in the forest.",
      canvas: "2048×1024 px (art 256 × 128 px at x8)", game: "10 pieces, cut apart", attach: ["D2", "D3", "D1"],
      text: [
        "TASK: ten props, spread apart on one transparent canvas, each standing on a flat ground line:",
        "a lantern post (40 tall, a hanging brass lantern, glass unlit); a second lantern post, lit (flame #FFE59A, no halo); a wooden bench (32 wide); a red banner on a pole (40 tall); a wooden crate (24 × 20); a barrel (20 × 24); a clay pot; a wooden signpost; a cluster of red-capped mushrooms; a cluster of yellow and white flowers."
      ] },

    // ------------------------------------------------------------- backdrop
    { id: "D16", group: "backdrop", file: "day_sky", title: "A day sky",
      about: "The sky behind everything: soft and bright, a few clouds.",
      canvas: BG, scale: 4, game: "768 × 360, repeating sideways, scroll 0.05", attach: ["D1", "D3", "D6"],
      background: "Opaque: the sky fills the whole canvas edge to edge.",
      text: [
        "TASK: the daytime sky for a side-scrolling game: soft blue at the top, paler blue-green toward the bottom, as in the mockups, with a few soft pixel clouds drifting in the upper half. The left and right edges join so it repeats without a seam. No sun disc, no birds, no moons."
      ] },
    { id: "D17", group: "backdrop", file: "day_far_forest", title: "The far forest", pilot: true,
      about: "The distant forest: pale, hazy trees, as in every mockup's background.",
      canvas: BG, scale: 4, game: "768 × 360, repeating sideways, scroll 0.15", attach: ["D1", "D5", "D6"],
      text: [
        "TASK: a far backdrop: rows of tall forest trees far away, pale and hazy (#84C9AF, #6FB0A0, lighter at the bottom where the mist is), low contrast, no dark outlines.",
        "- The tree crowns reach about y = 60 to 140; above them the canvas is transparent (the sky shows). The bottom 80 px is solid mist.",
        "- The left and right edges join. Nothing that looks like a ledge."
      ] },
    { id: "D18", group: "backdrop", file: "day_mid_forest", title: "The mid forest",
      about: "Nearer trees between the far forest and the play: darker, more detail, still behind everything.",
      canvas: BG, scale: 4, game: "768 × 360, repeating sideways, scroll 0.35", attach: ["D1", "D2"],
      text: [
        "TASK: a mid backdrop: trunks and crowns of forest trees at middle distance, greener and darker than D17 (#399483, #24717D, trunks #4E3A36), some haze at their feet.",
        "- Crowns from about y = 30 to 200, trunks down to the bottom; transparent above the crowns; the bottom 40 px solid.",
        "- The left and right edges join. Nothing that looks like a ledge."
      ] },
    { id: "D19", group: "backdrop", file: "day_foreground_leaves", title: "The leafy foreground band",
      about: "One band of big leaves and bushes along the bottom of the view, nearest the camera, as in every mockup.",
      canvas: "3072×384 px (art 768 × 96 px at x4)", scale: 4, game: "768 × 96, repeating sideways, scroll 1.25", attach: ["D1", "D3", "D6"],
      text: [
        "TASK: one long band of the mockups' foreground: big leaves, ferns and round bushes along the bottom edge, deep green (#1D5C51, #24717D, lit edges #399483), a few dark mossy rocks.",
        "- It rises to different heights: mostly low (16 to 40 px), with a few taller clumps up to 90 px, so it never hides much of the play.",
        "- The bottom 12 px is solid. The left and right edges join. Transparent above the plants."
      ] }
  ];

  var FIXES = [
    ["It came back smooth or painterly, not pixel art", "This is a painting, not pixel art. Redo it as true pixel art: every pixel a hard square of one flat colour on an even grid at the stated scale, no anti-aliasing, no blur, no smooth gradients. Keep the same layout and canvas."],
    ["It is too dark", "Keep everything else, but make it bright daylight like the attached mockups: lighter earth, brighter grass, no black shadows, no night tones."],
    ["The walking line bends or dips", "Keep everything else, but make the walking line perfectly straight and perfectly horizontal along its whole length, at exactly the height the request gives. Only grass and plants may overlap it."],
    ["The measurements are off", "Keep the look, but redraw it to the exact measurements in the request: the walking line, the widths and the openings must be exactly where it says, in art pixels."],
    ["The ends do not join", "Keep the image, but make the left and right edges match exactly, so it continues without a seam beside a copy of itself."],
    ["The masses go black inside", "Keep the edges, but fill the inside with earth all the way in: a little darker with depth, never black."],
    ["Lights have halos painted on", "Remove every halo, bloom and light falling on surfaces. Keep only the flame and lit glass themselves; the game adds the glow."],
    ["It came back on white or a checkerboard", "Remove the background completely. If you cannot make it transparent, use one flat pure blue #0000FF background instead."]
  ];

  // ---------------------------------------------------------------------------
  // Rendering (the same as Books 1 and 2)
  // ---------------------------------------------------------------------------
  function el(tag, attrs, children) {
    var node = document.createElement(tag);
    if (attrs) for (var k in attrs) {
      if (k === "text") node.textContent = attrs[k];
      else node.setAttribute(k, attrs[k]);
    }
    (children || []).forEach(function (c) { if (c) node.appendChild(c); });
    return node;
  }

  function shared(card) { return [rules(card), STYLE_LOCK].join("\n\n"); }
  function attachLine(card) {
    var list = card.attach.map(function (a) {
      var p = PACK.filter(function (x) { return x[0] === a; })[0];
      return p ? a + ": " + p[2] : a.replace("Your approved ", "the approved ");
    });
    return "\n\nATTACHED: " + list.join("; ") + ".";
  }
  function body(card) {
    var text = Array.isArray(card.text) ? card.text.join("\n") : card.text;
    return text + attachLine(card);
  }
  function fullPrompt(card) { return state.rules ? shared(card) + "\n\n" + body(card) : body(card); }

  function copyText(text, button) {
    function ok() {
      var label = button.textContent;
      button.textContent = "Copied";
      button.classList.add("copied");
      setTimeout(function () { button.textContent = label; button.classList.remove("copied"); }, 1400);
    }
    function fallback() {
      var area = el("textarea", { readonly: "readonly", "aria-hidden": "true" });
      area.value = text;
      area.style.position = "fixed";
      area.style.opacity = "0";
      document.body.appendChild(area);
      area.select();
      try { if (document.execCommand("copy")) ok(); } catch (e) { /* select by hand */ }
      document.body.removeChild(area);
    }
    if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).then(ok, fallback);
    else fallback();
  }

  function progress() {
    var n = CARDS.filter(function (c) { return state.done[c.id]; }).length;
    document.getElementById("progress").textContent = n + " of " + CARDS.length + " done";
  }

  function thumb(letter) {
    var item = PACK.filter(function (p) { return p[0] === letter; })[0];
    if (!item) return el("span", { class: "thumb", style: "grid-template-columns:1fr;padding-left:10px", text: letter });
    return el("a", { class: "thumb", href: "#pack" }, [
      el("img", { src: item[1], alt: "", loading: "lazy" }),
      el("span", {}, [el("b", { text: item[0] + " " }), document.createTextNode(item[2])])
    ]);
  }

  function renderCard(card) {
    var check = el("input", { type: "checkbox", id: "done-" + card.id });
    check.checked = !!state.done[card.id];
    var head = el("div", { class: "card-head" }, [
      el("span", { class: "tag", text: card.id + (card.pilot ? " · pilot" : "") }),
      el("h3", { text: card.title }),
      el("label", { class: "done", for: "done-" + card.id }, [check, document.createTextNode("Done")])
    ]);
    var node = el("article", { class: "card" + (check.checked ? " is-done" : ""), id: card.id }, [head, el("p", { class: "about", text: card.about })]);
    check.addEventListener("change", function () {
      if (check.checked) state.done[card.id] = true; else delete state.done[card.id];
      node.classList.toggle("is-done", check.checked);
      save();
      progress();
    });
    node.appendChild(el("dl", { class: "spec" }, [
      el("dt", { text: "Save as" }), el("dd", {}, [el("code", { text: card.file + ".png" })]),
      el("dt", { text: "Canvas" }), el("dd", { text: card.canvas }),
      el("dt", { text: "In game" }), el("dd", { text: card.game })
    ]));
    node.appendChild(el("div", { class: "thumbs" }, card.attach.map(thumb)));
    var pre = el("pre", { text: body(card) });
    var button = el("button", { class: "copy", type: "button", text: "Copy", "aria-label": "Copy the prompt for " + card.id });
    button.addEventListener("click", function () { copyText(fullPrompt(card), button); });
    node.appendChild(el("div", { class: "prompt" }, [el("div", { class: "prompt-bar" }, [el("strong", { text: "Prompt" }), el("span", { text: "The shared rules are added when you copy" }), button]), pre]));
    return node;
  }

  CARDS.forEach(function (card) { document.getElementById("cards-" + card.group).appendChild(renderCard(card)); });
  document.getElementById("count").textContent = CARDS.length + " images";

  AUDIT.forEach(function (row) {
    document.getElementById("audit").appendChild(el("tr", {}, [
      el("td", { text: row[0] }), el("td", { text: row[1] }),
      el("td", {}, [el("span", { class: "status " + row[2], text: row[3] })])
    ]));
  });

  SWATCHES.forEach(function (s) {
    document.getElementById("swatches").appendChild(el("div", { class: "swatch" }, [
      el("i", { style: "background:" + s[1] }), el("div", {}, [el("b", { text: s[0] }), el("span", { text: s[1] })])
    ]));
  });

  PACK.forEach(function (p) {
    document.getElementById("pack-list").appendChild(el("div", { class: "ref" }, [
      el("img", { src: p[1], alt: p[2], loading: "lazy" }),
      el("div", {}, [el("strong", { text: p[0] + ". " + p[2] }), el("span", { text: p[3] }), el("span", {}, [el("code", { text: p[1].split("/").pop() })])])
    ]));
  });

  FIXES.forEach(function (f) {
    var button = el("button", { class: "copy", type: "button", text: "Copy" });
    button.addEventListener("click", function () { copyText(f[1], button); });
    document.getElementById("fix-list").appendChild(el("div", { class: "prompt" }, [
      el("div", { class: "prompt-bar" }, [el("strong", { text: f[0] }), button]),
      el("pre", { text: f[1] })
    ]));
  });

  var rulesBox = document.getElementById("include-rules");
  rulesBox.checked = state.rules;
  rulesBox.addEventListener("change", function () { state.rules = rulesBox.checked; save(); });
  progress();
})();
