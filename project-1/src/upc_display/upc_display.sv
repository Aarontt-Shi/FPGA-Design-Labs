module upc_display (U, P, C, h5, h4, h3, h2, h1, h0);
  input  logic U, P, C;
  output logic [6:0] h5, h4, h3, h2, h1, h0;

  // Segments are active-low on this board, so every constant below uses 1 = OFF
  localparam [6:0] BLANK = 7'b1111111;
  localparam [6:0] CH_C  = 7'b1000110;
  localparam [6:0] CH_O  = 7'b1000000;
  localparam [6:0] CH_U  = 7'b1000001;
  localparam [6:0] CH_H  = 7'b0001001;
  localparam [6:0] CH_P  = 7'b0001100;
  localparam [6:0] CH_E  = 7'b0000110;
  localparam [6:0] CH_A  = 7'b0001000;
  localparam [6:0] CH_r  = 7'b0101111;
  localparam [6:0] CH_L  = 7'b1000111;
  localparam [6:0] CH_d  = 7'b0100001;
  localparam [6:0] CH_t  = 7'b0000111;
  localparam [6:0] CH_u  = 7'b1100011;   // lower-case u, also used as V
  localparam [6:0] CH_n  = 7'b0101011;

  always_comb begin
    case ({U, P, C})
      // 000  Couch  ->  C O U C H   (expensive)
      3'b000: begin h5=CH_C; h4=CH_O; h3=CH_U; h2=CH_C; h1=CH_H; h0=BLANK; end
      // 001  PEn    ->  P E n       (inexpensive)
      3'b001: begin h5=CH_P; h4=CH_E; h3=CH_n; h2=BLANK; h1=BLANK; h0=BLANK; end
      // 011  CUP    ->  C U P       (inexpensive)
      3'b011: begin h5=CH_C; h4=CH_U; h3=CH_P; h2=BLANK; h1=BLANK; h0=BLANK; end
      // 100  PEArL  ->  P E A r L   (expensive)
      3'b100: begin h5=CH_P; h4=CH_E; h3=CH_A; h2=CH_r; h1=CH_L; h0=BLANK; end
      // 101  Hdtu   ->  H D T V     (expensive)
      3'b101: begin h5=CH_H; h4=CH_d; h3=CH_t; h2=CH_u; h1=BLANK; h0=BLANK; end
      // 110  CAP    ->  C A P       (inexpensive)
      3'b110: begin h5=CH_C; h4=CH_A; h3=CH_P; h2=BLANK; h1=BLANK; h0=BLANK; end
      // 010 and 111 are unused -> left as don't care for Quartus
      default: begin h5='x; h4='x; h3='x; h2='x; h1='x; h0='x; end
    endcase
  end
endmodule
