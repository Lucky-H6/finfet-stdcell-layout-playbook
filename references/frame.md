# Cell frames

All coordinates are in u (1 u = core contacted gate pitch), with the origin at the
lower-left corner of PRBND. Dump any reference cell to see the exact numbers:
`scripts/gdsref.py dump CORE_INV_X1`.

## Core frame (CORE_*)

**Row and fins**
- Row height 6 u, 12 fins at 0.5 u: 4 NMOS fins, a 4-fin N/P gap, 4 PMOS fins.
- Fin centres sit at 0.25 + 0.5k, so every cell and every flipped row lands on the same grid.
- The original row was 11 fins tall. A rail-marker spacing rule forbade that height, so
  the whole library was stretched once to 12 fins. Row height is set by rules, not by
  convenience.

**Width and gates**
- Width = number of gate pitches. There is one PO per pitch boundary.
- The two edge gates sit exactly on the PRBND left and right edges (POEDGE marks them).
  They are shared with the neighbour, so a cell owns half of each.
- OD always ends on a gate centreline. A gate where OD starts or stops is a non-device
  dummy and carries PODE over the OD.

**Device rows**
- N OD spans y 0.5–2.5 and P OD spans y 3.5–5.5, so a device has 4 fins.
- Cells with 3-fin devices (TBUF, TINV) shrink the OD towards the rails, which widens
  the gap to 5 or 6 fins for gate contacts and M1.

**Rails**
- M1 rails are centred on y = 0 and y = 6 and extend past the left and right edges.
  M1RAIL covers them.
- Two CPO strips centred on the rails cut every gate between rows. No other CPO is used
  in core cells.

**S/D columns (MD)**
- Every column sits at a half-pitch centre (x = 0.5, 1.5, ...).
- A **rail-tied** column runs from the OD into the rail: MD, then MD_RT in the rail
  band, then V0R joining it to the M1 rail.
- A **cut** column ends with MD_RC under a CMD strip. CMD runs along each rail and covers
  only consecutive cut columns. It must stop before a rail-tied column (a real mistake
  made once: a CMD running over a VSS end column).
- **Every column must have MD reaching both rail bands** (rail-tied, cut, or dummy). See
  verification.md, "line-end-must-touch-cut". A floating **dummy** column is uncut MD +
  MD_RT, with no V0R and no CMD, like the filler cells.

**Gate contacts (MP)**
- MP sits in the N/P gap: a square pad for one gate, a thin bar for 2+ gates.
- It needs space to the MD line ends above and below it. That space, plus the V0
  enclosure, sets how far the S/D columns may enter the gap.

**Wells and implants**
- NW covers the P half and extends past the cell on the top and sides, so wells merge
  in rows.
- NIMP and PIMP split at y = 3.
- VTN/VTP cover the cell halves exactly.

**Abutment**
- Rows alternate R0 / MX, so neighbouring rows share a rail.
- Cells abut left/right on the shared edge gate.
- Because of the shared edge gates, M1 near the left and right edges is the abutment
  hazard; see routing.md, "edge clearance".

**Pitch variants**
- The same frame was built for two gate pitches. Most cells are identical in u.
- At the tighter pitch a few shapes need small nudges, because the rules do not scale
  with the pitch. Keep a per-cell nudge list in the generator; don't fork the
  design.

## Thick-oxide frame (THICK_*)

**Style**
- Analog-style, as the user requested: none of the std-cell special layers, i.e. no
  CPO, CMD, MD_RT/MD_RC, V0R, M1RAIL or POEDGE.
- TO covers the whole cell.

**Row and gates**
- Row height 10 u, 20 fins: 3 rail-margin fins, 4 N, a 6-fin gap, 4 P, 3 margin.
- That height is the rule minimum, set by the well-to-active rule for thick devices and
  by the gate line-end space between rows. It may grow only for rules or specs; the
  user rejected a taller row requested for routing.
- Thick gate pitch ≈ 2.8 u. Long, wide gates.
- Edge gates are drawn inside the cell, half a pitch from each edge, each with PODE over
  the OD ends. Width = (device gates + 2) × thick pitch.

**Wiring**
- Sources go straight into wide M1 rails that sit inside the cell; no butted rail
  contacts are used.
- S/D strips get 2 V0 each.
- Gate contacts are tall MP bars with 2 V0.
- All M1 spacing is at the thick-voltage spacing, which is larger than core.

**Implants and placement**
- NW and TO share their top and side edges.
- Implants extend a fixed margin past the cell sides.
- Thick cells cannot share a row with core cells: thin gates need a large space to TO.

## Special cells

**FILLTIE (core)**
- Built from the frame with N+ and P+ tap OD in the gap rows.
- Implants are swapped locally around the taps, as notches in NIMP/PIMP/NW/VT.
- Notch sizes are chosen so the notch's parallel run stays below the length that would
  trigger a wider well-spacing rule.
- Two FILLTIEs must never be horizontally adjacent (put a FILL1 between them) or stacked
  vertically.

**FILLTIE (thick)**
- Taps run gate[1]..gate[-2] with PODE.
- The tap OD drops the rail-side fin, so the swapped implant box clears the rail. That
  lets a FILLTIE stack on a FILLTIE.
- 4 thick pitches is the minimum: every OD edge, taps included, must sit on a
  PODE-marked gate centreline, and the implant must cover the end gate plus a margin.

**FILL1..FILL16**
- FILL1 has no OD. FILL2+ have full OD with floating inner gates (PODE).
- Every MD column is rail-tied on both rails.
- Each inner gate gets a floating M1 dummy.

**ENDCAP_ROW / ENDCAP_COLN / ENDCAP_COLP / CORNER_***
- Row-end and column-end caps.
- Orientation matters: the cap's inner (core-facing) edge carries the edge gate. Check
  which side, then place R0/MX at one end and MY/R180 at the other.
- The corner cells pair with the column caps: the N-well corner sits with the column
  cap that has a well, the other corner with the other cap.
