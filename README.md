# CEN323_G04_CaesarCipherTool

## Project Description
This project is a menu-driven **Caesar Cipher Cryptography Tool** engineered strictly for the 16-bit 8086 architecture using **emu8086**. It provides an interactive platform for encrypting and decrypting alphabetical messages with customizable shift keys ranging from 1 to 5. 

The system leverages direct BIOS and DOS interrupts to control hardware operations, including custom video memory clearing (with magenta background configuration), continuous keyboard polling, and dynamically managed user data strings. Core cryptographic mutations are performed dynamically via modular procedure stacks using local variable bounds tracking and wrap-around mathematical verification.

---

## Features
* **Menu-Driven Interface:** High-end screen layouts utilizing localized terminal clears and reset states via BIOS `INT 10h`.
* **Dynamic Ciphering Pipeline:** Shared modular algorithmic architecture (`CRYPTO_PROCESS`) managing parameter mapping by value, Two's Complement conversions for decryption shifts, and stack frame cleaning (`ret 4`).
* **Robust Input Sanitization:** Automated boundary checking against ASCII ranges to explicitly validate keys (1–5) and reject non-alphabetic/non-space character elements.
* **Auto-Decryption Loop:** Context-aware terminal state checking that lets a user immediately cycle a freshly generated ciphertext back to plaintext without manual menu re-entry.

---

## Team Contributions & Role Division

| Member Name | Registration No. | Module(s) Owned & Components Implemented | GitHub Verification ID |
| :--- | :--- | :--- | :--- |
| **Maryum Hayat** | 01-135232-042 | Mathematical Encryption & Decryption Core, Stack Frame Management, Boundary Wrap Subroutines (`CRYPTO_PROCESS`). | `commit_m42_a98e72c` |
| **Alisha Jamshaid** | 01-135232-007 | Main System Menu Loop Architecture, Interactive I/O Controls, Visual Screen Customization Macros. | `commit_a07_f310b84` |
| **Madeeha Rizwan** | 01-135232-037 | Input Validation Engine, Numeric/Special Character Filtering Array Loops, Error Trapping Routines (`CHAR_ERR`). | `commit_m37_c6742d1` |

---

## Setup & Run Instructions

### Prerequisites
1. Download and install **emu8086** (Microprocessor Emulator).
2. Ensure the standard standard include file `emu8086.inc` is present within your emu8086 installation library directory.

### Execution Steps
1. Clone this repository or download the source code file:
   ```bash
   git clone [https://github.com/MaryumHayat/CEN323_G4_Caeser-Cipher-Tool](https://github.com/MaryumHayat/CEN323_G4_Caeser-Cipher-Tool)