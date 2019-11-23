module display_hex(
input clk,
input logic [3:0] H_0_W,
input logic [3:0] H_1_W,
input logic [3:0] H_2_W,
input logic [3:0] H_3_W,

input logic [3:0] H_0_T,
input logic [3:0] H_1_T,
input logic [3:0] H_2_T,
input logic [3:0] H_3_T,

input dsp_Hex,

output logic [6:0] Hex_0,
output logic [6:0] Hex_1,
output logic [6:0] Hex_2,
output logic [6:0] Hex_3

);

logic [3:0] time_H0 =0;
logic [3:0] time_H1 =0;
logic [3:0] time_H2 =0;
logic [3:0] time_H3 =0;

always_ff@(posedge clk)begin
    if (dsp_Hex) begin
        time_H0 <= H_0_W;
        time_H1 <= H_1_W;
        time_H2 <= H_2_W;
        time_H3 <= H_3_W;
    end else begin
        time_H0 <= H_0_T;
        time_H1 <= H_1_T;
        time_H2 <= H_2_T;
        time_H3 <= H_3_T;       
    end
        
end

    decoder D_0(
      .sw(time_H0), //  4 bit binary input
	  .led(Hex_0)  //  16-bit out 
    );
    decoder D_1(
      .sw(time_H1), //  4 bit binary input
	  .led(Hex_1)  //  16-bit out 
    );
    decoder D_2(
      .sw(time_H2), //  4 bit binary input
	  .led(Hex_2)  //  16-bit out 
    );
    decoder D_3(
      .sw(time_H3), //  4 bit binary input
	  .led(Hex_3)  //  16-bit out 
    );
endmodule:display_hex

module decoder (
    input[3:0] sw, //  4 bit binary input

    output logic[6:0] led  //  16-bit out 
);

	always_comb
		 case (sw)         
			4'b0001 : led <= 7'b1111001;//1     7'1111001;
			4'b0010 : led <= 7'b0100100;//2		7'0100100;
			4'b0011 : led <= 7'b0110000;//3		7'0110000;
			4'b0100 : led <= 7'b0011001;//4		7'0011001;
			4'b0101 : led <= 7'b0010010;//5		7'0010010;
			4'b0110 : led <= 7'b0000010;//6		7'0000010;
			4'b0111 : led <= 7'b1111000;//7		7'1111000;
			4'b1000 : led <= 7'b0000000;//8		7'0000000;
			4'b1001 : led <= 7'b0010000;//9		7'0010000;
			4'b0000 : led <= 7'b1000000;//0		7'1000000;
			default : led <= 7'b1000000;
		 endcase

endmodule:decoder