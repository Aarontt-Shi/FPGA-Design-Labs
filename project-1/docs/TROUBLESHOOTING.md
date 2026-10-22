# Troubleshooting

Nine environment problems hit during this project, with the root cause of each. Most of them are
specific to Quartus Prime 17.0 running on modern Windows.

| # | Problem | Root cause | Fix |
|---|---|---|---|
| 1 | Quartus froze, showed a blank white window, and every menu item (Save As, right-click → Remove) silently did nothing | The project lived under a directory containing Chinese characters. Quartus 17.0 handles non-ASCII paths poorly and its file dialogs stopped resolving them | Moved the entire project to an ASCII-only path. Both Quartus and ModelSim behaved normally afterwards |
| 2 | After programming, flipping the switches did not light `LEDR[0]` | Programmer was started while compilation was still running, so the **previously generated** `.sof` was downloaded | Wait for *Full Compilation was successful* **and** for the `.sof` timestamp to update before re-opening the `.cdf` and pressing Start |
| 3 | A garbled absolute path pointing at a deleted folder appeared in the project's `.qsf` and could not be removed from the GUI | The file had been added by browsing, and Quartus stored a relative path whose non-ASCII folder name was written with a broken encoding | Delete the offending line from the `.qsf` with a byte-level edit. Quartus must be fully closed first or it rewrites the file on exit |
| 4 | A leftover `quartus.exe` process survived the exit and reverted manual edits | The crashed GUI left a child process running | End the process in Task Manager before editing any project file |
| 5 | The first `do run_sim.do` stopped with *cannot open macro file `<module>_wave.do`*, and no waveform appeared | The `*_wave.do` file does not exist until the user saves the layout, so the Tcl script aborts **before** reaching `run -all` | Type `run -all` manually, save the layout with File → Save Format, then re-run `do run_sim.do` |
| 6 | A second, unrelated error (`Error opening …/verilog_src/std/std.sv`) appeared at the same time | Side effect of issue 5 — ModelSim tries to open the offending macro file for editing and fails again | Ignore it; it disappears once the `*_wave.do` file exists |
| 7 | The waveform window looked empty right after loading | The saved layout zooms to the first nanosecond only | Use **Zoom Full**; zoom into a narrow window when a single short pulse must be inspected |
| 8 | The wave pane disappeared after being closed | The pane was simply closed; the signal list still exists in the session | Type `view wave` in the Transcript |
| 9 | ModelSim would not start from the supplied batch file | `Launch_ModelSim.bat` hard-codes `D:\intelFPGA_lite\17.0\…`, but ModelSim was installed elsewhere | Edit the single path line in the working copy of the batch file |

## General lessons

- **ASCII-only paths for Quartus projects.** This one change removed almost all of the tool
  instability in this project.
- **A "successful" download does not mean the newest design was loaded.** Check the `.sof`
  timestamp against the compilation time.
- **Simulate before mapping to the FPGA.** A design that is wrong in ModelSim is wrong on the
  board, and debugging on hardware is an order of magnitude slower.
- **Don't-care conditions are not "nothing".** They are resolved by the synthesis tool into fixed,
  sometimes surprising values, and each one has to be measured rather than predicted.
- **Read bus values with the cursor** instead of eyeballing a dense waveform when checking
  whether one narrow pulse occurred.
- **The seven-segment displays are active-low.** A decoder written with 1 = lit must be inverted
  at the top level.
