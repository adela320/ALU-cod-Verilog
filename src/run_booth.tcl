# 1. Cur??area bibliotecii vechi ?i crearea uneia noi
if [file exists work] {vdel -all}
vlib work
vmap work work

# 2. Compilarea fi?ierelor în ordinea ierarhic?
# Mai întâi modulele de baz? (Arithmetic)
vlog adder_rca.v

# Apoi componentele înmul?itorului Booth Radix-4
vlog booth_multiplier_datapath.v
vlog booth_multiplier_ctrl.v

# La final, Testbench-ul pentru înmul?itor
vlog booth_multiplier_tb.v

# 3. Pornirea simul?rii
# Folosim -voptargs=+acc pentru a vedea semnalele interne în Waveform
vsim -voptargs=+acc work.booth_multiplier_tb

# 4. Ad?ugarea semnalelor în fereastra Wave
# Ad?ug?m semnalele de control c0-c8 ?i registrele importante
add wave -divider "Control Signals"
add wave -color "Yellow" sim:/booth_multiplier_tb/ctrl/st
add wave sim:/booth_multiplier_tb/ctrl/c0
add wave sim:/booth_multiplier_tb/ctrl/c1
add wave sim:/booth_multiplier_tb/ctrl/c2
add wave sim:/booth_multiplier_tb/ctrl/c3
add wave sim:/booth_multiplier_tb/ctrl/c4
add wave sim:/booth_multiplier_tb/ctrl/c5
add wave sim:/booth_multiplier_tb/ctrl/c6
add wave sim:/booth_multiplier_tb/ctrl/c7
add wave sim:/booth_multiplier_tb/ctrl/c8

add wave -divider "Data Registers"
add wave -radix decimal sim:/booth_multiplier_tb/dp/multiplier
add wave -radix decimal sim:/booth_multiplier_tb/dp/multiplicand
add wave -radix binary  sim:/booth_multiplier_tb/dp/triplet
add wave -radix decimal sim:/booth_multiplier_tb/dp/A
add wave -radix decimal sim:/booth_multiplier_tb/dp/Q
add wave -radix decimal sim:/booth_multiplier_tb/product

# 5. Rularea simul?rii
run -all

# Zoom pentru a vedea toate formele de und?
wave zoom full