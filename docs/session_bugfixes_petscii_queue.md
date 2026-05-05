# Session Bug Fixes — PETSCII Queue & IC Flag Issues

Date: 2026-04-22

## Background

During live stress testing between two Commodore 64s, two bugs were identified in the PETSCII art receive/view flow. A third latent bug was also found through code analysis.

---

## Bug 1: Stale `dp` Flag from PETSCII Editor

### Symptom
After using the `/p edit n` command to edit an existing PETSCII slot, if a PETSCII art message subsequently arrived over the air, the program would jump directly to `endPetsciiView` without drawing the art or clearing the screen. The screen appeared unchanged (no art, no messages). Pressing any key revealed the "press # to store in slot or f7 to end" prompt, confirming `dp = 1`.

### Root Cause
`petsciiEditDrawingExisting` set `dp = 1` (Done Petscii flag) as part of drawing the editor preview. This flag persisted into the main loop. When a new PETSCII message arrived, `printPetsciiArt` saw `dp = 1` and jumped to `endPetsciiView`, skipping the art draw entirely.

`dp = 1` belongs exclusively to the received-PETSCII viewing flow (meaning "art has been drawn from an incoming message, now wait for dismiss"). The editor preview is a different context and should not set it.

### Fix
Removed `dp = 1` from `petsciiEditDrawingExisting` (was line 431).

---

## Bug 2: PETSCII Queue Index Drift While Waiting for F1

### Symptom
If a new text message arrived in the serial stream while the program was showing the "received petscii art - press f1 to view" prompt, `im$(im-1)` would shift to point to the new message instead of the PETSCII message. When the user pressed F1:
- The screen was cleared
- `dp = 1` was set
- Art was "drawn" from the wrong message's bytes (garbage/invisible output)
- The wrong message was removed from the queue by `endPetsciiView`
- Pressing a slot key stored the wrong message's data

### Root Cause
`printPetsciiArt` and `endPetsciiView` always referenced `im$(im-1)` (the newest queued message). The PETSCII message was the newest at detection time, but new messages appended to the queue during the F1 wait shifted `im-1` away from it.

### Fix
Introduced variable `pj` (Petscii queue Index) to record the queue index of the PETSCII message at the moment it is identified. `pj` is set alongside `pp = 1` and used consistently in place of `im-1` throughout both `printPetsciiArt` and `endPetsciiView`.

**Line 263** — record index when PETSCII detected:
```basic
if mid$(im$(im-1),11,1) = "p" then pp = 1 : pj = im - 1
```

**Lines 270, 274, 280** — use `pj` in art drawing loops:
```basic
xc=asc(mid$(im$(pj),12,1)) : yc=asc(mid$(im$(pj),13,1))
poke 1024+x+xo+(y+yo)*40,asc(mid$(im$(pj),pc,1))
poke 55296+x+xo+(y+yo)*40,asc(mid$(im$(pj),pc,1))
```

**Line 297** — use `pj` when storing to a slot:
```basic
ps$(sl) = right$(im$(pj),len(im$(pj))-9)
```

**Line 304** — use `pj` as removal loop start index:
```basic
for i = pj to (im-1)
```

Note: `pi` was the original name chosen but was renamed to `pj` because `pi` converts to the π symbol during `.bas` to `.prg` compilation.

---

## Bug 3: `ic` Flag Not Reset After PETSCII Message Stored

### Symptom
Observed live: after receiving a PETSCII art message followed immediately by several text messages (1111, 2222, 3333, 4444, 5555, 6666, 7777), the first three text messages displayed with wrong character case, missing reverse-video formatting, extra spaces, and unstripped colons. Messages 4444 onward displayed correctly.

### Root Cause
`ic` (Incoming Command flag) is set to 1 when the ESC byte is detected in the serial stream, signaling that subsequent bytes are raw binary PETSCII data and should bypass PETSCII conversion. When chr$(96) terminates the PETSCII data and `convertINstingToMSstringAndStore` is called, `bc` and `in$` are reset but `ic` was not reset. It remained 1.

While `ic = 1`, every incoming byte was stored raw (no PETSCII conversion), and chr$(10) no longer triggered message termination — it was intercepted by the `if ic = 1` branch instead. Text messages arriving during this window were processed incorrectly.

`ic` was only reset to 0 in `endPetsciiView` (when the user dismisses the art). Messages 1111–3333 arrived before the user dismissed the art (ic=1); messages 4444–7777 arrived after dismissal (ic=0), explaining the exact cutoff seen on screen.

### Fix
Added `ic = 0` to `convertINstingToMSstringAndStore` (line 118):
```basic
bc = 0 : in$ = "" : ic = 0 : rem reset for next message
```

`ic = 1` is only needed while the PETSCII binary payload is being received byte-by-byte. Once the full message is stored in the queue, `ic` should immediately return to 0 so subsequent text messages are handled normally. The `ic = 0` reset in `endPetsciiView` remains as a harmless safety net.

---

## Variable Reference Updates

- Added `pj` (Petscii queue Index) to `docs/variable_reference.md`
- Removed old `pi` entry (renamed due to π symbol conflict)
