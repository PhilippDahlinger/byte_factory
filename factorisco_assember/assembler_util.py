from cProfile import label


def get_text_segment(code):
    def get_directive(key_word):
        directive = [(i, line) for (i, line) in enumerate(code) if line.startswith(key_word)]
        assert len(directive) <= 1, f"Only 1 {key_word} segment allowed in code!"
        if len(directive) == 0:
            return None
        i, line = directive[0]
        assert directive[0][1].strip() == key_word, f"Invalid line {i}: `{line}`"
        return  i

    text_directive = get_directive(".text")
    data_directive = get_directive(".data")
    if data_directive is not None and text_directive < data_directive:
        text_segment = code[text_directive + 1:data_directive]
    else:
        # either no data segment or data segment was before the text segment
        text_segment = code[text_directive + 1:]
    return text_segment



def tokenize(code):
    output = []
    _start_found = False
    _start_label_found = False
    for i, line in enumerate(code):
        tokens = line.split(" ")
        tokens = [x.strip() for x in tokens]
        assert len(tokens) > 0, f"Error parsing empty line {i}: `{line}`"
        if tokens[0] == ".globl" and tokens[1] == "_start":
            # entry point def: jump to start
            _start_found = True
            tokens = ["j", "_start"]
        # check for basic syntax
        # labels
        if tokens[0].endswith(":"):
            if tokens[0] == "_start:":
                _start_label_found = True
            assert ":" not in tokens[0][:-1], f"label `{line}` in line {i} contains illegal character `:`"
            assert len(tokens) == 1, f"Label definition `{line}` in line {i} contains multiple words"
        # instructions
        assert "," not in tokens[0], f"Error parsing line {i}: `{line}`"
        smaller_tokens = [tokens[0]]
        for arg in tokens[1:]:
            if "," in arg:
                split_tokens = arg.split(",")
                split_tokens = [x.strip() for x in split_tokens]
                split_tokens = [x for x in split_tokens if x != ""]
                smaller_tokens += split_tokens
            else:
                smaller_tokens.append(arg)
        tokens = smaller_tokens
        # more checks?
        output.append(tokens)
    assert _start_found and _start_label_found, "Could not find `.globl _start` in the code. Needs to present to define the entry point"
    return output
