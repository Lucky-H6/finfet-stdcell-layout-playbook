# Generic layers

GDS layer/datatype used in `assets/finfet_stdcell_ref.gds` and by `scripts/gdsref.py`.
To use a real PDK, find the layer with the same role in its layer map and design rule
manual. Names differ between foundries; the roles below are the same in every FinFET
std-cell process we have seen.

| Name | GDS | Role |
|---|---|---|
| FIN | 1/0 | Fin grid lines (drawn across the whole cell at the fin pitch, 0.5 u in the core frame) |
| OD | 2/0 | Active / diffusion. N and P strips, ending on gate centrelines |
| PO | 3/0 | Gate poly / metal gate lines. Every pitch has one, including the edge gates |
| PODE | 4/0 | Poly-on-diffusion-edge marker: covers a gate where an OD ends (dummy, non-device gate) |
| POEDGE | 5/0 | Marks the two shared edge gates on the cell boundary |
| CPO | 6/0 | Poly cut. The core frame uses it only as two strips along the rails, cutting every gate between rows |
| NW | 7/0 | N-well (PMOS half, extends past the cell top and sides so rows merge) |
| NIMP / PIMP | 8/0, 9/0 | N+ / P+ implant (split at the N/P boundary; swapped inside tap cells) |
| VTN / VTP | 10/0, 11/0 | Threshold-voltage selection for the N / P half (one VT flavour per cell) |
| TO | 12/0 | Thick gate oxide (covers the whole thick-oxide cell) |
| PRBND | 13/0 | Cell placement boundary (the abutment box) |
| MD | 20/0 | Source/drain trench contact ("M0" in some PDKs): vertical strips at the half-pitch column centres |
| CMD | 21/0 | MD cut: a horizontal strip near a rail that cuts the MD columns that must not reach the rail |
| MD_RT | 22/0 | MD rail-tie extension: the part of a column inside the rail region, column NOT cut (rail-tied or floating dummy) |
| MD_RC | 23/0 | MD rail-cut extension: the part of a cut column inside the rail region (under CMD) |
| MP | 24/0 | Gate contact: pads or bars on the gates, in the N/P gap |
| V0 | 30/0 | Via MD/MP to M1 |
| V0R | 31/0 | Butted rail via: tall V0 joining a rail-tied MD column to the M1 rail |
| M1 | 32/0 | Metal 1 (rails, pins, local routing; double-patterned in the core frame) |
| M1RAIL | 33/0 | Marker over the M1 power rails (special rail rules apply under it) |
| V1 | 40/0 | Via M1 to M2 (square or rectangular) |
| M2 | 41/0 | Metal 2 (straps, combs, inter-finger connections) |
| M1_TXT / M2_TXT | 132/0, 141/0 | Pin labels on M1 / M2 |

Not reproduced: pitch-variant marker layers, density/dummy layers, colour (mask A/B)
layers. Draw those as the PDK requires.

Conventions in the reference library:
- **Pins** are text labels only, with no pin shapes. Use the supply names VDD/VSS; the
  level shifter supplies are in its netlist.
- **Rail labels** sit on the rails at the left edge.
