## Makefile para compilação e simulação de Verilog usando o Vivado
#TOP_MODULE = processador
#
## 1. Altere aqui para o nome do módulo do seu arquivo de Testbench
#TB_MODULE = top_level_tb
#
## 2. Nome do snapshot que o Vivado vai gerar
#SNAPSHOT = sim_snapshot
#
## 3. Pega automaticamente todos os arquivos .v na pasta atual
#SRC = $(wildcard *.v)
#
#.PHONY: all compile elaborate simulate wave clean
#
## O comando padrão ao digitar apenas 'make'
#all: simulate
#
#compile:
#	@echo "==> [1/3] Compilando os arquivos Verilog..."
#	xvlog $(SRC)
#
#elaborate: compile
#	@echo "==> [2/3] Elaborando o design..."
#	xelab -debug typical -top $(TB_MODULE) -snapshot $(SNAPSHOT)
#
#simulate: elaborate
#	@echo "==> [3/3] Executando a simulação no terminal..."
#	xsim $(SNAPSHOT) -R
#
#rtl:
#	@echo "==> Gerando script Tcl para analise RTL..."
#	@echo "read_verilog $(SRC)" > open_rtl.tcl
#	@echo "synth_design -rtl -top $(TOP_MODULE)" >> open_rtl.tcl
#	@echo "start_gui" >> open_rtl.tcl
#	@echo "==> Abrindo Vivado..."
#	env -u LD_LIBRARY_PATH vivado -source open_rtl.tcl &
#
#wave:
#	@echo "==> Abrindo as formas de onda no GTKWave..."
#	LD_LIBRARY_PATH= LD_PRELOAD= GTK_PATH= GTK_MODULES= gtkwave ondas.vcd &
#
#clean:
#	@echo "==> Limpando arquivos de log e cache do Vivado..."
#	rm -rf xsim.dir .Xil *.jou *.log *.pb ondas.vcd open_rtl.tcl





# Variáveis
PROJECT = processador
BITSTREAM = $(PROJECT).bit

# Alvo principal: compila a FPGA
all: build

build:
	vivado -mode batch -source build.tcl

build_q:
	@echo "Compilando em silêncio..."
	@vivado -mode batch -source build.tcl > /dev/null 2>&1

# Grava o bitstream na placa Zybo
program:
	vivado -mode batch -source program.tcl

# Limpa o "lixo" gerado pelo Vivado
clean:
	rm -rf .Xil *.jou *.log *.pb *.cache usage_statistics_webtalk.* *.bit

erros:
	@echo "=== RELATÓRIO DE FALHAS ==="
	@grep -E "INFO:|ERROR:|WARNING:|CRITICAL WARNING:" vivado.log || echo "Nenhum erro encontrado no log."