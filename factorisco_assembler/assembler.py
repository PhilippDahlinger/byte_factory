import os

from factorisco_assembler.create_low_level_code import remove_white_space, remove_comments
from factorisco_assembler.assembler_util import get_text_segment, tokenize, replace_pseudo_instructions, collect_labels, \
    replace_labels, replace_instructions, get_data_segment, compute_data_values, convert_data
from factorisco_assembler.input_encodings.create_data_blueprint import create_data_blueprint
from factorisco_assembler.machine_language import create_machine_code


def assemble(assembly_code, output_file, output_version="v3", kernel_mode=False, verbose=True):
    assembly_code, line_labels = remove_comments(assembly_code)
    assembly_code, line_labels = remove_white_space(assembly_code, line_labels)
    code, code_line_labels = get_text_segment(assembly_code, line_labels)
    assert len(code_line_labels) == len(code)
    data, data_line_labels = get_data_segment(assembly_code, line_labels)
    assert len(data_line_labels) == len(data)
    # replace macros
    ...
    # tokenize
    code, code_line_labels = tokenize(code, code_line_labels, is_text_segment=True)
    assert len(code_line_labels) == len(code)
    data, data_line_labels = tokenize(data, data_line_labels, is_text_segment=False)
    assert len(data_line_labels) == len(data)
    data, data_line_labels = compute_data_values(data, data_line_labels)
    assert len(data_line_labels) == len(data)
    # replace pseudo instructions
    code, code_line_labels = replace_pseudo_instructions(code, code_line_labels)
    assert len(code_line_labels) == len(code)
    labels, code, data, code_line_labels, data_line_labels = collect_labels(code, data, code_line_labels, data_line_labels)
    assert len(code_line_labels) == len(code)
    code = replace_labels(code, labels, code_line_labels)
    assert len(code_line_labels) == len(code)
    code, code_line_labels = replace_instructions(code, code_line_labels)
    assert len(code_line_labels) == len(code)
    # if user program is generated, write the length as the first address. used for copying file to disk
    machine_code = create_machine_code(code, data, code_line_labels, add_length=not kernel_mode)
    if verbose:
        for i, line in enumerate(code):
            print(f"{i}: {line}")
        for i, line in enumerate(machine_code):
            print(f"{i}: {line}")
    blueprint = create_data_blueprint(machine_code, output_file=output_file, output_version=output_version)
    machine_code_output_file = output_file.replace(".txt", "_machine_code.txt")
    with open(machine_code_output_file, 'w') as f:
        for word in machine_code:
            f.write(f"{word}\n")
    return blueprint


def kernel_program(file_name, verbose=True):
    print("--------------------------------------------------------")
    output_version = "v3"
    input_file = os.path.join("factorisco_v_assembly", "kernel", f"{file_name}.s")
    output_file = os.path.join("output", "factorisco", "kernel", f"{file_name}.txt")
    with open(input_file, 'r') as infile:
        source_code = infile.read()
        # split by line
        source_code = source_code.split("\n")
        print("Source code read successfully.")
    assemble(source_code, output_file, output_version, kernel_mode=True, verbose=verbose)
    print(f"File Name: {file_name}")
    print("--------------------------------------------------------")


def user_program(file_name, verbose=True):
    print("--------------------------------------------------------")
    output_version = "v3"
    input_file = os.path.join("factorisco_v_assembly", f"{file_name}.s")
    output_file = os.path.join("output", "factorisco", f"{file_name}.txt")
    with open(input_file, 'r') as infile:
        source_code = infile.read()
        # split by line
        source_code = source_code.split("\n")
        print("Source code read successfully.")
    assemble(source_code, output_file, output_version, kernel_mode=False, verbose=verbose)
    print(f"File Name: {file_name}")
    print("--------------------------------------------------------")

def read_data(file_name, verbose=True):
    print("--------------------------------------------------------")
    output_version = "v3"
    input_file = os.path.join("factorisco_v_assembly", "data", f"{file_name}.txt")
    output_file = os.path.join("output", "factorisco", "data", f"{file_name}.txt")
    with open(input_file, 'r') as infile:
        source_code = infile.read()
        # split by line
        print("Source code read successfully.")
    convert_data(source_code, output_file, verbose=verbose)
    print(f"File Name: {file_name}")
    print("--------------------------------------------------------")


if __name__ == "__main__":
    import argparse
    import sys
    import pyperclip

    parser = argparse.ArgumentParser(description='Factorisco Assembler')
    parser.add_argument('source_file', help='The source code filename or path')
    parser.add_argument('--verbose', '-v', action='store_true', help='Enable verbose output')

    args = parser.parse_args()

    source_file = args.source_file
    verbose = args.verbose

    if not os.path.exists(source_file):
        # Fallback to check if it's in the default directory if just a name is provided
        default_path = os.path.join("factorisco_v_assembly", f"{source_file}.s") if not source_file.endswith(".s") else os.path.join("factorisco_v_assembly", source_file)
        if os.path.exists(default_path):
             source_file = default_path
        else:
             print(f"Error: File '{source_file}' does not exist.")
             sys.exit(1)

    # Determine output file path
    base_name = os.path.splitext(os.path.basename(source_file))[0]
    output_dir = os.path.join("output", "factorisco")
    os.makedirs(output_dir, exist_ok=True)
    output_file = os.path.join(output_dir, f"{base_name}.txt")

    print("--------------------------------------------------------")
    with open(source_file, 'r') as infile:
        source_code = infile.read()
        source_code = source_code.split("\n")
        print("Source code read successfully.")

    # Assume user program mode by default
    blueprint = assemble(source_code, output_file, output_version="v3", kernel_mode=False, verbose=verbose)

    if blueprint:
        try:
            pyperclip.copy(blueprint)
            print("Blueprint copied to clipboard!")
        except Exception as e:
            print(f"Could not copy to clipboard: {e}")

    print(f"File Name: {base_name}")
    print("--------------------------------------------------------")
