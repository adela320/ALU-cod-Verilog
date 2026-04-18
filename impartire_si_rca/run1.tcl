# 1. Crearea bibliotecii de lucru
vlib work
vmap work work

# 2. Compilarea fi?ierelor (în ordinea dependen?elor)
# Compil?m mai întâi modulele de baz?
vlog adder_rca.v
vlog addsub.v

# Compil?m componentele divizorului bazat pe semnale de control
vlog restoring_div_datapath.v
vlog restoring_div_ctrl.v

# Compil?m modulul Top (ALU Main) ?i Testbench-ul
vlog alu_main.v
vlog alu_main_tb.v

# 3. Pornirea simul?rii
# -voptargs=+acc permite vizualizarea semnalelor interne în Waveform
vsim -voptargs=+acc work.alu_main_tb

# 4. Ad?ugarea semnalelor în fereastra Wave (op?ional)
add wave -position insertpoint sim:/alu_main_tb/dut/*
add wave -position insertpoint sim:/alu_main_tb/dut/ctrl/*
add wave -position insertpoint sim:/alu_main_tb/dut/dp/*

# 5. Rularea simul?rii pân? la final ($stop în Verilog)
run -all