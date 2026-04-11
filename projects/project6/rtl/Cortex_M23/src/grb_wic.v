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


module grb_wic
  #(parameter IRQDIS_0  =  32'h00000000,
    parameter IRQDIS_1  =  32'h00000000,
    parameter IRQDIS_2  =  32'h00000000,
    parameter IRQDIS_3  =  32'h00000000,
    parameter IRQDIS_4  =  32'h00000000,
    parameter IRQDIS_5  =  32'h00000000,
    parameter IRQDIS_6  =  32'h00000000,
    parameter IRQDIS_7  =  16'h0000,
    parameter WICLINES  =  8,
    parameter FLOPPARITY = 0)
   (input  wire         FCLK,
    input  wire         RESETn,

    input  wire [239:0] IRQ,
    input  wire         NMI,
    input  wire         RXEV,

    input  wire         WICLOAD,
    input  wire         WICCLEAR,
    input  wire [239:0] WICMASKISR,
    input  wire         WICMASKNMI,
    input  wire         WICMASKRXEV,
    input  wire         WICENREQ,
    input  wire         WICDSACKn,

    output wire         WAKEUP,
    output wire [241:0] WICSENSE,
    output wire [239:0] WICPENDISR,
    output wire         WICPENDNMI,
    output wire         WICPENDRXEV,
    output wire         WICDSREQn,
    output wire         WICENACK,

    output wire         WICDFE);

  reg         wic_actv_q;
  reg         wic_ds_req_q;
  reg         wic_en_ack_q;


  wire [239:0] wiclines_m = ~({240{1'b1}}<<(WICLINES-2));

  wire [239:0] cfg_irq_dis = {IRQDIS_7, IRQDIS_6, IRQDIS_5, IRQDIS_4,
                              IRQDIS_3, IRQDIS_2, IRQDIS_1, IRQDIS_0};

  wire [239:0] cfg_wiclines = wiclines_m & ~cfg_irq_dis;


  wire [239:0] masked_irq = cfg_wiclines & IRQ;


  wire                wic_ds_req_set = WICENREQ & WICDSREQn;
  wire                wic_ds_req_clr = ~WICDSREQn & ~WICENREQ;

  always @(posedge FCLK or negedge RESETn)
    if(~RESETn)
      wic_ds_req_q <= 1'b0;
    else if (wic_ds_req_set | wic_ds_req_clr)
      wic_ds_req_q <= wic_ds_req_set;

  wire                wic_en_ack_set = ~WICDSACKn & ~WICENACK;
  wire                wic_en_ack_clr = WICENACK & WICDSACKn;

  always @(posedge FCLK or negedge RESETn)
    if(~RESETn)
      wic_en_ack_q <= 1'b0;
    else if (wic_en_ack_set | wic_en_ack_clr)
      wic_en_ack_q <= wic_en_ack_set;


  wire       nxt_mask_nmi  = WICLOAD & WICMASKNMI;
  wire       nxt_mask_rxev = WICLOAD & WICMASKRXEV;
  reg        mask_nmi_q;
  reg        mask_rxev_q;

  wire       mask_en       = (WICCLEAR | WICLOAD);

  always @(posedge FCLK or negedge RESETn)
    begin
      if (~RESETn)
      begin
        mask_nmi_q  <= 1'b0;
        mask_rxev_q <= 1'b0;
      end
      else
      begin
        if (mask_en)
        begin
          mask_nmi_q  <= nxt_mask_nmi;
          mask_rxev_q <= nxt_mask_rxev;
        end
      end
    end


  reg  [239:0] mask_irq_q;


  wire [239:0] mask_irq_nxt = cfg_wiclines & {240{WICLOAD}} & WICMASKISR;

  always @(posedge FCLK or negedge RESETn)
    if (~RESETn)
      mask_irq_q <= 240'b0;
    else if (mask_en)
      mask_irq_q <= mask_irq_nxt;


  wire [241:0] wic_sense = {mask_irq_q, mask_nmi_q, mask_rxev_q};



  reg         pend_nmi_q;
  reg         pend_rxev_q;
  wire        nxt_pend_nmi    = ~WICCLEAR & (NMI  | pend_nmi_q);
  wire        nxt_pend_rxev   = ~WICCLEAR & (RXEV | pend_rxev_q);

  wire        pend_wr_en      = (WICLOAD | wic_actv_q);
  wire        pend_nmi_wr_en  = pend_wr_en & (WICCLEAR | NMI);
  wire        pend_rxev_wr_en = pend_wr_en & (WICCLEAR | RXEV);

  always @(posedge FCLK or negedge RESETn)
    begin
    if (~RESETn)
      begin
      pend_nmi_q  <= 1'b0;
      pend_rxev_q <= 1'b0;
      end
    else
      begin
      if (pend_nmi_wr_en)
          pend_nmi_q  <= nxt_pend_nmi;
      if (pend_rxev_wr_en)
          pend_rxev_q <= nxt_pend_rxev;
      end
    end


  reg [239:0] pend_irq_q;

  wire [239:0] pend_irq_nxt = cfg_wiclines & {240{~WICCLEAR}} & (masked_irq | pend_irq_q);

  wire pend_irq_wr_en = pend_wr_en & (WICCLEAR | (|masked_irq));


  always @(posedge FCLK or negedge RESETn)
    if (~RESETn)
      pend_irq_q <= 240'b0;
    else if (pend_irq_wr_en)
      pend_irq_q <= pend_irq_nxt;


  wire [241:0] wic_pend = {pend_irq_q, pend_nmi_q, pend_rxev_q};


  always @(posedge FCLK or negedge RESETn)
    if (~RESETn)
      wic_actv_q <= 1'b0;
    else if (WICLOAD | WICCLEAR)
      wic_actv_q <= WICLOAD;

  wire        wake_up = (|(wic_pend & wic_sense));

  assign      WAKEUP      = wake_up;
  assign      WICSENSE    = wic_sense;
  assign      WICPENDISR  = pend_irq_q | IRQ;
  assign      WICPENDNMI  = pend_nmi_q | NMI;
  assign      WICPENDRXEV = pend_rxev_q | RXEV;
  assign      WICDSREQn   = ~wic_ds_req_q;
  assign      WICENACK    = wic_en_ack_q;



generate
  if (FLOPPARITY) begin : g_flop_parity

    wire flop_parity_fault_0;
    wire flop_parity_fault_1;
    wire flop_parity_fault_2;
    wire flop_parity_fault_3;
    wire flop_parity_fault_4;
    wire flop_parity_fault_5;
    wire flop_parity_fault_6;

    localparam FAULT_WIDTH_AUTO = 7;

    wire [FAULT_WIDTH_AUTO-1:0] flop_parity_fault_auto;




    if (1) begin : g_flop_parity_0

      localparam FLOP_GROUP_WIDTH = 240 +
                                    1 +
                                    1;

      localparam FLOP_GROUP_RESET_VALUE = {240'b0,
                                           1'b0,
                                           1'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_0, flop_group_0_next; wire flop_group_0_en;

      assign flop_group_0_next = {mask_irq_nxt,
                                  nxt_mask_nmi,
                                  nxt_mask_rxev};

      assign flop_group_0 = {mask_irq_q,
                             mask_nmi_q,
                             mask_rxev_q};

      assign flop_group_0_en = mask_en;

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_0(
                                 .clk(FCLK),
                                 .reset_n(RESETn),
                                 .flop_enable_i(flop_group_0_en),
                                 .flop_i(flop_group_0),
                                 .flop_next_i(flop_group_0_next),
                                 .fault_o(flop_parity_fault_0));


    end



    if (1) begin : g_flop_parity_1

      localparam FLOP_GROUP_WIDTH = 240;

      localparam FLOP_GROUP_RESET_VALUE = {240'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_1, flop_group_1_next; wire flop_group_1_en;

      assign flop_group_1_next = pend_irq_nxt;

      assign flop_group_1 = pend_irq_q;

      assign flop_group_1_en = pend_irq_wr_en;

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_1(
                                 .clk(FCLK),
                                 .reset_n(RESETn),
                                 .flop_enable_i(flop_group_1_en),
                                 .flop_i(flop_group_1),
                                 .flop_next_i(flop_group_1_next),
                                 .fault_o(flop_parity_fault_1));


    end



    if (1) begin : g_flop_parity_2

      localparam FLOP_GROUP_WIDTH = 1;

      localparam FLOP_GROUP_RESET_VALUE = {1'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_2, flop_group_2_next; wire flop_group_2_en;

      assign flop_group_2_next = nxt_pend_nmi;

      assign flop_group_2 = pend_nmi_q;

      assign flop_group_2_en = pend_nmi_wr_en;

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_2(
                                 .clk(FCLK),
                                 .reset_n(RESETn),
                                 .flop_enable_i(flop_group_2_en),
                                 .flop_i(flop_group_2),
                                 .flop_next_i(flop_group_2_next),
                                 .fault_o(flop_parity_fault_2));


    end



    if (1) begin : g_flop_parity_3

      localparam FLOP_GROUP_WIDTH = 1;

      localparam FLOP_GROUP_RESET_VALUE = {1'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_3, flop_group_3_next; wire flop_group_3_en;

      assign flop_group_3_next = nxt_pend_rxev;

      assign flop_group_3 = pend_rxev_q;

      assign flop_group_3_en = pend_rxev_wr_en;

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_3(
                                 .clk(FCLK),
                                 .reset_n(RESETn),
                                 .flop_enable_i(flop_group_3_en),
                                 .flop_i(flop_group_3),
                                 .flop_next_i(flop_group_3_next),
                                 .fault_o(flop_parity_fault_3));


    end



    if (1) begin : g_flop_parity_4

      localparam FLOP_GROUP_WIDTH = 1;

      localparam FLOP_GROUP_RESET_VALUE = {1'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_4, flop_group_4_next; wire flop_group_4_en;

      assign flop_group_4_next = WICLOAD;

      assign flop_group_4 = wic_actv_q;

      assign flop_group_4_en = ((WICLOAD | WICCLEAR));

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_4(
                                 .clk(FCLK),
                                 .reset_n(RESETn),
                                 .flop_enable_i(flop_group_4_en),
                                 .flop_i(flop_group_4),
                                 .flop_next_i(flop_group_4_next),
                                 .fault_o(flop_parity_fault_4));


    end



    if (1) begin : g_flop_parity_5

      localparam FLOP_GROUP_WIDTH = 1;

      localparam FLOP_GROUP_RESET_VALUE = {1'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_5, flop_group_5_next; wire flop_group_5_en;

      assign flop_group_5_next = wic_ds_req_set;

      assign flop_group_5 = wic_ds_req_q;

      assign flop_group_5_en = ((wic_ds_req_set | wic_ds_req_clr));

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_5(
                                 .clk(FCLK),
                                 .reset_n(RESETn),
                                 .flop_enable_i(flop_group_5_en),
                                 .flop_i(flop_group_5),
                                 .flop_next_i(flop_group_5_next),
                                 .fault_o(flop_parity_fault_5));


    end



    if (1) begin : g_flop_parity_6

      localparam FLOP_GROUP_WIDTH = 1;

      localparam FLOP_GROUP_RESET_VALUE = {1'b0};

      wire [FLOP_GROUP_WIDTH-1:0] flop_group_6, flop_group_6_next; wire flop_group_6_en;

      assign flop_group_6_next = wic_en_ack_set;

      assign flop_group_6 = wic_en_ack_q;

      assign flop_group_6_en = ((wic_en_ack_set | wic_en_ack_clr));

      grb_flop_parity_fault_detection #(.WIDTH(FLOP_GROUP_WIDTH),
                                        .RESET_VALUE(FLOP_GROUP_RESET_VALUE),
                                        .RESET(1),
                                        .PARITY_CALC_WIDTH(8))     u_flop_parity_fault_detection_6(
                                 .clk(FCLK),
                                 .reset_n(RESETn),
                                 .flop_enable_i(flop_group_6_en),
                                 .flop_i(flop_group_6),
                                 .flop_next_i(flop_group_6_next),
                                 .fault_o(flop_parity_fault_6));


    end



    assign flop_parity_fault_auto = {flop_parity_fault_0,
                                     flop_parity_fault_1,
                                     flop_parity_fault_2,
                                     flop_parity_fault_3,
                                     flop_parity_fault_4,
                                     flop_parity_fault_5,
                                     flop_parity_fault_6};








    grb_flop_parity_fault_tree #(
      .WIDTH_AUTO                    (FAULT_WIDTH_AUTO),
      .WIDTH_MANUAL                  (0 /* Set to the width of the manual parity fault bus */),
      .REGISTER_OUTPUT               (1)
    ) u_flop_parity_fault_tree (
      .clk                           (FCLK),
      .reset_n                       (RESETn),
      .flop_parity_fault_auto_i      (flop_parity_fault_auto),
      .flop_parity_fault_manual_i    (1'b0 /* Connect to manual parity fault bus */),
      .flop_parity_fault_o           (WICDFE)
    );

  end else begin : g_no_flop_parity

    assign WICDFE = 1'b0;

  end

endgenerate

endmodule
