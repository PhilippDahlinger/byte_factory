import argparse
import os


def compile_bython(input_file, output_file, verbose=False):
    """
    Compiles the Bython source code into a numeric output format.

    Args:
        input_file (str): Path to the input Bython file.
        output_file (str): Path to the output compiled file.
        verbose (bool): If True, print detailed compilation steps.
        optimize (bool): If True, apply optimizations during compilation.
    """
    if verbose:
        print(f"Reading input file: {input_file}")

    if not os.path.exists(input_file):
        print(f"Error: File '{input_file}' does not exist.")
        return

    # Example logic: Read the input file (implement actual parsing/compilation logic)
    with open(input_file, 'r') as infile:
        source_code = infile.read()
        if verbose:
            print("Source code read successfully:")
            print(source_code)

    compiled_output = ["todo", "todo2"]

    # Write the compiled output to the output file
    with open(output_file, 'w') as outfile:
        for line in compiled_output:
            outfile.write(line + "\n")  # Write each string to a new line

    if verbose:
        print(f"Compilation completed. Output written to: {output_file}")


def main():
    parser = argparse.ArgumentParser(description="Bython Compiler - Compile Bython files into Factorio blueprints.")
    parser.add_argument("input_file", type=str, help="Path to the Bython source file.")
    parser.add_argument("-o", "--output_root_path", type=str, default="output",
                        help="Output file name (default: <input_file>.byo).")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output.")
    parser.add_argument("--optimize", action="store_true", help="Enable optimizations during compilation.")

    args = parser.parse_args()
    out_file_name = ".".join(os.path.basename(args.input_file).split(".")[:-1]) + ".byo"
    output_file = os.path.join(args.output_root_path, out_file_name)

    # Call the compiler function with the provided arguments
    compile_bython(args.input_file, output_file, verbose=args.verbose)


if __name__ == "__main__":
    main()
