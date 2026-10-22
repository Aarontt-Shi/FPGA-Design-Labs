# FPGA Design — SystemVerilog RTL on Cyclone V

![Language](https://img.shields.io/badge/language-SystemVerilog-blue)
![Toolchain](https://img.shields.io/badge/Quartus_Prime_Lite-17.0-blueviolet)
![Simulator](https://img.shields.io/badge/ModelSim-10.5b_Starter-orange)
![Board](https://img.shields.io/badge/Terasic-DE1--SoC_Cyclone_V-brightgreen)

Digital design work carried through the full flow: RTL source → testbench → ModelSim simulation →
Quartus synthesis → bitfile → hands-on validation on real hardware.

Each project lives in its own directory with its own README, which is the complete write-up for
that piece of work.

---

## Projects

| Directory | Topic | Designs | Highlights |
|---|---|---|---|
| [`project-1/`](project-1/) | Combinational & RTL fundamentals | 4:1 mux, two-digit recognizer, UPC detector, seven-segment decoder, integrated top level | K-map minimisation to a 6-gate solution, active-low segment encoding, don't-care behaviour measured on silicon |

More will be added as the work progresses.

---

## What this demonstrates

| Skill | Where it shows up |
|---|---|
| **HDL / RTL design** | SystemVerilog `always_comb`, hierarchical reuse of verified blocks, parameterised decoders |
| **Logic minimisation** | Truth table → Karnaugh map → gate-level schematic, with an argument for minimality |
| **Functional verification** | Self-contained testbenches per module; exhaustive sweeps (64 / 256 / 16 input combinations) |
| **Simulation tooling** | ModelSim-Intel FPGA Starter Edition, TCL/`.do` compile-and-run scripts |
| **Synthesis & implementation** | Quartus Prime Lite 17.0 targeting Cyclone V 5CSEMA5F31C6, USB-Blaster II programming |
| **Hardware validation** | Switch/LED and seven-segment checks on the DE1-SoC board |
| **Tool-chain debugging** | Nine environment problems documented with root causes and fixes ([`project-1/docs/TROUBLESHOOTING.md`](project-1/docs/TROUBLESHOOTING.md)) |

## Environment

| Component | Version |
|---|---|
| Quartus Prime Lite Edition | 17.0.0 Build 595 |
| ModelSim-Intel FPGA Starter Edition | 10.5b |
| Target device | Cyclone V 5CSEMA5F31C6 |
| Board | Terasic DE1-SoC |
| HDL | SystemVerilog (`.sv`) |

## Repository layout

```
.
├── project-1/             # combinational & RTL design
│   ├── README.md          # full write-up
│   ├── docs/              # design notes, troubleshooting, report PDF, figures/
│   ├── src/               # one directory per design, each with design + testbench
│   └── scripts/           # ModelSim .do script and launcher
├── LICENSE
└── .gitattributes / .gitignore
```

Board support packages and vendor project scaffolding (`*.qsf`, `*.qpf`, `*.sdc`, `*.cdf`) are
intentionally not included — all RTL, waveforms and photographs are authored by me.

## Author

**Aaron (Tianle) Shi** — electrical engineering (RF / hardware focus). Open an issue if you would
like to discuss any of the design decisions here.
