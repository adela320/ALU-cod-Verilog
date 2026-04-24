# ALU-cod-Verilog

Mini-ALU în Verilog cu operații:
- **ADD / SUB** (intern pe 9 biți)
- **DIV unsigned** (algoritm *restoring*)
- **MUL** (Booth Radix-4)

Include **testbench-uri** și **scripturi TCL** pentru simulare în ModelSim.

## Structură
- `src/` – modulele Verilog, testbench-uri și scripturi `.tcl`

## Simulare (ModelSim)
Rulează din folderul `src/`:
- `do run_alu.tcl` – testbench ALU (top)
- `do run.tcl` – diviziune restoring / addsub
- `do run_booth.tcl` – Booth multiplier
