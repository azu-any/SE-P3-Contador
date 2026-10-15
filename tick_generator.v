

module tick_generator (
	 input wire clk ,
	 input wire reset ,
	 input wire enable ,
	 input wire speed_sel , // 0: 1 s, 1: 100 ms
	 output reg tick
 ) ;

	reg [25:0] counter ;

	wire [25:0] terminal_count = speed_sel
									? 26'd16_666_663
									: 26'd49_999_999 ;

	always @ ( posedge clk or posedge reset ) begin
		if ( reset ) begin
		counter <= 26'd0 ;
		tick <= 1'b0 ;
	end else if (! enable ) begin
		counter <= 26'd0 ;
		tick <= 1'b0 ;
	end else if ( counter >= terminal_count ) begin
		counter <= 26'd0 ;
		tick <= 1'b1 ;
	end else begin
		counter <= counter + 26'd1 ;
		tick <= 1'b0 ;
		end
	end
endmodule