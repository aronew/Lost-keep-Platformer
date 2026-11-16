# Lost Keep: Platformer — asset kit

22 export sheets cover the 15 briefs. Oversized groups are split across additional
canvases; none of the requested export canvases was enlarged.

## Files

- `sheets/`: full-size RGBA PNG exports at x8, or x4 for the backgrounds.
- `native/`: the same atlases at their logical art-pixel resolution.
- `sprites/`: separately extracted full-size atlas regions, for convenient import.
- `manifest.json`: canvas sizes, atlas regions, walking lines, anchors and offsets.
- `palette.json`: the restricted export color ramps.
- `previews/`: contact sheet and character review images; these are previews only.
- `validation.json`: machine checks of the exported dimensions, pixel grids,
  alpha, declared repeating boundaries and functional key-green guides.
- `raw/`: original ImageGen source artwork, before technical assembly. These are
  source images, not engine-ready exports and do not satisfy the export grid rules.
- `export_assets.py`: reproducible technical assembly; requires Pillow and NumPy.

## Split sheets

- Islands 1–3 and 4–5 occupy separate 3072×1024 canvases.
- The 224-pixel trunk and 192-pixel root arch each have a 3072×1024 canvas.
- Branches occupy two 2048×1024 sheets, with one column and two rows on each.
- Each tree has its own 3072×2048 canvas. Crown widths remain 224, 176 and 160
  logical pixels; their walkable lines are at logical y=40.
- Two mushroom sprites have a companion 3072×1024 sheet. Their heights are 40 and
  26 logical pixels. Place them behind island 1; the large mushroom begins at y=-8
  relative to the island, so it reaches the island's y=32 walking line without
  clipping. The island sheet itself contains the rock foundation and vegetation.
- Kleo and her crate guides use separate 1536×1152 sheets. Every green guide is
  exactly 24×20 logical pixels. Runtime placement uses `crate_offset`, measured
  from Kleo's feet. Some overhead placements have negative y relative to the
  48×48 animation cell; keeping the guides separate preserves their full size.

## Coordinates and import

All `rect_native` rectangles are `[x, y, width, height]` in logical art pixels.
Multiply all coordinates by the sheet's `pixel_scale` when using `sheets/`.
Walking lines and ground anchors describe geometric boundaries, not the topmost
grass pixel. Decorative moss overlaps some collision boundaries.

Kleo's cells are 48×48 logical pixels (384×384 output). Frames run left-to-right,
then top-to-bottom: lift A/B/C, carry stand, four carry-run frames, throw A/B/C,
set down. The character anchor is `[24,43]`, equivalent to `[192,344]` output.
The guide-only sheet deliberately has no box in follow-through frame 11.
For the separate green guide sprites, use the manifest's attach offsets rather
than the guide's storage position on its atlas. These are layout guides, not
finished crate artwork.

Use nearest-neighbor texture filtering. Avoid rescaling by non-integer factors.
The aqueduct is transparent above its silhouette and has a solid bottom 60 logical
pixel mist band. The sky is opaque. Other exports use only alpha 0 or 255.
Repeating segments are identified in the manifest; the entire wall/corner atlas
and entire bramble atlas should not be repeated as a single texture.

## Art review notes

The artwork was generated with ImageGen, then assembled and normalized to exact
export grids. It is not a claim of individually hand-placed source pixels.
Visual similarity, animation weight and attachment alignment still warrant an
in-engine art pass. The 12-frame character sheet is an animation draft; the
guide placements and pose transitions should be reviewed at the intended frame
rate before gameplay use. The supplied brief references approved W1/K1/G/A/Z
assets that were not separately attached; the supplied scenes, character sheet
and palette were used instead.

No red/crimson Blight colors are included in these non-Blight exports. The
separate bright-green boxes use only #00FF00. The preview backgrounds and labels
are not part of the game art.
