# Variable Reference — Meshtastic 64

## State Flags

| Variable | Full Name | Values / Meaning |
|---|---|---|
| `pp` | Printing Petscii | `1` = currently displaying petscii art; blocks keyboard input and incoming message display |
| `dp` | Done Petscii | `1` = petscii art has been drawn and is waiting for user to press a key to finish |
| `ep` | Edit Petscii | `1` = petscii editor should be launched at the top of the main loop |
| `ic` | Incoming Command | `1` = currently parsing an escape-sequence command embedded in the serial stream |
| `ss` | Sound State | `1` = sound on; `0` = sound off |

---

## Serial / Message Input

| Variable | Full Name | Values / Meaning |
|---|---|---|
| `rb$` | Read Byte | Single byte just read from the serial port each loop tick |
| `nc$` | New Character | The converted PETSCII character derived from `rb$` |
| `in$` | Input String | Serial bytes being accumulated into the current incoming message |
| `bc` | Byte Count | Number of bytes received so far in the current incoming message; resets to `0` on message completion |

---

## Message Queue

| Variable | Full Name | Values / Meaning |
|---|---|---|
| `im` | Incoming Message count | Number of messages currently queued; `0` = nothing pending |
| `im$(6)` | Incoming Message array | Queue of up to 6 formatted incoming message strings waiting to be printed |
| `ms$` | Message String | General-purpose display string — holds the formatted message being printed to the screen or a status/error text |

---

## Outgoing / Keyboard

| Variable | Full Name | Values / Meaning |
|---|---|---|
| `og$` | Outgoing string | What the user is currently typing; sent on `<return>`, cleared after send |
| `pj` | Petscii queue Index | Saved index into `im$()` pointing to the PETSCII art message being viewed; set when art is detected so the index stays stable if `im` changes during display |
| `sc$` | Saved Command | Copy of `og$` saved at the start of `parseCommands` for later parsing |
| `a$` | (temp) | Temporary single character from keyboard or general string scratch |
| `a` | (temp) | Temporary ASCII value of `a$` during character conversion loops |

---

## PETSCII Art

| Variable | Full Name | Values / Meaning |
|---|---|---|
| `ps$(9)` | Petscii Slot data | Array of 10 slots (`0`–`9`); each holds the raw petscii art string for that slot |
| `ps(9)` | Petscii Slot status | `1` = slot has stored art; `0` = slot is empty |
| `sl` | Slot number | Which petscii art slot is being acted on (0–9; `99` = no slot / discard) |
| `ea` | Edit Art slot | Slot number to pre-load when entering the editor with existing art; `0` or `99` = blank editor |
| `pc` | Petscii Counter | Byte position index while reading or writing petscii art data within `ps$()` |
| `xc` | X Count | Width of petscii art in character columns |
| `yc` | Y Count | Height of petscii art in character rows |
| `xo` | X Offset | Horizontal screen offset to center the art: `int((40-xc)/2)` |
| `yo` | Y Offset | Vertical screen offset to center the art: `int((25-yc)/2)` |

---

## LED Blink

| Variable | Full Name | Values / Meaning |
|---|---|---|
| `lc` | LED Counter | Current index (0–5) into the `ld()` pattern array |
| `li` | LED Increment | Animation direction: `+1` = stepping forward, `-1` = stepping backward |
| `ld` | LED step count | Total number of steps in the LED pattern (set to `5`) |
| `ld(20)` | LED Data array | Port bitmask values for LED animation steps; poked to the user port. Currently 6 steps used (indices 0–5); array sized to 20 for future expansion |

---

## Disk / File I/O

| Variable | Full Name | Values / Meaning |
|---|---|---|
| `fl$` | Filename | Disk filename parsed from the `/p save` or `/p load` command |
| `st` | Status | Built-in BASIC I/O status register; `64` = end of file, `66` = device error |

---

## Loop / Temp

| Variable | Full Name | Values / Meaning |
|---|---|---|
| `i` | (loop counter) | Generic `for` loop index used throughout |
| `i$` | (temp string) | Temporary label string used in the petscii editor slot display (`:open ` vs `:{rvon}used{rvof} `) |
| `ds` | Delay Sound | Loop counter used only inside `dingSound` to let the SID release phase fade |
