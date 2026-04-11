//####################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
// Author:        Chaitra Rangaswamaiah
// Project:       Uintah
//
// Description:   FIFO Top
//               
//               
//-------------------------------------------------------------------------------------------------------------------

module rp_fifo_top # (
  parameter SIMONLY        = 0, // 1 for behavior mem model, 0 for TSMC mem model
  parameter MEM_WIDTH      = 32,
  parameter MEM_LOG2DEPTH  = 14
 // parameter ADC_DATA       = 32
  )
(
  input                            clk, 
  input                            rst_n, 
   
  // GENERIC BUS PORTS
  host_if.slave                    host_if_slave,

  input                            din_dv,    
  input [MEM_WIDTH-1:0]             din_data, 

  // Microprocessor  
  output reg                       fifo_rdy,

  // Interrupt Generator
  output reg                       fifo_overrun,
  output reg                       fifo_underrun,

  //Test Mux ports
  output reg [7:0]                 test_data,
  input      [7:0]                 test_sel, 

  output                           fifo_err_parity
);

 localparam VERSION = 16'h0100;
  //signal declarations

 //Host I/F signals
   logic [MEM_LOG2DEPTH-1:0]        fifo_thresh; 
   logic [MEM_LOG2DEPTH:0]          fifo_level;
   logic [MEM_WIDTH-1:0]            ingress_cnt;
   logic [MEM_WIDTH-1:0]            egress_cnt;
   logic [MEM_WIDTH-1:0]            read_data;
  // logic                            mbist_en; 
  // logic [3:0]                      mbist_mode; 
  // logic                            mbist_pass_nfail; 
  // logic                            mbist_done; 
   logic [MEM_LOG2DEPTH:0]          err_addr;
   logic                            parity_odd_not_even;
   logic                            clear_err_addr;
   logic                            a_in1;
   logic                            a_in2;
   logic                            a_in3;
   logic                            a_in4;
  // logic                            a_in5;
   logic                            a_in6;
   logic                            a_in7;
   logic                            b_out1;
   logic                            b_out2;
   logic                            b_out3;
   logic                            b_out4;
  // logic                            b_out5;
   logic                            b_out6;
   logic                            b_out7;
 



rp_fifo_core #( .SIMONLY           (SIMONLY),
               .MEM_WIDTH          (MEM_WIDTH),
               .MEM_LOG2DEPTH      (MEM_LOG2DEPTH)
              )
               
 fifo_core_1(
               .parity_odd_not_even(parity_odd_not_even),
               .fifo_err_parity    (fifo_err_parity),
               .err_addr           (err_addr),
               .clear_err_addr     (clear_err_addr),
               .clk                (clk), 
               .rst_n              (rst_n), 
               .fifo_thresh        (fifo_thresh), // inputfrom host if
               .read_init          (b_out4),  //read enable
               .wr_en              (din_dv),      //write enable 
               .fifo_overrun       (fifo_overrun), 
               .fifo_underrun      (fifo_underrun),
               .read_data          (read_data),
               .write_data         (din_data), 
               .fifo_rdy           (fifo_rdy),
               .fifo_full          (a_in6),
               .fifo_empty         (a_in7),
               .fifo_level         (fifo_level),
               .capture            (b_out2),
               .clear              (b_out1),
               .resync             (b_out3),
               .ingress_cnt        (ingress_cnt),
               .egress_cnt         (egress_cnt), 
             //  .mbist_en           (mbist_en),
             //  .mbist_mode         (mbist_mode),
             //  .mbist_init         (b_out5),
             //  .mbist_pass_nfail   (mbist_pass_nfail),
             //  .mbist_done         (mbist_done),   
               .test_sel           (test_sel),
               .test_data          (test_data)
);


fifo_reg_block #(
               .ADDR_WIDTH                               (8),
               .DATA_WIDTH                               (32)
)
fifo_reg_block_0(
  // FIELD OUTPUT PORTS
               .clear_err_addr_reg_fifo_clear            (clear_err_addr),
               .clear_reg_fifo_clear                     (a_in1),
               .capture_reg_fifo_capture                 (a_in2),
               .resync_reg_fifo_resync                   (a_in3),
               .fifo_thresh_reg_fifo_thresh              (fifo_thresh),  
               .read_en_reg_fifo_read_init               (a_in4),
               .parity_odd_not_even_reg_fifo_cfg         (parity_odd_not_even),
 
  // FIELD INPUT PORTS
               .version_reg_fifo_version_ip              (VERSION),
               .fifo_level_reg_fifo_level_ip             (fifo_level),
               .err_addr_reg_fifo_status_ip              (err_addr),
               .fifo_full_reg_fifo_status_ip             (b_out6),
               .fifo_empty_reg_fifo_status_ip            (b_out7),
               .ingress_cnt_reg_fifo_ingress_cnt_ip      (ingress_cnt),
               .egress_cnt_reg_fifo_egress_cnt_ip        (egress_cnt),
               .def_fld_reg_fifo_read_data_ip            (read_data),
             //  .mbist_mode_reg_fifo_mbist_config_ip      (mbist_mode),
             //  .mbist_enable_reg_fifo_mbist_config_ip    (mbist_en),
             //  .mbist_init_reg_fifo_mbist_init_ip        (a_in5),
             //  .mbist_done_reg_fifo_mbist_status_ip      (mbist_done),
             //  .mbist_pass_nfail_reg_fifo_mbist_status_ip(mbist_pass_nfail),
         
  // GENERIC BUS PORTS
                .clock      (host_if_slave.hclk) , // Register Bus Clock
                .reset      (host_if_slave.hrst_n) , // Register Bus Reset
                .waddr      (host_if_slave.addr) , // Write Address-Bus
                .raddr      (host_if_slave.addr) , // Read Address-Bus
                .wdata      (host_if_slave.wdata) , // Write Data-Bus
                .rdata      (host_if_slave.rdata) , // Read Data-Bus
                .rstrobe    (host_if_slave.rstrobe) , // Read-Strobe
                .wstrobe    (host_if_slave.wstrobe) , // Write-Strobe
                .raddrerr   (host_if_slave.raddrerr) , // Read-Address-Error
                .waddrerr   (host_if_slave.waddrerr) , // Write-Address-Error
                .wack       (host_if_slave.wack) , // Write Acknowledge
                .rack       (host_if_slave.rack)// Read Acknowledge
   );

rp_synch_pulse	rp_synch_pulse1
(
.a_clk              (clk),
.a_rst_n            (rst_n),
.b_clk              (host_if_slave.hclk  ),
.b_rst_n            (host_if_slave.hrst_n),
.a_in               (a_in1),
.b_out              (b_out1)
);
rp_synch_pulse	rp_synch_pulse2
(
.a_clk              (clk),
.a_rst_n            (rst_n),
.b_clk              (host_if_slave.hclk  ),
.b_rst_n            (host_if_slave.hrst_n),
.a_in               (a_in2),
.b_out              (b_out2)
);
rp_synch_pulse	rp_synch_pulse3
(
.a_clk              (clk),
.a_rst_n            (rst_n),
.b_clk              (host_if_slave.hclk  ),
.b_rst_n            (host_if_slave.hrst_n),
.a_in               (a_in3),
.b_out              (b_out3)
);
rp_synch_pulse	rp_synch_pulse4
(
.a_clk              (clk),
.a_rst_n            (rst_n),
.b_clk              (host_if_slave.hclk  ),
.b_rst_n            (host_if_slave.hrst_n),
.a_in               (a_in4),
.b_out              (b_out4)
);
//rp_synch_pulse	rp_synch_pulse5
//(
//.a_clk              (clk),
//.a_rst_n            (rst_n),
//.b_clk              (host_if_slave.hclk  ),
//.b_rst_n            (host_if_slave.hrst_n),
//.a_in               (a_in5),
//.b_out              (b_out5)
//);
rp_synch_pulse	rp_synch_pulse6
(
.a_clk              (clk),
.a_rst_n            (rst_n),
.b_clk              (host_if_slave.hclk  ),
.b_rst_n            (host_if_slave.hrst_n),
.a_in               (a_in6),
.b_out              (b_out6)
);
rp_synch_pulse	rp_synch_pulse7
(
.a_clk              (clk),
.a_rst_n            (rst_n),
.b_clk              (host_if_slave.hclk  ),
.b_rst_n            (host_if_slave.hrst_n),
.a_in               (a_in7),
.b_out              (b_out7)
);


endmodule
