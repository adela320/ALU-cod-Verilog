if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog -work work -timescale "1ns/1ns" adder_rca.v
vlog -work work -timescale "1ns/1ns" addsub.v
vlog -work work -timescale "1ns/1ns" restoring_div_unsigned.v

vlog -work work -timescale "1ns/1ns" addsub_tb.v
vlog -work work -timescale "1ns/1ns" restoring_div_unsigned_tb.v

# Ruleaza unul:
# vsim -t 1ns work.addsub_tb
vsim -t 1ns work.restoring_div_unsigned_tb

run -all