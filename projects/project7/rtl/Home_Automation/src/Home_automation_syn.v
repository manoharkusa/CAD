/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : T-2022.03-SP5-1
// Date      : Sun Oct 22 20:50:48 2023
/////////////////////////////////////////////////////////////


module HomeAutomation ( rst, clk, frontSens, rearSens, WindowSens, fireSens, 
        tempSens, frontOut, rearOut, windowOut, buzz, cooler, heater );
  input [7:0] tempSens;
  input rst, clk, frontSens, rearSens, WindowSens, fireSens;
  output frontOut, rearOut, windowOut, buzz, cooler, heater;
  wire   N35, N36, N37, n331, n354, n376, n378, n379, n387, n391, n393, n402,
         n403, n404, n405, n406, n407, n408, n409, n410, n411, n412, n413,
         n414, n415, n416, n417, n418, n419, n420, n421, n426, n427, n428,
         n429, n430, n431, n432, n433, n434, n435, n436, n437, n438, n439,
         n440, n441, n442, n443, n444, n445, n446, n447, n448, n449, n450,
         n451, n452, n453, n454, n455, n456, n457, n458, n459, n460, n461,
         n462, n463, n464, n465, n466, n467, n468, n469, n470, n471, n472,
         n473, n474, n475, n476, n477, n478, n479, n480, n481, n482, n483,
         n485, n486, n487;
  wire   [2:0] state;

  DFQD2BWP40P140HVT \state_reg[0]  ( .D(N35), .CP(clk), .Q(state[0]) );
  DFQD2BWP40P140HVT \state_reg[2]  ( .D(N37), .CP(clk), .Q(state[2]) );
  DFQD1BWP40P140HVT \state_reg[1]  ( .D(N36), .CP(clk), .Q(state[1]) );
  ND2OPTPAD2BWP40P140HVT U232 ( .A1(n430), .A2(n436), .ZN(n462) );
  OAI32D2BWP40P140HVT U233 ( .A1(n387), .A2(n428), .A3(n429), .B1(n379), .B2(
        tempSens[6]), .ZN(n430) );
  AOI21OPTREPBD1BWP40P140HVT U234 ( .A1(n391), .A2(n437), .B(n433), .ZN(n429)
         );
  AOI31D2BWP40P140HVT U235 ( .A1(tempSens[1]), .A2(tempSens[2]), .A3(
        tempSens[0]), .B(tempSens[3]), .ZN(n433) );
  IOA21D0BWP40P140HVT U236 ( .A1(n482), .A2(n460), .B(n415), .ZN(n442) );
  IOA21D0BWP40P140HVT U237 ( .A1(rearSens), .A2(n460), .B(n415), .ZN(n439) );
  ND2OPTPAD6BWP40P140HVT U238 ( .A1(n414), .A2(n481), .ZN(n413) );
  AN2D1BWP40P140HVT U239 ( .A1(n409), .A2(n410), .Z(n434) );
  CKND2D1BWP40P140HVT U240 ( .A1(n480), .A2(n431), .ZN(n410) );
  INVD2BWP40P140HVT U241 ( .I(n462), .ZN(n480) );
  OR2D1BWP40P140HVT U242 ( .A1(n435), .A2(tempSens[6]), .Z(n402) );
  OR2D1BWP40P140HVT U243 ( .A1(n379), .A2(rst), .Z(n403) );
  OR2D1BWP40P140HVT U244 ( .A1(n456), .A2(state[2]), .Z(n404) );
  NR2D1BWP40P140HVT U245 ( .A1(n404), .A2(n455), .ZN(n405) );
  NR2D1BWP40P140HVT U246 ( .A1(n482), .A2(frontSens), .ZN(n406) );
  CKND2D1BWP40P140HVT U247 ( .A1(n417), .A2(n455), .ZN(n471) );
  CKND2D4BWP40P140HVT U248 ( .A1(n406), .A2(n421), .ZN(n414) );
  OAI21D2BWP40P140HVT U249 ( .A1(tempSens[2]), .A2(tempSens[1]), .B(
        tempSens[4]), .ZN(n393) );
  NR2D0BWP40P140HVT U250 ( .A1(n463), .A2(n462), .ZN(n407) );
  NR2D1BWP40P140HVT U251 ( .A1(n376), .A2(n420), .ZN(n408) );
  NR2D1BWP40P140HVT U252 ( .A1(n407), .A2(n408), .ZN(n470) );
  OAI222D0BWP40P140HVT U253 ( .A1(n472), .A2(n471), .B1(WindowSens), .B2(n470), 
        .C1(n469), .C2(n468), .ZN(n474) );
  NR2D1P5BWP40P140HVT U254 ( .A1(n418), .A2(n437), .ZN(n428) );
  INR2D4BWP40P140HVT U255 ( .A1(n487), .B1(tempSens[4]), .ZN(n418) );
  AOI221D2BWP40P140HVT U256 ( .A1(n416), .A2(n402), .B1(n435), .B2(tempSens[6]), .C(tempSens[7]), .ZN(n415) );
  CKND0BWP40P140HVT U257 ( .I(WindowSens), .ZN(n461) );
  NR2OPTPAD2BWP40P140HVT U258 ( .A1(n465), .A2(n480), .ZN(n421) );
  ND2D0BWP40P140HVT U259 ( .A1(n433), .A2(n432), .ZN(n409) );
  INVD1BWP40P140HVT U260 ( .I(n427), .ZN(n411) );
  OAI21D4BWP40P140HVT U261 ( .A1(n411), .A2(WindowSens), .B(n426), .ZN(n437)
         );
  CKND0BWP40P140HVT U262 ( .I(n458), .ZN(n412) );
  CKND0BWP40P140HVT U263 ( .I(tempSens[7]), .ZN(n436) );
  INVD0P7BWP40P140HVT U264 ( .I(n438), .ZN(n416) );
  ND2D1BWP40P140HVT U265 ( .A1(n331), .A2(n405), .ZN(n458) );
  CKND2D1BWP40P140HVT U266 ( .A1(state[2]), .A2(n419), .ZN(n378) );
  CKND1BWP40P140HVT U267 ( .I(n475), .ZN(n472) );
  CKND8BWP40P140HVT U268 ( .I(n403), .ZN(heater) );
  INVD6BWP40P140HVT U269 ( .I(n471), .ZN(frontOut) );
  INVD1P5BWP40P140HVT U270 ( .I(n415), .ZN(n465) );
  OA21D0BWP40P140HVT U271 ( .A1(n466), .A2(n465), .B(n464), .Z(n467) );
  CKND0BWP40P140HVT U272 ( .I(rst), .ZN(n331) );
  NR2D0BWP40P140HVT U273 ( .A1(rst), .A2(n404), .ZN(n417) );
  INVD1BWP40P140HVT U274 ( .I(state[0]), .ZN(n456) );
  INVD18BWP40P140HVT U275 ( .I(n413), .ZN(rearOut) );
  CKND1BWP40P140HVT U276 ( .I(n476), .ZN(n469) );
  CKND1BWP40P140HVT U277 ( .I(n479), .ZN(n466) );
  AOI31D0BWP40P140HVT U278 ( .A1(n458), .A2(n459), .A3(n450), .B(n420), .ZN(
        n451) );
  CKND2D1BWP40P140HVT U279 ( .A1(n473), .A2(n468), .ZN(n482) );
  CKND2D1BWP40P140HVT U280 ( .A1(n421), .A2(n460), .ZN(n483) );
  ND2D0BWP40P140HVT U281 ( .A1(tempSens[5]), .A2(tempSens[4]), .ZN(n391) );
  IAO21D0BWP40P140HVT U282 ( .A1(n480), .A2(n418), .B(n434), .ZN(n438) );
  ND2D0BWP40P140HVT U283 ( .A1(tempSens[4]), .A2(tempSens[5]), .ZN(n431) );
  OAI21D0BWP40P140HVT U284 ( .A1(tempSens[2]), .A2(tempSens[1]), .B(n435), 
        .ZN(n432) );
  AO211D0BWP40P140HVT U285 ( .A1(n486), .A2(n442), .B(n441), .C(heater), .Z(
        n447) );
  CKND6BWP40P140HVT U286 ( .I(n459), .ZN(windowOut) );
  INVD1BWP40P140HVT U287 ( .I(n449), .ZN(n481) );
  INVD1BWP40P140HVT U288 ( .I(n354), .ZN(n464) );
  CKND6BWP40P140HVT U289 ( .I(n458), .ZN(buzz) );
  INVD6BWP40P140HVT U290 ( .I(n378), .ZN(cooler) );
  IND2D1BWP40P140HVT U291 ( .A1(n426), .B1(n331), .ZN(n459) );
  CKND2D1BWP40P140HVT U292 ( .A1(n419), .A2(n457), .ZN(n449) );
  INVD1BWP40P140HVT U293 ( .I(n482), .ZN(n453) );
  CKND2D1BWP40P140HVT U294 ( .A1(n378), .A2(n376), .ZN(n354) );
  IND2D1BWP40P140HVT U295 ( .A1(n427), .B1(n455), .ZN(n379) );
  MOAI22D1BWP40P140HVT U296 ( .A1(n487), .A2(n393), .B1(n379), .B2(tempSens[6]), .ZN(n387) );
  AO22D0BWP40P140HVT U297 ( .A1(frontSens), .A2(n476), .B1(n481), .B2(n475), 
        .Z(n477) );
  INVD1BWP40P140HVT U298 ( .I(tempSens[5]), .ZN(n487) );
  NR3D0BWP40P140HVT U299 ( .A1(state[0]), .A2(n455), .A3(rst), .ZN(n419) );
  AO22D0BWP40P140HVT U300 ( .A1(fireSens), .A2(n481), .B1(n485), .B2(n482), 
        .Z(n445) );
  AO22D0BWP40P140HVT U301 ( .A1(n417), .A2(n442), .B1(n481), .B2(n439), .Z(
        n440) );
  INVD1BWP40P140HVT U302 ( .I(fireSens), .ZN(n468) );
  INVD1BWP40P140HVT U303 ( .I(rearSens), .ZN(n473) );
  INVD1BWP40P140HVT U304 ( .I(frontSens), .ZN(n460) );
  INVD1BWP40P140HVT U305 ( .I(state[2]), .ZN(n457) );
  CKND2D1BWP40P140HVT U306 ( .A1(state[2]), .A2(state[0]), .ZN(n427) );
  INVD1BWP40P140HVT U307 ( .I(state[1]), .ZN(n455) );
  IOA21D1BWP40P140HVT U308 ( .A1(heater), .A2(n480), .B(n467), .ZN(n476) );
  NR2D1BWP40P140HVT U309 ( .A1(frontSens), .A2(n444), .ZN(n446) );
  DEL025D1BWP40P140HVT U310 ( .I(n421), .Z(n420) );
  IOA21D0BWP40P140HVT U311 ( .A1(heater), .A2(n462), .B(n454), .ZN(N37) );
  AO211D0BWP40P140HVT U312 ( .A1(n447), .A2(n462), .B(n446), .C(n445), .Z(N36)
         );
  OA21D0BWP40P140HVT U313 ( .A1(n465), .A2(n403), .B(n378), .Z(n463) );
  IOA21D0BWP40P140HVT U314 ( .A1(n483), .A2(n461), .B(n468), .ZN(n475) );
  CKND0BWP40P140HVT U315 ( .I(n437), .ZN(n435) );
  AOI31D0BWP40P140HVT U316 ( .A1(n354), .A2(n461), .A3(n465), .B(n443), .ZN(
        n444) );
  OAI222D0BWP40P140HVT U317 ( .A1(n420), .A2(n464), .B1(n448), .B2(n403), .C1(
        n459), .C2(n461), .ZN(n452) );
  AN2D1BWP40P140HVT U318 ( .A1(n440), .A2(n461), .Z(n441) );
  AN2D1BWP40P140HVT U319 ( .A1(n465), .A2(n461), .Z(n448) );
  IOA21D0BWP40P140HVT U320 ( .A1(n412), .A2(n461), .B(n459), .ZN(n479) );
  CKND0BWP40P140HVT U321 ( .I(n459), .ZN(n486) );
  CKND0BWP40P140HVT U322 ( .I(n471), .ZN(n485) );
  OR3D1BWP40P140HVT U323 ( .A1(state[1]), .A2(n457), .A3(state[0]), .Z(n426)
         );
  OA21D1BWP40P140HVT U324 ( .A1(n354), .A2(heater), .B(n482), .Z(n443) );
  OA22D1BWP40P140HVT U325 ( .A1(n482), .A2(n471), .B1(n449), .B2(fireSens), 
        .Z(n450) );
  AOI31D1BWP40P140HVT U326 ( .A1(n460), .A2(n453), .A3(n452), .B(n451), .ZN(
        n454) );
  ND4D1BWP40P140HVT U327 ( .A1(n331), .A2(n457), .A3(n456), .A4(n455), .ZN(
        n376) );
  CKAN2D1BWP40P140HVT U328 ( .A1(n474), .A2(n473), .Z(n478) );
  AO211D1BWP40P140HVT U329 ( .A1(n480), .A2(n479), .B(n478), .C(n477), .Z(N35)
         );
endmodule

