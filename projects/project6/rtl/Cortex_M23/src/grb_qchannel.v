//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016,2021-2023 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//   Release Information   : AT621-MN-70005-r2p0-00rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------

`include "grebe_defs.v"


module grb_qchannel
  #(parameter CBAW = 0,
    `GRB_TOP_PARAM_DECL)
 (
  input wire  clk,
  input wire  nPORESET,

  input  wire wakeup_i,
  input  wire sleep_i,
  input  wire nsleepholdack_i,
  input  wire sysqreqn_i,
  output wire sysqacceptn_o,
  output wire sysqdeny_o,
  output wire sysqactive_o,
  input  wire dbg_active_i,
  input  wire dbg_trcena_i,
  input  wire dbg_etm_pwrup_i,
  input  wire dbg_etm_psel_i,
  input  wire dbg_etm_penable_i,
  input  wire dbg_cti_psel_i,
  input  wire dbg_cti_pready_i,
  input  wire dbgqreqn_i,
  output wire dbgqacceptn_o,
  output wire dbgqdeny_o,
  output wire dbgqactive_o,

  input  wire dap_pwrup_req_i,
  output wire dap_pwrup_ack_o,

  input  wire sleepholdreqn_i,
  output wire core_idle_req_n_o,

  output wire dbg_apb_powered_up_o,
  input  wire fusaen_i,

  input  wire dftse_i,

  output wire flop_parity_fault_o
);


wire  cfg_dbg;

generate
if(CBAW == 0) begin : gen_cbaw
   assign cfg_dbg = (DBG != 0);
end
endgenerate


localparam   Q_RUN         = 3'b110;
localparam   Q_REQUEST     = 3'b010;
localparam   Q_STOPPED     = 3'b000;
localparam   Q_EXIT        = 3'b100;
localparam   Q_DENIED      = 3'b011;
localparam   Q_CONTINUE    = 3'b111;

reg [2:0] sys_state_q;
reg [2:0] sys_state_nxt;

reg sysqactive_q;
wire sysq_gating;
wire sysqreqn_sync;
wire sysqactive_nxt;

reg [2:0] dbg_state_q;
reg [2:0] dbg_state_nxt;

reg dbgqactive_q;
wire dbgq_gating;
wire dbgqreqn_sync;
wire dbgqactive_nxt;
wire dbg_sys_ack;

wire cfg_fusa;
assign cfg_fusa = (FLOPPARITY != 0);



grb_sync u_sysqreqn_sync(
  .SYNCRSTn   (nPORESET),
  .SYNCCLK    (clk),
  .SYNCDI     (sysqreqn_i),
  .SYNCDO     (sysqreqn_sync),
  .DFTSE      (dftse_i)
);


wire sysq_pwrdwn_req_sync = ~sysqreqn_sync;
wire core_is_idle = ~nsleepholdack_i;


assign sysq_gating = (sys_state_nxt != sys_state_q) |
                     (sysqactive_nxt != sysqactive_q);

always @(posedge clk or negedge nPORESET)
  if(~nPORESET)
    sys_state_q <= Q_STOPPED;
  else if(sysq_gating)
    sys_state_q <= sys_state_nxt;

always @(*)
  case(sys_state_q)

    Q_STOPPED:
      sys_state_nxt = sysq_pwrdwn_req_sync ? Q_STOPPED : Q_EXIT;
    Q_EXIT:
      sys_state_nxt = (~sysq_pwrdwn_req_sync & ~core_is_idle) ? Q_RUN : Q_EXIT;
    Q_RUN:
      sys_state_nxt = sysq_pwrdwn_req_sync ? Q_REQUEST : Q_RUN;
    Q_REQUEST:
    sys_state_nxt = (core_is_idle & ~sysqactive_nxt & ~sysqactive_q) ? Q_STOPPED : Q_DENIED;
    Q_DENIED:
      sys_state_nxt = sysq_pwrdwn_req_sync ? Q_DENIED : Q_CONTINUE;
    Q_CONTINUE:
      sys_state_nxt = Q_RUN;
    default:
      sys_state_nxt = 3'bxxx;
  endcase

assign sysqactive_nxt = ~sleep_i | wakeup_i | dbgqactive_nxt;

always@(posedge clk or negedge nPORESET)
  if(~nPORESET)
    sysqactive_q <= 1'b0;
  else if(sysq_gating)
    sysqactive_q <= sysqactive_nxt;

wire   sysq_is_pwrdwn = (sys_state_q == Q_STOPPED) | (sys_state_q == Q_EXIT);
assign sysqacceptn_o = ~sysq_is_pwrdwn;

assign sysqdeny_o = (sys_state_q == Q_DENIED) | (sys_state_q == Q_CONTINUE);
assign sysqactive_o = sysqactive_q;



generate if ((DBG != 0) | (CBAW != 0))
begin: gen_grb_qch_dbg

grb_sync u_dbgqreqn_sync(
  .SYNCRSTn   (nPORESET),
  .SYNCCLK    (clk),
  .SYNCDI     (dbgqreqn_i),
  .SYNCDO     (dbgqreqn_sync),
  .DFTSE      (dftse_i)
);

end
else begin: gen_grb_qch_no_dbg
  assign dbgqreqn_sync = 1'b0;
  wire unused = dbgqreqn_i;
end
endgenerate


wire dbgq_pwrdwn_req_sync = ~dbgqreqn_sync;

wire ext_apb_ongoing = dbg_etm_psel_i | dbg_cti_psel_i;

assign dbgq_gating = (dbg_state_nxt != dbg_state_q) |
                     (dbgqactive_nxt != dbgqactive_q);

always @(posedge clk or negedge nPORESET)
  if(~nPORESET)
    dbg_state_q <= Q_STOPPED;
  else if(cfg_dbg & dbgq_gating)
    dbg_state_q <= dbg_state_nxt;

always @(*)
  case(dbg_state_q)
    Q_STOPPED:
      dbg_state_nxt = dbgq_pwrdwn_req_sync ? Q_STOPPED : Q_EXIT;
    Q_EXIT:
      dbg_state_nxt = dbg_sys_ack ? Q_RUN : Q_EXIT;
    Q_RUN:
      dbg_state_nxt = dbgq_pwrdwn_req_sync ? Q_REQUEST : Q_RUN;
    Q_REQUEST:
      dbg_state_nxt = (dbgqactive_q | dbgqactive_nxt | ext_apb_ongoing) ? Q_DENIED : Q_STOPPED;
    Q_DENIED:
      dbg_state_nxt = dbgq_pwrdwn_req_sync ? Q_DENIED : Q_CONTINUE;
    Q_CONTINUE:
      dbg_state_nxt = Q_RUN;
    default:
      dbg_state_nxt = 3'bxxx;
  endcase

assign dbg_sys_ack = (sys_state_nxt == Q_RUN) |
                     (sys_state_q == Q_RUN);

assign dbgqactive_nxt = (cfg_fusa & fusaen_i) ? 1'b0 : (dbg_active_i | dbg_trcena_i | dbg_etm_pwrup_i | dap_pwrup_req_i);

always@(posedge clk or negedge nPORESET)
  if(~nPORESET)
    dbgqactive_q <= 1'b0;
  else if(cfg_dbg & dbgq_gating)
    dbgqactive_q <= dbgqactive_nxt;


wire  dbgq_is_pwrdwn = (dbg_state_q == Q_STOPPED) | (dbg_state_q == Q_EXIT);
assign dbgqacceptn_o = ~dbgq_is_pwrdwn;

assign dbgqdeny_o = (dbg_state_q == Q_DENIED) | (dbg_state_q == Q_CONTINUE);
assign dbgqactive_o = dbgqactive_q;



reg  dap_pwrup_ack_q;

wire dap_pwrup_ack_set =  dap_pwrup_req_i & dbgq_gating &
                           (dbg_state_nxt == Q_RUN) & (dbg_state_q != Q_CONTINUE);

wire dap_pwrup_ack_clr =  dap_pwrup_ack_q & ~dap_pwrup_req_i;

wire dap_pwrup_ack_en = dap_pwrup_ack_set | dap_pwrup_ack_clr;

always@(posedge clk or negedge nPORESET)
  if(~nPORESET)
    dap_pwrup_ack_q <= 1'b0;
  else if(cfg_dbg & dap_pwrup_ack_en)
    dap_pwrup_ack_q <= dap_pwrup_ack_set;

assign dap_pwrup_ack_o = dap_pwrup_ack_q;

wire   leg_pwrdwn_req = ~sleepholdreqn_i;

wire   core_idle_req  =  sysq_pwrdwn_req_sync & leg_pwrdwn_req;
assign core_idle_req_n_o = ~core_idle_req;




reg  leg_apb_power_up_q;

wire leg_apb_power_up_set = cfg_dbg & dap_pwrup_req_i;

wire leg_apb_power_up_clr = leg_apb_power_up_q & ~dap_pwrup_req_i &
                            ( ~dbg_etm_psel_i & ~dbg_cti_psel_i |
                               dbg_etm_psel_i & dbg_etm_penable_i |
                               dbg_cti_psel_i & dbg_cti_pready_i) ;

wire leg_apb_power_up_en = leg_apb_power_up_set | leg_apb_power_up_clr;

always @(posedge clk or negedge nPORESET)
  if(~nPORESET)
    leg_apb_power_up_q <= 1'b0;
  else if(cfg_dbg & leg_apb_power_up_en)
    leg_apb_power_up_q <= leg_apb_power_up_set;

wire qch_apb_power_up = ~dbgq_is_pwrdwn;

assign  dbg_apb_powered_up_o = qch_apb_power_up | leg_apb_power_up_q;




`ifdef ARM_GRB_VAL_MONITOR

   reg [8*15-1:0] sys_state_q_mon;
   always @*
        case(sys_state_q)
          Q_RUN      : sys_state_q_mon = "      Q_RUN";
          Q_REQUEST  : sys_state_q_mon = "  Q_REQUEST";
          Q_STOPPED  : sys_state_q_mon = "  Q_STOPPED";
          Q_EXIT     : sys_state_q_mon = "     Q_EXIT";
          Q_DENIED   : sys_state_q_mon = "   Q_DENIED";
          Q_CONTINUE : sys_state_q_mon = " Q_CONTINUE";
          default    : sys_state_q_mon = "        ???";
        endcase

   reg [8*15-1:0] sys_state_nxt_mon;
   always @*
        case(sys_state_nxt)
          Q_RUN      : sys_state_nxt_mon = "      Q_RUN";
          Q_REQUEST  : sys_state_nxt_mon = "  Q_REQUEST";
          Q_STOPPED  : sys_state_nxt_mon = "  Q_STOPPED";
          Q_EXIT     : sys_state_nxt_mon = "     Q_EXIT";
          Q_DENIED   : sys_state_nxt_mon = "   Q_DENIED";
          Q_CONTINUE : sys_state_nxt_mon = " Q_CONTINUE";
          default    : sys_state_nxt_mon = "        ???";
        endcase

   reg [8*15-1:0] dbg_state_q_mon;
   always @*
        case(dbg_state_q)
          Q_RUN      : dbg_state_q_mon = "      Q_RUN";
          Q_REQUEST  : dbg_state_q_mon = "  Q_REQUEST";
          Q_STOPPED  : dbg_state_q_mon = "  Q_STOPPED";
          Q_EXIT     : dbg_state_q_mon = "     Q_EXIT";
          Q_DENIED   : dbg_state_q_mon = "   Q_DENIED";
          Q_CONTINUE : dbg_state_q_mon = " Q_CONTINUE";
          default    : dbg_state_q_mon = "        ???";
        endcase

   reg [8*15-1:0] dbg_state_nxt_mon;
   always @*
        case(dbg_state_nxt)
          Q_RUN      : dbg_state_nxt_mon = "      Q_RUN";
          Q_REQUEST  : dbg_state_nxt_mon = "  Q_REQUEST";
          Q_STOPPED  : dbg_state_nxt_mon = "  Q_STOPPED";
          Q_EXIT     : dbg_state_nxt_mon = "     Q_EXIT";
          Q_DENIED   : dbg_state_nxt_mon = "   Q_DENIED";
          Q_CONTINUE : dbg_state_nxt_mon = " Q_CONTINUE";
          default    : dbg_state_nxt_mon = "        ???";
        endcase
`endif



generate
  if (FLOPPARITY) begin : g_flop_parity

    wire flop_parity_fault_0;
    wire flop_parity_fault_1;
    wire flop_parity_fault_2;
    wire flop_parity_fault_3;

    localparam FAULT_WIDTH_AUTO = 4;

    wire [FAULT_WIDTH_AUTO-1:0] flop_parity_fault_auto;




    if (1) begin : g_flop_parity_0

      localparam FLOP_GROUP_WIDTH = 1;

      localparam FLOP_GROUP_RESET_VALUE = {1'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_0, flop_group_0_next; wire flop_group_0_en;

      assign flop_group_0_next = dap_pwrup_ack_set;

      assign flop_group_0 = dap_pwrup_ack_q;

      assign flop_group_0_en = ((cfg_dbg & dap_pwrup_ack_en));

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_0(
                                 .clk(clk),
                                 .reset_n(nPORESET),
                                 .flop_enable_i(flop_group_0_en),
                                 .flop_i(flop_group_0),
                                 .flop_next_i(flop_group_0_next),
                                 .fault_o(flop_parity_fault_0));


    end



    if (1) begin : g_flop_parity_1

      localparam FLOP_GROUP_WIDTH = 3 +
                                    1;

      localparam FLOP_GROUP_RESET_VALUE = {Q_STOPPED,
                                           1'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_1, flop_group_1_next; wire flop_group_1_en;

      assign flop_group_1_next = {dbg_state_nxt,
                                  dbgqactive_nxt};

      assign flop_group_1 = {dbg_state_q,
                             dbgqactive_q};

      assign flop_group_1_en = ((cfg_dbg & dbgq_gating));

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_1(
                                 .clk(clk),
                                 .reset_n(nPORESET),
                                 .flop_enable_i(flop_group_1_en),
                                 .flop_i(flop_group_1),
                                 .flop_next_i(flop_group_1_next),
                                 .fault_o(flop_parity_fault_1));


    end



    if (1) begin : g_flop_parity_2

      localparam FLOP_GROUP_WIDTH = 1;

      localparam FLOP_GROUP_RESET_VALUE = {1'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_2, flop_group_2_next; wire flop_group_2_en;

      assign flop_group_2_next = leg_apb_power_up_set;

      assign flop_group_2 = leg_apb_power_up_q;

      assign flop_group_2_en = ((cfg_dbg & leg_apb_power_up_en));

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_2(
                                 .clk(clk),
                                 .reset_n(nPORESET),
                                 .flop_enable_i(flop_group_2_en),
                                 .flop_i(flop_group_2),
                                 .flop_next_i(flop_group_2_next),
                                 .fault_o(flop_parity_fault_2));


    end



    if (1) begin : g_flop_parity_3

      localparam FLOP_GROUP_WIDTH = 3 +
                                    1;

      localparam FLOP_GROUP_RESET_VALUE = {Q_STOPPED,
                                           1'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_3, flop_group_3_next; wire flop_group_3_en;

      assign flop_group_3_next = {sys_state_nxt,
                                  sysqactive_nxt};

      assign flop_group_3 = {sys_state_q,
                             sysqactive_q};

      assign flop_group_3_en = sysq_gating;

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_3(
                                 .clk(clk),
                                 .reset_n(nPORESET),
                                 .flop_enable_i(flop_group_3_en),
                                 .flop_i(flop_group_3),
                                 .flop_next_i(flop_group_3_next),
                                 .fault_o(flop_parity_fault_3));


    end



    assign flop_parity_fault_auto = {flop_parity_fault_0,
                                     flop_parity_fault_1,
                                     flop_parity_fault_2,
                                     flop_parity_fault_3};








    grb_flop_parity_fault_tree #(
      .WIDTH_AUTO                    (FAULT_WIDTH_AUTO),
      .WIDTH_MANUAL                  (0 /* Set to the width of the manual parity fault bus */),
      .REGISTER_OUTPUT               (1)
    ) u_flop_parity_fault_tree (
      .clk                           (clk),
      .reset_n                       (nPORESET),
      .flop_parity_fault_auto_i      (flop_parity_fault_auto),
      .flop_parity_fault_manual_i    (1'b0 /* Connect to manual parity fault bus */),
      .flop_parity_fault_o           (flop_parity_fault_o)
    );

  end else begin : g_no_flop_parity

    assign flop_parity_fault_o = 1'b0;

  end

endgenerate

endmodule
