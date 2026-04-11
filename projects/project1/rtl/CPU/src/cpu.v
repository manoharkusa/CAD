///////////////////////////////////////////////////////////////////////
/////	Design of the 16-Bit CPU is shown below			//////
/////////////////////////////////////////////////////////////////////
//`/`include "/home/charles/dc/proj6/designs/alu.v"
//`include "/home/charles/dc/proj6/designs/basics.v"
//`include "/home/charles/dc/proj6/designs/counter.v"
//`include "/home/charles/dc/proj6/designs/datamemory.v"
//`include "/home/charles/dc/proj6/designs/instmemory.v"
//`include "/home/charles/dc/proj6/designs/logicunit.v"
//`include "/home/charles/dc/proj6/designs/muxb.v"
//`include "/home/charles/dc/proj6/designs/regA.v"
//`include "/home/charles/dc/proj6/designs/regB.v"
//`include "/home/charles/dc/proj6/designs/regC.v"
//`include "/home/charles/dc/proj6/designs/arithunit.v"
//`include "/home/charles/dc/proj6/designs/controller.v"
//`include "/home/charles/dc/proj6/designs/cpu.v"
//`include "/home/charles/dc/proj6/designs/encoder16_4.v"
//`include "/home/charles/dc/proj6/designs/instreg.v"
//`include "/home/charles/dc/proj6/designs/muxa.v"
//`include "/home/charles/dc/proj6/designs/pc.v"

module CPU(clk, en, we_IM, codein, immd, za, zb, eq, gt, lt);
input clk;
input en;
input we_IM;
input [15:0] codein;
input [11:0] immd;
output za;
output zb;
output eq;
output gt;
output lt;

reg za;
reg zb;
reg eq;
reg gt;
reg lt;

wire [11:0] curradd; wire [15:0] outIMd; wire [11:0] addressd; wire [3:0] opcodeD;
wire loadIRd, loadAd, loadBd, loadCd, moded, we_DMd, selAd, selBd, loadPCd, incPCd;
wire [11:0] execaddd; wire [15:0] dataAoutd; wire [15:0] dataBoutd; wire [31:0] outALUd;
wire [31:0] currdat; wire [31:0] outDMd; wire [31:0] dataCoutd;
wire zad, zbd, eqd, gtd, ltd;


instmem 	a1 (.clk(clk), .we_IM(we_IM), .dataIM(codein), .addIM(curradd), .outIM(outIMd));
insReg 		a2 (.clk(clk), .loadIR(loadIRd), .insin(outIMd), .address(addressd), .opcode(opcodeD));
controller 	a3 (.clk(clk), .en(en), .opcode(opcodeD), .loadA(loadAd), .loadB(loadBd), .loadC(loadCd), .loadIR(loadIRd), .loadPC(loadPCd), .incPC(incPCd), .mode(moded), .we_DM(we_DMd), .selA(selAd), .selB(selBd));
PC 		a4 (.clk(clk), .loadPC(loadPCd), .incPC(incPCd), .address(addressd), .execadd(execaddd));
muxB		a5 (.clk(clk), .in1(execaddd), .in2(immd), .sel(selBd), .outB(curradd));
regA 		a6 (.clk(clk), .loadA(loadAd), .dataAin(outDMd[15:0]), .dataAout(dataAoutd));
regB 		a7 (.clk(clk), .loadB(loadBd), .dataBin(outDMd[31:16]), .dataBout(dataBoutd));
regC		a8 (.clk(clk), .loadC(loadCd), .dataCin(currdat), .dataCout(dataCoutd));
datamem 	a9 (.clk(clk), .we_DM(we_DMd), .dataDM(dataCoutd), .addDM(addressd), .outDM(outDMd));
muxA		b1 (.clk(clk), .in1(outALUd), .in2({4'b0000,immd}), .sel(selAd), .outA(currdat));
ALU 		b2 (.a(dataAoutd), .b(dataBoutd), .opcode(opcodeD[2:0]), .mode(moded), .outALU(outALUd), .za(zad), .zb(zbd), .eq(eqd), .gt(gtd), .lt(ltd));

endmodule
