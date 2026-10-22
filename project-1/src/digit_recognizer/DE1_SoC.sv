// Top-level module that defines the I/Os for the DE-1 SoC board

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
output logic [9:0]  LEDR;
input  logic [3:0]  KEY;
input  logic [9:0]  SW;

// Default: turn off all HEX displays (segments are active-low, all 1's = blank)
assign HEX0 = '1;
assign HEX1 = '1;
assign HEX2 = '1;
assign HEX3 = '1;
assign HEX4 = '1;
assign HEX5 = '1;

// Two-digit recognizer: the last two digits of the target number are 22
//   SW[7:4] = tens digit = 2 = 4'b0010
//   SW[3:0] = ones digit = 2 = 4'b0010
// LEDR[0] is asserted only when both digits match
assign LEDR[0] = (SW[7:4] == 4'b0010) && (SW[3:0] == 4'b0010);

endmodule

// The testbench below is for simulation only; it is never loaded onto the FPGA
// (DE1_SoC never instantiates it, so Quartus ignores it when programming)
module DE1_SoC_testbench();
  logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  logic [9:0] LEDR;
  logic [3:0] KEY;
  logic [9:0] SW;

  DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW);

  integer i;
  initial begin
    SW[9] = 1'b0;
    SW[8] = 1'b0;
    for (i = 0; i < 256; i++) begin
      SW[7:0] = i; #10;   // sweep all 256 combinations of the two digits
    end
  end
endmodule
