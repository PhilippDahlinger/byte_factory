

def hash64_word(words):
    """
    Python equivalent of the FactoRISCo V hash64_word routine.
    Each element in `words` is a 32-bit integer (only low byte used).
    Terminates at first 0 word.
    Returns hash in range 0..63.
    """
    h = 5384  # same seed as in assembly
    for w in words:
        if w == 0:
            break
        c = w & 0xFF      # use only low byte (as CPU does)
        h = ((h * 38) ^ c) & 0xFFFFFFFF  # emulate 32-bit wraparound
    return h & 2047  # restrict to 0..2047
    return h

if __name__ == "__main__":
    commands = [
        "LS",
        "MKDIR",
        "TOUCH",
        "CP",
        "CPROM",
        "RUN",
        "RUNROM",
        "MV",
        "RM",
        "R0",
        "R1",
        "FSINIT",
        "CLS",
    ]
    for command in commands:
        # create ascii word
        words = [ord(c) for c in command]
        print(words, hash64_word(words))

