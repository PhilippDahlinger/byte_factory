from bython_compiler.input_encodings.create_data_blueprint import create_data_blueprint
from bython_compiler.input_encodings.int_encoding import encode_int, decode_int



if __name__ == "__main__":
    input_file = "aoc_2024_inputs/01.txt"
    bits = 17
    numbers_per_code = 1
    new_line_marker = False
    outputs = encode_int(input_file, bits=bits, numbers_per_code=numbers_per_code, new_line_marker=new_line_marker)
    test = decode_int(outputs, bits=bits, numbers_per_code=numbers_per_code, new_line_marker=new_line_marker)
    print(test)
    create_data_blueprint(outputs, input_file[:-4] + ".bp")