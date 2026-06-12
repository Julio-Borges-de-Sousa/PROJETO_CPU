import sys
import re

def parse_reg(reg_str):
    """Converte string de registrador (ex: 'r0', 'R7') para inteiro 0-7."""
    return int(reg_str.lower().replace('r', ''))

def parse_imm(imm_str):
    """Converte imediato (ex: '#10', '#0xA', '#0b101') para inteiro."""
    imm_str = imm_str.replace('#', '')
    if '0x' in imm_str.lower():
        return int(imm_str, 16)
    elif '0b' in imm_str.lower():
        return int(imm_str, 2)
    else:
        return int(imm_str, 10)

def assemble_instruction(line):
    # Remove comentários (tudo após ';') e espaços extras
    line = line.split('/')[0].strip()
    if not line:
        return None

    # Substitui vírgulas e colchetes por espaços para padronizar a separação dos tokens
    clean_line = re.sub(r'[\s,\[\]]+', ' ', line).strip()
    tokens = clean_line.split(' ')
    
    op = tokens[0].upper()
    
    try:
        # NOP
        if op == "NOP":
            return 0x0000
        
        # HALT
        elif op == "HALT":
            return 0xFFFF
        
        # MOV Rd, Rm / MOV Rd, #Im
        elif op == "MOV":
            rd = parse_reg(tokens[1])
            if tokens[2].startswith('#'):
                imm = parse_imm(tokens[2]) & 0xFF # 8 bits
                # 0001 1 Rd[2:0] Im[7:0]
                return (1 << 12) | (1 << 11) | (rd << 8) | imm
            else:
                rm = parse_reg(tokens[2])
                # 0001 0 Rd[2:0] Rm[2:0] 00000
                return (1 << 12) | (0 << 11) | (rd << 8) | (rm << 5)
        
        # STR [Rm], Rn / STR [Rm], #Im
        elif op == "STR":
            rm = parse_reg(tokens[1])
            if tokens[2].startswith('#'):
                imm = parse_imm(tokens[2]) & 0xFF # 8 bits divididos [7:5] e [4:0]
                imm_high = (imm >> 5) & 0x7 # 3 bits
                imm_low = imm & 0x1F        # 5 bits
                # 0010 1 Im[7:5] Rm[2:0] Im[4:0]
                return (2 << 12) | (1 << 11) | (imm_high << 8) | (rm << 5) | imm_low
            else:
                rn = parse_reg(tokens[2])
                # 0010 0 000 Rm[2:0] Rn[2:0] 00
                return (2 << 12) | (0 << 11) | (rm << 5) | (rn << 2)
        
        # LDR Rd, [Rm]
        elif op == "LDR":
            rd = parse_reg(tokens[1])
            rm = parse_reg(tokens[2])
            # 0011 0 Rd[2:0] Rm[2:0] 00000 (assumindo bit 11 como 0)
            return (3 << 12) | (rd << 8) | (rm << 5)
            
        # ULA Operations: ADD, SUB, MUL, AND, ORR, XOR
        elif op in ["ADD", "SUB", "MUL", "AND", "ORR", "XOR"]:
            rd = parse_reg(tokens[1])
            rm = parse_reg(tokens[2])
            rn = parse_reg(tokens[3])
            opcodes = {"ADD": 4, "SUB": 5, "MUL": 6, "AND": 7, "ORR": 8, "XOR": 10}
            opcode_base = opcodes[op]
            # OPCODE 0 Rd Rm Rn 00
            return (opcode_base << 12) | (rd << 8) | (rm << 5) | (rn << 2)
            
        # NOT Rd, Rm
        elif op == "NOT":
            rd = parse_reg(tokens[1])
            rm = parse_reg(tokens[2])
            # 1001 0 Rd Rm 000 00
            return (9 << 12) | (rd << 8) | (rm << 5)
            
        # PSH Rn
        elif op == "PSH":
            rn = parse_reg(tokens[1])
            # 0000 0 000 000 Rn 01
            return (rn << 2) | 1
            
        # POP Rd
        elif op == "POP":
            rd = parse_reg(tokens[1])
            # 0000 0 Rd 000 000 10
            return (rd << 8) | 2
            
        # CMP Rm, Rn
        elif op == "CMP":
            rm = parse_reg(tokens[1])
            rn = parse_reg(tokens[2])
            # 0000 0 000 Rm Rn 11
            return (rm << 5) | (rn << 2) | 3
            
        # DESVIO: JMP, JEQ, JLT, JGT
        elif op in ["JMP", "JEQ", "JLT", "JGT"]:
            imm = parse_imm(tokens[1]) & 0x1FF # 9 bits
            conds = {"JMP": 0, "JEQ": 1, "JLT": 2, "JGT": 3}
            cond = conds[op]
            # 0000 1 Im[8:0] cond[1:0]
            return (1 << 11) | (imm << 2) | cond
            
        # IN Rd
        elif op == "IN":
            rd = parse_reg(tokens[1])
            # 1111 0 Rd 000 000 01
            return (15 << 12) | (rd << 8) | 1
            
        # OUT Rm / OUT #Im
        elif op == "OUT":
            if tokens[1].startswith('#'):
                imm = parse_imm(tokens[1]) & 0xFF # 8 bits
                imm_high = (imm >> 5) & 0x7 # 3 bits
                imm_low = imm & 0x1F        # 5 bits
                # 1111 1 Im[7:5] 000 Im[4:0]
                return (15 << 12) | (1 << 11) | (imm_high << 8) | imm_low
            else:
                rm = parse_reg(tokens[1])
                # 1111 0 000 Rm 000 10
                return (15 << 12) | (0 << 11) | (rm << 5) | 2
                
        # SHR Rd, Rm, #Im / SHL Rd, Rm, #Im
        elif op in ["SHR", "SHL"]:
            rd = parse_reg(tokens[1])
            rm = parse_reg(tokens[2])
            imm = parse_imm(tokens[3]) & 0x1F # 5 bits
            opcode_base = 11 if op == "SHR" else 12
            # OPCODE 0 Rd Rm Im[4:0]
            return (opcode_base << 12) | (rd << 8) | (rm << 5) | imm
            
        # ROR Rd, Rm / ROL Rd, Rm
        elif op in ["ROR", "ROL"]:
            rd = parse_reg(tokens[1])
            rm = parse_reg(tokens[2])
            opcode_base = 13 if op == "ROR" else 14
            # OPCODE 0 Rd Rm 000 00
            return (opcode_base << 12) | (rd << 8) | (rm << 5)
            
        else:
            raise ValueError(f"Instrução desconhecida: {op}")

    except Exception as e:
        print(f"Erro ao processar instrução '{line}': {e}")
        sys.exit(1)

def main(input_file, output_file):
    try:
        with open(input_file, 'r') as f_in, open(output_file, 'w') as f_out:
            rom_index = 0  # Inicializa o contador do índice da ROM
            
            for line_number, line in enumerate(f_in, 1):
                hex_val = assemble_instruction(line)
                
                # Só incrementa o índice da ROM se a linha gerou uma instrução válida (ignora linhas vazias/comentários)
                if hex_val is not None:
                    f_out.write(f"ROM[{rom_index}] = 16'H{hex_val:04X};\n")
                    rom_index += 1
                    
        print(f"Montagem concluída. Arquivo '{output_file}' gerado para inicialização da ROM.")
    except FileNotFoundError:
        print(f"Erro: Arquivo '{input_file}' não encontrado.")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python assembler.py <arquivo_entrada.asm> <arquivo_saida.hex>")
        sys.exit(1)
        
    main(sys.argv[1], sys.argv[2])