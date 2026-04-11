//####################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
// Author:        David Tetzlaff
// Project:       Uintah  
//
// Description: This block is the datapath for the digital waveforms for the OPA DACs
//               
//               
//-------------------------------------------------------------------------------------------------------------------



module  rp_opa_wfm_gen_dp  (
    // clock/reset
    input               clk,          // clock
    input               rst_n,        // active low reset
    // Controls
    input               load_init,    // load initial state
    input               ramp_active,  // ramp in progress
    input       [ 7:0]  update_state, // update state
    input               up_down_n,    // up or down

    // Configurations
    input       [19:0]  cfg_accum_ivalue,  // initial value
    input       [31:0]  cfg_step_size,     // step size (signed)
    input       [19:0]  cfg_limit_max,     // max limit
    input       [19:0]  cfg_limit_min,     // min limit

    // outputs
    output reg  [ 9:0]  out_opa_wfm,       // opa_wfm output

    // Test I/F
    input       [ 7:0]  test_mux_sel,       // test mux select
    output reg  [ 7:0]  test_data           // test data
);

// -------------------------------------------------------------------------
// Version Log
// -------------------------------------------------------------------------
localparam VERSION          = 16'h01_00;  // Initial VERSION

// -------------------------------------------------------------------------
// Signal Declarations
// -------------------------------------------------------------------------
   
logic   [31:0]  sq_accum ;
logic   [31:0]  neg_step_size ;
logic   [31:0]  limit_correction ;
logic   [ 3:0]  norm_shift ;
logic   [31:0]  sq_norm ;
logic   [10:0]  sqrt_norm ;
logic   [10:0]  sqrt_out ;


// -------------------------------------------------------------------------
// Datapath
// -------------------------------------------------------------------------

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sq_accum         <= 32'h0 ;
        neg_step_size    <= 32'h0 ;
        limit_correction <= 32'h0 ;
        norm_shift       <=  4'h0 ;
        sq_norm          <= 32'h0 ;
        sqrt_norm        <= 11'h0 ;
        sqrt_out         <= 11'h0 ;
    end
    else begin
        if (load_init == 1'b1) begin
            sq_accum         <= {2'b0, cfg_accum_ivalue, 10'b0} ;
            limit_correction <= {2'b0, cfg_limit_max, 10'b0} - {2'b0, cfg_limit_min, 10'b0} ;
            neg_step_size    <= (~cfg_step_size) + 32'h1 ;   // negative step value
        end
        else if (ramp_active == 1'b0) begin
            sqrt_out <= 11'h0 ;
        end
        else begin
            if (update_state[2] == 1'b1) begin  // step accumulator
                if (up_down_n == 1'b1) begin
                    sq_accum <= sq_accum + cfg_step_size ;
                end
                else begin
                    sq_accum <= sq_accum + neg_step_size ;
                end
            end
            else if (update_state[3] == 1'b1) begin  // correct for limit violations
                if ( (sq_accum[31] == 1'b1) || (sq_accum[31:10] < {2'b0, cfg_limit_min}) ) begin
                    sq_accum <= sq_accum + limit_correction ;  // too low correction
                end
                else if (sq_accum[31:10] >= {2'b0, cfg_limit_max}) begin
                    sq_accum <= sq_accum - limit_correction ;  // too high correction
                end
            end
            if (update_state[4] == 1'b1) begin  // normalize
                casex (sq_accum[31:10])
                    22'b00_0000_0000_0000_0000_000?: norm_shift <= 4'hA ;
                    22'b00_0000_0000_0000_0000_0???: norm_shift <= 4'h9 ;
                    22'b00_0000_0000_0000_000?_????: norm_shift <= 4'h8 ;
                    22'b00_0000_0000_0000_0???_????: norm_shift <= 4'h7 ;
                    22'b00_0000_0000_000?_????_????: norm_shift <= 4'h6 ;
                    22'b00_0000_0000_0???_????_????: norm_shift <= 4'h5 ;
                    22'b00_0000_000?_????_????_????: norm_shift <= 4'h4 ;
                    22'b00_0000_0???_????_????_????: norm_shift <= 4'h3 ;
                    22'b00_000?_????_????_????_????: norm_shift <= 4'h2 ;
                    22'b00_0???_????_????_????_????: norm_shift <= 4'h1 ;
                    22'b0?_????_????_????_????_????: norm_shift <= 4'h0 ;
                    default: norm_shift <= 4'h0 ;
                endcase
            end
            if (update_state[5] == 1'b1) begin  // normalize
                sq_norm <= (sq_accum << (norm_shift*2) ) ;
            end
            if (update_state[6] == 1'b1) begin  // normalized square root
                sqrt_norm <= 11'b00111110000 + sq_norm[31:21] - {5'b0, sq_norm[31:26]} ;
            end
            if (update_state[7] == 1'b1) begin  // normalized square root
                sqrt_out <= (sqrt_norm >> norm_shift) ;
                ////$display("sq= %8d  sqrt= %4d  cal= %4d  err= %4d  %4d%", 
                ////    sq_accum[31:10], sqrt_norm >> norm_shift, $sqrt(sq_accum[31:10]),
                ////    (sqrt_norm >> norm_shift)-$sqrt(sq_accum[31:10]),
                ////    ((sqrt_norm >> norm_shift)-$sqrt(sq_accum[31:10]))*100/$sqrt(sq_accum[31:10])) ;
            end
        end
    end
end

assign out_opa_wfm = sqrt_out[9:0] ;

// !!! TEMP
assign test_data = 8'b0;

endmodule



