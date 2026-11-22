# Tooling notes

## Generators over hand edits

- Write one small generator per cell family, taking (pitch, gate length, VT, name,
  size). It emits every shape from frame constants plus per-cell routing tables.
- Rebuild instead of patching. When the user hand-edits a cell, dump it and diff it
  against the generator output. Then fold the change back into the generator.
- To port a cell to another frame (different row height or gate pitch), write a
  **mapper** rather than editing by hand:
  - snap x to the nearest half-pitch and keep absolute overhangs outside the boundary;
  - remap y in zones (below the gap, the gap, above the gap, rails);
  - re-width the inner gates to the target gate length.

  Diff the mapped result against the source cell; it catches transcription errors.
- Keep a nudge list per pitch variant inside the generator, with a comment naming the
  rule family each nudge satisfies.

## Shapes

- Merge with union-find on touching or overlapping rects per layer, then a boolean OR
  per group. In Cadence SKILL: `dbLayerOr(cv lpp shapeList)`, then delete the originals.
- Afterwards, check that no two same-layer shapes touch.

## Virtuoso / SKILL scripting (when the flow is Cadence)

**SKILL language**
- `t` cannot be a loop or lambda variable.
- `rexMatchp` has no `|` alternation.
- Wrap multiple forms in `let`/`progn`.

**Cellviews**
- Open with `dbOpenCellViewByType(lib cell "layout" "maskLayout" mode)`. If the user
  has the cellview open read-only, `dbReopen` it in "a" mode.
- Always `dbSave`, then check that no open cellview has `modifiedButNotSaved`.
- Never open layout windows from a remote or batch bridge (menu-callback errors).
- Shape moves: `dbMoveFig(obj cv list(dx:dy "R0"))`.
- Copy a cell for prototyping with `dbCopyCellView`. Delete the target first; copying
  onto an open cellview silently keeps the old one.

**Runs**
- Stream out per top cell for DRC/LVS. Run the batch DRC with a copy of the deck whose
  header switches are edited.
- Parse the ASCII result database for rule names, counts and polygons. Map polygons
  back to instances via the array's placement list to classify errors by cell and local
  position.

## The reference GDS

`scripts/gdsref.py` reads `assets/finfet_stdcell_ref.gds` without any GDS library.
The geometry is snapped to 1/8 u, so use it for topology and style, not for dimensions.
- `place ARRAY` lists the placements of an array cell.
- `png ARRAY out.png --window x0 y0 x1 y1` renders a detail view of an array.
- `list` prints the boundaries.
- `dump CELL [LAYER..]` prints shapes in u.
- `png CELL out.png` renders a cell. Use it on your own cells too: write them with the
  same generic layer numbers and the same scale.

Any real dimension or rule must come from the target deck.
