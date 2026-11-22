# Reference cell catalogue

Look at `assets/png/<CELL>.png` first, then `scripts/gdsref.py dump <CELL>` for exact
shapes. The schematics are in `assets/reference_netlists.sp`.

Notation:
- Gates g0..gN from left to right; g0 and gN are the edge gates.
- Columns c0..c(N-1) sit between gates.
- "N:" and "P:" give each column's net, left to right.

## Core inverter family — CORE_INV_X1/X2/X4/X8/X16 (2/3/5/9/17 u)

- Kx: K gates, source/drain alternating; sources rail-tied, drains cut.
- **Output Y:** an M1 C. A bar over the NMOS drains, a bar under the PMOS drains, and
  a wide vertical at the right.
- **Input A:** straight in the gap over one MP (X1) or an MP bar (X2+).
- **V0 count (X4):** 2 V0 on the MP bar, on the inner gates. The user rejected 1 V0
  with a thin output.
- **X8:** MP in groups of 4 gates.
- **X16:** output = two M1 bars plus an M2 comb, with the Y label on M2.

## NAND / NOR — CORE_NAND2/3_X1/X2, CORE_NOR2/3_X1/X2

**Pin order**
- Inputs are ordered so the stack input next to the rail (B, C) sits at the rail end,
  and A is nearest the output.
- NOR is the dual: the PMOS stack runs VDD-C-B-A-Y.

**X1**
- One square MP pad per gate in the gap.
- The input bars are offset so that each stays clear of the Y vertical.

**X2**
- Outer gates carry one input (B), joined over M2 with V1. The inner pair carries A
  on one MP bar.
- The A/B labels are on M2; Y is on M1.

**Lesson**
- A stray rail via on a column that should be cut gave a false short. Check every
  column's rail state against the netlist.

## Pass gate — CORE_PG_X1/X2/X4 (4/6/10 u)

**Topology**
- Two separate poly halves: PMOS OD on the left and NMOS OD on the right, separated by
  a diffusion break (a PODE gate in the middle).
- K fingers per device. Column nets alternate A/Y starting from A at the left; the last
  NMOS column is Y.

**Gate contacts and pins**
- PMOS gates (SN) are contacted in the empty NMOS area and NMOS gates (S) in the empty
  PMOS area. Each side has one shared MP bar for X2/X4.
- M1 tracks in the gap: A (upper) with a stub up at c0, and Y (lower) with a stub down
  at the last column.
- The SN and S pin bars sit beside the tracks.

**Dummy MD**
- The empty halves (NMOS-left, PMOS-right) carry uncut floating dummy MD from the rail.
  This is required so that cells abutted across the rail never leave a short MD unjoined.
- The SN/S pads were moved as far toward the gap as the A/Y MD extensions allow. The
  pin bar must stay out of the M1 forbidden-pitch window next to the narrow tracks
  (see verification.md).

**Other lessons**
- A narrow Y stub at the right edge formed a double-patterning odd loop with a
  neighbouring TIE cell. It was widened into a non-line-end.
- A split-gate / shared-poly PG does not fit: the pad-to-gate overlap rule forces both
  neighbouring MD columns to break.

## Tie cells — CORE_TIEH / CORE_TIEL (2 u)

- **Circuit:** a diode-connected device sets net8, and the other device drives Z.
- **Layout:** a copy of INV_X1 with only the non-rail M1 changed.
  - net8 = the input bar + a bridge + one drain vertical.
  - Z = the other drain vertical.
- **Double patterning:** the upper shape stops short of VDD, so the rails aren't in the
  odd chain.

## Tri-state buffer — CORE_TBUF (11 u)

- A standard tri-state buffer: one ENABLE→ENB inverter, NAND-like pull-up and NOR-like
  pull-down pre-drivers (OH/OL), and an output stage. All devices are 3 fins.
- Drawn on the frame with 3-fin devices, which leaves a 6-fin gap for gate contacts and
  M1.
- Floating MD stubs over a P-side diffusion break were lengthened until they pass the
  minimum-length and minimum-area rules on their own. Before, they only passed when
  abutted to a cell with MD at the same x.
- The pin bars with room were widened. Widening must skip the width band that needs a
  larger via side enclosure.

## Tri-state inverter — CORE_TINV (4 u)

- **Circuit:** PM1 (ENB) – PM0 (A) – Y – NM1 (A) – NM0 (EN).
- **Why stagger:** gate 1 is ENB on the PMOS side and EN on the NMOS side, so a 3-pitch
  layout would need a split gate. It doesn't fit the gap.
- **Staggered layout:**

  | Gate | Net | PMOS side | NMOS side |
  |---|---|---|---|
  | g1 | ENB | device | NMOS OD start (PODE) |
  | g2 | A | device | device |
  | g3 | EN | PMOS OD end (PODE) | device |

  - P OD runs g0..g3 with columns VDD, net011, Y.
  - N OD runs g1..g4 with columns Y, net010, VSS.
- **Dummy MD** in NMOS c0 and PMOS c3.
- **M1:**
  - the ENB and A pads are high with their bars running up;
  - EN is low;
  - Y is an L: a bar through the NMOS-Y V0, then a vertical on PMOS c2.
- **Double patterning:** the conflict graph is a tree. An earlier snaking Y made an
  odd triangle.

## Fill / tap / caps — CORE_FILL*, CORE_FILLTIE, CORE_ENDCAP_*, CORE_CORNER_*

See frame.md, "Special cells".

## Thick-oxide family — THICK_*

**INV X1..X8**
- Sources go straight into the wide rails. Y is a C (bars over the drains, vertical at
  the right). A is a straight middle bar.
- MP: 1X uses a wider pad with 2 V0. K≥2 uses one thin MP per gate, each with 2 V0. A
  long shared MP bar is illegal in this frame (length windows).

**NAND/NOR X1**
- Gates C, B, A from left to right, with A next to Y.
- The input segments sit on the middle track, far enough apart to avoid odd
  double-patterning loops with the Y bar.

**NAND/NOR X2**
- Grouped inputs (e.g. B B A A); NAND3 X2 uses a diffusion break.
- Stack nodes are joined by a thin bar on the lower gap track and a bar under the NMOS
  OD. The bar keeps out of the "forbidden band" spacing to the wide rail.
- NOR mirrors NAND about the row centre.

**PG X1**
- A is a C on the left and Y a mirrored C on the right. S and SN are horizontal bars
  across the gap.
- Poly columns are shared, with every gate split in the gap (edge gates too).
- The user rejected:
  - four straight bars with MD crossing the gap;
  - plain verticals.

**PG X2/X4**
- Two interlocking Cs: the NMOS columns run A Y A.. and the PMOS columns run Y A Y..
- M1 from bottom to top: VSS | Y arm | A arm | S | SN | Y arm | A arm | VDD.
- Each column has its V0 under its own arm. A gets a left vertical and Y a mirrored right
  vertical.
- A 2nd V0 is added on the free outer columns using teeth. Full-height blocks would
  become wide metal.

**FILLTIE** — 4 pitches minimum (see frame.md).

**TIEH / TIEL (4 pitches)**
- TIEL is the mirror of TIEH.
- The gate split gives an N piece on Z and a P piece on net4.
- net4 is an inverted U. Z = an MD extension plus an L to a low pad with 2 V0.
- A double-patterning chain was fixed by lowering the VSS V0 pair.

**LS_LO2HI (level shifter, 47 pitches)**
- **Circuit:** two cross-coupled stages and an output pull-down. The user set the
  device order:

  | Stage | PMOS columns | NMOS |
  |---|---|---|
  | 1 | INTB net2 VX1 VDD VX1 net3 INT | NM0×3, NM1×3 |
  | 2 | net1 net9 VX2 VDD VX2 net7 VO | NM2×3, NM3×3 |

  Output: a single NM4.
- **Gates:** continuous gates where N and P share a net; diffusion breaks between the
  stages.
- **Routing:** M1 + M2. M2 tracks are listed per net, wide, with L-turns and vertical
  rectangular V1 at the track ends. Pin rows are kept free of foreign M2.
- Read its PNG together with routing.md "Multi-stage".
