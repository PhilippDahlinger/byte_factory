from bython_compiler.input_encodings.create_data_blueprint import create_data_blueprint
from bython_compiler.input_encodings.int_encoding import encode_int, decode_int

def main():
    input_file = "aoc_2024_inputs/02.txt"
    outputs = encode_int(input_file, new_line_marker=False)
    test = decode_int(outputs)
    print(test)
    create_data_blueprint(outputs, input_file[:-4] + ".bp")
    return outputs

if __name__ == "__main__":
    main()  
