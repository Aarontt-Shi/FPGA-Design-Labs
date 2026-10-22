module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
output logic [9:0]  LEDR;
input  logic [3:0]  KEY;
input  logic [9:0]  SW;

logic [6:0] ones, tens;

seg7 d0 (.bcd(SW[3:0]), .leds(ones));    // ones digit -> HEX0
seg7 d1 (.bcd(SW[7:4]), .leds(tens));    // tens digit -> HEX1

// Segments are active-low on this board while seg7 uses 1 = lit, so invert the output
assign HEX0 = ~ones;
assign HEX1 = ~tens;

assign HEX2 = 7'b1111111;
assign HEX3 = 7'b1111111;
assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;
assign LEDR = 10'b0;

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
    for (i = 0; i < 256; i++) begin
      SW[7:0] = i; #10;
    end
  end
endmodule
