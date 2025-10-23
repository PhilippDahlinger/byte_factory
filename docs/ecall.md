# 🧩 FactoRISCo V — ECALL Reference Manual

### Version 1.0 • Based on `interrupt_handler_02.s`

This document describes every **ECALL (Environment Call)** implemented in the **FactoRISCo V Runtime**.
ECALLs provide a system-level interface between **user programs** and the **FactoRISCo V kernel** — similar to system calls in traditional operating systems.

---

## ⚙️ Calling Convention

| Register        | Purpose                                  |
| --------------- | ---------------------------------------- |
| `a0–a6`         | ECALL input arguments and return values  |
| `a7`            | ECALL code number                        |
| `ra`            | Return address (preserved automatically) |
| `zero`          | Always 0                                 |
| Other registers | Saved and restored by ECALL handler      |

**Execution after ECALL:**

* Returns to the instruction **after** the `ecall` instruction.
* `a0–a6` may be modified with results.
* All other registers are preserved.

---

## 🧠 ECALL Dispatch Logic

The ECALL handler:

1. Validates that `0 ≤ a7 ≤ 34`
2. Looks up the target subroutine in the **jump table**
3. Executes it via `jalr`
4. Restores registers and resumes user code

Invalid ECALL codes branch to [`raise_exception`](#3---raise_exception).

---

# 📖 ECALL List

| Code | Name                                                     | Category   | Description                           |
| ---- | -------------------------------------------------------- | ---------- | ------------------------------------- |
| 0    | [reset](#0---reset)                                      | System     | Reset state (unused placeholder)      |
| 1    | [exit](#1---exit)                                        | System     | Terminate program and return to OS    |
| 2    | [sbrk](#2---sbrk)                                        | Memory     | Adjust program heap break             |
| 3    | [raise_exception](#3---raise_exception)                  | System     | Force an exception/abort              |
| 4    | [get_time](#4---get_time)                                | System     | Read system timer                     |
| 5    | [sleep](#5---sleep)                                      | System     | Busy-wait delay                       |
| 6    | [set_cursor](#6---set_cursor)                            | Display    | Set cursor position                   |
| 7    | [set_cursor_rel](#7---set_cursor_rel)                    | Display    | Move cursor by delta                  |
| 8    | [get_cursor](#8---get_cursor)                            | Display    | Get cursor position                   |
| 9    | [set_font](#9---set_font)                                | Display    | Configure font, stride, wrap          |
| 10   | [get_font](#10---get_font)                               | Display    | Read current font parameters          |
| 11   | [set_fdr](#11---set_fdr)                                 | Display    | Set frame display row                 |
| 12   | [set_fdr_rel](#12---set_fdr_rel)                         | Display    | Move frame display row                |
| 13   | [get_fdr](#13---get_fdr)                                 | Display    | Read frame display row                |
| 14   | [clear_row](#14---clear_row)                             | Display    | Clear current row                     |
| 15   | [cls](#15---cls)                                         | Display    | Clear full screen                     |
| 16   | [print](#16---print)                                     | I/O        | Print string at address               |
| 17   | [println](#17---println)                                 | I/O        | Print string and newline              |
| 18   | [print_char](#18---print_char)                           | I/O        | Print one ASCII character             |
| 19   | [print_int](#19---print_int)                             | I/O        | Print signed integer                  |
| 20   | [cprint](#20---cprint)                                   | I/O        | Color print (stub)                    |
| 21   | [cprint_ln](#21---cprint_ln)                             | I/O        | Color print line (stub)               |
| 22   | [open_key_stream](#22---open_key_stream)                 | Input      | Enable keyboard stream                |
| 23   | [close_key_stream](#23---close_key_stream)               | Input      | Disable keyboard stream               |
| 24   | [read_key_stream](#24---read_key_stream)                 | Input      | Read next key code                    |
| 25   | [wait_for_next_key](#25---wait_for_next_key)             | Input      | Block until key pressed               |
| 26   | [input](#26---input)                                     | Input      | Read line from keyboard               |
| 27   | [rand_int](#27---rand_int)                               | Math       | Random integer in [0, a0)             |
| 28   | [rand_word](#28---rand_word)                             | Math       | Random 32-bit word                    |
| 29   | [str_to_cstr](#29---str_to_cstr)                         | Conversion | Convert string to C-string (stub)     |
| 30   | [cstr_to_str](#30---cstr_to_str)                         | Conversion | Convert C-string to string (stub)     |
| 31   | [str_to_int](#31---str_to_int)                           | Conversion | Parse integer from string             |
| 32   | [int_to_str](#32---int_to_str)                           | Conversion | Convert integer to string             |
| 33   | [set_cursor_to_next_line](#33---set_cursor_to_next_line) | Display    | Move cursor to next line              |
| 34   | [msb](#34---msb)                                         | Math       | Compute most significant bit position |

---

## 🧩 Detailed ECALL Descriptions

---

### 0 - reset

**Purpose:** Reserved / unused.
**Action:** Returns immediately (`ret`).
**Notes:** Placeholder for hardware reset integration.

---

### 1 - exit

**Purpose:** End user program and return control to OS.
**Input:** None.
**Behavior:**

* Resets memory pointers.
* Configures default font and cursor.
* Jumps to OS entry point (`mem[1050]`).
  **Example:**

```asm
li a7, 1
ecall
```

---

### 2 - sbrk

**Purpose:** Adjust program heap break pointer.
**Input:** `a0` = requested allocation size (bytes).
**Output:** `a0` = previous break address.
**Errors:** Raises exception if below 1000 or into stack.
**Example:**

```asm
li a0, 64
li a7, 2
ecall
```

---

### 3 - raise_exception

**Purpose:** Trigger fatal halt.
**Behavior:** Sets `s10 = -1`, `s11 = -1`, halts CPU.
**Use:** For runtime error signaling.
**Example:**

```asm
li a7, 3
ecall
```

---

### 4 - get_time

**Output:** `a0` = system time counter (`mem[16]`).
**Usage:** Benchmarking, animation timing.

---

### 5 - sleep

**Input:** `a0` = delay time.
**Behavior:** Busy-wait loop for approximate delay.
**Notes:** 1 loop iteration ≈ 5 cycles (approximation).

---

### 6 - set_cursor

**Inputs:** `a0` = row, `a1` = column.
**Effect:** Updates cursor position in `mem[5]` and `mem[6]`.

---

### 7 - set_cursor_rel

**Inputs:** `a0`, `a1` = relative offset.
**Effect:** Moves cursor position by delta values.

---

### 8 - get_cursor

**Output:**

* `a0` = current row
* `a1` = current column

---

### 9 - set_font

**Inputs:**

* `a0` = font ID
* `a1` = stride
* `a2` = wrap
  **Effect:** Configures text rendering.

---

### 10 - get_font

**Outputs:**

* `a0` = font ID
* `a1` = stride
* `a2` = wrap

---

### 11 - set_fdr

**Input:** `a0` = frame display row.
**Effect:** Sets visible screen row (`mem[9]`).

---

### 12 - set_fdr_rel

**Input:** `a0` = row delta.
**Effect:** Moves display window up/down.

---

### 13 - get_fdr

**Output:** `a0` = current FDR value.

---

### 14 - clear_row

**Effect:** Clears current row (`mem[11]`), refreshes display.

---

### 15 - cls

**Effect:** Clears full screen (`mem[10]`), refreshes display.

---

### 16 - print

**Input:** `a0` = address of ASCIZ string.
**Effect:** Prints characters until `\0` or newline.
**Note:** Handles newlines by moving cursor down.

---

### 17 - println

**Behavior:** Calls `print`, then adds newline.

---

### 18 - print_char

**Input:** `a0` = ASCII code.
**Behavior:** Prints one character. Handles newline (ASCII 10).

---

### 19 - print_int

**Input:** `a0` = signed integer.
**Effect:** Converts integer to string and prints it.
**Uses:** `int_to_str` and `sbrk` internally.
**Example:**

```asm
li a0, 42
li a7, 19
ecall
```

---

### 20 - cprint

**Status:** Stub (reserved for future color printing).

---

### 21 - cprint_ln

**Status:** Stub (reserved for future color line printing).

---

### 22 - open_key_stream

**Effect:** Enables keyboard stream input (`mem[3] = 1`).

---

### 23 - close_key_stream

**Effect:** Disables keyboard stream and flushes input buffer.

---

### 24 - read_key_stream

**Output:**

* `a0` = next key code if available.
* `a0 = 0` if buffer empty.

---

### 25 - wait_for_next_key

**Effect:** Blocks until a key is pressed.
**Output:** `a0` = key code.

---

### 26 - input

**Purpose:** Reads an input line from keyboard.
**Inputs:**

* `a0` = buffer address (0 for auto-alloc).
* `a1` = max length.
  **Output:**
* `a0` = start address of string.
  **Behavior:**
* Displays live input on screen.
* Ends on ENTER (key code 10).
* Supports backspace and scrolling.

---

### 27 - rand_int

**Input:** `a0` = upper bound.
**Output:** `a0` = random integer in [0, a0).
**Uses:** Hardware RNG (`mem[17]`).
**Error:** Calls [`raise_exception`](#3---raise_exception) if `a0 == 0`.

---

### 28 - rand_word

**Output:** `a0` = raw 32-bit random word from RNG (`mem[17]`).

---

### 29 - str_to_cstr

**Status:** Stub.

---

### 30 - cstr_to_str

**Status:** Stub.

---

### 31 - str_to_int

**Input:** `a0` = address of ASCII decimal string.
**Output:**

* `a0` = integer result.
* `a1` = 0 (success) or -1 (error).
  **Handles:** Optional `-` sign, validates digits.
  **Errors:** Returns `a0 = 0`, `a1 = -1` for invalid input.

---

### 32 - int_to_str

**Input:** `a0` = integer value.
**Output:** `a0` = address of ASCIZ string.
**Effect:** Allocates up to 12 bytes using `sbrk`, stores string representation.

---

### 33 - set_cursor_to_next_line

**Effect:** Moves cursor down one line, resets column to 0.

---

### 34 - msb

**Input:** `a0` = integer.
**Output:** `a0` = index of most significant bit set.
**Algorithm:** Binary search on bit range [0, 31].
**Example:**

```asm
li a0, 0x8000
li a7, 34
ecall  # a0 = 15
```

---

## 🧱 Notes

* ECALLs 20, 21, 29, and 30 are **reserved** for future extensions.
* The ECALL handler automatically re-enables interrupts after each call.
* `mret` is used to return to user mode safely.

---

© 2025 FactoRISCo V Contributors — MIT License
