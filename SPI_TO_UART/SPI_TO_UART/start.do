transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Temp/Veriog_kelvin/SPI_TO_UART {../../div_freq.v}
vlog -vlog01compat -work work +incdir+C:/Temp/Veriog_kelvin/SPI_TO_UART {../../uart_tx.v}
vlog -vlog01compat -work work +incdir+C:/Temp/Veriog_kelvin/SPI_TO_UART {../../spi_controller.v}
vlog -vlog01compat -work work +incdir+C:/Temp/Veriog_kelvin/SPI_TO_UART {../../fsm.v}
vlog -vlog01compat -work work +incdir+C:/Temp/Veriog_kelvin/SPI_TO_UART {../../SPI_TO_UART.v}
vlog -vlog01compat -work work +incdir+C:/Temp/Veriog_kelvin/SPI_TO_UART {../../config_circuit.v}

vlog -vlog01compat -work work +incdir+C:/Temp/Veriog_kelvin/SPI_TO_UART/simulation/modelsim {SPI_TO_UART_tst.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  SPI_TO_UART_vlg_tst

#add wave *
do wave.do
view structure
view signals
view variables
run 4000000 ns
