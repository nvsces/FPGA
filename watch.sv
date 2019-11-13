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

logic [1:0] Hex_bit = '0;

localparam C_key_one = 200_000_000;
localparam C_key_two = 200_000_000;

assign key_one = ~key_one_n;
assign key_two = ~key_two_n;
//----------------------------------------------------------------------------------------------------------//
always_comb begin
	mod_next = SHOW_MM;
    case (mod_state)
        //--------------------------------------------------------------------------------------------------//
    MOD_WATCH:// режим часы
        if (key_one_cleared && !key_two) // нажимаем на 1 кнопку
            mod_next = MOD_SETTING;
        else if ((count_key_one >=C_key_one) && (count_key_two >= C_key_two)) begin // держим (1 и 2) кнопку 
             mod_next = MOD_TIMER; //следующий режим секундомер
             C_key_one ='0;
             C_key_two ='0;
             end          
        else mod_next = MOD_WATCH;  //ничего не нажимаем
        //--------------------------------------------------------------------------------------------------//
    MOD_SETTING:// режим настройки времени 
        if ((count_key_one >=C_key_one) && (!key_two) ) begin //держим 1 кнопку 
                  mod_next = MOD_WATCH; //следующий режим - часы
                  C_key_two = '0;
        end else mod_next = MOD_SETTING; // ничего не нажимаем
        //--------------------------------------------------------------------------------------------------//
    MOD_TIMER:// режим секундомер
        if ((count_key_one >=C_key_one) && (count_key_two >= C_key_two)) begin // держим (1 и 2) кнопку 
             mod_next = MOD_WATCH;// переход в режи часы
             C_key_one ='0;
             C_key_two ='0;
        end else mod_next = MOD_TIMER; //ничего не нажимаем   
    default: mod_next = MOD_WATCH;    
    endcase
end
//---------------------------------------------------------------------------------------------------------//
always_ff @(posedge clk )
	begin
        if (key_one)
            count_key_one <= count_key_one + 1'b1;            
        if (key_two)
            count_key_two <= count_key_two + 1'b1;
        

        case (mod_state)
        MOD_WATCH:
                    if ((count_key_two >= C_key_one)&&(!key_one))
                        //показываем секунды  
        //--------------------------------------------------//    
        MOD_SETTING:
                    if ((key_one_cleared) && (!key_two))
                        Hex_bit <= Hex_bit+1;
               else if ((key_two_cleared) && (!key_one))
                            add_Hex();
        //-------------------------------------------------//                     
        default: MM_SS();
        endcase                             
    end
//-------------------------------------------------------------------------------------------------------//    
task add_Hex();
  case(Hex_bit)
  2'b00:time_H_0 <= time_H_0 + 1'b1;
  2'b01:time_H_1 <= time_H_1 + 1'b1;
  2'b10:time_H_2 <= time_H_2 + 1'b1;
  2'b11:time_H_3 <= time_H_3 + 1'b1;
  default : Hex_bit <= '0;
  endcase
endtask :add_Hex



endmodule : watch