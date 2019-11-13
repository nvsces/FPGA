module watch(
input clk,
input key_one_n;
input key_two_n;

output logic [0:3] Hex_0,
output logic [0:3] Hex_1,
output logic [0:3] Hex_2,
output logic [0:3] Hex_3

);

typedef enum logic[2:0] {MOD_WATCH, MOD_SETTING,MOD_TIMER} mode_of_operation;
mode_of_operation mod_state, mod_next;

logic key_one_cleared;
logic key_two_cleared;

logic key_one;
logic key_two;

logic [3:0] time_H_0 = 0;
logic [3:0] time_H_1 = 0;
logic [3:0] time_H_2 = 0;
logic [3:0] time_H_3 = 0;

logic [31:0] count_key_one;
logic [31:0] count_key_two;

localparam C_key_one = 200_000_000;
localparam C_key_two = 200_000_000;

assign key_one = ~key_one_n;
assign key_two = ~key_two_n;

always_comb begin
	mod_next = SHOW_MM;
    case (mod_state)
    MOD_WATCH:
        if (key_one_cleared && !key_two_cleared)
            mod_next = MOD_SETTING;
        else if ((count_key_two >=C_key_two) && (!key_one_cleared) ) begin 
                  mod_next = MOD_WATCH;
                  C_key_two = '0;
                  end
        else if ((count_key_one >=C_key_one) && (count_key_two >= C_key_two)) begin
             mod_next = MOD_TIMER;
             C_key_one ='0;
             C_key_two ='0;
             end          
        else mod_next = MOD_WATCH;

    MOD_SETTING: mod_next = MOD_SETTING;

    MOD_TIMER:mod_next = MOD_TIMER;
    default: mod_next = MOD_WATCH;    
    endcase
end
//--------------------------------------------------------------------------------------------------------------//
always_ff @(posedge clk )
	begin
        if (key_one_cleared)
            count_key_one <= count_key_one + 1'b1;            
        if (key_two_cleared)
            count_key_two <= count_key_two + 1'b1;
        

        case (show_state)
        SHOW_MM: SS_MM();
        SHOW_SS: MM_SS();
        default: MM_SS();
        endcase                             
    end

endmodule : watch