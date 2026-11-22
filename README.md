# finfet-stdcell-layout-playbook

An agent skill for drawing **FinFET standard-cell-style layouts**. It uses the open
`SKILL.md` format, so it works with any coding agent that supports skills, such as Claude Code,
Codex or OpenCode, and with any other agent through a one-line pointer. It holds the design experience gathered while building a complete cell library by
hand and by script: logic gates, pass gates, tie cells, tri-state cells, fillers, well taps,
end caps, thick-oxide gates and a level shifter. Reference layouts and schematics come with it.

Everything is **technology-neutral**:
- No foundry, process or PDK names.
- Generic layer names.
- Dimensions in gate-pitch units.
- Geometry deliberately approximate, snapped to 1/8 pitch.

The skill teaches **topology, routing style and verification method**, not design rules.
Every real number must come from your own PDK.

## What the skill helps with

- Planning a new cell:
  - device and gate order;
  - the net of every source/drain column;
  - which columns tie to a rail and which are cut;
  - where the gate contacts and M1 tracks go.
- Routing in a consistent, reviewable style:
  - C-shaped outputs;
  - L shapes instead of T or H shapes;
  - merged polygons;
  - wide metal where there is room;
  - fully enclosed rectangular vias;
  - pins that stay reachable from above.
- Filling every source/drain column with contact (MD) that reaches both rails, so short MD
  pieces in abutted cells always join up.
- Verifying correctly:
  - telling single-cell DRC artifacts from real errors;
  - building full-coverage abutment arrays;
  - latch-up tap coverage;
  - double-patterning odd loops that only appear when cells are abutted;
  - LVS with well bodies.

## Contents

```
finfet-stdcell-layout-playbook/
├── SKILL.md                     entry point: workflow and key principles
├── references/
│   ├── layers.md                generic layer names and their roles
│   ├── frame.md                 core and thick-oxide cell frames, special cells
│   ├── routing.md               routing style rules, with the reason for each
│   ├── cells.md                 catalogue of every reference cell
│   ├── verification.md          DRC/LVS/abutment/latch-up method, rule families
│   └── tooling.md               generator and scripting notes (incl. Virtuoso SKILL)
├── assets/
│   ├── finfet_stdcell_ref.gds   53 reference cells + 2 abutment arrays (approximate geometry)
│   ├── png/                     a preview of every cell and array
│   ├── schematics/FINFET_STDCELL_REF_SCH/   Virtuoso library: schematics + symbols (analogLib nmos4/pmos4)
│   └── reference_netlists.sp    the same circuits as generic SPICE
└── scripts/
    └── gdsref.py                pure-Python GDS reader / renderer for the reference GDS
```

### Reference cells

**Core family (`CORE_*`, 6-pitch-tall row)**
- Logic: INV X1–X16, NAND2/3 X1–X2, NOR2/3 X1–X2, PG (pass gate) X1/X2/X4.
- Ties and tri-state: TIEH, TIEL, TBUF, TINV.
- Physical cells: FILLTIE, FILL1–16, ENDCAP_ROW/COLN/COLP, four corner cells.
- `EXAMPLE_CORE`: the full abutment test array these cells passed with.

**Thick-oxide family (`THICK_*`, analog-style 10-pitch row)**
- Logic: INV X1–X8, NAND2/3 X1–X2, NOR2/3 X1–X2, PG X1/X2/X4.
- FILLTIE, TIEH, TIEL, and LS_LO2HI (level shifter).
- `EXAMPLE_THICK`: the family's abutment test array.

**Units and coordinates**
- 1 unit = the core contacted gate pitch.
- Each cell's origin is the lower-left corner of its placement boundary.

## Installation

Clone the repository into your agent's skills directory:

```bash
git clone https://github.com/Lucky-H6/finfet-stdcell-layout-playbook.git <skills-dir>/finfet-stdcell-layout-playbook
```

| Agent | Typical skills directory (user-level; check your agent's docs) |
|---|---|
| Claude Code | `~/.claude/skills/` (or `.claude/skills/` in a project) |
| Codex CLI | `~/.codex/skills/` (or `.codex/skills/` in a project) |
| OpenCode | `~/.config/opencode/skill/` (or `.opencode/skill/` in a project) |

The agent reads the `name` and `description` from `SKILL.md` and loads the skill for
std-cell layout work. You can also ask for it by name ("use the
finfet-stdcell-layout-playbook skill").

**Agents without skill support.** Clone the repository anywhere and add a line to the
project's `AGENTS.md` (or the agent's equivalent instruction file):

```
For standard-cell layout work, first read <path>/finfet-stdcell-layout-playbook/SKILL.md and follow it.
```

`SKILL.md` points to everything else. If your agent cannot view images, use
`scripts/gdsref.py dump` to read cell shapes as text instead of the PNG previews.

## Using the assets directly

**Inspect the reference GDS (Python 3; matplotlib only for PNG output)**

```bash
python3 scripts/gdsref.py list                                   # cells and boundaries
python3 scripts/gdsref.py dump CORE_TINV M1 V0 MP                # shapes per layer
python3 scripts/gdsref.py png  CORE_PG_X2 pg.png                 # render one cell
python3 scripts/gdsref.py place EXAMPLE_CORE | head              # placements of an array
python3 scripts/gdsref.py png  EXAMPLE_CORE win.png --window 0 0 40 14   # detail of an array
```

The GDS uses the generic layer numbers listed in `references/layers.md`. Any GDS viewer
(e.g. KLayout) opens it too.

**Open the schematics in Cadence Virtuoso**
1. Add this line to your `cds.lib` (analogLib must be available):

   ```
   DEFINE FINFET_STDCELL_REF_SCH <path-to-skill>/assets/schematics/FINFET_STDCELL_REF_SCH
   ```

2. Each transistor is an analogLib `nmos4`/`pmos4`:
   - `model` is one of nch / pch / nch_thk / pch_thk;
   - `m` is the finger count; sized cells use `pPar("nfg")`/`pPar("pfg")` from their cell CDF;
   - `nfin` is an instance property.
3. Map these to your PDK devices when porting.

## Important limitations

- **Not rule-exact.** Shapes are snapped to a coarse grid on purpose. Do not measure widths
  or spacings from them, and do not tape out from them.
- **Bring your own PDK.** Layer mapping, design rules, device models and the DRC/LVS
  decks come from your foundry. The skill tells you which kinds of rule matter; your deck
  supplies the numbers.
- **No affiliation.** The project is not affiliated with or endorsed by any foundry or EDA
  vendor. Tool names are used only to describe workflows.

## License

Released under the MIT License; see [LICENSE](LICENSE).
