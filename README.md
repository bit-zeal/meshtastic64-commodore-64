# Meshtastic 64 for the Commodore 64

This Commodore BASIC program allows the **Commodore 64** to connect to the [Meshtastic](https://meshtastic.org/) peer-to-peer network using the Meshtastic 64 module.

**Author:** Jim Happel / jim_64  
**Version:** 1.1  
**License:** Proprietary — see [LICENSE.md](LICENSE.md) for terms  
**Copyright:** © 2026 BIT Zeal LLC. All Rights Reserved.  
**GitHub:** [bit-zeal/meshtastic64](https://github.com/bit-zeal/meshtastic64)

---

## Overview

Meshtastic 64 establishes a two-way text link between a Commodore 64 and a Meshtastic node connected via the user port (RS-232). It handles:

- Opening the user port at 600 baud using Commodore Kernal routines
- Continuously polling for incoming serial bytes (RX)
- Accepting keyboard input and sending messages (TX)
- Converting between ASCII (used by Meshtastic) and PETSCII (used by Commodore 8-bit computers)
- Receiving, viewing, editing, and sending PETSCII art over the mesh network
- Visual LED activity indicator via the user port CIA chip
- SID sound notification on new message receipt

---

## How It Works

The program is structured as a polling loop:

```
initialize -> mainLoop -> LEDblinking -> readSerialInput -> printPetsciiArt
          -> printIncommingMessage -> readKeyboard -> repeat
```

### Subroutines

| Subroutine | Purpose |
|---|---|
| `initialize` | Opens user port (device 2) at 600 baud, inits computer |
| `initComputer` | Sets up screen colors, arrays, splash screen, LED state |
| `mainLoop` | Continuously calls all RX/TX/display handlers |
| `LEDblinking` | Drives a scanning LED pattern on user port CIA pins |
| `dingSound` | Plays a short SID tone on new message arrival |
| `readSerialInputAndConvertToPetscii` | Reads one byte from the radio; converts ASCII→PETSCII into the incoming message buffer |
| `convertINstingToMSstringAndStore` | Formats and stores a completed incoming message for display |
| `printIncommingMessage` | Dequeues and displays the next pending message; triggers ding sound |
| `printPetsciiArt` | Detects and renders incoming PETSCII art messages; handles store/dismiss |
| `endPetsciiView` | Saves viewed PETSCII art to a numbered slot or exits view mode |
| `readKeyboard` | Reads keypresses; routes to send, delete, or character append |
| `sendSerialMessage` | Converts typed PETSCII string to ASCII and sends via serial; routes slash commands |
| `parseCommands` | Handles `/` commands typed by the user |
| `listHelp` | Prints the command reference to the screen |
| `redrawInputBox` | Redraws the input area at the bottom of the screen |
| `reprintInputString` | Reprints the current typed string in the input box |
| `deleteKey` | Handles backspace in the input box |
| `updateScreen` | Scrolls display area and prints a message line |
| `petsciiEditor` | Enters the built-in PETSCII art editor |
| `petsciiScreenReader` | Reads the C64 screen RAM into a PETSCII art slot (line 50000) |
| `petsciiEditDrawingExisting` | Pre-loads an existing slot onto screen for re-editing |
| `clearPetsciiSlot` | Clears a stored PETSCII art slot |
| `sendPetsciiArt` | Transmits a stored PETSCII art slot over the mesh |
| `savePetsciiArtToDisk` | Saves a PETSCII art slot to a disk file |
| `loadPetsciiArtFromDisk` | Loads a PETSCII art slot from a disk file |

### Character Set Conversion

The C64 uses PETSCII internally, while Meshtastic nodes communicate in standard ASCII. The program maps between the two:

- **RX (ASCII → PETSCII):** Uppercase letters (A–Z, 65–90) are shifted into the PETSCII uppercase range (+128). Lowercase letters (a–z, 97–122) are shifted down (−32). Printable symbols and CR pass through unchanged.
- **TX (PETSCII → ASCII):** PETSCII shifted uppercase chars (193–218) are mapped back to ASCII lowercase (−128). PETSCII uppercase (65–90) maps to ASCII lowercase (+32). Other printable characters pass through.

---

## Commands

| Command | Description |
|---|---|
| `/?` | Show help |
| `/s on` / `/s off` | Enable / disable message sound |
| `/p edit` | Open PETSCII editor (blank canvas) |
| `/p edit n` | Open PETSCII editor with slot `n` loaded |
| `/p send n` | Send PETSCII art slot `n` over mesh |
| `/p clear n` | Clear PETSCII art slot `n` |
| `/p save n filename` | Save slot `n` to disk file |
| `/p load n filename` | Load disk file into slot `n` |

Nine PETSCII art slots (1–9) are available in memory. The editor uses a separate screen and is accessed by typing `/p edit` at the input prompt.

---

## Hardware Setup

- **Commodore 64** with user port accessible
- **Meshtastic 64** module connected to the user port via an RS-232 level shifter
- Serial settings: **600 baud**
- A **1541 (or similar) disk drive** is required for save/load of PETSCII art to disk

---

## Customization

### LED Blinking Pattern

The LED pattern is defined in the `initComputer` subroutine by the `ld()` array. Each entry is a bitmask written to CIA port B (address 56577), which controls user port pins PB1–PB6. The direction register is set to `126` (`%01111110`), making those six pins outputs.

The default pattern is a left-to-right scanner across the six pins:

```basic
ld(0) = 064  ' %01000000  pin PB6
ld(1) = 032  ' %00100000  pin PB5
ld(2) = 016  ' %00010000  pin PB4
ld(3) = 008  ' %00001000  pin PB3
ld(4) = 004  ' %00000100  pin PB2
ld(5) = 002  ' %00000010  pin PB1
ld = 5       ' last step index (0..5 = 6 steps)
```

The `LEDblinking` routine bounces a step counter `lc` between `0` and `ld`, outputting `ld(lc)` on each main loop tick.

**Important:** The highest bit (bit 7, value `128`) and the lowest bit (bit 0, value `1`) of each `ld(n)` value must always be zero — they do not correspond to any LED on the module. The Meshtastic 64 module has only 6 LEDs, controlled by bits 1–6 (pins PB1–PB6). Setting bit 7 or bit 0 will not light an LED and may produce unexpected behavior.

To change the pattern, edit the `ld()` values and the `ld` step count in `initComputer`:

- **All-on flash:** Set all entries to `126` (`%01111110`) and use a single step.
- **Two LEDs at once:** Use values like `096` (`%01100000`) or `006` (`%00000110`).
- **Fewer steps:** Lower `ld` — e.g., `ld = 2` uses only `ld(0)`..`ld(2)`.
- **More steps:** Increase `ld` and add matching `ld(n)` entries (array is dimensioned at 6 in `dim ld(6)`; add `dim ld(n)` with a larger `n` if needed).

---

## Releases

Pre-built `.prg` files are available on the [GitHub Releases page](https://github.com/bit-zeal/meshtastic64/releases/latest) — no build tools required.

---

## Building

This project uses the [VS64 (version 2.6.4 or later)](https://github.com/rolandshacks/vs64/releases) extension for VS Code. The project configuration is in [project-config.json](project-config.json).

To build:
1. Open the project folder in VS Code with the VS64 extension installed.
2. Run the build task — output goes to the [build/](build/) directory as a `.prg` file.

The compiled program can be loaded on a real Commodore 64.

---

## License

This software is proprietary. It is licensed for use only by purchasers of the Meshtastic 64 hardware unit from BIT Zeal LLC. See [LICENSE.md](LICENSE.md) for full terms.
