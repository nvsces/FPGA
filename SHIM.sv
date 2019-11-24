module SHIM(
input clk,
input dsp_Hex='0,

output logic led_red_1,
output logic led_red_2, 
output logic led_red_3, 
output logic led_red_4, 
output logic led_red_5, 
output logic led_red_6, 
output logic led_red_7, 
output logic led_red_8,
output logic led_red_9, 
output logic led_red_10,

output logic led_green_1,
output logic led_green_2,
output logic led_green_3,
output logic led_green_4,
output logic led_green_5,
output logic led_green_6,
output logic led_green_7,
output logic led_green_8
);

logic [31:0] cn_true=0;
logic [31:0] Count=0;
localparam IN_HZ=50_000_000;
localparam time_led=IN_HZ*5;
localparam etalon=time_led/10; ///25_500_000
//localparam etalon=2_500;
logic [31:0] fraction =0;
logic flag=1;

always_ff@(posedge clk) begin
    if((flag)&& (cn_true >=etalon))
            flag<=0;
    if((!flag)&&(cn_true==0))
            flag<=1;
end

always_ff@(posedge clk) begin
        Count <= Count + 1'b1;
        if (dsp_Hex)
            Red();
        else
            Green();
end

task Red();
    if((!led_red_1) && (fraction >=Count))
        falseRed();
     else if (Count>= fraction && !led_red_1)begin
                trueRed();
                Count<=0;
         end
    if (led_red_1)
       if(Count >= cn_true) begin
          falseRed();
          Count <= 0;
          Led();
       end
endtask:Red

task Green();
    if((!led_green_1) && (fraction >=Count))
        falseGreen();
     else if (Count>= fraction && !led_green_1)begin
                trueGreen();
                Count<=0;
         end
    if (led_green_1)
       if(Count >= cn_true) begin
          falseGreen();
          Count <= 0;
          Led();
       end
endtask:Green

task Led();
    if (flag)begin
        cn_true  <= cn_true +(etalon/10);
        fraction <= etalon - cn_true;
    end else begin
        cn_true  <= cn_true -(etalon/10);
        fraction <= etalon - cn_true;
    end
endtask:Red
//-------------------------------------//
task trueGreen();
    led_green_1 <= '1;
    led_green_2 <= '1;
    led_green_3 <= '1;
    led_green_4 <= '1;
    led_green_5 <= '1;
    led_green_6 <= '1;
    led_green_7 <= '1;
    led_green_8 <= '1;
endtask:trueGreen
//------------------------------------//
task falseGreen();
    led_green_1 <= '0;
    led_green_2 <= '0;
    led_green_3 <= '0;
    led_green_4 <= '0;
    led_green_5 <= '0;
    led_green_6 <= '0;
    led_green_7 <= '0;
    led_green_8 <= '0;
endtask:falseGreen
//------------------------------------//
task trueRed();
    led_red_1  <= '1;
    led_red_2  <= '1;
    led_red_3  <= '1;
    led_red_4  <= '1;
    led_red_5  <= '1;
    led_red_6  <= '1;
    led_red_7  <= '1;
    led_red_8  <= '1;
    led_red_9  <= '1;
    led_red_10 <= '1;
endtask:trueRed
//------------------------------------//
task falseRed();
    led_red_1  <= '0;
    led_red_2  <= '0;
    led_red_3  <= '0;
    led_red_4  <= '0;
    led_red_5  <= '0;
    led_red_6  <= '0;
    led_red_7  <= '0;
    led_red_8  <= '0;
    led_red_9  <= '0;
    led_red_10 <= '0;
endtask:falseRed

endmodule:SHIM