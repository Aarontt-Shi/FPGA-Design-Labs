# Design Notes

Technical detail behind the five designs. Everything here was measured on the actual toolchain
(Quartus Prime Lite 17.0 / ModelSim 10.5b) or on the DE1-SoC board.

---

## 1. Task 1.3 — 4:1 multiplexer

Three copies of a verified 2:1 multiplexer. `sel0` picks one input from each pair, producing the
internal wires `v0` and `v1`; `sel1` picks which of the two reaches `out`.

```verilog
mux2_1 m0(.out(v0),  .i0(i00), .i1(i01), .sel(sel0));
mux2_1 m1(.out(v1),  .i0(i10), .i1(i11), .sel(sel0));
mux2_1 m (.out(out), .i0(v0),  .i1(v1),  .sel(sel1));
```

| `sel1` | `sel0` | `out` |
|---|---|---|
| 0 | 0 | `i00` |
| 0 | 1 | `i01` |
| 1 | 0 | `i10` |
| 1 | 1 | `i11` |

The testbench drives all 64 combinations of the six inputs with
`{sel1, sel0, i00, i01, i10, i11} = i; #10`.

---

## 2. Task 2.1 — Two-digit recognizer

`SW[3:0]` encodes the ones digit, `SW[7:4]` the tens digit; `LEDR[0]` asserts only when both
match. With a target of `22` (2 = `4'b0010`):

```verilog
assign LEDR[0] = (SW[7:4] == 4'b0010) && (SW[3:0] == 4'b0010);

// equivalent gate-level form
wire tens_ok = ~SW[7] & ~SW[6] &  SW[5] & ~SW[4];
wire ones_ok = ~SW[3] & ~SW[2] &  SW[1] & ~SW[0];
assign LEDR[0] = tens_ok & ones_ok;
```

The testbench sweeps `SW[7:0]` from 0 to 255. The matching value is `0b0010_0010 = 34`, and the
waveform confirms `LEDR[0]` rises for exactly that one pattern and stays low for the other 255.

---

## 3. Task 2.2 — UPC return detector (the interesting one)

### 3.1 Problem

| UPC | Product | Discounted? | Expensive? |
|---|---|---|---|
| 000 | Shoes | No | Yes |
| 001 | Costume Jewelry | No | No |
| 011 | Christmas Ornament | Yes | No |
| 100 | Business Suit | No | Yes |
| 101 | Winter Coat | Yes | Yes |
| 110 | Socks | Yes | No |
| 010 / 111 | unused | X | X |

Inputs `U = SW9`, `P = SW8`, `C = SW7`, `M = SW0` (secret mark). Expensive items are marked when
sold, so an expensive item returned **without** the mark was stolen.

### 3.2 Truth table

| UPC | M | Discounted | Stolen |
|---|---|---|---|
| 000 | 0 / 1 | 0 | 1 / 0 |
| 001 | 0 / 1 | 0 | 0 / X |
| 010 | 0 / 1 | X | X |
| 011 | 0 / 1 | 1 | 0 / X |
| 100 | 0 / 1 | 0 | 1 / 0 |
| 101 | 0 / 1 | 1 | 1 / 0 |
| 110 | 0 / 1 | 1 | 0 / X |
| 111 | 0 / 1 | X | X |

### 3.3 Minimisation

**Discounted.** The three 1-cells (`011`, `101`, `110`) are pairwise non-adjacent. Merging them
with the don't-care cell `111` yields two terms:

- `P` covers `011` and `110`
- `U·C` covers `101`

No 0-cell is covered. Cost: one AND2 + one OR2 = **2 gates**, minimal because the function is
neither a constant nor a single literal.

**Stolen.** The expensive items are `000`, `100`, `101`. Two options:

| Approach | Cost |
|---|---|
| Compute `E = (P NOR C) OR (U AND C)`, then `Stolen = E AND NOT M` | 5 gates |
| Minimise the four-variable function directly | **4 gates** |

The direct form wins:

```
Discounted = P + (U AND C)                        →  AND2 + OR2 = 2 gates
Stolen     = NOR(P, C, M) OR (U AND C AND NOT M)  →  NOR3 + NOT + AND3 + OR2 = 4 gates
```

`NOR(P,C,M)` covers `000` and `100` at `M = 0`; `U·C·M'` covers `101` at `M = 0`.

**Total: 6 gates** for both outputs.

```verilog
assign LEDR[1] = P | (U & C);                    // Discounted
assign LEDR[0] = ~(P | C | M) | (U & C & ~M);    // Stolen
```

### 3.4 Don't-care behaviour — measured, not assumed

Because `010` and `111` are `X`, the synthesiser is free to assign them. Reading the actual
simulation values for all 16 combinations gives:

```
SW=0000000000 → LEDR=xxxxxxxx01      SW=0000000001 → 00
SW=0010000000 → 00                   SW=0010000001 → 00
SW=0100000000 → 10                   SW=0100000001 → 10
SW=0110000000 → 10                   SW=0110000001 → 10
SW=1000000000 → 01                   SW=1000000001 → 00
SW=1010000000 → 11                   SW=1010000001 → 10
SW=1100000000 → 10                   SW=1100000001 → 10
SW=1110000000 → 11                   SW=1110000001 → 10
```

So `LEDR[1]` is high for **10** of the 16 combinations (6 required plus 4 don't-care cells that
came out as 1), and `LEDR[0]` for **4**. Predicting "6 and 3" by reasoning only about the six
valid products would have been wrong — the don't-care cells have to be measured.

---

## 4. Task 3.1 — Two seven-segment displays

The handout's `seg7` decoder uses **1 = lit**, but the DE1-SoC segments are **active-low**
(a segment lights when its bit is 0), so the top level must invert:

```verilog
seg7 d0 (.bcd(SW[3:0]), .leds(ones));   // ones digit -> HEX0
seg7 d1 (.bcd(SW[7:4]), .leds(tens));   // tens digit -> HEX1
assign HEX0 = ~ones;
assign HEX1 = ~tens;
```

Bit order (from the comment `// Light: 6543210`): `bit6 = g`, `bit5..bit0 = f, e, d, c, b, a`.
Measured values:

| Digit | `seg7` output (1 = lit) | After inversion (board) |
|---|---|---|
| 0 | `0111111` | `1000000` |
| 1 | `0000110` | `1111001` |
| 8 | `1111111` | `0000000` |
| 10–15 | `xxxxxxx` | see below |

Inputs 10–15 hit the `default` branch (`7'bX`). On the board they were observed as:
10 → mirrored 9, 11 → 9, 12 → 9, 13 → 5, 14 → 6, 15 → 9. Each illegal code is an independent
don't care, so the tool chose a different value for each.

---

## 5. Task 3.2 — UPC code to product display

A display module with three inputs and six 7-bit outputs, written at RTL level:

```verilog
upc_display (U, P, C, h5, h4, h3, h2, h1, h0);
input  logic U, P, C;
output logic [6:0] h5, h4, h3, h2, h1, h0;
always_comb begin
  case ({U, P, C}) ... default: ... = 'x;
end
```

Constraints: 6 products, expensive products keep the "expensive" UPCs (000, 100, 101), the
inexpensive ones use 001, 011, 110, and no product may duplicate Task 2.2's list.

| UPC | Expensive | Product | Display (HEX5 → HEX0) |
|---|---|---|---|
| 000 | Yes | Couch | `C O U C H` |
| 001 | No | Pen | `P E n` |
| 011 | No | Cup | `C U P` |
| 100 | Yes | Pearl | `P E A r L` |
| 101 | Yes | HDTV | `H d t u` |
| 110 | No | Cap | `C A P` |
| 010 / 111 | — | unused | default → `'x` |

Lower-case `r, n, d, t, u` are used because a seven-segment display cannot render convincing
upper-case `R, N, D, T` or `V`; the pattern for `u` doubles as `V`. All constants are written
directly in active-low form so the top level can wire them straight to the displays.

Measured HEX codes (active-low):

```
000 → 1000110 1000000 1000001 1000110 0001001 1111111   = C O U C H
001 → 0001100 0000110 0101011 1111111 1111111 1111111   = P E n
011 → 1000110 1000001 0001100 1111111 1111111 1111111   = C U P
100 → 0001100 0000110 0001000 0101111 1000111 1111111   = P E A r L
101 → 0001001 0100001 0000111 1100011 1111111 1111111   = H d t u
110 → 1000110 0001000 0001100 1111111 1111111 1111111   = C A P
010 / 111 → xxxxxxx ×6
```

Because the display module and the detector are both instantiated and share the same `U, P, C`,
the board shows the product name and both status LEDs simultaneously. The LED sequence is
identical to Task 2.2's, confirming the two modules do not interfere.
