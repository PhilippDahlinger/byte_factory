import os

from bython_compiler.create_low_level_code import remove_white_space, remove_comments
from factorisco_assember.assembler_util import get_text_segment, tokenize, replace_pseudo_instructions, collect_labels, \
    replace_labels, replace_reg_names, replace_instructions


def assemble(assembly_code):
    assembly_code = remove_comments(assembly_code)
    assembly_code = remove_white_space(assembly_code)
    code = get_text_segment(assembly_code)
    # replace macros
    ...
    # tokenize and replace .globl _start with j _start
    code = tokenize(code)
    # replace pseudo instructions
    code = replace_pseudo_instructions(code)
    labels, code = collect_labels(code)
    code = replace_labels(code, labels)
    machine_code = replace_instructions(code)
    return machine_code


if __name__ == "__main__":
    input_file = os.path.join("factorisco_v_assembly", "hello_world.s")
    with open(input_file, 'r') as infile:
        source_code = infile.read()
        # split by line
        source_code = source_code.split("\n")
        print("Source code read successfully.")
    machine_code = assemble(source_code)
