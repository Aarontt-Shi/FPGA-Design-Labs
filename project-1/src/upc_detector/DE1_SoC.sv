// Top-level module that defines the I/Os for the DE-1 SoC board
// UPC return detector

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
output logic [9:0]  LEDR;
input  logic [3:0]  KEY;
input  logic [9:0]  SW;

// Switch mapping: U = SW9, P = SW8, C = SW7, M = SW0
logic U, P, C, M;
assign U = SW[9];
assign P = SW[8];
assign C = SW[7];
assign M = SW[0];

assign HEX0 = '1;
assign HEX1 = '1;
assign HEX2 = '1;
assign HEX3 = '1;
assign HEX4 = '1;
assign HEX5 = '1;

// Discounted = P + (U AND C)                      -> 2 gates
assign LEDR[1] = P | (U & C);

// Stolen = NOR(P,C,M) OR (U AND C AND NOT M)      -> 4 gates
assign LEDR[0] = ~(P | C | M) | (U & C & ~M);

endmodule

module DE1_SoC_testbench();
  logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  logic [9:0] LEDR;
  logic [3:0] KEY;
  logic [9:0] SW;

  DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW);

  integer i;
  initial begin
    SW  = 10'b0;
    KEY = 4'b0;
    for (i = 0; i < 16; i++) begin
      {SW[9], SW[8], SW[7], SW[0]} = i; #10;
    end
  end
endmodule
