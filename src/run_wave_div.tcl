# 1. Cur??are bibliotec? veche
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# 2. Compilare fi?iere (Asigur?-te c? numele fi?ierelor .v sunt corecte în folder)
vlog -work work -timescale "1ns/1ns" adder_rca.v
vlog -work work -timescale "1ns/1ns" restoring_div_unsigned.v
vlog -work work -timescale "1ns/1ns" restoring_div_unsigned_tb.v

# 3. Înc?rcare simulare
vsim -t 1ns work.restoring_div_unsigned_tb

# 4. Configurare Waveform
view wave
delete wave *

# Ad?ug?m semnalele din Testbench (cele de tip reg/wire din fi?ierul t?u)
add wave -noupdate -divider "Testbench"
add wave -hex sim:/restoring_div_unsigned_tb/*

# Ad?ug?m semnalele INTERNE (Aici am schimbat uut în dut!)
add wave -noupdate -divider "Datapath"
add wave -recursive -hex sim:/restoring_div_unsigned_tb/dut/*

# 5. Rulare ?i Zoom
run -all
wave zoom full