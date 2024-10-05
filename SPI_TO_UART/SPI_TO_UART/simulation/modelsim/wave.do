onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /SPI_TO_UART_vlg_tst/clk
add wave -noupdate /SPI_TO_UART_vlg_tst/rst_n
add wave -noupdate /SPI_TO_UART_vlg_tst/miso
add wave -noupdate /SPI_TO_UART_vlg_tst/mosi
add wave -noupdate /SPI_TO_UART_vlg_tst/sclk
add wave -noupdate /SPI_TO_UART_vlg_tst/ss
add wave -noupdate /SPI_TO_UART_vlg_tst/tx_uart
add wave -noupdate -divider FSM
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/state_next
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/state_reg
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/rx_byte_spi
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/complete_spi
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/busy_uart
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/complete_uart
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/enable_uart
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/tx_byte_uart
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/tx_byte_spi
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/config_inst_temp_tx_packed
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/config_inst_temp_rx_packed
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/enable_spi
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/dgT1_msb
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/dgT1_lsb
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/dgT2_msb
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/dgT2_lsb
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/dgT3_msb
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/dgT3_lsb
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/temp_msb
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/temp_lsb
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/temp_xlsb
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/temp_cut
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/start
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/end_transfer_uart
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/end_config
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/tx_spi_config_flag
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/rx_spi_read_flag
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/send_to_uart
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/bit_count
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/bit_count_config_tx
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/config_inst_temp_tx
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/config_inst_temp_rx
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/spi_controller_inst/num_bits_tx
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/spi_controller_inst/num_bits_rx
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/spi_controller_inst/complete
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/spi_controller_inst/complete_rx
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/spi_controller_inst/complete_tx
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/config_circuit_inst/dgT1
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/config_circuit_inst/dgT2
add wave -noupdate /SPI_TO_UART_vlg_tst/i1/fsm_inst/config_circuit_inst/dgT3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3639804985 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 184
configure wave -valuecolwidth 142
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3535623522 ps} {4065777710 ps}
