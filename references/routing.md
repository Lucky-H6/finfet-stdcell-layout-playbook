# Routing style

These are the user's preferences, learned through review rounds. Each item says why;
the reasons matter when a new situation doesn't match the examples.

## Shapes

- **Merge every touching same-layer shape into one polygon**, on every layer including
  M2: a rail plus its source strips, a track plus its L-turns. The user hand-merged
  the first cell and asked for it everywhere. In a generator, collect rects per layer,
  group touching or overlapping ones (union-find), and boolean-OR each group.
- **No H shapes in M1.** Two verticals joined by a middle bar read as an H, and so does
  a narrow-middle dumbbell. Use a straight strap, an L, or a C. A straight output strap
  on its own column, with neighbouring pads using their far V0, beats an H.
- **L over T.** Tabs at a stub end point one way, flush with the end. Avoid a tab
  parallel to a pad bar at slot distance: a slot inside one polygon narrower than the
  minimum is illegal even though it is "one net".
- **No tiny notches or jogs.** A tab closer than minimum to a stub end gets made flush
  with that end.
- **C-shaped outputs.** In INV-like cells, Y = a bar over the NMOS drains, a bar under
  the PMOS drains, and a vertical joining them at the far side. The input goes straight
  through the middle. This applies to the thick cells too, and to PG: A is a C on the
  left and Y a mirrored C on the right. For multi-finger PGs, the A and Y Cs interlock.
- **Use wide metal where there is room.** Minimum-width M1/M2 only where forced.
  Examples: widen pin bars that have free neighbours; make M2 tracks wider than
  minimum, keeping them at least one wide-track pitch apart. Check that widening
  doesn't drop the metal into a width band with a stricter via-enclosure or spacing rule.

## Gate contacts and inputs

- One gate gets a square MP pad. Several gates driven together get **one shared MP bar**
  across them, not separate pads (user correction). The bar has V0s at intervals.
- A gate pad's M1 bar extends past its end V0 by the full line-end enclosure. Too short
  fails V0 enclosure.
- Large inverters (8X+): split the MP into groups of about 4 gates. For 16X+, two M1
  output bars are strapped by an M2 comb using V1 stacked on the drain V0s.

## S/D columns

- **Every column reaches both rails** (see frame.md). Where a staggered layout leaves
  no device, draw an uncut floating dummy, as the filler cells do.
- Columns that must reach an M1 track in the gap extend into the gap only as far as
  their V0 needs. Every extension pushes the gate pads further out.
- Series-stack internal nodes in thick cells get MD without V0.

## Vias

- **Rectangular V1 wherever it fits** (the user wants "more RV1s"). M1 and M2 must
  enclose every V1 by more than zero on all four sides; edge-flush is not accepted.
- On long straps or gate stubs, use a **vertical** rectangular V1 and let the M2 track
  end there with an L-turn over it, rather than adding odd tabs.
- Mid-track vias are horizontal.
- Rectangular-via spacing is larger than square-via spacing, and a rect via's short
  side needs extra space to any via in line with it.
- V1 may stack on V0.
- Use 2 V0 per column where it fits (thick cells everywhere; core outputs where there
  is room).

## Pins and access

- Pins are M1 (or M2) shapes with a text label.
- **No foreign-net M2 over an M1 pin.** Route long nets on tracks that avoid the pin
  rows, so every pin can still be reached from above.
- Left-edge pins stay well away from the rails.
- Multi-pin nets that need M2 (for example the outer gates of a 2X NAND) carry their pin
  label on M2.

## Edge clearance (abutment)

- Keep non-rail M1 a fixed clearance from the left cell edge and a slightly different
  one from the right. Choose the two so that any left/right abutment gives a gap above
  the double-patterning conflict distance and outside any "medium-space" via-enclosure
  band. Note it only holds for non-mirrored abutment, so check MY placements too.
- When a via must sit close to an edge (an edge signal column at the tighter pitch),
  wrap it in a short stub (short enough to stay under the long-parallel-run trigger)
  and pull the rest of the wire back.

## Multi-stage / larger cells (level shifter lessons)

- **Device order on request.** The user specifies the PMOS/NMOS finger order; keep each
  stage as symmetric as possible and put same-net outer columns on N and P.
- **Cross-couple without H shapes.** Use ']' brackets: a stub, one inner jog, and a strap
  over a dummy column.
- **M2 track plan.** Write a table of tracks and the nets on each, keep pin rows free of
  foreign M2, and give each net one track with L-turns.
- **Generator comments.** Never put a `#` comment in the middle of a line that holds
  several statements: it silently removed two M2 tracks once, and only LVS caught it.
