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
	logic key='0;
    logic go ='0;
	logic[$bits(CNT_TH)-1:0] cnt='0;
    localparam CNT_key = 15;


always_ff @(posedge clk)
            key <= in_key;

always_ff @(posedge clk) begin
    if (cnt >= CNT_key) begin
        out_key_long <= '1;
        go  <= '1;
        cnt <= '0;
    end
    else out_key_long <= '0;
    if (in_key && !go)
        cnt <= cnt + 1'b1;
    else 
        cnt <= '0;
    if (!out_key_long && !in_key)
        go <= '0;
end
    

always_ff@(posedge clk)
        if (!in_key && key && !go)
            out_key_first <= '1;
        else
            out_key_first <= '0;
endmodule:key_process