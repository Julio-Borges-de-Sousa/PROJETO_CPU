create_project -in_memory -part xc7z010clg400-1

# Lê TODOS os arquivos com extensão .v do diretório atual automaticamente
read_verilog [glob ./*.v]

read_xdc ./zybo.xdc

synth_design -top processador
opt_design
place_design
route_design
write_bitstream -force processador.bit