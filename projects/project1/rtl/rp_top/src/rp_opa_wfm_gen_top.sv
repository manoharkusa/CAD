//####################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
// Author:        David Tetzlaff
// Project:       Uintah  
//
// Description: This block generates the digital waveforms for the OPA DACs
//               
//               
//-------------------------------------------------------------------------------------------------------------------



module  rp_opa_wfm_gen_top  (
    // clock/reset
    input               clk,          // clock
    input               rst_n,        // active low reset
    // Controls
    input               sweep_reset,  // opa sweep reset
    input               sweep_start,  // opa sweep start

    // Configurations
    input       [19:0]  cfg_accum_ivalue1,  // initial value
    input       [31:0]  cfg_step_size1,     // step size (signed)
    input       [19:0]  cfg_limit_max1,     // max limit
    input       [19:0]  cfg_limit_min1,     // min limit
    input       [19:0]  cfg_accum_ivalue2,  // initial value
    input       [31:0]  cfg_step_size2,     // step size (signed)
    input       [19:0]  cfg_limit_max2,     // max limit
    input       [19:0]  cfg_limit_min2,     // min limit
    input       [19:0]  cfg_accum_ivalue3,  // initial value
    input       [31:0]  cfg_step_size3,     // step size (signed)
    input       [19:0]  cfg_limit_max3,     // max limit
    input       [19:0]  cfg_limit_min3,     // min limit
    input       [19:0]  cfg_accum_ivalue4,  // initial value
    input       [31:0]  cfg_step_size4,     // step size (signed)
    input       [19:0]  cfg_limit_max4,     // max limit
    input       [19:0]  cfg_limit_min4,     // min limit
    input       [ 7:0]  cfg_num_ramps,      // number of ramps
    input       [ 7:0]  cfg_update_rate,    // DAC update rate
    input       [11:0]  cfg_ramp_duration,  // Ramp Duration, number of DAC updates

    // outputs
    output reg  [ 9:0]  out_opa_wfm1,       // opa_wfm output
    output reg  [ 9:0]  out_opa_wfm2,       // opa_wfm output
    output reg  [ 9:0]  out_opa_wfm3,       // opa_wfm output
    output reg  [ 9:0]  out_opa_wfm4,       // opa_wfm output

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

logic           ramp_active ;       // ramp in progress
logic           next_ramp_active ;  // ramp in progress
logic           load_init ;         // load initial values
logic   [ 7:0]  update_state ;
logic   [ 7:0]  update_counter ;    // divide clock to determine when to update
logic   [11:0]  duration_counter ;  // counter number of updates per ramp
logic   [ 7:0]  ramp_counter ;      // count number of ramps before stopping
logic           up_down_n ;         // ramp direction 1=up, 0=down
logic           next_up_down_n ;    // ramp direction 1=up, 0=down
   
logic   [ 7:0]  test_data1 ;        // from channel 1
logic   [ 7:0]  test_data2 ;        // from channel 2
logic   [ 7:0]  test_data3 ;        // from channel 3
logic   [ 7:0]  test_data4 ;        // from channel 3


// -------------------------------------------------------------------------
// State Machine Code
// -------------------------------------------------------------------------

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ramp_active         <= 1'b0 ;
        next_ramp_active    <= 1'b0 ;
        load_init           <= 1'b0 ;
        update_state        <= 8'b0 ;
        update_counter      <= 8'b0 ;
        duration_counter    <= 12'b0 ;
        ramp_counter        <= 8'b0 ;
        up_down_n           <= 1'b0 ; 
        next_up_down_n      <= 1'b0 ; 
    end
    else begin
        if (sweep_start == 1'b1) begin
            ramp_active         <= 1'b0 ;
            next_ramp_active    <= 1'b1 ;
            load_init           <= 1'b1 ;
            update_state        <= 8'b0 ;
            update_counter      <= cfg_update_rate ;
            duration_counter    <= cfg_ramp_duration ;
            ramp_counter        <= cfg_num_ramps ;
            up_down_n           <= 1'b1 ; 
            next_up_down_n      <= 1'b1 ; 
        end
        else if ( (sweep_reset == 1'b1) | ( (load_init == 1'b0) && (ramp_active == 1'b0) ) ) begin
            ramp_active         <= 1'b0 ;
            next_ramp_active    <= 1'b0 ;
            load_init           <= 1'b0 ;
            update_state        <= 8'b0 ;
            update_counter      <= 8'b0 ;
            duration_counter    <= 12'b0 ;
            ramp_counter        <= 8'b0 ;
            up_down_n           <= 1'b0 ; 
            next_up_down_n      <= 1'b0 ; 
        end
        else begin
            ramp_active <= ramp_active || load_init ;
            load_init   <= 1'b0 ;
            if (update_counter > 8'b1) begin
                update_counter <= update_counter - 8'b1 ;
                update_state   <= update_state << 1 ; 
            end
            else begin
                ramp_active <= next_ramp_active ;
                update_counter <= cfg_update_rate ;
                update_state   <= 8'b1 ;
                up_down_n      <= next_up_down_n ;
                if (duration_counter > 12'b1) begin
                    duration_counter <= duration_counter - 12'b1 ;
                end
                else begin
                    duration_counter <= cfg_ramp_duration ;
                    next_up_down_n   <= !up_down_n ;
                    if (ramp_counter > 8'b1) begin
                        ramp_counter <= ramp_counter - 8'b1 ;
                    end
                    else begin
                        next_ramp_active <= 1'b0 ;
                    end
                end
            end
        end
    end
end


// -------------------------------------------------------------------------
// Datapath
// -------------------------------------------------------------------------

rp_opa_wfm_gen_dp rp_opa_wfm_gen_dp1 (
    .clk                 (clk),
    .rst_n               (rst_n),
    .load_init           (load_init),
    .ramp_active         (ramp_active),
    .update_state        (update_state),
    .up_down_n           (up_down_n),
    .cfg_accum_ivalue    (cfg_accum_ivalue1),
    .cfg_step_size       (cfg_step_size1),
    .cfg_limit_max       (cfg_limit_max1),
    .cfg_limit_min       (cfg_limit_min1),
    .out_opa_wfm         (out_opa_wfm1),
    .test_mux_sel        (test_mux_sel),
    .test_data           (test_data1)
) ; 

rp_opa_wfm_gen_dp rp_opa_wfm_gen_dp2 (
    .clk                 (clk),
    .rst_n               (rst_n),
    .load_init           (load_init),
    .ramp_active         (ramp_active),
    .update_state        (update_state),
    .up_down_n           (up_down_n),
    .cfg_accum_ivalue    (cfg_accum_ivalue2),
    .cfg_step_size       (cfg_step_size2),
    .cfg_limit_max       (cfg_limit_max2),
    .cfg_limit_min       (cfg_limit_min2),
    .out_opa_wfm         (out_opa_wfm2),
    .test_mux_sel        (test_mux_sel),
    .test_data           (test_data2)
) ; 

rp_opa_wfm_gen_dp rp_opa_wfm_gen_dp3 (
    .clk                 (clk),
    .rst_n               (rst_n),
    .load_init           (load_init),
    .ramp_active         (ramp_active),
    .update_state        (update_state),
    .up_down_n           (up_down_n),
    .cfg_accum_ivalue    (cfg_accum_ivalue3),
    .cfg_step_size       (cfg_step_size3),
    .cfg_limit_max       (cfg_limit_max3),
    .cfg_limit_min       (cfg_limit_min3),
    .out_opa_wfm         (out_opa_wfm3),
    .test_mux_sel        (test_mux_sel),
    .test_data           (test_data3)
) ; 

rp_opa_wfm_gen_dp rp_opa_wfm_gen_dp4 (
    .clk                 (clk),
    .rst_n               (rst_n),
    .load_init           (load_init),
    .ramp_active         (ramp_active),
    .update_state        (update_state),
    .up_down_n           (up_down_n),
    .cfg_accum_ivalue    (cfg_accum_ivalue4),
    .cfg_step_size       (cfg_step_size4),
    .cfg_limit_max       (cfg_limit_max4),
    .cfg_limit_min       (cfg_limit_min4),
    .out_opa_wfm         (out_opa_wfm4),
    .test_mux_sel        (test_mux_sel),
    .test_data           (test_data4)
) ; 

// !!! TEMP
assign test_data = 8'b0;

endmodule



