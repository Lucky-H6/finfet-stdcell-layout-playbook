---
name: finfet-stdcell-layout-playbook
description: Design experience and reference layouts for drawing FinFET standard-cell-like layouts (logic gates, pass gates, tie cells, tri-state buffers/inverters, fillers, well-tap cells, end caps, level shifters, thick-oxide/IO-voltage gates) by script or by hand in any FinFET process. Use it whenever the user asks to draw, generate, review, fix or extend a std-cell or std-cell-style layout (INV, NAND, NOR, PG/transmission gate, TIEH/TIEL, TBUF, TINV, FILLTIE, FILL, ENDCAP, LS ...), to plan device order / M0-M1-M2 routing for a small gate, to build an abutment test array, or to chase DRC that only appears when cells are abutted (double-patterning loops, line-end/cut rules, latch-up tap spacing), even if the user does not mention "standard cell".
---

# FinFET std-cell layout

Distilled from a full library built together with the user: core-voltage cells on a
std-cell frame (rails, cut layers, butted rail contacts) and thick-oxide cells on an
analog-style frame. Everything here is technology-neutral: layer names are generic,
dimensions are in **gate-pitch units (u)**, where 1 u = the core contacted gate pitch, and no
real rule values are given.

The reference geometry is **approximate on purpose**. Every coordinate is snapped to a
1/8 u grid, so the cells show topology, column plans, routing style and relative
placement, not rule-exact shapes. Never read a spacing or width off them. Take every
number from the target PDK's deck.

## What is in the skill

| Path | Use |
|---|---|
| `references/layers.md` | Generic layer names: what each one is, and how to find its counterpart in a real PDK |
| `references/frame.md` | Cell frame architecture: core row and thick-oxide row, rails, cuts, edges, implants |
| `references/routing.md` | Routing style the user wants (MD/MP/V0/M1/M2 patterns, shapes, vias, pins) |
| `references/cells.md` | Catalogue of every reference cell: topology, device order, routing idea, lessons |
| `references/verification.md` | How to verify: standalone vs abutted DRC, abutment arrays, latch-up, DP loops, LVS |
| `references/tooling.md` | Practical scripting notes (generators, shape merging, Virtuoso/SKILL gotchas) |
| `assets/finfet_stdcell_ref.gds` | 53 reference cells plus 2 abutment arrays (EXAMPLE_CORE, EXAMPLE_THICK), in u, generic layers, 1/8 u grid, origin at the cell's lower-left corner |
| `assets/png/<CELL>.png` | Quick-look render of every cell; the arrays have a floorplan plus a `_zoom` detail; read these first |
| `assets/schematics/FINFET_STDCELL_REF_SCH/` | Virtuoso (OA) library: schematic and symbol of every reference circuit, built from analogLib `nmos4`/`pmos4` |
| `assets/reference_netlists.sp` | The same circuits as generic SPICE |
| `scripts/gdsref.py` | `list`, `dump`, `png` (with `--window` for arrays) and `place` (array placements) on the reference GDS, in pure Python |

Cell names:
- `CORE_*` are core-voltage std cells (6 u row). `THICK_*` are thick-oxide cells
  (10 u row, their own gate pitch). `_Xk` = k fingers per device.
- `EXAMPLE_CORE` and `EXAMPLE_THICK` are the full-coverage abutment arrays that each
  cell family was accepted with (see verification.md).

Schematic library:
- To use it, add `DEFINE FINFET_STDCELL_REF_SCH <path>/assets/schematics/FINFET_STDCELL_REF_SCH`
  to a cds.lib; it needs analogLib.
- Each device instance carries:
  - `model` = nch / pch / nch_thk / pch_thk;
  - `m` = the finger count (`pPar("nfg")` / `pPar("pfg")` on sized cells, whose cell
    CDF defines nfg/pfg);
  - a `nfin` property.
- Map model, fins and fingers to the PDK device when porting.

## Workflow

1. **Understand the circuit.** Read the user's schematic or netlist and find the closest
   reference in `references/cells.md` and `assets/reference_netlists.sp`, and follow its
   column plan and routing pattern.
2. **Plan on paper first.** Write out, before any code:
   - the gate order and the net of every S/D column, for NMOS and PMOS separately;
   - which columns tie to a rail and which are cut;
   - where the gate contacts (MP) go;
   - the M1 tracks.

   Prefer shared diffusion and as few pitches as possible. Use a diffusion break
   (PODE dummy gate) only when the nets force it. When N and P need different gate nets,
   stagger the N and P diffusion rather than splitting a gate in a narrow N/P gap
   (see TINV and PG in cells.md).
3. **Build from the frame** in `references/frame.md`. Copy a reference cell of the same
   family and change only what must change. Frames are shared library-wide, so never
   invent a new row height. The row grows only for a design rule or a real
   specification, never to make routing easier.
4. **Route** per `references/routing.md`. The short version:
   - L shapes, not T or H shapes;
   - C-shaped outputs;
   - wide M1/M2 where there is room;
   - rectangular V1 enclosed on all four sides;
   - every touching same-layer shape merged into one polygon;
   - pins reachable from above;
   - every S/D column has MD reaching both rails (dummy if unused).
5. **Verify** per `references/verification.md`:
   - DRC the cell alone and classify each flag as abutment-only or real;
   - then DRC a full-coverage abutment array with latch-up checks on;
   - run LVS against the schematic, with bodies on the wells.

   A cell is done only when the array is clean apart from floating-input flags.
6. **Show the user and iterate.** The user reviews layouts by eye and gives style
   corrections. Fold each correction into the generator and, if it is general, into
   this skill.

## Principles that cost the most to learn

- **Single-cell DRC lies in both directions.** Some flags vanish once abutted: line ends
  that join the neighbour's MD, well area, cut-layer extension at the cell edge. Others
  appear only when abutted: double-patterning odd loops through shared rails, latch-up
  tap distance, cut-line rules on short MD whose neighbour has no MD in that column.
  Always DRC an abutment array before calling a cell done.
- **Every S/D column needs MD reaching both rail edges.** If any column is missing in a
  cell, a short MD in the cell across the rail cannot join anything and violates the
  line-end-must-touch-cut rule. Fill empty columns with uncut floating dummy MD (MD_RT
  at the rail end, as fillers do).
- **Odd double-patterning loops** form through the shared VDD/VSS rails. Keep each
  cell's M1 conflict graph a tree, and keep the VSS…VDD conflict chain even. Keep M1
  near the left and right cell edges far enough from the edge that two abutted cells
  can never conflict.
- **Ask before library-wide edits.** Prototype on a copy, run DRC, show the evidence,
  then change accepted cells. Never overwrite a cell the user is reviewing; create a
  new one.
- **Every rule you hit is information.** When a fix needs a number, find the rule in
  the real deck and note which family of rule it was (see verification.md). Don't
  nudge until it passes.
