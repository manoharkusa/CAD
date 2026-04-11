/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : T-2022.03-SP5-1
// Date      : Wed Nov 15 11:41:15 2023
/////////////////////////////////////////////////////////////


module state_machine ( Op_code, rst, z, clk, inst_en, PC_inc, out, swap1, 
        memory, ALU_sel, Regs_Y, Regs_B, Regs_A, to_DR, mv_to_PC, swap2 );
  input [3:0] Op_code;
  output [2:0] ALU_sel;
  output [2:0] Regs_Y;
  output [2:0] Regs_B;
  output [2:0] Regs_A;
  output [1:0] to_DR;
  input rst, z, clk;
  output inst_en, PC_inc, out, swap1, memory, mv_to_PC, swap2;
  wire   n362, n363, n364, n365, n366, n367, n368, N39, N40, N41, N42, N43,
         N44, n155, n156, n157, n206, n207, n208, n232, n233, n234, n236, n237,
         n238, n240, n241, n242, n243, n244, n247, n249, n250, n252, n253,
         n254, n255, n256, n257, n258, n259, n260, n261, n262, n264, n266,
         n270, n271, n272, n273, n274, n275, n276, n277, n279, n280, n281,
         n282, n283, n284, n285, n286, n288, n289, n290, n291, n292, n293,
         n294, n295, n296, n297, n298, n299, n300, n301, n302, n303, n304,
         n305, n306, n307, n308, n309, n310, n311, n312, n313, n314, n315,
         n316, n317, n318, n319, n320, n321, n322, n323, n324, n325, n326,
         n327, n328, n329, n330, n331, n332, n333, n334, n335, n336, n337,
         n338, n339, n340, n341, n342, n343, n344, n345, n346, n347, n348,
         n349, n350, n351, n352, n353, n354, n355, n356, n357, n358, n359,
         n360, n361;
  wire   [5:0] Current_st;

  DFQD4BWP40P140HVT \Current_st_reg[0]  ( .D(N39), .CP(clk), .Q(Current_st[0])
         );
  DFQD4BWP40P140HVT \Current_st_reg[1]  ( .D(N40), .CP(clk), .Q(Current_st[1])
         );
  DFQD4BWP40P140HVT \Current_st_reg[3]  ( .D(N42), .CP(clk), .Q(Current_st[3])
         );
  DFQD4BWP40P140HVT \Current_st_reg[2]  ( .D(N41), .CP(clk), .Q(Current_st[2])
         );
  DFQD4BWP40P140HVT \Current_st_reg[5]  ( .D(N44), .CP(clk), .Q(Current_st[5])
         );
  DFQD4BWP40P140HVT \Current_st_reg[4]  ( .D(N43), .CP(clk), .Q(Current_st[4])
         );
  AN3D4BWP40P140HVT U202 ( .A1(n285), .A2(n236), .A3(n276), .Z(n275) );
  INVD3BWP40P140HVT U203 ( .I(n368), .ZN(n266) );
  INVD2BWP40P140HVT U204 ( .I(n281), .ZN(n241) );
  CKND2D1BWP40P140HVT U205 ( .A1(Current_st[2]), .A2(n344), .ZN(n290) );
  INVD2BWP40P140HVT U206 ( .I(Current_st[0]), .ZN(n344) );
  INVD15BWP40P140HVT U207 ( .I(n264), .ZN(inst_en) );
  INVD18BWP40P140HVT U208 ( .I(n286), .ZN(Regs_Y[2]) );
  AN2D1BWP40P140HVT U209 ( .A1(n332), .A2(n306), .Z(n236) );
  INVD1P5BWP40P140HVT U210 ( .I(n259), .ZN(n276) );
  INVD3BWP40P140HVT U211 ( .I(Current_st[2]), .ZN(n334) );
  INVD2BWP40P140HVT U212 ( .I(n254), .ZN(n250) );
  AN2D6BWP40P140HVT U213 ( .A1(n276), .A2(n355), .Z(n255) );
  INVD1BWP40P140HVT U214 ( .I(n313), .ZN(n233) );
  CKND0BWP40P140HVT U215 ( .I(n313), .ZN(n261) );
  ND4D2BWP40P140HVT U216 ( .A1(Current_st[5]), .A2(n361), .A3(n243), .A4(n283), 
        .ZN(n313) );
  CKND0BWP40P140HVT U217 ( .I(Current_st[3]), .ZN(n342) );
  CKND2D0BWP40P140HVT U218 ( .A1(n334), .A2(n344), .ZN(n316) );
  INVD1BWP40P140HVT U219 ( .I(n243), .ZN(n295) );
  NR2OPTPAD1BWP40P140HVT U220 ( .A1(Current_st[3]), .A2(Current_st[4]), .ZN(
        n243) );
  AN4D1BWP40P140HVT U221 ( .A1(Current_st[1]), .A2(Current_st[5]), .A3(n241), 
        .A4(n361), .Z(n259) );
  INVD1BWP40P140HVT U222 ( .I(n327), .ZN(n336) );
  CKND2D1BWP40P140HVT U223 ( .A1(Current_st[2]), .A2(Current_st[0]), .ZN(n327)
         );
  CKND2D1BWP40P140HVT U224 ( .A1(n341), .A2(n241), .ZN(n306) );
  OR3D1BWP40P140HVT U225 ( .A1(n334), .A2(n301), .A3(Current_st[0]), .Z(n308)
         );
  CKND2D1BWP40P140HVT U226 ( .A1(n289), .A2(n361), .ZN(n332) );
  INVD1BWP40P140HVT U227 ( .I(n208), .ZN(n305) );
  INVD15BWP40P140HVT U228 ( .I(n250), .ZN(to_DR[0]) );
  INVD9BWP40P140HVT U229 ( .I(n272), .ZN(Regs_A[2]) );
  OR2D1BWP40P140HVT U230 ( .A1(n331), .A2(n309), .Z(n272) );
  INVD2BWP40P140HVT U231 ( .I(n365), .ZN(n286) );
  CKND16BWP40P140HVT U232 ( .I(n244), .ZN(ALU_sel[2]) );
  CKND2D1BWP40P140HVT U233 ( .A1(n350), .A2(n285), .ZN(n367) );
  OR2D1BWP40P140HVT U234 ( .A1(n333), .A2(n237), .Z(n232) );
  INVD1BWP40P140HVT U235 ( .I(Current_st[1]), .ZN(n359) );
  INR3D2BWP40P140HVT U236 ( .A1(n288), .B1(n353), .B2(n303), .ZN(n285) );
  INVD12BWP40P140HVT U237 ( .I(n355), .ZN(to_DR[1]) );
  CKND2D1BWP40P140HVT U238 ( .A1(n329), .A2(n334), .ZN(n309) );
  CKND2D2BWP40P140HVT U239 ( .A1(n279), .A2(n357), .ZN(n256) );
  CKND2D1BWP40P140HVT U240 ( .A1(n360), .A2(n334), .ZN(n345) );
  INVD3BWP40P140HVT U241 ( .I(n362), .ZN(n264) );
  INVD2BWP40P140HVT U242 ( .I(n316), .ZN(n361) );
  INVD12BWP40P140HVT U243 ( .I(n256), .ZN(mv_to_PC) );
  NR2D1BWP40P140HVT U244 ( .A1(n326), .A2(n240), .ZN(n294) );
  ND2D1BWP40P140HVT U245 ( .A1(Current_st[1]), .A2(Current_st[3]), .ZN(n326)
         );
  CKND0BWP40P140HVT U246 ( .I(Regs_Y[1]), .ZN(n296) );
  OA21D0BWP40P140HVT U247 ( .A1(n291), .A2(n281), .B(Current_st[5]), .Z(n300)
         );
  BUFFD1BWP40P140HVT U248 ( .I(n295), .Z(n281) );
  OR3D0BWP40P140HVT U249 ( .A1(out), .A2(n353), .A3(n304), .Z(n320) );
  CKND12BWP40P140HVT U250 ( .I(n308), .ZN(out) );
  INVD15BWP40P140HVT U251 ( .I(n247), .ZN(Regs_Y[0]) );
  INVD2BWP40P140HVT U252 ( .I(n366), .ZN(n247) );
  INVD12BWP40P140HVT U253 ( .I(n232), .ZN(Regs_B[1]) );
  CKBD8BWP40P140HVT U254 ( .I(n257), .Z(swap2) );
  INVD12BWP40P140HVT U255 ( .I(n266), .ZN(Regs_A[1]) );
  INVD18BWP40P140HVT U256 ( .I(n262), .ZN(PC_inc) );
  CKND4BWP40P140HVT U257 ( .I(n363), .ZN(n262) );
  INVD18BWP40P140HVT U258 ( .I(n255), .ZN(memory) );
  INVD18BWP40P140HVT U259 ( .I(n277), .ZN(ALU_sel[1]) );
  DCCKND4BWP40P140HVT U260 ( .I(n364), .ZN(n277) );
  INVD9BWP40P140HVT U261 ( .I(n271), .ZN(Regs_A[0]) );
  CKND12BWP40P140HVT U262 ( .I(n270), .ZN(swap1) );
  INVD3BWP40P140HVT U263 ( .I(n367), .ZN(n234) );
  INVD18BWP40P140HVT U264 ( .I(n234), .ZN(Regs_B[0]) );
  CKND2D1BWP40P140HVT U265 ( .A1(Current_st[0]), .A2(n359), .ZN(n335) );
  OR3D1BWP40P140HVT U266 ( .A1(n354), .A2(n353), .A3(n254), .Z(n364) );
  OR2D0BWP40P140HVT U267 ( .A1(n347), .A2(Current_st[3]), .Z(n237) );
  OR3D0BWP40P140HVT U268 ( .A1(Current_st[1]), .A2(Current_st[5]), .A3(n290), 
        .Z(n333) );
  AN2D4BWP40P140HVT U269 ( .A1(n340), .A2(n339), .Z(n273) );
  DCCKBD4BWP40P140HVT U270 ( .I(n274), .Z(n238) );
  INVD18BWP40P140HVT U271 ( .I(n238), .ZN(ALU_sel[0]) );
  INR3D0BWP40P140HVT U272 ( .A1(n349), .B1(n352), .B2(n351), .ZN(n274) );
  INVD18BWP40P140HVT U273 ( .I(n275), .ZN(Regs_Y[1]) );
  AOI31D0BWP40P140HVT U274 ( .A1(n327), .A2(n280), .A3(n260), .B(n347), .ZN(
        n299) );
  OR2D1BWP40P140HVT U275 ( .A1(Current_st[5]), .A2(Current_st[4]), .Z(n240) );
  OR3D0BWP40P140HVT U276 ( .A1(Current_st[4]), .A2(Current_st[5]), .A3(n326), 
        .Z(n301) );
  INVD1BWP40P140HVT U277 ( .I(n335), .ZN(n329) );
  OR2D1BWP40P140HVT U278 ( .A1(n301), .A2(n242), .Z(n349) );
  OR3D1BWP40P140HVT U279 ( .A1(n316), .A2(n359), .A3(n317), .Z(n355) );
  OR2D0BWP40P140HVT U280 ( .A1(n344), .A2(Current_st[2]), .Z(n242) );
  IOA21D2BWP40P140HVT U281 ( .A1(n294), .A2(n361), .B(n349), .ZN(n353) );
  INVD2BWP40P140HVT U282 ( .I(n252), .ZN(n244) );
  NR3D0BWP40P140HVT U283 ( .A1(n328), .A2(n327), .A3(n326), .ZN(n257) );
  CKND0BWP40P140HVT U284 ( .I(Current_st[4]), .ZN(n347) );
  CKND0BWP40P140HVT U285 ( .I(n285), .ZN(n252) );
  INR2D1BWP40P140HVT U286 ( .A1(n356), .B1(n257), .ZN(n270) );
  ND2D0BWP40P140HVT U287 ( .A1(n336), .A2(n294), .ZN(n356) );
  IND2D1BWP40P140HVT U288 ( .A1(n295), .B1(n284), .ZN(n311) );
  CKND2D1BWP40P140HVT U289 ( .A1(n289), .A2(n336), .ZN(n323) );
  CKND2D0BWP40P140HVT U290 ( .A1(Current_st[4]), .A2(n346), .ZN(n328) );
  DEL025D1BWP40P140HVT U291 ( .I(n342), .Z(n280) );
  CKND2D1BWP40P140HVT U292 ( .A1(Current_st[2]), .A2(n329), .ZN(n330) );
  OR2D0BWP40P140HVT U293 ( .A1(n280), .A2(Current_st[4]), .Z(n249) );
  NR2D1BWP40P140HVT U294 ( .A1(n260), .A2(n249), .ZN(n366) );
  CKND0BWP40P140HVT U295 ( .I(n341), .ZN(n260) );
  INVD1BWP40P140HVT U296 ( .I(n323), .ZN(n303) );
  INVD1BWP40P140HVT U297 ( .I(n309), .ZN(n343) );
  OAI33D1BWP40P140HVT U298 ( .A1(n348), .A2(n347), .A3(n346), .B1(n345), .B2(
        n344), .B3(n283), .ZN(n365) );
  INVD2BWP40P140HVT U299 ( .I(Current_st[5]), .ZN(n346) );
  AN2D0BWP40P140HVT U300 ( .A1(n346), .A2(Current_st[1]), .Z(n284) );
  INVD1BWP40P140HVT U301 ( .I(n350), .ZN(n351) );
  ND2D0BWP40P140HVT U302 ( .A1(n336), .A2(n294), .ZN(n253) );
  AN3D1BWP40P140HVT U303 ( .A1(Current_st[5]), .A2(n241), .A3(n343), .Z(n254)
         );
  CKND0BWP40P140HVT U304 ( .I(n253), .ZN(n304) );
  CKND0BWP40P140HVT U305 ( .I(n288), .ZN(n352) );
  AOI211D0BWP40P140HVT U306 ( .A1(n261), .A2(n305), .B(n304), .C(n303), .ZN(
        n258) );
  AOI22D0BWP40P140HVT U307 ( .A1(n318), .A2(n283), .B1(n206), .B2(n261), .ZN(
        n319) );
  CKND0BWP40P140HVT U308 ( .I(n345), .ZN(n318) );
  IND4D0BWP40P140HVT U309 ( .A1(n320), .B1(n355), .B2(n323), .B3(n322), .ZN(
        n325) );
  CKND2D1BWP40P140HVT U310 ( .A1(n332), .A2(n306), .ZN(n354) );
  CKND2D1BWP40P140HVT U311 ( .A1(n338), .A2(n280), .ZN(n317) );
  INVD1BWP40P140HVT U312 ( .I(n311), .ZN(n289) );
  INVD1BWP40P140HVT U313 ( .I(n328), .ZN(n338) );
  INVD1BWP40P140HVT U314 ( .I(n330), .ZN(n357) );
  OR2D1BWP40P140HVT U315 ( .A1(n331), .A2(n330), .Z(n271) );
  INVD1BWP40P140HVT U316 ( .I(n290), .ZN(n291) );
  INVD1BWP40P140HVT U317 ( .I(n358), .ZN(n363) );
  OR3D1BWP40P140HVT U318 ( .A1(Current_st[5]), .A2(n342), .A3(Current_st[4]), 
        .Z(n331) );
  IND4D1BWP40P140HVT U319 ( .A1(Op_code[3]), .B1(Op_code[1]), .B2(Op_code[2]), 
        .B3(n156), .ZN(n208) );
  OAI32D1BWP40P140HVT U320 ( .A1(n207), .A2(n156), .A3(n155), .B1(n208), .B2(
        n157), .ZN(n206) );
  INVD1BWP40P140HVT U321 ( .I(Op_code[0]), .ZN(n156) );
  OR3D1BWP40P140HVT U322 ( .A1(Op_code[1]), .A2(Op_code[3]), .A3(z), .Z(n207)
         );
  INVD1BWP40P140HVT U323 ( .I(Op_code[2]), .ZN(n155) );
  INVD1BWP40P140HVT U324 ( .I(z), .ZN(n157) );
  INVD1BWP40P140HVT U325 ( .I(rst), .ZN(n324) );
  IOA21D0BWP40P140HVT U326 ( .A1(n310), .A2(n317), .B(n343), .ZN(n312) );
  INVD1BWP40P140HVT U327 ( .I(n333), .ZN(n341) );
  OR3D1BWP40P140HVT U328 ( .A1(n316), .A2(n331), .A3(Current_st[1]), .Z(n288)
         );
  OA21D0BWP40P140HVT U329 ( .A1(n313), .A2(n155), .B(n306), .Z(n307) );
  OA211D0BWP40P140HVT U330 ( .A1(n313), .A2(n156), .B(n312), .C(n350), .Z(n314) );
  AOI31D0BWP40P140HVT U331 ( .A1(n250), .A2(n355), .A3(n319), .B(rst), .ZN(N44) );
  ND4D0BWP40P140HVT U332 ( .A1(n258), .A2(n349), .A3(n250), .A4(n314), .ZN(
        n315) );
  ND4D0BWP40P140HVT U333 ( .A1(n253), .A2(n296), .A3(n250), .A4(n324), .ZN(
        n297) );
  AN2D0BWP40P140HVT U334 ( .A1(n335), .A2(n334), .Z(n337) );
  INVD1BWP40P140HVT U335 ( .I(n317), .ZN(n360) );
  AN3D1BWP40P140HVT U336 ( .A1(n361), .A2(n360), .A3(n283), .Z(n362) );
  IOA21D0BWP40P140HVT U337 ( .A1(n279), .A2(n343), .B(n332), .ZN(n368) );
  AOI31D0BWP40P140HVT U338 ( .A1(n357), .A2(Current_st[5]), .A3(n241), .B(n233), .ZN(n358) );
  INVD18BWP40P140HVT U339 ( .I(n273), .ZN(Regs_B[2]) );
  OR3D0BWP40P140HVT U340 ( .A1(n347), .A2(n333), .A3(Current_st[3]), .Z(n340)
         );
  INVD0BWP40P140HVT U341 ( .I(n279), .ZN(n310) );
  AO21D0BWP40P140HVT U342 ( .A1(n279), .A2(n334), .B(n293), .Z(n298) );
  NR2D0BWP40P140HVT U343 ( .A1(n295), .A2(Current_st[5]), .ZN(n279) );
  ND2D0BWP40P140HVT U344 ( .A1(n350), .A2(n332), .ZN(n321) );
  ND2D0BWP40P140HVT U345 ( .A1(n343), .A2(n280), .ZN(n348) );
  AN2D0BWP40P140HVT U346 ( .A1(n316), .A2(n280), .Z(n292) );
  CKMUX2D0BWP40P140HVT U347 ( .I0(Current_st[3]), .I1(n292), .S(Current_st[1]), 
        .Z(n293) );
  AOI33D0BWP40P140HVT U348 ( .A1(Current_st[3]), .A2(n338), .A3(n337), .B1(
        n336), .B2(Current_st[1]), .B3(n360), .ZN(n339) );
  INVD1BWP40P140HVT U349 ( .I(Current_st[1]), .ZN(n283) );
  IND2D0BWP40P140HVT U350 ( .A1(n295), .B1(n284), .ZN(n282) );
  OR4D1BWP40P140HVT U351 ( .A1(n300), .A2(n299), .A3(n298), .A4(n297), .Z(N43)
         );
  AO211D1BWP40P140HVT U352 ( .A1(Op_code[3]), .A2(n261), .B(n352), .C(n320), 
        .Z(n302) );
  CKAN2D1BWP40P140HVT U353 ( .A1(n302), .A2(n324), .Z(N42) );
  AOI31D1BWP40P140HVT U354 ( .A1(n258), .A2(n308), .A3(n307), .B(rst), .ZN(N41) );
  OR3D1BWP40P140HVT U355 ( .A1(n344), .A2(n282), .A3(Current_st[2]), .Z(n350)
         );
  CKAN2D1BWP40P140HVT U356 ( .A1(n315), .A2(n324), .Z(N39) );
  AOI31D1BWP40P140HVT U357 ( .A1(Op_code[1]), .A2(n208), .A3(n261), .B(n321), 
        .ZN(n322) );
  CKAN2D1BWP40P140HVT U358 ( .A1(n325), .A2(n324), .Z(N40) );
endmodule

