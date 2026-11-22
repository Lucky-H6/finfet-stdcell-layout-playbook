# Verification

## 1. Single-cell DRC: classify every flag

Run the full deck on the cell alone. Disable only full-chip checks: density, dummy fill,
chip-boundary and corner checks, and latch-up for single cells. Then sort every flag
into one of two groups.

**Abutment-only artifacts (acceptable in a single cell)**
- **Well and implant:** area or width of the well or VT layers.
- **Rail cut layer:** CPO extension or overlap at the row ends.
- **Gate checks:** floating or undriven gate inputs, gate density, the pitch-variant
  marker's minimum width.
- **Short MD:** length, area, and line-end-must-touch-cut on MD that joins the
  neighbour's MD across the rail once abutted (dummy columns, short cut columns).
- **Not relevant:** top-metal or passivation rules.

**Real errors (fix in the cell)**
- Everything else.
- An MD/MP/V0/M1 flag that would stay after abutment.

To tell which group a flag belongs in: if it is about something the neighbour supplies
(MD continuity, well continuity), it is an artifact. Confirm it disappears in the array.

## 2. Abutment array: the real acceptance test

Build a block that exercises every adjacency. `EXAMPLE_CORE` (10997 placements) and
`EXAMPLE_THICK` (6727) in the reference GDS are the arrays both families passed with.
To study one:
- `gdsref.py place EXAMPLE_CORE` lists the placements;
- `assets/png/EXAMPLE_*.png` shows the floorplan;
- `gdsref.py png EXAMPLE_CORE out.png --window x0 y0 x1 y1` renders any region in detail.

**Horizontal pairs**
- One row per core cell `a`, laid out as `a b0 a b1 a ... a` over all cells `b`.
- Use the row once in R0 and once in MX, so every ordered left/right pair is covered in
  both orientations.

**Vertical pairs**
- Two-row bands of aligned blocks (upper u over lower l) for every (u, l) pair.
- One set of bands shares VSS and another shares VDD.

**Row ends and caps**
- Row end caps on both sides.
- Column caps along the top and bottom rows, with corner cells.

**Placement rules**
- No FILLTIE next to or on top of a FILLTIE.
- Pad rows to equal width with fillers.

**Latch-up**
- Every PMOS source/drain must be within the deck's maximum distance of an N-well tap
  in the same well. NMOS likewise.
- Wells are the row pairs that share VDD. The first row is alone unless the end-cap
  row's well merges with it.
- Put each row's FILLTIE mid-row, and check the worst distance per well in the
  generator. Keep margin: measure to the tap cell edge, not to the tap OD.

**Running it**
- Run the array with latch-up checks **on**. Accept only floating-input flags (the
  array leaves gate inputs undriven) and irrelevant top-metal flags. M0/MD length,
  area or line-end flags in the array are real.
- Keep the array in a scratch cell or a test library. If the user asked for a
  library copy of it (an EXAMPLE block), rebuild that only after the scratch array is
  clean.

## 3. Rule families learned the hard way

| Family | Lesson |
|---|---|
| **MD line end must touch a cut** (short MD only) | Every column needs MD to the rail bands, or the neighbour's short MD stays short. Fix the cell that leaves the hole: add a dummy column. |
| **MD extension past a CMD cut** | Short cut dummies fail. Prefer uncut floating dummies, as the filler cells use. |
| **MP ↔ MD spacing** | Depends on whether MP is a square pad or a bar, and on whether the MD end is cut. Pads move only as far as this allows. |
| **V0 ↔ V0 spacing** | Also applies diagonally within a small negative parallel run. It limits how close a gate-pad V0 may come to a track V0. |
| **M1 forbidden pitch** (single-mask) | For a narrow line between two others, the sums W1+S1+W2+S2 or S1+W2+S2+W3 must avoid a forbidden window. To stay out: keep the pin bar beyond the window from narrow tracks, widen the middle line past the narrow threshold, or keep the parallel run short. |
| **M1 double patterning** | Odd conflict loops form through shared rails and only show when abutted. Keep each cell's graph a tree, the VSS…VDD chain even, and left/right edge clearances above the conflict distance. Line ends have a larger conflict distance than sides. |
| **Via enclosure by M1 width band** | Narrow, medium and wide M1 have different side and end enclosures, and some depend on the parallel run to a neighbour. Widening a bar can make it fail. |
| **Slot in one polygon** | A same-net gap narrower than minimum inside one polygon is illegal. |
| **Wide-metal spacing bands** | Wide rails forbid a band of spacings to other metal. Keep bars either close or far. |
| **Gate-edge rules** | Every OD vertical edge sits on a PODE-marked gate centreline, taps included. Implants cover the OD-end gate plus a margin. This sets the minimum tap-cell width. |
| **Gate split in the N/P gap** | Needs line-end space on both pieces plus pad-to-gate overlap. A small gap can't hold it, so stagger the OD instead. |

## 4. LVS

- Compare against the schematic netlist with the device bodies as their own nets (the
  wells). Logic cells have no taps, so the bodies cannot connect to VDD/VSS in the
  layout.
- Check one cell per topology and pitch variant after every routing change.
- LVS catches what DRC cannot: lost shapes, wrong column rail state, swapped pins.

## 5. Before declaring done

- [ ] Standalone DRC classified, no real errors
- [ ] Abutment array clean, latch-up on
- [ ] LVS correct
- [ ] Every cellview saved, nothing left modified
- [ ] Generator updated so a rebuild reproduces the accepted cell
