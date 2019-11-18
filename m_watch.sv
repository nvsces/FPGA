module m_watch(
input clk,
input key_long_1,
input key_long_2,
input key_first_1,
input key_first_2,
input key_double_long,

output logic next_mod,

output logic [0:3] Hex_0,
output logic [0:3] Hex_1,
output logic [0:3] Hex_2,
output logic [0:3] Hex_3
);
logic [3:0] time_Hm2 = 0;
logic [3:0] time_Hm1 = 0;
logic [3:0] time_Hs2 = 0;
logic [3:0] time_Hs1 = 0;
logic [3:0] time_Hmin2 = 0;
logic [3:0] time_Hmin1 = 0;
logic [3:0] time_Hc2 = 0;
logic [3:0] time_Hc1 = 0;


logic [31:0] Count_Time  = 0;
logic [31:0] count_mlsec = 0;
logic [31:0] count_sec   = 0;
logic [31:0] count_min   = 0;
logic [31:0] count_ch    = 0;

logic statr_time = '0;
logic [1:0] Hex_bit = '0;

localparam  IN_CLK_HZ = 50_000_000;
localparam  MLSec = IN_CLK_HZ/100;



typedef enum logic[2:0] {WATCH_TIME, WATCH_SEC,WATCH_SETTING} watch_t;
watch_t watch_next, watch_state;

always_comb begin 
	watch_next = WATCH_TIME;
    case (watch_state)
    WATCH_TIME:
        if (key_first_1)
            watch_next = WATCH_SETTING;
        if (key_long_2)
            watch_next = WATCH_SEC;
        else
            watch_next = WATCH_TIME;
    WATCH_SEC: 
        if (key_long_2)
            watch_next = WATCH_SEC;
        else
            watch_next = WATCH_TIME;
    WATCH_SETTING:
        if (key_long_1) 
            watch_next = WATCH_TIME;
        else 
            watch_next = WATCH_SETTING;

    default: watch_next = WATCH_TIME;    
    endcase
end

always_ff@(posedge clk)begin
    if (statr_time) begin
        Count_Time <= Count_Time + 1'b1;
        time_w();
    end
end
//--------------------------------------------------------------------//
always_ff@(posedge clk) begin
    case (watch_state)
        WATCH_TIME:
            if (key_first_1) begin
                statr_time <= '0;
                reset();
            end
            if (key_double_long)
                next_mod <= '1;
        WATCH_SEC: MM_SS();
        WATCH_SETTING:
            if (key_first_1)
                Hex_bit <= Hex_bit + 1'b1;
            if (key_first_2)  begin
                add_Hex();
                case (Hex_bit)
                    2'b00:
                            if (time_Hmin2 >=10) 
                                time_Hmin2 <= 0;
                    2'b01:
                            if (time_Hmin1 >=6) 
                                time_Hmin1 <= 0;
                    2'b10:
                            if (time_Hch1 >= 2) begin 
                                if (time_Hch2 >=4) 
                                    time_Hmin2 <= 0;
                            end 
                            else
                                if (time_Hch2 >=10) 
                                    time_Hmin2 <= 0;
                    2'b11:
                            if (time_Hch1 >= 3) 
                                time_Hch1 <= 0;
                    default:Hex_bit <= 0;
                    endcase
            end
            if (key_long_1) begin
                add_Hex_converTime();
                statr_time <= 1';
            end
        default: watch_next <= WATCH_TIME;
        endcase 
end
//---------------------------------------------------------------------------//
task add_Hex_converTime();//переводим наше заданное время в индикаторах
    count_min <= time_Hmin2 + 10*time_Hmin1;
    count_ch  <= time_Hch2  + 10*time_Hch1;
endtask : add_Hex_converTime
//---------------------------------------------------------------------------//
task add_Hex();// +1 к разряду Hex
  case(Hex_bit)
  2'b00:time_Hmin2 <= time_Hmin2 + 1'b1;
  2'b01:time_Hmin1 <= time_Hmin1 + 1'b1;
  2'b10:time_Hch2 <= time_Hch2 + 1'b1;
  2'b11:time_Hch1 <= time_Hch1 + 1'b1;
  default : Hex_bit <= '0;
  endcase
endtask :add_Hex
//--------------------------------------------------------------------------//
task reset();
    Count_Time  <= 0;
    count_mlsec <= 0;
    count_sec   <= 0;
    count_min   <= 0;
    count_ch    <= 0;
endtask : reset
//--------------------------------------------------------------------------//
task time_w();
    if (Count_Time >= MLSec) begin
        count_mlsec <= count_mlsec + 1'b1;
        Count_Time <= 0;
    end
    if (count_mlsec >= 100 ) begin
        count_sec <= count_sec + 1'b1;
        count_mlsec <= 0;
    end
    if (count_sec >= 60) begin
        count_min <= count_min + 1'b1;
        count_sec <= 0;
    end
    if (count_min >=60) begin
        count_ch  <= count_ch + 1'b1;
        count_min <= 0;
    end
    if (count_ch >=24)
        reset();

    time_Hm1   <= count_mlsec % 10; // вычисление значения первой цифры в счетчике милисекунд
    time_Hm2   <= count_mlsec/10;   // вычисление значения второй цифры в счетчике милисекунд
    time_Hs1   <= count_sec % 10;   // вычисление значения первой цифры в счетчике секунд
	time_Hs2   <= count_sec/10;     // вычисление значения второй цифры в счетчике секунд
	time_Hmin1 <= count_min % 10;   // вычисление значения первой цифры в счетчике минут
	time_Hmin2 <= count_min/10;     // вычисление значения второй цифры в счетчике минут
    time_Hch1  <= count_ch % 10;    // вычисление значения первой цифры в счетчике часов
	time_Hch2  <= count_ch/10;      // вычисление значения второй цифры в счетчике часов
endtask : time_w 
//---------------------------------------------------------------------------------------------//
endmodule : m_watch