vlib work
vlog adder_rca.v
vlog alu_control_unit.v
vlog alu_datapath.v
vlog alu_main.v
vlog alu_top_tb.v
vsim -voptargs=+acc work.alu_top_tb
add wave -radix decimal sim:/alu_top_tb/*
add wave -divider "Registers"
add wave -radix decimal sim:/alu_top_tb/dut/dp/A
add wave -radix decimal sim:/alu_top_tb/dut/dp/Q
run -all