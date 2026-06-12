# Abre o servidor de hardware local
open_hw_manager
connect_hw_server

# Conecta ao primeiro dispositivo encontrado (sua placa Zybo)
open_hw_target
set device [lindex [get_hw_devices xc7z010_1] 0]
current_hw_device $device

# Define o arquivo .bit gerado e programa
set_property PROGRAM.FILE "processador.bit" $device
program_hw_devices $device

# Encerra a conexão
close_hw_manager