# Lost Keep: Platformer — Sunlit Woodland Kit

21 production PNG sheets, 71 separately cropped pieces, and matching native-resolution PNGs.
The four islands and three walkable crowns retain their requested dimensions and are split over extra sheets; no canvas was enlarged to fit them.

## Files

- `sheets/`: exact requested output canvases. Gameplay art is x8; sky and parallax art are x4.
- `native/`: the same art at logical pixel resolution. For a game with a 28-pixel-tall Kleo, use these native files or compensate for the export scale consistently.
- `pieces/`: individual assets at their parent sheet's export scale. Crops preserve the declared transparent padding and anchors.
- `atlas.json`: sheet dimensions, scale, native rectangles, walking lines, waterlines, entrance sizes and repeat axes. All coordinates are logical art pixels; multiply by the sheet scale for output PNG coordinates. Coordinates in each piece entry are relative to its parent sheet. Subtract the rectangle origin for a standalone piece's local anchor.
- `palette.json`: material color ramps.
- `validation.json`: automated export checks and their limits.
- `previews/`: review images only. Their backgrounds and labels are not part of the production sprites.
- `sources/`: original image-generated artwork, before technical export. These files are reference sources, not engine-ready assets.
- `tasks.json`: the normalized prompt set. Artwork was created with the built-in image generator, then assembled, palette-limited and exported on native grids. This is generated artwork, not a claim of manually placed source pixels.
- `export_kit.py`, `validate_kit.py`: reproducible export and checks (Python, Pillow, NumPy).

## Rendering and placement

Use nearest-neighbor sampling and integer scaling. Do not apply smoothing or fractional positioning if you want to retain the exported pixel grid. Choose one consistent interpretation of native pixels and exported pixels across the project.

Opaque sheets: earth fill, pond water and sky. All other sheets have binary transparency, with the specified solid bands inside the parallax sheets. There are no semi-transparent pixels in the production exports. Daylight, reflection rendering and lantern/Anima halos remain game effects.

The long ground bands repeat horizontally; the wall face repeats vertically; earth fill repeats in both axes. The sheet and piece repeat declarations identify exactly which regions to tile. Undersides and corners are decorative silhouettes; create physics geometry from the walking anchors rather than tracing every root or grass blade.

The stone steps have three 16-pixel rises and three 16-pixel treads, with 16 pixels of transparent left padding within their specified 64×48 bounding rectangle. The doorway's opening is 32×56 and the bonus openings are 20×28 logical pixels. Their interiors are deliberately dark; ground mass uses earth colors throughout.

This package contains art and placement metadata, not a Godot project or an in-engine test. The validation report covers canvas size, square pixel replication, binary alpha, repeat edges, and the recorded structural anchors. Inspect the art in your level to judge the final visual match and gameplay feel.
