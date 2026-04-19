# ALU-cod-Verilog

Pentru ca simularea să pornească, ai nevoie exact de aceste fișiere în folderul tău: (adica ce e inclus in run_alu.tcl la inceput)

    adder_rca.v 

    alu_control_unit.v 

    alu_datapath.v 

    alu_main.v 

    alu_top_tb.v 

Alte note:
run_ex -> folosit la testarea adder_rca_sanity_tb

add_sub -> folosit pentru restoring division

run.tcl -> folosit la testarea restoring division

run_alu.tcl -> folosit la testarea finala alu

Info: 
Datapath (Calea de date): Ansamblul de registre (A,Q,M), sumatoare (RCA) si conexiuni care executa operațiile aritmetice si stochează biții procesați.

Control Unit (Unitatea de control): Automat de stări (FSM) care genereaza semnalele de comanda (c0​,c1​,…) pentru a dirija operațiile din Datapath in ordinea corecta.

Top Module: Modulul de nivel înalt care instanțiala si conectează porturile Control Unit-ului cu cele ale Datapath-ului.

Testbench: Mediu de simulare extern folosit pentru a genera stimuli (ceas, date de intrare) si pentru a verifica corectitudinea rezultatelor.
