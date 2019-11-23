module stopwatch(
    input clk,
    input key_start_n,
    input key_reset_n,

    output logic [3:0] Hex_0,
    output logic [3:0] Hex_1,
    output logic [3:0] Hex_2,
    output logic [3:0] Hex_3
);
localparam  IN_CLK_HZ = 50_000_000;
localparam  MM_count=IN_CLK_HZ/100;

typedef enum logic[1:0] {SHOW_MM, SHOW_SS} show_t;

show_t show_next, show_state;

logic key_reset_cleared;
logic key_start_cleared;

logic key_start;
logic key_reset;

logic [25:0] count = 1;

logic start_stop ='0;

logic [3:0] time_S  =0;
logic [3:0] time_SS =0;
logic [3:0] time_M  =0;
logic [3:0] time_MM =0;

assign key_reset = ~key_reset_n;
assign key_start = ~key_start_n;

always_comb begin
	show_next = SHOW_MM;
    case (show_state)
    SHOW_MM:
        if ((time_MM >=5) && (time_M >=4'b1001) && (time_SS >=4'b1001) && (time_S >=4'b1001) && (count >= MM_count))
            show_next = SHOW_SS;
        else
            show_next = SHOW_MM;
    SHOW_SS: show_next = SHOW_SS;
    default: show_next = SHOW_MM;    
    endcase
end

always_ff @(posedge clk or posedge key_reset_cleared)
    if (key_reset_cleared)
        show_state <= SHOW_MM;
    else
        show_state <= show_next;


always_ff@(posedge clk) begin
    Hex_0 <= time_S;
    Hex_1 <= time_SS;
    Hex_2 <= time_M;
    Hex_3 <= time_MM;
end
//----------------------------------------------------------------------------//
always_ff @(posedge clk or posedge key_reset_cleared)
	if (key_reset_cleared) begin
        time_S  <= 0;
        time_SS <= 0;
        time_M  <= 0;
        time_MM <= 0;   
        start_stop <= '0;
	end
	else begin
        if (key_start_cleared) 
            start_stop <= ~start_stop;                  
        
        if (start_stop)                
            count <= count +1'b1;

        case (show_state)
        SHOW_MM: SS_MM();
        SHOW_SS: MM_SS();
        default: MM_SS();
        endcase                             
    end

//-------------------------------------------------------------------------//
task SS_MM();
       if (count >= MM_count) begin                        
            if (time_S >=4'b1001) begin               
                time_S  <= 4'b0000;
                if (time_SS >=4'b1001) begin 
                    time_SS <= 4'b0000;
                   if (time_M >=4'b1001) begin 
                       time_M <= 4'b0000;
                       if (time_MM >=5) begin 
                           time_MM <= 4'b0000;
                           time_M  <= 4'b0001;
                           time_SS <= 4'b0000;
                           time_S  <= 4'b0000;
                       end else 
                           time_MM <= time_MM +1'b1;
                    end else 
                        time_M <= time_M +1'b1;
                end else 
                    time_SS <= time_SS+4'b0001;
            end else          
                time_S <= time_S+1'b1;
            count <= '0;
        end         
    endtask : SS_MM
//------------------------------------------------------------------------//
task MM_SS();        
        if (count >= IN_CLK_HZ) begin                        
            if (time_S==4'b1001) begin               
                time_S  <= 4'b0000;
                if (time_SS==4'b0101) begin 
                    time_SS <= 4'b0000;
                   if (time_M==4'b1001) begin 
                       time_M <= 4'b0000;
                       if (time_MM==4'b0101) begin 
                           time_MM <= 4'b0000;
                           time_M  <= 4'b0000;
                           time_SS <= 4'b0000;
                           time_M  <= 4'b0000;
                       end else 
                           time_MM <= time_MM +1'b1;
                    end else 
                        time_M <= time_M +1'b1;
                end else 
                    time_SS <= time_SS+1'b1;
            end else          
                time_S <= time_S+1'b1;
            count <= '0;
        end          
    endtask : MM_SS
    //---------------------------------------------------------------------------//
    key_stable key_str(
		clk,
        key_reset,
		key_start,
		key_start_cleared
	);

    key_stable key_rst(
		clk,
        1'b0,
		key_reset,
		key_reset_cleared
	);
	 
//------------------------------------------------------------------------//
endmodule :stopwatch
//-----------------------------------------------------------------------//
module key_stable #(
	IN_C_HZ = 50_000_000
)(
	input clk, rst,
	
	input in_key,
	output out_key='0
);
	localparam STROBE_TIME_MS = 500;
	localparam CNT_TH = STROBE_TIME_MS * (IN_C_HZ / 1000);
	
	logic[$bits(CNT_TH)-1:0] cnt='0;
	
    logic key, x_key;
    logic go;

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
		
endmodule : key_stable

//------------------------------------------------------//