module timer(
    input clk,
    input key_start_n,
    input key_reset_n,

    output logic [6:0] Hex_0,
    output logic [6:0] Hex_1,
    output logic [6:0] Hex_2,
    output logic [6:0] Hex_3
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

    decoder D_S(
      .sw(time_S), //  4 bit binary input
	  .led(Hex_0)  //  16-bit out 
    );
    decoder D_SS(
        .sw(time_SS), //  4 bit binary input
		.led(Hex_1)  //  16-bit out 
    );
	 
     decoder D_M(
        .sw(time_M), //  4 bit binary input
		.led(Hex_2)  //  16-bit out 
    );
	 
    decoder D_MM(
        .sw(time_MM), //  4 bit binary input
		.led(Hex_3)  //  16-bit out 
    );

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
endmodule :timer
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