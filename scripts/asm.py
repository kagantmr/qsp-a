import sys
import argparse

# opcodes
OPCODES = {
    'ADD_IMM':  0b000001,
    'ADD_REG':  0b000010,
    'SUB_IMM':  0b000011,
    'SUB_REG':  0b000100,
    'MOV_IMM':  0b001101,
    'MOV_REG':  0b001110,
    'CMP_IMM':  0b001111,
    'CMP_REG':  0b010000,
    'NOP':      0b111111
}

REGS = {f'S{i}': i for i in range(16)}

def assemble_line(line, line_num):
    line = line.split('//')[0].split(';')[0].strip()
    if not line:
        return None
        
    parts = line.replace(',', ' ').split()
    instr = parts[0].upper()
    
    if instr not in OPCODES:
        print(f"Error at line {line_num}: Unknown/illegal instruction {instr}")
        sys.exit(1)
        
    opcode = OPCODES[instr]
    
    try:
        sd = REGS[parts[1].upper()]
        ss1 = REGS[parts[2].upper()]
        
        if instr.endswith('_IMM'):
            # Immediate format: imm18
            imm = int(parts[3].replace('#', ''), 0) & 0x3FFFF
            binary = (opcode << 26) | (sd << 22) | (ss1 << 18) | imm
        else:
            # Register format: ss2
            ss2 = REGS[parts[3].upper()] if len(parts) > 3 else 0
            binary = (opcode << 26) | (sd << 22) | (ss1 << 18) | (ss2 << 14)
            
        return f"{binary:08x}"
    except (IndexError, KeyError, ValueError) as e:
        print(f"Error at line {line_num}: Invalid syntax or register. {e}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='QTP-A assembler')
    parser.add_argument('input', help='Input assembly file (.asm)')
    parser.add_argument('-o', '--output', default='memory.mem', help='Output hex file (default: memory.mem)')
    
    args = parser.parse_args()

    try:
        with open(args.input, 'r') as f_in, open(args.output, 'w') as f_out:
            for i, line in enumerate(f_in, 1):
                hex_val = assemble_line(line, i)
                if hex_val:
                    f_out.write(hex_val + "\n")
        print(f"Successfully assembled {args.input} -> {args.output}")
    except FileNotFoundError:
        print(f"Error: Could not find file {args.input}")

if __name__ == "__main__":
    main()