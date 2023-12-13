def gen_i_mem_code(hex_file, output_file):
    with open(output_file, mode='w') as gen_f:
        gen_f.write(f'// this file is generated automatically\nmodule Imem (\n\tinput [9:0] addr,\n\toutput reg[31:0] instr\n);\n\t')
        gen_f.write(f'always @(addr) begin\n\t\tcase (addr)\n')
        # generate the main i_mem code
        with open(hex_file) as hex_f:
            lines = hex_f.readlines()
            start_idx = 1 if lines[0][0] == 'v' else 0
            addr = 0
            for idx in range(start_idx, len(lines)):
                addr_b = bin(addr)[2:]
                addr_b_f = '10\'b' + (10 - len(addr_b)) * '0' + addr_b
                instr_part = lines[idx] if idx == len(lines) - 1 else lines[idx][:-1]
                onepair = addr_b_f + ' : ' + 'instr = ' + '32\'h' + instr_part + ';\n'
                gen_f.write('\t\t\t' + onepair)
                addr += 1
            gen_f.write('\t\t\tdefault: instr = 0;\n')
        gen_f.write('\t\tendcase\n\tend\nendmodule')
        
        
if __name__ == '__main__':
    gen_i_mem_code('./tests/benchmark_ccab.hex', './tests/benchmark_ccab.v')
        
                    
        