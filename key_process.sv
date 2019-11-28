module key_process #(
	IN_C_HZ = 50_000_000
)(
	input clk,
	
	input in_key,
	output logic out_key_first='0,
    output logic out_key_long='0
);  
	localparam STROBE_TIME_MS = 500;
	localparam CNT_TH = STROBE_TIME_MS * (IN_C_HZ / 1000);

    localparam CNT_key = 2*IN_C_HZ;
	   
	logic [$bits(CNT_TH)-1:0] cnt='0;
    logic [$bits(CNT_key)-1:0] cnt_stable=0;

    logic key='0;
    logic go_stable='0;
    logic flag_out_key_long ='0;


always_ff @(posedge clk)
    if (!go_stable)
        key <= in_key;
    else
        key <= '0;

always_ff @(posedge clk) 
    if (cnt >= CNT_key && key)
        flag_out_key_long <= '1;
    else 
        flag_out_key_long <= '0;

always_ff@(posedge clk) begin
        if (in_key)
            cnt <= cnt + 1'b1;
        else 
            cnt <= '0;

        if (!in_key && key && !flag_out_key_long) begin
            out_key_first <= '1;
            cnt <= '0;
            go_stable <='1;
        end
        else
            out_key_first <= '0;

        if (!in_key && key && flag_out_key_long) begin
            out_key_long <= '1;
            go_stable <='1;
        end
        else
            out_key_long <= '0;

    if (cnt_stable + 1'b1 >= CNT_TH) begin
                cnt_stable <= '0;
                go_stable <= '0;
            end
    else if (go_stable)
                cnt_stable <= cnt_stable + 1'b1;    
        
end

endmodule:key_process