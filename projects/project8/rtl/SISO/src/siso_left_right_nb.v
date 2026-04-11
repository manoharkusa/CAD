	

	module siso_left_right_Nb #( parameter BUS_WIDTH = 8, SISO_WIDTH = 4 )      (
	                                                                                input RST,
	                                                                                input CLK,
	                                                                                input [1:0] SHIFT,
	                                                                                input [BUS_WIDTH-1:0] IN,
	                                                                                output [BUS_WIDTH-1:0] OUT
	                                                                            );
	

	    reg [BUS_WIDTH-1:0] siso_mem_p[SISO_WIDTH-1:0], siso_mem_n[SISO_WIDTH-1:0];
	    reg [BUS_WIDTH-1:0] fixed_out = 0;
	    integer i = 0, j = 0;
	

	    always@(*)
	    begin
	        case( SHIFT )
	            2'b01       :   begin
	                                for( i = SISO_WIDTH-1; i >= 0; i = i - 1 )
	                                begin
	                                    if( i == 0 )
	                                    begin
	                                        siso_mem_n[i] = IN;
	                                    end
	                                    else
	                                    begin
	                                        siso_mem_n[i] = siso_mem_p[i-1];
	                                    end
	                                end
	                            end
	            2'b10       :   begin
	                                for( i = 0; i < SISO_WIDTH; i = i + 1 )
	                                begin
	                                    if( i == (SISO_WIDTH-1) )
	                                    begin
	                                        siso_mem_n[i] = IN;
	                                    end
	                                    else
	                                    begin
	                                        siso_mem_n[i] = siso_mem_p[i+1];
	                                    end
	                                end
	                            end
	            default     :   begin
	                                for( i = 0; i < SISO_WIDTH; i = i + 1 )
	                                begin
	                                    siso_mem_n[i] = siso_mem_p[i];
	                                end
	                            end
	        endcase
	    end
	

	    always@( posedge CLK or posedge RST )
	    begin
	      /*  for( j = 0; j < SISO_WIDTH; j = j + 1 )
	        begin
	            siso_mem_p[j] <= siso_mem_p[j];
	        end
	*/

	        if( RST )
	        begin
	            // Does nothing actually
	        end
	        else
	        begin
	            for( j = 0; j < SISO_WIDTH; j = j + 1 )
	            begin
	                siso_mem_p[j] <= siso_mem_n[j];
	            end
	        end
	    end
	

	    assign OUT = ( SHIFT == 2'b00 || SHIFT == 2'b11 ) /* No Shift */ ? fixed_out : ( SHIFT == 2'b01 /* Left Shift */ ) ? siso_mem_p[SISO_WIDTH-1] : ( SHIFT == 2'b10 /* Right Shift */ ) ? siso_mem_p[0] : fixed_out;
	

	endmodule


