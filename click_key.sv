module click_key#(
    IN_C_HZ = 50_000_000
)(  
input clk,
input in_key,

output logic fast_click = '0,
output logic long_click = '0
);
localparam CNT_key = 150_000_000;
localparam STROBE_TIME_MS = 500;
localparam CNT_TH = STROBE_TIME_MS * (IN_C_HZ / 1000);
	
logic[$bits(CNT_TH)-1:0] cnt='0;
	
logic key, x_key;
logic go = '1;

    always_ff @(posedge clk or posedge rst)
        if (rst)
            {key, x_key} <= '0;
        else
            {key, x_key} <= {x_key, in_key};

    always_ff @(posedge clk or posedge rst)
        if (rst)
            out_key <= '0;
        else if (key && !go)
            out_key <= '1;
        else
            out_key <= '0;

	always_ff @(posedge clk or posedge rst)
        if (rst) begin
            cnt <= '0;
            go <= '0;
        end
        else begin
            if (key && !go)
                go <= '1;

            if (cnt + 1'b1 >= CNT_TH) begin
                cnt <= '0;
                go <= '0;
            end
            else if (go)
                cnt <= cnt + 1'b1;
        end
		
endmodule :click_key