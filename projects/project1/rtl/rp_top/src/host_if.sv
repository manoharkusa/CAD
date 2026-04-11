//####################################################################################################################
//PROPRIETARY AND CONFIDENTIAL
//# THIS SOFTWARE IS THE SOLE PROPERTY AND COPYRIGHT (c) 2021 OF ROCKLEY PHOTONICS LTD. 
//# USE OR REPRODUCTION IN PART OR AS A WHOLE WITHOUT THE WRITTEN AGREEMENT OF ROCKLEY PHOTONICS LTD IS PROHIBITED. 
//# RPLTD NOTICE VERSION: 1.1.1 
//###################################################################################################################
//###################################################################################################################
// Author:        Puneeth Reddy
// Project:       Uintah  
//
// Description: 
//               
//               
//-------------------------------------------------------------------------------------------------------------------
interface host_if #(ADDR_WIDTH = 8, DATA_WIDTH = 32) (input hclk, input hrst_n);


    // Interface signals
    // ----------------------
        

logic   [ADDR_WIDTH-1:0]        addr   ;  // Read/Write Address-Bus
logic   [DATA_WIDTH-1:0]        wdata   ; // Write Data-Bus
logic   [DATA_WIDTH-1:0]        rdata   ; // Read Data-Bus
logic                           rstrobe ; // Read-Strobe
logic                           wstrobe ; // Write-Strobe
logic                           raddrerr; // Read-Address-Error
logic                           waddrerr; // Write-Address-Error
logic                           wack    ; // Write Acknowledge
logic                           rack    ; // Read Acknowledge   




    // Master modport
    modport master (
        input  hclk,                
        input  hrst_n,              
        input  rdata,             
        input  rack,  
        input  wack,    
        input  raddrerr,  
        input  waddrerr,        

        output addr,   
        output rstrobe,       
        output wstrobe,                           
        output wdata             
    );


    // Slave modport
    modport slave (
        input   hclk,                
        input   hrst_n,              
        output  rdata,             
        output  rack,  
        output  wack,    
        output  raddrerr,  
        output  waddrerr,        

        input   addr,   
        input   rstrobe,       
        input   wstrobe,                           
        input   wdata             
    );


endinterface : host_if



