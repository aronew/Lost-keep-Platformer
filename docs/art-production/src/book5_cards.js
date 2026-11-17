(function () {
  "use strict";

  var KEY = "lostkeep-platformer-book5";
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
    ["Mossy purple stone: tops, undersides, walls, corners", "Book 3's purple stone (black inside, too dark)", "need", "F1, F2"],
    ["The stone inside every mass", "A thin strip repeated in rows", "need", "F3"],
    ["Ruins: arches, pillars, steps, a tower stub", "Book 1's ruins", "need", "F4"],
    ["Stone islands and pillars standing in water", "Book 3's islands", "need", "F5"],
    ["A fallen log and a great root", "Book 3's trunk", "need", "F6"],
    ["Hanging ceiling: stalactite stone and vines", "None", "need", "F7"],
    ["The flooded water", "Your dusk water", "need", "F8"],
    ["Sunken blocks and water plants", "Book 1's pieces, tinted", "need", "F9"],
    ["The lantern hut and the doorway out", "None (the stall was removed)", "need", "F10"],
    ["Mushrooms, flowers, ferns, vines", "Book 3's flora", "need", "F11"],
    ["Thorns, a banner checkpoint, a crate, a chest spot", "Mixed stand-ins", "need", "F12"],
    ["Far ruins: aqueducts and waterfalls in teal mist", "Book 3's aqueduct", "need", "F13, F14"],
    ["The cavern sky: shafts of teal light", "A dusk sky", "need", "F15"],
    ["The foreground: dark ferns and stones", "Your fern and stone bands", "need", "F16"],
    ["Kleo, the HUD, letters, token, creatures", "Books 2 to 4 and your roster", "ok", "Kept"],
    ["Fog, light shafts, glows, the water's ripple and reflection", "Code", "code", "Stays code by design"]
  ];

  var PACK = [
    ["S1", "platformer-attach/S1-three-tier-ruins.jpg", "Three tiers of ruins", "Your mockup: mossy purple ledges on arches, lantern huts, mushrooms, water below. Goes with every card."],
    ["S2", "platformer-attach/S2-cavern-run.jpg", "Cavern run", "A low run under a hanging stone ceiling, a floating mass, beads over the water."],
    ["S3", "platformer-attach/S3-waterfall-terraces.jpg", "Waterfall terraces", "Stepped terraces, small islands, waterfalls, far aqueducts in teal mist."],
    ["S4", "platformer-attach/S4-log-and-pillars.jpg", "Log and pillars", "A fallen log between stone masses, a tall pillar, sunken blocks under the water."],
    ["G8", "platformer-attach/G8-game-daylight.jpg", "In the game: Kleo's size", "A game shot for scale only: Kleo is 28 art pixels tall. Not the look."]
  ];

  var SWATCHES = [
    ["Stone light", "#7A5C8A"], ["Stone", "#5A4470"], ["Stone shade", "#3E2F52"], ["Stone deep", "#2A2140"],
    ["Moss", "#5FA83A"], ["Moss light", "#9AD44E"], ["Vine", "#2E7A4A"], ["Mist teal", "#2FA7A0"],
    ["Deep teal", "#145A66"], ["Water", "#1F5F8A"], ["Water deep", "#123A5C"], ["Cap red", "#C2384A"],
    ["Lantern amber", "#F2B04A"], ["Timber", "#8A5A3C"], ["Anima teal", "#3FE0C8"], ["Outline", "#1A1428"]
  ];

  function rules(card) {
    var scale = card.scale || 8;
    var bg = card.background || "Fully transparent (alpha) PNG. Never paint a checkerboard, paper texture, white or a scene behind the art. If transparency is impossible, use one flat pure blue #0000FF background with no gradient, noise or shadow (never magenta).";
    return [
      "STYLE AND TECHNICAL RULES (they apply to everything in this request)",
      "Project: \"Lost Keep: Platformer\", a 2D side-scrolling action platformer made in Godot 4.7, in premium, top-tier pixel art. These images become game assets, so the technical rules matter as much as the look.",
      "",
      "Look",
      "- High-end pixel art matching the attached mockups S1 to S4 exactly: a flooded sanctuary of mossy purple stone ruins in a teal-lit cavern forest, bright green moss and vines, red-capped mushrooms, warm amber lanterns, deep blue water. Moody but CLEAR: every ledge, hazard and creature must read at a glance. Never murky, never black.",
      "- Pixel scale x" + scale + ": every art pixel is an exact " + scale + " x " + scale + " px square of one flat colour, aligned to a " + scale + " px grid from the top-left corner. No anti-aliasing, no blur, no smooth gradients, no sub-pixel detail, no half-transparent pixels.",
      "- Strict orthographic side view, like a 2D platformer: no perspective, no camera tilt, no visible top surfaces.",
      "- Soft cool light from above, the same on every piece: tops lit, undersides in shade. No cast shadows onto the background, no bloom. Glows are made by the game: paint a lantern's flame and lit glass, never the halo.",
      "- Colour: lanterns amber #F2B04A with a #FFE59A flame; Anima teal #3FE0C8 is life-force; mushroom caps and banners may be red.",
      "",
      "Canvas",
      "- Exact canvas: " + card.canvas + ".",
      "- Background: " + bg,
      "- No grid lines, frames, borders, labels, numbers, captions, swatches, logos, signatures or watermarks. No text of any kind.",
      "- No characters, creatures or people unless the request says so."
    ].join("\n");
  }

  var STYLE_LOCK = [
    "MAKE IT FEEL REAL AND NATURAL (this matters most)",
    "- The world is natural, old and lived in, the way Donkey Kong Country's levels feel: nothing out of place. Worn edges, moss where water runs, roots pushing through stone. Nothing clean, symmetrical or freshly made.",
    "- Hand-placed pixels, not a filter over a painting. No two stones, roots or leaves identical. At most five tones per material.",
    "- Keep each colour as you paint it: do not snap the image to a fixed palette afterwards.",
    "- Match the attached mockups' pixel density; Kleo (see G8) is 28 art pixels tall."
  ].join("\n");

  var SPRITE_RULES = "";

  var STONE = "THE STONE (match S1 to S4 exactly): chunky rounded blocks of purple stone, about 10 to 14 art pixels across, in uneven courses; faces #5A4470 to #7A5C8A with worn lighter upper edges, mortar #3E2F52; thick bright moss (#5FA83A, #9AD44E) cushioned along every top and spilling over the edge, vines hanging down the faces, small ferns, tiny white and yellow flowers.";
  var DEPTH = "DEPTH: the stone stays stone all the way in: no black, no void. Deeper stone is a little darker and calmer (#3E2F52, then #2A2140) with its blocks still showing, so a big mass reads as solid stone, never a hole.";
  var WIDE = "3072×1024 px (art 384 × 128 px at x8)";
  var BG = "3072×1440 px (art 768 × 360 px at x4)";

  var CARDS = [
    { id: "F1", group: "terrain", file: "sanct_stone_bands", title: "Mossy stone: walkable tops and undersides", pilot: true,
      about: "The ground of the flooded sanctuary: every ledge and terrace she walks on. Band 1 is the top; band 2 the underside of a ledge.",
      canvas: WIDE, game: "2 bands, 384 × 48 each, repeating", attach: ["S1", "S3", "S4", "G8"],
      text: [
        "TASK: two long horizontal bands of the mockups' mossy stone, on one transparent canvas. Each runs the full width, edge to edge, and its left and right ends join a copy of itself.",
        "", STONE, "",
        "BAND 1, a walkable top, from y = 64 to y = 448:",
        "- The walking line: at y = 128 a perfectly straight, perfectly horizontal top edge of stone along the whole width. Her feet stand on it, so it must not dip, bend or break.",
        "- Above the line, y = 64 to 128 only: moss cushions, grass tufts, small ferns and flowers in uneven clumps, overlapping the line slightly.",
        "- Below the line: the moss lip spilling over, then courses of stone, ending in plain mid stone (#3E2F52 blocks) at y = 448 that joins the fill (F3).",
        "",
        "BAND 2, an underside, from y = 576 to y = 960:",
        "- The top 128 px mid stone joining the fill; then the underside, NOT a straight line: hanging wedges of two or three blocks, loose blocks, vines and thin roots dangling to y = 960.",
        "", DEPTH
      ] },
    { id: "F2", group: "terrain", file: "sanct_stone_walls_corners", title: "Mossy stone: wall faces and corners",
      about: "The sides of ledges and pillars, and the corners where tops and undersides turn into walls. Must join F1 exactly.",
      canvas: "2048×2048 px (art 256 × 256 px at x8)", game: "1 face band 44 × 256, 4 corners 64 × 64, cut apart", attach: ["S1", "S4", "Your approved F1"],
      text: [
        "TASK: the edges of the same stone as the attached approved F1, on one transparent canvas, matching it exactly.",
        "", STONE, "",
        "LAYOUT: the wall face band stands in the LEFT HALF; four corners sit in a 2 × 2 grid of 512 × 512 px cells in the upper RIGHT quarter (a top left, b top right, c bottom left, d bottom right). The lower right quarter stays empty.",
        "",
        "1. A wall face band, top edge to bottom edge, joining a copy of itself top to bottom. The face points RIGHT; its line is at x = 320. Blocks stand a little proud of the line here and there; vines and moss down the face. Inward (left) the stone runs on, a little darker.",
        "2. Four corners, each with its two edges meeting at its cell's centre: a. outer top (the moss lip wraps the corner and spills down the face); b. outer under (hanging blocks turn up into the face); c. inner top; d. inner under.",
        "", DEPTH
      ] },
    { id: "F3", group: "terrain", file: "sanct_stone_fill", title: "Stone fill: inside every mass", pilot: true,
      about: "The inside of every ledge and pillar, behind its edges: one even, seamless tile. This is what stops big masses looking black or striped.",
      canvas: "1024×1024 px (art 128 × 128 px at x8)", game: "128 × 128, repeating in both directions", attach: ["S1", "S2", "Your approved F1"],
      background: "Opaque: the stone fills the whole canvas edge to edge.",
      text: [
        "TASK: one square, seamless tile of the mockups' stone, filling the whole canvas.",
        "- It repeats in BOTH directions with no visible seam and no repeating row or column.",
        "- Hand-laid blocks of several sizes, staggered, a few cracked, a thin root or two in the joints. Mid tones only (#3E2F52 to #5A4470, mortar #2A2140): calm and even, no moss, no lit top, no shadow toward any side, never black."
      ] },
    { id: "F4", group: "terrain", file: "sanct_ruins", title: "Ruins: arches, pillars, steps",
      about: "The masonry standing on and under the ledges in S1: arches holding a ledge up, broken pillars, a flight of steps, a ruined archway.",
      canvas: "2048×1024 px (art 256 × 128 px at x8)", game: "5 pieces, cut apart", attach: ["S1", "S3"],
      text: [
        "TASK: five pieces of the mockups' ruin stone, spread apart (at least 16 art px between pieces) on one transparent canvas.",
        "1. A supporting arch, 96 × 64 art px: two piers and a round arch between, as under S1's ledges; its top edge flat (a ledge sits on it).",
        "2. A ruined archway, 64 × 72: a doorless arch with a broken top, vines over it.",
        "3. A broken pillar with a mossy cap, 24 × 56.",
        "4. Stone steps, 64 × 48: three steps up, each 16 tall and 16 deep, tops perfectly flat.",
        "5. A low block, 32 × 16, its top flat: a step."
      ] },
    { id: "F5", group: "pieces", file: "sanct_islands_pillars", title: "Stone islands and pillars in the water", pilot: true,
      about: "What she hops across the flood on: small mossy stone islands, and tall pillars rising from the water (S3, S4).",
      canvas: WIDE, game: "5 pieces, cut apart", attach: ["S3", "S4", "S1"],
      text: [
        "TASK: five pieces, side by side with at least 16 art px between them, on one transparent canvas.",
        "", STONE, "",
        "Each has a flat mossy top whose walking line is perfectly straight and level, 16 art px below the piece's top edge of moss.",
        "- Island A: 48 art px wide, 40 tall, a rounded mossy stone.",
        "- Island B: 64 wide, 56 tall.",
        "- Island C: 96 wide, 64 tall, a small bush on it.",
        "- Pillar D: 32 wide, 112 tall: a stack of blocks rising from the water.",
        "- Pillar E: 48 wide, 96 tall, leaning stones at its foot.",
        "The lower third of each sits under water: paint it the same stone (the game tints it)."
      ] },
    { id: "F6", group: "pieces", file: "sanct_log_root", title: "A fallen log and a great root",
      about: "S4's mossy log between two stone masses, and S1's great root running down a wall.",
      canvas: WIDE, game: "2 pieces, cut apart", attach: ["S4", "S1"],
      text: [
        "TASK: two pieces, side by side, on one transparent canvas.",
        "1. A fallen log, 160 art px long, 40 tall: a mossy trunk with a root flare at one end, as in S4. Its walking line is perfectly straight and level, 6 art px below its top edge, along its whole length.",
        "2. A great root, 96 wide, 128 tall: thick twisting roots running down a wall face, as on S1's right side. Scenery: nothing flat on it."
      ] },
    { id: "F7", group: "pieces", file: "sanct_ceiling", title: "The hanging ceiling",
      about: "S2's cavern roof: stone hanging down in stalactite clusters with vines. A band along the top of the level.",
      canvas: WIDE, game: "384 × 96, repeating sideways", attach: ["S2", "S4"],
      text: [
        "TASK: one long band of cavern ceiling, its left and right ends joining a copy of itself.",
        "- The top 32 art px solid stone; below it the ceiling breaks into hanging clusters of blocks and stalactite shapes of different lengths (16 to 64 px), with gaps of open air between, vines and leafy strands hanging from them.",
        "- Never a straight bottom edge. Transparent below the stone."
      ] },
    { id: "F8", group: "water", file: "sanct_water", title: "The flooded water",
      about: "The deep still water under everything: blue, calm, with soft ripples at its surface.",
      canvas: "3072×512 px (art 384 × 64 px at x8)", game: "384 × 64, repeating sideways", attach: ["S3", "S4", "S2"],
      background: "Opaque: the water fills the whole canvas.",
      text: [
        "TASK: one long band of the mockups' water, its left and right ends joining a copy of itself.",
        "- The surface at y = 0: a thin broken line of pale ripples.",
        "- Blue (#1F5F8A) near the surface, deepening to #123A5C at the bottom, with a few long soft horizontal streaks.",
        "- No reflections painted (the game reflects the world and the lanterns in it), no plants or stones (F9)."
      ] },
    { id: "F9", group: "water", file: "sanct_sunken", title: "Sunken blocks and water plants",
      about: "What shows under and on the water in every mockup: drowned blocks and steps, tall water ferns, lily pads.",
      canvas: "2048×1024 px (art 256 × 128 px at x8)", game: "10 pieces, cut apart", attach: ["S4", "S3"],
      text: [
        "TASK: ten pieces spread apart on one transparent canvas:",
        "- Four drowned stone pieces (a stack of blocks, broken steps, a pillar stub, a rubble heap), 24 to 48 art px wide, in cool blue-purple (they are under water).",
        "- Three tall water ferns and weeds, 24 to 32 wide, 32 to 48 tall, dark teal-green.",
        "- Three lily pad clusters, 24 to 40 wide, flat."
      ] },
    { id: "F10", group: "things", file: "sanct_hut_door", title: "The lantern hut and the doorway out",
      about: "S1's timber hut with its lantern and banner (a level's start) and its stone doorway under a timber roof (a level's end).",
      canvas: "2048×1024 px (art 256 × 128 px at x8)", game: "2 pieces, cut apart", attach: ["S1", "S4"],
      text: [
        "TASK: two pieces, side by side, on one transparent canvas, each standing on a flat ground line at its bottom edge.",
        "1. The lantern hut, 96 × 88 art px: an open timber lean-to with a tiled roof, a hanging lantern (flame and glass only, no halo), a small banner, a crate and a barrel inside, vines over the roof.",
        "2. The doorway out, 112 × 96: a stone wall under a timber roof with an arched doorway, its opening 32 wide and 56 tall, dark inside, a lantern each side, a banner."
      ] },
    { id: "F11", group: "things", file: "sanct_flora", title: "Mushrooms, flowers, ferns and vines",
      about: "The plants that dress every ledge in the mockups.",
      canvas: "2048×1024 px (art 256 × 128 px at x8)", game: "12 pieces, cut apart", attach: ["S1", "S3"],
      text: [
        "TASK: twelve plants spread apart on one transparent canvas, each standing on a flat ground line (the vines hang from a top line):",
        "- A big red-capped mushroom with pale spots (40 wide, 40 tall), two medium, a cluster of three small.",
        "- Two ferns (32 wide), two clumps of white and yellow flowers, a grass tuft.",
        "- Three hanging vines of different lengths (16 wide; 32, 56 and 80 long)."
      ] },
    { id: "F12", group: "things", file: "sanct_things", title: "Thorns, the midway banner, a crate",
      about: "Things that act: a thorn bed the player reads as danger at once, the banner that marks the level's middle, and a crate to carry.",
      canvas: "2048×1024 px (art 256 × 128 px at x8)", game: "cut apart", attach: ["S1", "G8"],
      text: [
        "TASK: on one transparent canvas, spread apart:",
        "1. A bed of thorns 128 art px wide and 24 tall whose left and right ends join a copy of itself, and its two ends (24 × 24 each): dark twisted stems with MANY large pale thorns (bone #E8DCC0) bristling in every direction. High contrast against moss and purple stone: never a bush.",
        "2. The midway banner in three frames, each 40 × 64: a pole with the banner furled; flying, frame A; flying, frame B. Deep red cloth with a small gold emblem.",
        "3. A wooden crate, 24 × 20, and a barrel, 20 × 24."
      ] },
    { id: "F13", group: "backdrop", file: "sanct_far_ruins", title: "Far ruins in the mist", pilot: true,
      about: "The distance in every mockup: aqueducts and arches fading into teal mist.",
      canvas: BG, scale: 4, game: "768 × 360, repeating sideways, scroll 0.15", attach: ["S3", "S4", "S1"],
      text: [
        "TASK: a far backdrop: tiers of ruined aqueducts and arches, overgrown, fading into bright teal mist (#2FA7A0, #1F8A8A, lighter where the mist is thick). Low contrast, no dark outlines, no detail sharp enough to look near.",
        "- Ruins from about y = 80 to 300; transparent above them; the bottom 60 px solid mist.",
        "- The left and right edges join. Nothing that looks like a ledge to stand on."
      ] },
    { id: "F14", group: "backdrop", file: "sanct_mid_ruins", title: "Nearer ruins and waterfalls",
      about: "The middle distance: larger arches, trees on their tops, thin waterfalls (S3).",
      canvas: BG, scale: 4, game: "768 × 360, repeating sideways, scroll 0.35", attach: ["S3", "S1"],
      text: [
        "TASK: a mid backdrop: big ruined arches and walls with trees and vines on top and two or three thin pale waterfalls, in deep teal (#145A66, #1F7A80), darker and clearer than F13 but still hazy.",
        "- From about y = 60 to the bottom; transparent above; the bottom 40 px solid.",
        "- The left and right edges join. Nothing that looks like a ledge to stand on."
      ] },
    { id: "F15", group: "backdrop", file: "sanct_cavern_light", title: "The cavern's light",
      about: "Behind everything: the glow of teal light falling from above, as at the top of S1 and S3.",
      canvas: BG, scale: 4, game: "768 × 360, repeating sideways, scroll 0.05", attach: ["S1", "S3"],
      background: "Opaque: fills the whole canvas edge to edge.",
      text: [
        "TASK: the backdrop behind all the ruins: bright teal light at the top centre (#3FC8C0) falling in soft vertical bands, deepening to dark teal (#0F3A48) at the sides and bottom. Stepped bands of flat colour, no smooth gradient. The left and right edges join. Nothing else in it."
      ] },
    { id: "F16", group: "backdrop", file: "sanct_foreground", title: "The foreground band",
      about: "One band along the bottom of the view, nearest the camera: dark ferns, big leaves and mossy stones, as in every mockup.",
      canvas: "3072×384 px (art 768 × 96 px at x4)", scale: 4, game: "768 × 96, repeating sideways, scroll 1.25", attach: ["S2", "S3", "S4"],
      text: [
        "TASK: one long band of the mockups' foreground: dark purple-blue fern fronds, teal-green water plants and round mossy stones along the bottom edge.",
        "- Mostly low (16 to 40 px), with a few taller fronds up to 90 px, so it never hides much of the play.",
        "- The bottom 12 px solid. The left and right edges join. Transparent above."
      ] }
  ];

  var FIXES = [
    ["It came back smooth or painterly, not pixel art", "This is a painting, not pixel art. Redo it as true pixel art: every pixel a hard square of one flat colour on an even grid at the stated scale, no anti-aliasing, no blur, no smooth gradients. Keep the same layout and canvas."],
    ["It is too dark or murky", "Keep everything else, but lift it: brighter moss, clearer stone, no black. Every ledge must read at a glance, as in the attached mockups."],
    ["The walking line bends or dips", "Keep everything else, but make the walking line perfectly straight and perfectly horizontal along its whole length, at exactly the height the request gives."],
    ["The measurements are off", "Keep the look, but redraw it to the exact measurements in the request, in art pixels."],
    ["The ends do not join", "Keep the image, but make the left and right edges match exactly, so it continues without a seam beside a copy of itself."],
    ["The masses go black inside", "Keep the edges, but fill the inside with stone blocks all the way in: a little darker with depth, never black."],
    ["Lights have halos painted on", "Remove every halo, bloom and light falling on surfaces. Keep only the flame and lit glass; the game adds the glow."],
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
