module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
output logic [9:0]  LEDR;
input  logic [3:0]  KEY;
input  logic [9:0]  SW;

logic U, P, C, M;
assign U = SW[9];
assign P = SW[8];
assign C = SW[7];
assign M = SW[0];

// Display path (constants are already active-low, wire them straight through)
upc_display disp (.U(U), .P(P), .C(C),
                  .h5(HEX5), .h4(HEX4), .h3(HEX3),
                  .h2(HEX2), .h1(HEX1), .h0(HEX0));

// Detector path (reuses the minimised equations from Task 2.2)
assign LEDR[1] = P | (U & C);                    // Discounted
assign LEDR[0] = ~(P | C | M) | (U & C & ~M);    // Stolen

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
