import os

from bython_compiler.create_low_level_code import remove_white_space, remove_comments
from factorisco_assember.assembler_util import get_text_segment, tokenize, replace_pseudo_instructions, collect_labels, \
    replace_labels, replace_instructions, get_data_segment, compute_data_values
from factorisco_assember.input_encodings.create_data_blueprint import create_data_blueprint
from factorisco_assember.machine_language import create_machine_code


def assemble(assembly_code, output_file):
    assembly_code = remove_comments(assembly_code)
    assembly_code = remove_white_space(assembly_code)
    code = get_text_segment(assembly_code)
    data = get_data_segment(assembly_code)
    # replace macros
    ...
    # tokenize and replace .globl _start with j _start
    code = tokenize(code, is_text_segment=True)
    data = tokenize(data, is_text_segment=False)
    data = compute_data_values(data)
    # replace pseudo instructions
    code = replace_pseudo_instructions(code)
    labels, code, data = collect_labels(code, data)
    code = replace_labels(code, labels)
    code = replace_instructions(code)
    machine_code = create_machine_code(code, data)
    for i, line in enumerate(code):
        print(f"{i}: {line}")
    for i, line in enumerate(machine_code):
        print(f"{i}: {line}")
    create_data_blueprint(machine_code, output_file=output_file)
    return True


if __name__ == "__main__":
    file_name = "la_test"
    input_file = os.path.join("factorisco_v_assembly", f"{file_name}.s")
    output_file = os.path.join("output", "factorisco", f"{file_name}.txt")
    with open(input_file, 'r') as infile:
        source_code = infile.read()
        # split by line
        source_code = source_code.split("\n")
        print("Source code read successfully.")
    assemble(source_code, output_file)
