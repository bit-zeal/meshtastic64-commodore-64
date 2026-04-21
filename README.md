# Meshtastic for the VIC-20

The Meshtastic 64 module was degined to connect the commodore 64 to the Meshtastic peer-to-peer network.

This Commodore BASIC program allows the **VIC-20** to connect to the [Meshtastic](https://meshtastic.org/) network using the Meshtastic 64 module.

**Author:** Jim Happel / jim_64  
**Version:** 1.0  
**License:** [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)  
**GitHub:** [bit-zeal/meshtastic64-vic-20](https://github.com/bit-zeal/meshtastic64-vic-20)

---

## Overview

This program establishes a two-way text link between a VIC-20 and a Meshtastic node connected via the user port (RS-232). It handles:

- Opening the user port at 600 baud using the Commodore Kernal routines
- Continuously polling for incoming bytes (RX)
- Accepting keyboard input and sending messages (TX)
- Converting between ASCII (used by Meshtastic) and PETSCII (used by Commodore 8-bit computers)

---

## How It Works

The program is structured as a simple polling loop:

```
initialize -> main_loop -> rx_byte (print received) -> tx_byte (send input) -> repeat
```

### Subroutines

| Subroutine | Purpose |
|---|---|
| `initialize` | Opens user port (device 2) at 600 baud, shows splash screen |
| `main_loop` | Continuously calls RX and TX handlers |
| `rx_byte` | Reads one byte from the radio and prints it after ASCII→PETSCII conversion |
| `tx_byte` | Waits for a keypress, prompts for a message, converts PETSCII→ASCII, and sends it |
| `ascii_2_petscii_byte` | Converts a single received ASCII byte to its PETSCII equivalent |
| `petscii_2_ascii_string` | Converts a full PETSCII string (typed by the user) to ASCII for transmission |

### Character Set Conversion

The VIC-20 uses PETSCII internally, while Meshtastic nodes communicate in standard ASCII. The program maps between the two:

- **RX (ASCII → PETSCII):** Uppercase letters (A–Z, codes 65–90) are shifted into the PETSCII uppercase range (+128). Lowercase letters (a–z, codes 97–122) are shifted down (−32). Printable symbols and CR pass through unchanged.
- **TX (PETSCII → ASCII):** PETSCII uppercase shifted chars (193–218) are mapped back to standard ASCII lowercase (+32 offset reversed). Other printable characters pass through.

---

## Hardware Setup

- **VIC-20** with user port accessible
- **Meshtastic 64** module (e.g., a Heltec V3) connected to the user port via an RS-232 level shifter
- Serial settings: **600 baud**

---

## Releases

Pre-built `.prg` files are available on the [GitHub Releases page](https://github.com/bit-zeal/meshtastic64-vic-20/releases/latest) — no build tools required.

---

## Building

This project uses the [VS64 (version 2.6.4 or later)](https://github.com/rolandshacks/vs64/releases) extension for VS Code. The project configuration is in [project-config.json](project-config.json).

To build:
1. Open the project folder in VS Code with the VS64 extension installed.
2. Run the build task — output goes to the [build/](build/) directory as a `.prg` file.

The compiled program can be loaded on a real VIC-20.

---

## License

This work is licensed under [Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/).

You are free to share and adapt this material for non-commercial purposes, provided you give appropriate credit. See [LICENSE](LICENSE) for full details.
