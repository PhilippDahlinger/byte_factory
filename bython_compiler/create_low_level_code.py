

"""
Replaces:
- r1 = r2 if r4 > r5 to CMP(r4, r5); CMOV(r1, r2, <B-Code depending on coparator>)
- label to actual addresses. -> Every line in low level code is one line in the actual CPU
- If/else
- While
- Function calls
"""

def create_low_level_code(source_code: list[str]):
    source_code = remove_comments(source_code)
    return source_code

def remove_comments(code: list[str]):
    code = [line.split("#", 1)[0] for line in code]
    # Strip leading and trailing whitespace
    code = [line.strip() for line in code]
    relevant_lines = [i for i in range(len(code)) if code[i] != ""]
    code = [line for i, line in enumerate(code) if i in relevant_lines]
    return code