module top_watch(
input clk,
input key_1_n;
input key_2_n;

output logic [6:0] Hex_0,
output logic [6:0] Hex_1,
output logic [6:0] Hex_2,
output logic [6:0] Hex_3

);

typedef enum logic[1:0] {MOD_WATCH,MOD_STOPWATCH} mode_of_operation;
mode_of_operation mod_state, mod_next;

localparam  IN_CLK_HZ = 50_000_000;
localparam  MM_count=IN_CLK_HZ/100;

logic [3:0] H_0_W = 0;
logic [3:0] H_1_W = 0;
logic [3:0] H_2_W = 0;
logic [3:0] H_3_W = 0;

logic [3:0] H_0_T = 0;
logic [3:0] H_1_T = 0;
logic [3:0] H_2_T = 0;
logic [3:0] H_3_T = 0;

logic dsp_Hex = '0;

logic key_first_1='0;
logic key_first_2='0;

logic key_long_1='0;
logic key_long_2='0;

assign key_1 = ~key_1_n;
assign key_2 = ~key_2_n;
//----------------------------------------------------------------------------------------------------------//
always_comb begin //автомат событий для режимов работы
	mod_next = MOD_WATCH;
    case (mod_state)

    MOD_WATCH:// режим часы
        if (key_1_long)begin // долгое нажатие  на 1 кнопку
             mod_next = MOD_STOPWATCH;                    
        else mod_next = MOD_WATCH;  //ничего не нажимаем

    MOD_TIMER:// режим секундомер
        if (key_1_long)
             mod_next = MOD_WATCH;
        else mod_next = MOD_STOPWATCH; //ничего не нажимаем   
    
    default: mod_next = MOD_WATCH;    
    endcase
end

always_ff@(posedge clk) begin
    case(mod_state)
          MOD_WATCH: dsp_Hex <= '1;
      MOD_STOPWATCH: dsp_Hex <= '0;
           default : dsp_Hex <= '1;
end

always_ff@(posedge clk) begin
    mod_state <= mod_next;
end


//---------------------------------------------------------------------------------------------------------//
    m_watch M1(
        .clk(clk),
        .key_first_1(key_first_1),
        .key_first_2(key_first_2),
        .key_long_1(key_long_1),
        .key_long_2(key_long_2),
        .Hex_0(H_0_W),
        .Hex_1(H_1_W),
        .Hex_2(H_2_W),
        .Hex_3(H_3_W),
    );
    stopwatch M2(clk,key_first_2,key_first_1,H_0_T,H_1_T,H_2_T,H_3_T);

    display_hex M3(
        .clk(clk),

        .H_0_W(H_0_W),
        .H_1_W(H_1_W),
        .H_2_W(H_2_W),
        .H_3_W(H_3_W),

        .H_0_T(H_0_T),
        .H_1_T(H_1_T),
        .H_2_T(H_2_T),
        .H_3_T(H_3_T),

        .dsp_Hex(dsp_Hex),
        .Hex_0(Hex_0),
        .Hex_1(Hex_1),
        .Hex_2(Hex_2),
        .Hex_3(Hex_3)
    
    );
    key_process k1(
        clk,
        key_1,
        key_first_1,
        key_long_1
    );

        key_process k2(
        clk,
        key_2,
        key_first_2,
        key_long_2
    );

  /*  key_stable key_str(
		clk,
        key_one,
		key_two,
		key_two_cleared
	);

    key_stable key_rst(
		clk,
        1'b0,
		key_one,
		key_one_cleared
	);*/

endmodule : top_watch
//------------------------------------------------------//