module top_watch(
input clk,
input key_1_n;
input key_2_n;

output logic [0:3] Hex_0,
output logic [0:3] Hex_1,
output logic [0:3] Hex_2,
output logic [0:3] Hex_3

);

typedef enum logic[1:0] {MOD_WATCH,MOD_TIMER} mode_of_operation;
mode_of_operation mod_state, mod_next;

localparam  IN_CLK_HZ = 50_000_000;
localparam  MM_count=IN_CLK_HZ/100;

logic [3:0] H_0_state = 0;
logic [3:0] H_1_state = 0;
logic [3:0] H_2_state = 0;
logic [3:0] H_3_state = 0;

logic [3:0] H_0_W = 0;
logic [3:0] H_1_W = 0;
logic [3:0] H_2_W = 0;
logic [3:0] H_3_W = 0;

logic [3:0] H_0_T = 0;
logic [3:0] H_1_T = 0;
logic [3:0] H_2_T = 0;
logic [3:0] H_3_T = 0;

logic key_1_first='0;
logic key_2_first='0;

logic key_1_long='0;
logic key_2_long='0;

assign key_1 = ~key_1_n;
assign key_2 = ~key_2_n;
//----------------------------------------------------------------------------------------------------------//
always_comb begin //автомат событий для режимов работы
	mod_next = MOD_WATCH;
    case (mod_state)

    MOD_WATCH:// режим часы
        if (key_1_long)begin // долгое нажатие  на 1 кнопку
             mod_next = MOD_TIMER;                    
        else mod_next = MOD_WATCH;  //ничего не нажимаем

    MOD_TIMER:// режим секундомер
        if (key_1_long)
             mod_next = MOD_WATCH;
        else mod_next = MOD_TIMER; //ничего не нажимаем   
    
    default: mod_next = MOD_WATCH;    
    endcase
end

always_ff@(posedge clk) begin
    mod_state <= mod_next;
end

always_ff@(posedge clk) begin
    case (mod_state)
    MOD_WATCH:
              H_0_state <= H_0_W;
              H_1_state <= H_1_W;
              H_2_state <= H_2_W;
              H_3_state <= H_3_W;
    MOD_TIMER:
              H_0_state <= H_0_T;
              H_1_state <= H_1_T;
              H_2_state <= H_2_T;
              H_3_state <= H_3_T; 
    default : mod_state <= MOD_WATCH;
    endcase             
end
//---------------------------------------------------------------------------------------------------------//
always_ff @(posedge clk )
	begin
        if (key_one)
            count_key_one <= count_key_one + 1'b1; 
            else count_key_one <= '0;           
        if (key_two)
            count_key_two <= count_key_two + 1'b1;
            else count_key_two <= '0;
        
        //--------------------------------------------------//
        case (mod_state)
        MOD_WATCH: 
                    if (flag_count_wotch)
                        COUNT_WATCH <=  COUNT_WATCH + 1'b1;

                    case(watch_state)
                    WATCH_TIME:
                    WATCH_SEC:
                    default:
                    endcase 
                    

        //--------------------------------------------------//    
        MOD_SETTING:
                    if ((key_one_cleared) && (!key_two))
                        Hex_bit <= Hex_bit+1;
               else if ((key_two_cleared) && (!key_one))
                        add_Hex();
                    
        //-------------------------------------------------// 
        MOD_TIMER:       
                    	if ((key_one_cleared) &&(!key_two) begin
                            time_H_3  <= 0;
                            time_H_2  <= 0;
                            time_H_1  <= 0;
                            time_H_0  <= 0;   
                            start_stop <= '0;
                            show_state <= SHOW_MM;
                        end else show_state <= show_next;

                    if ((key_two_cleared) && (!key_one))
                        start_stop <= ~start_stop;

                    if (start_stop)                
                        count <= count +1'b1; 

                    case (show_state)
                    SHOW_MM: SS_MM();
                    SHOW_SS: MM_SS();
                    default: MM_SS();
                    endcase       
        //------------------------------------------------//                              
        default: mod_state = MOD_WATCH;
        endcase                             
    end
//-------------------------------------------------------------------------------------------------------//    
task add_Hex();// +1 к разряду Hex
  case(Hex_bit)
  2'b00:time_H_0 <= time_H_0 + 1'b1;
  2'b01:time_H_1 <= time_H_1 + 1'b1;
  2'b10:time_H_2 <= time_H_2 + 1'b1;
  2'b11:time_H_3 <= time_H_3 + 1'b1;
  default : Hex_bit <= '0;
  endcase
endtask :add_Hex
//--------------------------------------------------------------------------------------------------------//
task sec_mc_go();//отсчитывает секунды:милисекуныд в часах
   if (COUNT_WATCH >= MM_count)
        time_H_0 >=     
endtask:sec_go
//--------------------------------------------------------------------------------------------------------//
task CHCH_MM();//часы : минуты

endtask :CHCH_MM
//--------------------------------------------------------------------------------------------------------//
task SS_MM();//секунды : милисекунды
       if (count >= MM_count) begin                        
            if (time_H_0 >=4'b1001) begin               
                time_H_0  <= 4'b0000;
                if (time_H_1 >=4'b1001) begin 
                    time_H_1 <= 4'b0000;
                   if (time_H_2 >=4'b1001) begin 
                       time_H_2 <= 4'b0000;
                       if (time_H_3 >=5) begin 
                           time_H_1  <= 4'b0000;
                           time_H_0  <= 4'b0000;
                           time_H_3  <= 4'b0001;
                           time_H_2  <= 4'b0000;
                       end else 
                           time_H_3 <= time_H_3 +1'b1;
                    end else 
                        time_H_2 <= time_H_2 +1'b1;
                end else 
                    time_H_1 <= time_H_1+4'b0001;
            end else          
                time_H_0 <= time_H_0+1'b1;
            count <= '0;
        end         
    endtask : SS_MM
//------------------------------------------------------------------------//
task MM_SS();//минуты : секунды   
        if (count >= IN_CLK_HZ) begin                        
            if (time_H_0==4'b1001) begin               
                time_H_0  <= 4'b0000;
                if (time_H_1==4'b0101) begin 
                    time_H_1 <= 4'b0000;
                   if (time_H_2==4'b1001) begin 
                       time_H_2 <= 4'b0000;
                       if (time_H_3==4'b0101) begin 
                           time_H_0  <= 4'b0000;
                           time_H_1  <= 4'b0000;
                           time_H_2  <= 4'b0000;
                           time_H_3  <= 4'b0000;
                       end else 
                           time_H_3 <= time_H_3 +1'b1;
                    end else 
                        time_H_2 <= time_H_2 +1'b1;
                end else 
                    time_H_1 <= time_H_1+1'b1;
            end else          
                time_H_0 <= time_H_1+1'b1;
            count <= '0;
        end          
    endtask : MM_SS
    //---------------------------------------------------------------------------//

    decoder D_S(
      .sw(time_H_0), //  4 bit binary input
	  .led(Hex_0)  //  16-bit out 
    );
    decoder D_SS(
        .sw(time_H_1), //  4 bit binary input
		.led(Hex_1)  //  16-bit out 
    );
	 
     decoder D_M(
        .sw(time_H_2), //  4 bit binary input
		.led(Hex_2)  //  16-bit out 
    );
	 
    decoder D_MM(
        .sw(time_H_3), //  4 bit binary input
		.led(Hex_3)  //  16-bit out 
    );

    key_stable key_str(
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
	);

endmodule : top_watch
//------------------------------------------------------//
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