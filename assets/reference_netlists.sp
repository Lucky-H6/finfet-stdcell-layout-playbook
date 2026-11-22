* Reference netlists of the finfet-stdcell-layout-playbook skill (generic devices).
* nch/pch = core thin-oxide FinFET, nch_thk/pch_thk = thick-oxide FinFET; nfin = fins per finger, nf = fingers.
* The Virtuoso library assets/schematics/FINFET_STDCELL_REF_SCH draws the same circuits with analogLib nmos4/pmos4
* (model = nch/pch/..., m = nf, instance property nfin).
* Body pins are tied to the cell supplies in the schematic; in layout they are the wells (no taps in logic cells).
* Cells with a drive-strength parameter (nfg/pfg) are drawn in layout as _X1/_X2/... = that many fingers per device.

* pins Y:io A:in VSS:io VDD:io
.SUBCKT CORE_INV Y A VSS VDD nfg=1 pfg=1
MNM0 Y A VSS VSS nch nfin=4 nf=nfg
MPM0 Y A VDD VDD pch nfin=4 nf=pfg
.ENDS

* pins VSS:io A:in B:in Y:out VDD:io
.SUBCKT CORE_NAND2 VSS A B Y VDD nfg=1 pfg=1
MNM0 Y A net11 VSS nch nfin=4 nf=nfg
MNM1 net11 B VSS VSS nch nfin=4 nf=nfg
MPM0 Y B VDD VDD pch nfin=4 nf=pfg
MPM1 Y A VDD VDD pch nfin=4 nf=pfg
.ENDS

* pins C:in VDD:io A:in B:in Y:out VSS:io
.SUBCKT CORE_NAND3 C VDD A B Y VSS nfg=1 pfg=1
MNM0 Y A net011 VSS nch nfin=4 nf=nfg
MNM1 net011 B net014 VSS nch nfin=4 nf=nfg
MNM2 net014 C VSS VSS nch nfin=4 nf=nfg
MPM0 Y C VDD VDD pch nfin=4 nf=pfg
MPM1 Y B VDD VDD pch nfin=4 nf=pfg
MPM2 Y A VDD VDD pch nfin=4 nf=pfg
.ENDS

* pins VSS:io A:in B:in Y:out VDD:io
.SUBCKT CORE_NOR2 VSS A B Y VDD nfg=1 pfg=1
MNM0 Y B VSS VSS nch nfin=4 nf=nfg
MNM1 Y A VSS VSS nch nfin=4 nf=nfg
MPM0 net14 B VDD VDD pch nfin=4 nf=pfg
MPM1 Y A net14 VDD pch nfin=4 nf=pfg
.ENDS

* pins VSS:io A:in B:in Y:out C:in VDD:io
.SUBCKT CORE_NOR3 VSS A B Y C VDD nfg=1 pfg=1
MNM0 Y A VSS VSS nch nfin=4 nf=nfg
MNM1 Y B VSS VSS nch nfin=4 nf=nfg
MNM2 Y C VSS VSS nch nfin=4 nf=nfg
MPM0 net014 C VDD VDD pch nfin=4 nf=pfg
MPM1 net14 B net014 VDD pch nfin=4 nf=pfg
MPM2 Y A net14 VDD pch nfin=4 nf=pfg
.ENDS

* pins Y:io A:io VSS:io SN:in S:in VDD:io
.SUBCKT CORE_PG Y A VSS SN S VDD nfg=1 pfg=1
MNM0 A S Y VSS nch nfin=4 nf=nfg
MPM0 A SN Y VDD pch nfin=4 nf=pfg
.ENDS

* pins Z:out VDD:io VSS:io
.SUBCKT CORE_TIEH Z VDD VSS
MNM0 net8 net8 VSS VSS nch nfin=4 nf=1
MPM0 Z net8 VDD VDD pch nfin=4 nf=1
.ENDS

* pins Z:out VDD:io VSS:io
.SUBCKT CORE_TIEL Z VDD VSS
MNM0 Z net8 VSS VSS nch nfin=4 nf=1
MPM0 net8 net8 VDD VDD pch nfin=4 nf=1
.ENDS

* pins VDD:io Y:io VSS:io A:in ENABLE:in
.SUBCKT CORE_TBUF VDD Y VSS A ENABLE
MM0 ENB ENABLE VSS VSS nch nfin=3 nf=1
MM1 OL ENB VSS VSS nch nfin=3 nf=1
MM2 OH ENABLE OL VSS nch nfin=3 nf=1
MM3 OL A VSS VSS nch nfin=3 nf=1
MM4 Y OL VSS VSS nch nfin=3 nf=1
MM5 ENB ENABLE VDD VDD pch nfin=3 nf=1
MM6 OH ENABLE VDD VDD pch nfin=3 nf=1
MM7 OL ENB OH VDD pch nfin=3 nf=1
MM8 OH A VDD VDD pch nfin=3 nf=1
MM9 Y OH VDD VDD pch nfin=3 nf=1
.ENDS

* pins Y:io A:in VSS:io EN:in ENB:in VDD:io
.SUBCKT CORE_TINV Y A VSS EN ENB VDD
MNM0 net010 EN VSS VSS nch nfin=3 nf=1
MNM1 Y A net010 VSS nch nfin=3 nf=1
MPM0 Y A net011 VDD pch nfin=3 nf=1
MPM1 net011 ENB VDD VDD pch nfin=3 nf=1
.ENDS

* pins Y:io A:in VDD:io VSS:io
.SUBCKT THICK_INV Y A VDD VSS nfg=1 pfg=1
MNM0 Y A VSS VSS nch_thk nfin=4 nf=nfg
MPM0 Y A VDD VDD pch_thk nfin=4 nf=pfg
.ENDS

* pins VDD:io A:in B:in Y:out VSS:io
.SUBCKT THICK_NAND2 VDD A B Y VSS nfg=1 pfg=1
MNM0 Y A net011 VSS nch_thk nfin=4 nf=nfg
MNM1 net011 B VSS VSS nch_thk nfin=4 nf=nfg
MPM0 Y B VDD VDD pch_thk nfin=4 nf=pfg
MPM1 Y A VDD VDD pch_thk nfin=4 nf=pfg
.ENDS

* pins C:in VDD:io A:in B:in Y:out VSS:io
.SUBCKT THICK_NAND3 C VDD A B Y VSS nfg=1 pfg=1
MNM0 Y A net011 VSS nch_thk nfin=4 nf=nfg
MNM1 net011 B net014 VSS nch_thk nfin=4 nf=nfg
MNM2 net014 C VSS VSS nch_thk nfin=4 nf=nfg
MPM0 Y C VDD VDD pch_thk nfin=4 nf=pfg
MPM1 Y B VDD VDD pch_thk nfin=4 nf=pfg
MPM2 Y A VDD VDD pch_thk nfin=4 nf=pfg
.ENDS

* pins VDD:io A:in B:in Y:out VSS:io
.SUBCKT THICK_NOR2 VDD A B Y VSS nfg=1 pfg=1
MNM0 Y A VSS VSS nch_thk nfin=4 nf=nfg
MNM1 Y B VSS VSS nch_thk nfin=4 nf=nfg
MPM0 Y A net14 VDD pch_thk nfin=4 nf=pfg
MPM1 net14 B VDD VDD pch_thk nfin=4 nf=pfg
.ENDS

* pins VSS:io A:in B:in Y:out C:in VDD:io
.SUBCKT THICK_NOR3 VSS A B Y C VDD nfg=1 pfg=1
MNM0 Y A VSS VSS nch_thk nfin=4 nf=nfg
MNM1 Y B VSS VSS nch_thk nfin=4 nf=nfg
MNM2 Y C VSS VSS nch_thk nfin=4 nf=nfg
MPM1 net09 C VDD VDD pch_thk nfin=4 nf=pfg
MPM2 net14 B net09 VDD pch_thk nfin=4 nf=pfg
MPM3 Y A net14 VDD pch_thk nfin=4 nf=pfg
.ENDS

* pins Y:io A:io VDD:io SN:in S:in VSS:io
.SUBCKT THICK_PG Y A VDD SN S VSS nfg=1 pfg=1
MNM0 A S Y VSS nch_thk nfin=4 nf=nfg
MPM0 A SN Y VDD pch_thk nfin=4 nf=pfg
.ENDS

* pins VSS:io Z:out VDD:io
.SUBCKT THICK_TIEH VSS Z VDD
MNM0 net4 net4 VSS VSS nch_thk nfin=4 nf=1
MNM1 net4 Z VSS VSS nch_thk nfin=4 nf=1
MPM0 Z net4 VDD VDD pch_thk nfin=4 nf=2
.ENDS

* pins Z:out VSS:io VDD:io
.SUBCKT THICK_TIEL Z VSS VDD
MNM0 Z net8 VSS VSS nch_thk nfin=4 nf=2
MPM0 net8 net8 VDD VDD pch_thk nfin=4 nf=1
MPM1 net8 Z VDD VDD pch_thk nfin=4 nf=1
.ENDS

* pins IN:in CFOB:in INB:in VDD:io VO:out VSS:io
.SUBCKT THICK_LS_LO2HI IN CFOB INB VDD VO VSS
MNM0 INTB IN VSS VSS nch_thk nfin=4 nf=3
MNM1 INT INB VSS VSS nch_thk nfin=4 nf=3
MNM2 net1 INT VSS VSS nch_thk nfin=4 nf=3
MNM3 VO INTB VSS VSS nch_thk nfin=4 nf=3
MNM4 VO CFOB VSS VSS nch_thk nfin=4 nf=1
MPM0 VX1 CFOB VDD VDD pch_thk nfin=4 nf=2
MPM1 net2 INTB VX1 VDD pch_thk nfin=4 nf=1
MPM10 VX2 CFOB VDD VDD pch_thk nfin=4 nf=2
MPM11 net1 INT net9 VDD pch_thk nfin=4 nf=1
MPM12 VO INTB net7 VDD pch_thk nfin=4 nf=1
MPM3 INTB INT net2 VDD pch_thk nfin=4 nf=1
MPM4 INT INTB net3 VDD pch_thk nfin=4 nf=1
MPM7 net3 INT VX1 VDD pch_thk nfin=4 nf=1
MPM8 net9 VO VX2 VDD pch_thk nfin=4 nf=1
MPM9 net7 net1 VX2 VDD pch_thk nfin=4 nf=1
.ENDS
