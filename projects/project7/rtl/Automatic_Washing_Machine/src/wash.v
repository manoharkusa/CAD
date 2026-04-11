/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : T-2022.03-SP5-1
// Date      : Mon Nov  6 12:12:37 2023
/////////////////////////////////////////////////////////////


module washingmachine ( i_clk, i_lid, i_start, i_cancel, i_coin, i_mode_1, 
        i_mode_2, i_mode_3, o_idle, o_ready, o_soak, o_wash, o_rinse, o_spin, 
        o_coinreturn, o_waterinlet, o_done );
  input i_clk, i_lid, i_start, i_cancel, i_coin, i_mode_1, i_mode_2, i_mode_3;
  output o_idle, o_ready, o_soak, o_wash, o_rinse, o_spin, o_coinreturn,
         o_waterinlet, o_done;
  wire   soak_done, N12, N13, wash_done, N19, rinse_done, N20, spin_done, N21,
         n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n113, n114, n115, n116,
         n117, n118, n119, n120, n121, n122, n123, n124, n125, n126, n127,
         n128, n129, n130, n131, n132, n133, n134, n135, n136, n137, n138,
         n139, n140, n141, n142, n143, n144, n145, n146, n147, n148, n149,
         n150, n151, n152, n153, n155, n156, n157, n158, n159, n328, n1058,
         n1059, n1060, n1061, n1062, n1063, n1064, n1065, n1066, n1067, n1068,
         n1069, n1070, n1071, n1072, n1073, n1074, n1075, n1076, n1077, n1078,
         n1079, n1080, n1081, n1082, n1083, n1084, n1085, n1086, n1087, n1088,
         n1089, n1090, n1091, n1092, n1093, n1094, n1095, n1096, n1097, n1098,
         n1099, n1100, n1101, n1102, n1103, n1104, n1105, n1106, n1107, n1108,
         n1109, n1110, n1111, n1112, n1113, n1114, n1115, n1116, n1117, n1118,
         n1119, n1120, n1121, n1122, n1123, n1124, n1125, n1126, n1127, n1128,
         n1129, n1130, n1131, n1132, n1133, n1134, n1135, n1136, n1137, n1138,
         n1139, n1140, n1141, n1142, n1143, n1144, n1145, n1146, n1147, n1148,
         n1149, n1150, n1151, n1152, n1153, n1154, n1155, n1156, n1157, n1158,
         n1159, n1160, n1161, n1162, n1163, n1164, n1165, n1166, n1167, n1168,
         n1169, n1170, n1171, n1172, n1173, n1174, n1175, n1176, n1177, n1178,
         n1179, n1180, n1181, n1182, n1183, n1184, n1185, n1186, n1187, n1188,
         n1189, n1190, n1191, n1192, n1193, n1194, n1195, n1196, n1197, n1198,
         n1199, n1200, n1201, n1202, n1203, n1204, n1205, n1206, n1207, n1208,
         n1209, n1210, n1211, n1212, n1213, n1214, n1215, n1216, n1217, n1218,
         n1219, n1220, n1221, n1222, n1223, n1224, n1225, n1226, n1227, n1228,
         n1229, n1230, n1231, n1232, n1233, n1234, n1235, n1236, n1237, n1238,
         n1239, n1240, n1241, n1242, n1243, n1244, n1245, n1246, n1247, n1248,
         n1249, n1250, n1251, n1252, n1253, n1254, n1255, n1256, n1257, n1258,
         n1259, n1260, n1261, n1262, n1263, n1264, n1265, n1266, n1267, n1268,
         n1269, n1270, n1271, n1272, n1273, n1274, n1275, n1276, n1277, n1278,
         n1279, n1280, n1281, n1282, n1283, n1284, n1285, n1286, n1287, n1288,
         n1289, n1290, n1291, n1292, n1293, n1294, n1295, n1296, n1297, n1298,
         n1299, n1300, n1301, n1302, n1303, n1304, n1305, n1306, n1307, n1308,
         n1309, n1310, n1311, n1312, n1313, n1314, n1315, n1316, n1317, n1318,
         n1319, n1320, n1321, n1322, n1323, n1324, n1325, n1326, n1327, n1328,
         n1329, n1330, n1331, n1332, n1333, n1334, n1335, n1336, n1337, n1338,
         n1339, n1340, n1341, n1342, n1343, n1344, n1345, n1346, n1347, n1348,
         n1349, n1350, n1351, n1352, n1353, n1354, n1355, n1356, n1357, n1358,
         n1359, n1360, n1361, n1362, n1363, n1364, n1365, n1366, n1367, n1369;
  wire   [5:0] PS;
  wire   [14:0] soakcounter;
  wire   [14:0] washcounter;
  wire   [14:0] rinsecounter;
  wire   [14:0] spincounter;

  DFQD1BWP40P140HVT \rinsecounter_reg[1]  ( .D(n106), .CP(i_clk), .Q(
        rinsecounter[1]) );
  DFQD1BWP40P140HVT \soakcounter_reg[3]  ( .D(n111), .CP(i_clk), .Q(
        soakcounter[3]) );
  DFQD1BWP40P140HVT \soakcounter_reg[11]  ( .D(n119), .CP(i_clk), .Q(
        soakcounter[11]) );
  DFQD1BWP40P140HVT \soakcounter_reg[5]  ( .D(n113), .CP(i_clk), .Q(
        soakcounter[5]) );
  DFQD1BWP40P140HVT \soakcounter_reg[4]  ( .D(n112), .CP(i_clk), .Q(
        soakcounter[4]) );
  DFQD1BWP40P140HVT \soakcounter_reg[12]  ( .D(n120), .CP(i_clk), .Q(
        soakcounter[12]) );
  DFQD1BWP40P140HVT \soakcounter_reg[10]  ( .D(n118), .CP(i_clk), .Q(
        soakcounter[10]) );
  DFQD1BWP40P140HVT \soakcounter_reg[6]  ( .D(n114), .CP(i_clk), .Q(
        soakcounter[6]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[14]  ( .D(n108), .CP(i_clk), .Q(
        rinsecounter[14]) );
  DFQD1BWP40P140HVT \soakcounter_reg[7]  ( .D(n115), .CP(i_clk), .Q(
        soakcounter[7]) );
  DFQD1BWP40P140HVT \soakcounter_reg[9]  ( .D(n117), .CP(i_clk), .Q(
        soakcounter[9]) );
  DFQD1BWP40P140HVT \soakcounter_reg[13]  ( .D(n121), .CP(i_clk), .Q(
        soakcounter[13]) );
  DFQD1BWP40P140HVT \soakcounter_reg[2]  ( .D(n110), .CP(i_clk), .Q(
        soakcounter[2]) );
  DFQD1BWP40P140HVT \soakcounter_reg[1]  ( .D(n109), .CP(i_clk), .Q(
        soakcounter[1]) );
  DFQD1BWP40P140HVT \washcounter_reg[0]  ( .D(n137), .CP(i_clk), .Q(
        washcounter[0]) );
  DFQD1BWP40P140HVT \soakcounter_reg[8]  ( .D(n116), .CP(i_clk), .Q(
        soakcounter[8]) );
  DFQD1BWP40P140HVT \washcounter_reg[1]  ( .D(n136), .CP(i_clk), .Q(
        washcounter[1]) );
  DFQD1BWP40P140HVT \washcounter_reg[2]  ( .D(n135), .CP(i_clk), .Q(
        washcounter[2]) );
  DFQD1BWP40P140HVT \soakcounter_reg[14]  ( .D(n123), .CP(i_clk), .Q(
        soakcounter[14]) );
  DFQD1BWP40P140HVT \washcounter_reg[3]  ( .D(n134), .CP(i_clk), .Q(
        washcounter[3]) );
  DFQD1BWP40P140HVT \washcounter_reg[4]  ( .D(n133), .CP(i_clk), .Q(
        washcounter[4]) );
  DFQD1BWP40P140HVT \washcounter_reg[12]  ( .D(n125), .CP(i_clk), .Q(
        washcounter[12]) );
  DFQD1BWP40P140HVT \washcounter_reg[10]  ( .D(n127), .CP(i_clk), .Q(
        washcounter[10]) );
  DFQD1BWP40P140HVT \spincounter_reg[1]  ( .D(n155), .CP(i_clk), .Q(
        spincounter[1]) );
  DFQD4BWP40P140HVT \PS_reg[2]  ( .D(n141), .CP(i_clk), .Q(PS[2]) );
  DFQD4BWP40P140HVT \PS_reg[0]  ( .D(n159), .CP(i_clk), .Q(PS[0]) );
  DFQD4BWP40P140HVT \PS_reg[4]  ( .D(n139), .CP(i_clk), .Q(n328) );
  DFQD4BWP40P140HVT \PS_reg[5]  ( .D(n158), .CP(i_clk), .Q(PS[5]) );
  DFQD4BWP40P140HVT \PS_reg[1]  ( .D(n142), .CP(i_clk), .Q(PS[1]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[12]  ( .D(n95), .CP(i_clk), .Q(
        rinsecounter[12]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[2]  ( .D(n105), .CP(i_clk), .Q(
        rinsecounter[2]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[7]  ( .D(n100), .CP(i_clk), .Q(
        rinsecounter[7]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[3]  ( .D(n104), .CP(i_clk), .Q(
        rinsecounter[3]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[11]  ( .D(n96), .CP(i_clk), .Q(
        rinsecounter[11]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[10]  ( .D(n97), .CP(i_clk), .Q(
        rinsecounter[10]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[9]  ( .D(n98), .CP(i_clk), .Q(
        rinsecounter[9]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[8]  ( .D(n99), .CP(i_clk), .Q(
        rinsecounter[8]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[6]  ( .D(n101), .CP(i_clk), .Q(
        rinsecounter[6]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[5]  ( .D(n102), .CP(i_clk), .Q(
        rinsecounter[5]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[13]  ( .D(n94), .CP(i_clk), .Q(
        rinsecounter[13]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[4]  ( .D(n103), .CP(i_clk), .Q(
        rinsecounter[4]) );
  DFQD1BWP40P140HVT \spincounter_reg[14]  ( .D(n157), .CP(i_clk), .Q(
        spincounter[14]) );
  DFQD1BWP40P140HVT \spincounter_reg[12]  ( .D(n144), .CP(i_clk), .Q(
        spincounter[12]) );
  DFQD1BWP40P140HVT \washcounter_reg[11]  ( .D(n126), .CP(i_clk), .Q(
        washcounter[11]) );
  DFQD1BWP40P140HVT \spincounter_reg[3]  ( .D(n153), .CP(i_clk), .Q(
        spincounter[3]) );
  DFQD1BWP40P140HVT \washcounter_reg[8]  ( .D(n129), .CP(i_clk), .Q(
        washcounter[8]) );
  DFQD1BWP40P140HVT \washcounter_reg[7]  ( .D(n130), .CP(i_clk), .Q(
        washcounter[7]) );
  DFQD1BWP40P140HVT \spincounter_reg[2]  ( .D(n1369), .CP(i_clk), .Q(
        spincounter[2]) );
  DFQD1BWP40P140HVT \spincounter_reg[7]  ( .D(n149), .CP(i_clk), .Q(
        spincounter[7]) );
  DFQD1BWP40P140HVT \washcounter_reg[9]  ( .D(n128), .CP(i_clk), .Q(
        washcounter[9]) );
  DFQD1BWP40P140HVT \washcounter_reg[6]  ( .D(n131), .CP(i_clk), .Q(
        washcounter[6]) );
  DFQD1BWP40P140HVT \washcounter_reg[14]  ( .D(n138), .CP(i_clk), .Q(
        washcounter[14]) );
  DFQD1BWP40P140HVT \washcounter_reg[5]  ( .D(n132), .CP(i_clk), .Q(
        washcounter[5]) );
  DFQD1BWP40P140HVT \spincounter_reg[11]  ( .D(n145), .CP(i_clk), .Q(
        spincounter[11]) );
  DFQD1BWP40P140HVT \spincounter_reg[10]  ( .D(n146), .CP(i_clk), .Q(
        spincounter[10]) );
  DFQD1BWP40P140HVT \washcounter_reg[13]  ( .D(n124), .CP(i_clk), .Q(
        washcounter[13]) );
  DFQD1BWP40P140HVT \spincounter_reg[9]  ( .D(n147), .CP(i_clk), .Q(
        spincounter[9]) );
  DFQD1BWP40P140HVT \spincounter_reg[8]  ( .D(n148), .CP(i_clk), .Q(
        spincounter[8]) );
  DFQD1BWP40P140HVT \spincounter_reg[6]  ( .D(n150), .CP(i_clk), .Q(
        spincounter[6]) );
  DFQD1BWP40P140HVT \spincounter_reg[5]  ( .D(n151), .CP(i_clk), .Q(
        spincounter[5]) );
  DFQD1BWP40P140HVT \spincounter_reg[13]  ( .D(n143), .CP(i_clk), .Q(
        spincounter[13]) );
  DFQD1BWP40P140HVT \spincounter_reg[4]  ( .D(n152), .CP(i_clk), .Q(
        spincounter[4]) );
  DFQD4BWP40P140HVT \PS_reg[3]  ( .D(n140), .CP(i_clk), .Q(PS[3]) );
  DFQD1BWP40P140HVT \spincounter_reg[0]  ( .D(n156), .CP(i_clk), .Q(
        spincounter[0]) );
  DFQD1BWP40P140HVT \rinsecounter_reg[0]  ( .D(n107), .CP(i_clk), .Q(
        rinsecounter[0]) );
  DFQD1BWP40P140HVT \soakcounter_reg[0]  ( .D(n122), .CP(i_clk), .Q(
        soakcounter[0]) );
  LHQOPTDAD1BWP40P140HVT rinse_done_reg ( .E(N12), .D(N20), .Q(rinse_done) );
  LHQD1BWP40P140HVT soak_done_reg ( .E(N12), .D(N13), .Q(soak_done) );
  LHQD1BWP40P140HVT wash_done_reg ( .E(N12), .D(N19), .Q(wash_done) );
  LHQD1BWP40P140HVT spin_done_reg ( .E(N12), .D(N21), .Q(spin_done) );
  MOAI22D0BWP40P140HVT U761 ( .A1(n1315), .A2(n1268), .B1(n1269), .B2(n1267), 
        .ZN(n111) );
  NR3D1BWP40P140HVT U762 ( .A1(n1324), .A2(n1323), .A3(n1322), .ZN(N13) );
  AN2D6BWP40P140HVT U763 ( .A1(o_ready), .A2(i_cancel), .Z(o_coinreturn) );
  OAI21D1BWP40P140HVT U764 ( .A1(i_mode_2), .A2(n1353), .B(n1352), .ZN(n1354)
         );
  CKND3BWP40P140HVT U765 ( .I(n1310), .ZN(n1311) );
  ND2OPTIBD2BWP40P140HVT U766 ( .A1(n1194), .A2(n1102), .ZN(n1103) );
  OR2D1BWP40P140HVT U767 ( .A1(n1101), .A2(n1100), .Z(n1194) );
  ND2D1BWP40P140HVT U768 ( .A1(N12), .A2(n1185), .ZN(n1263) );
  CKND0BWP40P140HVT U769 ( .I(i_mode_3), .ZN(n1112) );
  ND2OPTIBD6BWP40P140HVT U770 ( .A1(n1173), .A2(n1177), .ZN(n1070) );
  CKND4BWP40P140HVT U771 ( .I(n1060), .ZN(n1071) );
  ND2D1BWP40P140HVT U772 ( .A1(o_soak), .A2(n1116), .ZN(n1187) );
  INR2D2BWP40P140HVT U773 ( .A1(o_spin), .B1(i_lid), .ZN(n1141) );
  CKND2D3BWP40P140HVT U774 ( .A1(n1078), .A2(n1058), .ZN(n1180) );
  IND3D6BWP40P140HVT U775 ( .A1(n1074), .B1(n1176), .B2(n1073), .ZN(n1075) );
  AN2D2BWP40P140HVT U776 ( .A1(n1179), .A2(PS[0]), .Z(n1073) );
  ND2OPTPAD1BWP40P140HVT U777 ( .A1(n1065), .A2(n328), .ZN(n1064) );
  NR2OPTPAD1BWP40P140HVT U778 ( .A1(n1076), .A2(n1077), .ZN(n1078) );
  CKND4BWP40P140HVT U779 ( .I(rinsecounter[0]), .ZN(n1059) );
  CKND2D4BWP40P140HVT U780 ( .A1(n1335), .A2(n1334), .ZN(n1336) );
  MOAI22D0BWP40P140HVT U781 ( .A1(rinsecounter[3]), .A2(n1327), .B1(
        rinsecounter[3]), .B2(n1326), .ZN(n1331) );
  XOR2UD1BWP40P140HVT U782 ( .A1(n1154), .A2(washcounter[14]), .Z(n1155) );
  ND2D1BWP40P140HVT U783 ( .A1(n1303), .A2(washcounter[13]), .ZN(n1154) );
  NR2D0P7BWP40P140HVT U784 ( .A1(n1150), .A2(n1149), .ZN(n126) );
  OAI21D0BWP40P140HVT U785 ( .A1(n1296), .A2(washcounter[11]), .B(n1151), .ZN(
        n1149) );
  ND2D0BWP40P140HVT U786 ( .A1(n1126), .A2(n1171), .ZN(n159) );
  ND2D0BWP40P140HVT U787 ( .A1(n1280), .A2(rinsecounter[11]), .ZN(n1106) );
  OAI21D0BWP40P140HVT U788 ( .A1(n1281), .A2(n1280), .B(rinsecounter[12]), 
        .ZN(n1282) );
  ND2D0BWP40P140HVT U789 ( .A1(n1284), .A2(rinsecounter[3]), .ZN(n1109) );
  CKND0BWP40P140HVT U790 ( .I(n1257), .ZN(n1193) );
  ND2D0BWP40P140HVT U791 ( .A1(n1285), .A2(n1107), .ZN(n1108) );
  OAI21D0BWP40P140HVT U792 ( .A1(n1285), .A2(n1284), .B(rinsecounter[4]), .ZN(
        n1286) );
  NR2D0P7BWP40P140HVT U793 ( .A1(n1200), .A2(n1245), .ZN(n1206) );
  ND2D0BWP40P140HVT U794 ( .A1(n1253), .A2(n1252), .ZN(n1255) );
  NR2D0BWP40P140HVT U795 ( .A1(n1290), .A2(n1289), .ZN(n1291) );
  AOI21D0P7BWP40P140HVT U796 ( .A1(n1269), .A2(n1260), .B(n1257), .ZN(n1268)
         );
  ND2D0BWP40P140HVT U797 ( .A1(n1281), .A2(n1104), .ZN(n1105) );
  ND2D0BWP40P140HVT U798 ( .A1(n1253), .A2(n1241), .ZN(n1243) );
  OAI21D0BWP40P140HVT U799 ( .A1(spincounter[12]), .A2(n1307), .B(n1157), .ZN(
        n1158) );
  NR2D0BWP40P140HVT U800 ( .A1(n1103), .A2(n1252), .ZN(n1246) );
  NR2D0BWP40P140HVT U801 ( .A1(n1103), .A2(n1241), .ZN(n1195) );
  ND2D1BWP40P140HVT U802 ( .A1(n1190), .A2(n1189), .ZN(n1257) );
  NR2D0BWP40P140HVT U803 ( .A1(n1168), .A2(n1169), .ZN(n1082) );
  OAI21D0BWP40P140HVT U804 ( .A1(soakcounter[13]), .A2(soakcounter[14]), .B(
        n1224), .ZN(n1225) );
  CKND0BWP40P140HVT U805 ( .I(n1308), .ZN(n1300) );
  OAI21D1BWP40P140HVT U806 ( .A1(i_coin), .A2(n1174), .B(n1120), .ZN(n1121) );
  NR2D0BWP40P140HVT U807 ( .A1(spincounter[9]), .A2(n1294), .ZN(n1295) );
  OAI21D0BWP40P140HVT U808 ( .A1(soakcounter[14]), .A2(n1223), .B(
        soakcounter[13]), .ZN(n1224) );
  AOI21D0BWP40P140HVT U809 ( .A1(n1099), .A2(n1098), .B(n1097), .ZN(n148) );
  NR2OPTIBD1BWP40P140HVT U810 ( .A1(n1119), .A2(n1118), .ZN(n1120) );
  AOI21D0BWP40P140HVT U811 ( .A1(n1147), .A2(n1146), .B(n1306), .ZN(n1148) );
  CKND0BWP40P140HVT U812 ( .I(n1227), .ZN(n1223) );
  ND2D0BWP40P140HVT U813 ( .A1(n1229), .A2(n1227), .ZN(n1228) );
  CKND0BWP40P140HVT U814 ( .I(n1187), .ZN(n1188) );
  AOI21D0BWP40P140HVT U815 ( .A1(n1272), .A2(spincounter[6]), .B(
        spincounter[7]), .ZN(n1274) );
  ND2D0BWP40P140HVT U816 ( .A1(rinsecounter[11]), .A2(n1104), .ZN(n1283) );
  NR2D0BWP40P140HVT U817 ( .A1(n1222), .A2(n1221), .ZN(n1227) );
  NR2OPTIBD1BWP40P140HVT U818 ( .A1(i_start), .A2(rinse_done), .ZN(n1102) );
  NR2OPTIBD1BWP40P140HVT U819 ( .A1(i_start), .A2(spin_done), .ZN(n1157) );
  ND2D0BWP40P140HVT U820 ( .A1(n1211), .A2(n1213), .ZN(n1212) );
  CKND0BWP40P140HVT U821 ( .I(soak_done), .ZN(n1116) );
  CKND0BWP40P140HVT U822 ( .I(n1232), .ZN(n1211) );
  ND2D0BWP40P140HVT U823 ( .A1(n1114), .A2(n1117), .ZN(n1115) );
  OAI21D0BWP40P140HVT U824 ( .A1(soakcounter[8]), .A2(soakcounter[9]), .B(
        n1208), .ZN(n1209) );
  ND2D0BWP40P140HVT U825 ( .A1(rinsecounter[9]), .A2(n1143), .ZN(n1288) );
  CKND0BWP40P140HVT U826 ( .I(n1196), .ZN(n1241) );
  CKND0BWP40P140HVT U827 ( .I(n1217), .ZN(n1207) );
  CKAN2D0BWP40P140HVT U828 ( .A1(o_wash), .A2(washcounter[0]), .Z(n1085) );
  ND2D0BWP40P140HVT U829 ( .A1(n1217), .A2(n1219), .ZN(n1218) );
  ND2D0BWP40P140HVT U830 ( .A1(n1161), .A2(o_wash), .ZN(n1163) );
  NR2D0P7BWP40P140HVT U831 ( .A1(n1096), .A2(n1095), .ZN(n1127) );
  ND2D0BWP40P140HVT U832 ( .A1(rinsecounter[3]), .A2(n1107), .ZN(n1287) );
  ND2D0BWP40P140HVT U833 ( .A1(n1342), .A2(n1341), .ZN(n1351) );
  ND2D0BWP40P140HVT U834 ( .A1(spincounter[7]), .A2(n1135), .ZN(n1095) );
  CKND0BWP40P140HVT U835 ( .I(n1266), .ZN(n1260) );
  CKND0BWP40P140HVT U836 ( .I(n1094), .ZN(n1088) );
  ND2D0BWP40P140HVT U837 ( .A1(n1344), .A2(n1343), .ZN(n1350) );
  NR2D0P7BWP40P140HVT U838 ( .A1(n1265), .A2(n1315), .ZN(n1266) );
  ND2D0BWP40P140HVT U839 ( .A1(n1358), .A2(n1357), .ZN(n1362) );
  CKND0BWP40P140HVT U840 ( .I(soakcounter[2]), .ZN(n1314) );
  ND2D0BWP40P140HVT U841 ( .A1(rinsecounter[2]), .A2(rinsecounter[0]), .ZN(
        n1327) );
  CKND0BWP40P140HVT U842 ( .I(rinsecounter[1]), .ZN(n1205) );
  CKND0BWP40P140HVT U843 ( .I(spincounter[3]), .ZN(n1360) );
  CKND0BWP40P140HVT U844 ( .I(soakcounter[11]), .ZN(n1213) );
  CKND0BWP40P140HVT U845 ( .I(soakcounter[7]), .ZN(n1216) );
  NR2OPTIBD6BWP40P140HVT U846 ( .A1(PS[1]), .A2(PS[5]), .ZN(n1065) );
  CKND0BWP40P140HVT U847 ( .I(rinsecounter[6]), .ZN(n1249) );
  CKND0BWP40P140HVT U848 ( .I(soakcounter[6]), .ZN(n1239) );
  CKND0BWP40P140HVT U849 ( .I(soakcounter[13]), .ZN(n1229) );
  CKND0BWP40P140HVT U850 ( .I(rinsecounter[7]), .ZN(n1242) );
  CKND0BWP40P140HVT U851 ( .I(soakcounter[4]), .ZN(n1259) );
  ND2D0BWP40P140HVT U852 ( .A1(rinsecounter[7]), .A2(rinsecounter[8]), .ZN(
        n1080) );
  ND2D0BWP40P140HVT U853 ( .A1(spincounter[5]), .A2(spincounter[6]), .ZN(n1096) );
  CKND0BWP40P140HVT U854 ( .I(spincounter[9]), .ZN(n1156) );
  CKND0BWP40P140HVT U855 ( .I(washcounter[4]), .ZN(n1338) );
  ND2D0BWP40P140HVT U856 ( .A1(spincounter[3]), .A2(spincounter[2]), .ZN(n1093) );
  CKND0BWP40P140HVT U857 ( .I(spincounter[11]), .ZN(n1309) );
  CKND0BWP40P140HVT U858 ( .I(rinsecounter[13]), .ZN(n1169) );
  CKND0BWP40P140HVT U859 ( .I(soakcounter[12]), .ZN(n1221) );
  CKND0BWP40P140HVT U860 ( .I(soakcounter[8]), .ZN(n1219) );
  NR2OPTIBD1BWP40P140HVT U861 ( .A1(n1155), .A2(n1302), .ZN(n138) );
  NR2OPTIBD1BWP40P140HVT U862 ( .A1(n1153), .A2(n1152), .ZN(n124) );
  OAI21D0P7BWP40P140HVT U863 ( .A1(n1303), .A2(washcounter[13]), .B(n1151), 
        .ZN(n1152) );
  AOI211D0BWP40P140HVT U864 ( .A1(n1305), .A2(n1304), .B(n1303), .C(n1302), 
        .ZN(n125) );
  INR2D1BWP40P140HVT U865 ( .A1(washcounter[12]), .B1(n1304), .ZN(n1303) );
  AOI211D0BWP40P140HVT U866 ( .A1(n1298), .A2(n1297), .B(n1296), .C(n1302), 
        .ZN(n127) );
  ND2D1BWP40P140HVT U867 ( .A1(n1296), .A2(washcounter[11]), .ZN(n1304) );
  NR2D0P7BWP40P140HVT U868 ( .A1(n1145), .A2(n1144), .ZN(n128) );
  OAI22D0BWP40P140HVT U869 ( .A1(n1181), .A2(n1174), .B1(n1077), .B2(n1178), 
        .ZN(n142) );
  INR2D1BWP40P140HVT U870 ( .A1(washcounter[10]), .B1(n1297), .ZN(n1296) );
  CKND0BWP40P140HVT U871 ( .I(n1297), .ZN(n1145) );
  NR2D0P7BWP40P140HVT U872 ( .A1(n1111), .A2(n1110), .ZN(n130) );
  OAI21D0BWP40P140HVT U873 ( .A1(n1275), .A2(washcounter[9]), .B(n1151), .ZN(
        n1144) );
  NR2D0P7BWP40P140HVT U874 ( .A1(n1084), .A2(n1100), .ZN(n108) );
  ND2D1BWP40P140HVT U875 ( .A1(n1275), .A2(washcounter[9]), .ZN(n1297) );
  OAI22D0BWP40P140HVT U876 ( .A1(n1230), .A2(n1229), .B1(n1263), .B2(n1228), 
        .ZN(n121) );
  OAI22D0BWP40P140HVT U877 ( .A1(n1206), .A2(n1205), .B1(n1103), .B2(n1204), 
        .ZN(n106) );
  OAI22D0BWP40P140HVT U878 ( .A1(n1270), .A2(n1314), .B1(n1251), .B2(n1263), 
        .ZN(n110) );
  OAI22D0BWP40P140HVT U879 ( .A1(n1220), .A2(n1210), .B1(n1263), .B2(n1209), 
        .ZN(n117) );
  OAI22D0BWP40P140HVT U880 ( .A1(n1220), .A2(n1219), .B1(n1263), .B2(n1218), 
        .ZN(n116) );
  OAI22D0BWP40P140HVT U881 ( .A1(n1268), .A2(n1259), .B1(n1263), .B2(n1258), 
        .ZN(n112) );
  ND2D0P7BWP40P140HVT U882 ( .A1(n1109), .A2(n1108), .ZN(n104) );
  OAI22D0BWP40P140HVT U883 ( .A1(n1240), .A2(n1216), .B1(n1263), .B2(n1215), 
        .ZN(n115) );
  OAI22D0BWP40P140HVT U884 ( .A1(n1244), .A2(n1199), .B1(n1198), .B2(n1103), 
        .ZN(n99) );
  OAI22D0BWP40P140HVT U885 ( .A1(n1193), .A2(n1221), .B1(n1263), .B2(n1192), 
        .ZN(n120) );
  OAI22D0BWP40P140HVT U886 ( .A1(n1240), .A2(n1239), .B1(n1263), .B2(n1238), 
        .ZN(n114) );
  OAI22D0BWP40P140HVT U887 ( .A1(n1235), .A2(n1234), .B1(n1263), .B2(n1233), 
        .ZN(n118) );
  OAI22D0BWP40P140HVT U888 ( .A1(n1206), .A2(n1203), .B1(n1103), .B2(n1202), 
        .ZN(n105) );
  OAI22D0BWP40P140HVT U889 ( .A1(n1268), .A2(n1264), .B1(n1263), .B2(n1262), 
        .ZN(n113) );
  OAI22D0BWP40P140HVT U890 ( .A1(n1256), .A2(n1249), .B1(n1248), .B2(n1103), 
        .ZN(n101) );
  OAI22D0BWP40P140HVT U891 ( .A1(n1235), .A2(n1213), .B1(n1263), .B2(n1212), 
        .ZN(n119) );
  OAI22D0BWP40P140HVT U892 ( .A1(n1230), .A2(n1226), .B1(n1263), .B2(n1225), 
        .ZN(n123) );
  ND2D0P7BWP40P140HVT U893 ( .A1(n1106), .A2(n1105), .ZN(n96) );
  XOR2UD0BWP40P140HVT U894 ( .A1(n1083), .A2(rinsecounter[14]), .Z(n1084) );
  AOI21D0P7BWP40P140HVT U895 ( .A1(spincounter[12]), .A2(n1307), .B(n1158), 
        .ZN(n144) );
  INR2D1BWP40P140HVT U896 ( .A1(washcounter[8]), .B1(n1276), .ZN(n1275) );
  AOI21D0P7BWP40P140HVT U897 ( .A1(n1269), .A2(n1232), .B(n1257), .ZN(n1235)
         );
  NR2D0P7BWP40P140HVT U898 ( .A1(n1246), .A2(n1245), .ZN(n1256) );
  AOI21D0P7BWP40P140HVT U899 ( .A1(n1269), .A2(n1207), .B(n1257), .ZN(n1220)
         );
  NR2D0P7BWP40P140HVT U900 ( .A1(n1195), .A2(n1245), .ZN(n1244) );
  AOI21D0P7BWP40P140HVT U901 ( .A1(n1269), .A2(n1236), .B(n1257), .ZN(n1240)
         );
  AOI21D0P7BWP40P140HVT U902 ( .A1(n1269), .A2(n1223), .B(n1257), .ZN(n1230)
         );
  ND2D1BWP40P140HVT U903 ( .A1(n1182), .A2(washcounter[7]), .ZN(n1276) );
  OAI22D0BWP40P140HVT U904 ( .A1(n1103), .A2(n1170), .B1(n1194), .B2(n1169), 
        .ZN(n94) );
  ND2D0BWP40P140HVT U905 ( .A1(n1101), .A2(n1082), .ZN(n1083) );
  OAI21D0BWP40P140HVT U906 ( .A1(n1182), .A2(washcounter[7]), .B(n1151), .ZN(
        n1110) );
  NR2D0P7BWP40P140HVT U907 ( .A1(n1092), .A2(n1091), .ZN(n132) );
  OAI21D0P7BWP40P140HVT U908 ( .A1(n1103), .A2(n1143), .B(n1194), .ZN(n1290)
         );
  NR2D0P7BWP40P140HVT U909 ( .A1(rinsecounter[9]), .A2(n1103), .ZN(n1289) );
  OAI21D0P7BWP40P140HVT U910 ( .A1(n1103), .A2(n1107), .B(n1194), .ZN(n1284)
         );
  NR2D0P7BWP40P140HVT U911 ( .A1(n1103), .A2(rinsecounter[3]), .ZN(n1285) );
  NR2D0P7BWP40P140HVT U912 ( .A1(n1103), .A2(rinsecounter[11]), .ZN(n1281) );
  OAI21D0P7BWP40P140HVT U913 ( .A1(n1103), .A2(n1104), .B(n1194), .ZN(n1280)
         );
  INVD0P7BWP40P140HVT U914 ( .I(n1103), .ZN(n1253) );
  XOR2UD0BWP40P140HVT U915 ( .A1(n1168), .A2(rinsecounter[13]), .Z(n1170) );
  AOI21D0P7BWP40P140HVT U916 ( .A1(spincounter[4]), .A2(n1278), .B(n1134), 
        .ZN(n152) );
  INR2D1BWP40P140HVT U917 ( .A1(washcounter[6]), .B1(n1183), .ZN(n1182) );
  AN2D0BWP40P140HVT U918 ( .A1(n1279), .A2(n1148), .Z(n1369) );
  NR2D0P7BWP40P140HVT U919 ( .A1(n1087), .A2(n1086), .ZN(n134) );
  NR2D0BWP40P140HVT U920 ( .A1(spincounter[10]), .A2(n1299), .ZN(n1301) );
  INVD0P7BWP40P140HVT U921 ( .I(n1081), .ZN(n1168) );
  NR2D0P7BWP40P140HVT U922 ( .A1(n1090), .A2(n1089), .ZN(n155) );
  NR2D0P7BWP40P140HVT U923 ( .A1(n1142), .A2(n1306), .ZN(n156) );
  AOI21D0P7BWP40P140HVT U924 ( .A1(spincounter[14]), .A2(n1132), .B(n1131), 
        .ZN(n157) );
  NR2D0P7BWP40P140HVT U925 ( .A1(n1138), .A2(n1306), .ZN(n150) );
  ND2D1BWP40P140HVT U926 ( .A1(i_lid), .A2(n1188), .ZN(n1189) );
  NR2D0P7BWP40P140HVT U927 ( .A1(n1140), .A2(n1306), .ZN(n143) );
  NR2D0P7BWP40P140HVT U928 ( .A1(n1136), .A2(n1306), .ZN(n151) );
  ND2D0BWP40P140HVT U929 ( .A1(n1157), .A2(n1293), .ZN(n1097) );
  INR2D0BWP40P140HVT U930 ( .A1(rinsecounter[12]), .B1(n1283), .ZN(n1081) );
  CKND0BWP40P140HVT U931 ( .I(n1293), .ZN(n1294) );
  NR2OPTIBD1BWP40P140HVT U932 ( .A1(i_lid), .A2(n1187), .ZN(n1185) );
  ND2D0BWP40P140HVT U933 ( .A1(n1147), .A2(n1157), .ZN(n1090) );
  OAI21D0BWP40P140HVT U934 ( .A1(spincounter[14]), .A2(n1132), .B(n1157), .ZN(
        n1131) );
  XNR2UD0BWP40P140HVT U935 ( .A1(n1272), .A2(spincounter[6]), .ZN(n1138) );
  XOR2UD0BWP40P140HVT U936 ( .A1(n1222), .A2(soakcounter[12]), .Z(n1192) );
  OR2D1BWP40P140HVT U937 ( .A1(i_start), .A2(wash_done), .Z(n1302) );
  ND2D0P7BWP40P140HVT U938 ( .A1(n1211), .A2(soakcounter[11]), .ZN(n1222) );
  XOR2UD0BWP40P140HVT U939 ( .A1(n1139), .A2(spincounter[13]), .Z(n1140) );
  CKND0BWP40P140HVT U940 ( .I(n1165), .ZN(n1160) );
  INR2D1BWP40P140HVT U941 ( .A1(washcounter[2]), .B1(n1165), .ZN(n1164) );
  XOR2UD0BWP40P140HVT U942 ( .A1(n1137), .A2(spincounter[5]), .Z(n1136) );
  INR2D0BWP40P140HVT U943 ( .A1(spincounter[13]), .B1(n1139), .ZN(n1132) );
  INVD0P7BWP40P140HVT U944 ( .I(n1147), .ZN(n1133) );
  NR2D0P7BWP40P140HVT U945 ( .A1(i_start), .A2(soak_done), .ZN(n1186) );
  CKND0BWP40P140HVT U946 ( .I(n1114), .ZN(n1113) );
  ND2D1BWP40P140HVT U947 ( .A1(n1162), .A2(washcounter[1]), .ZN(n1165) );
  NR2D0BWP40P140HVT U948 ( .A1(n1162), .A2(washcounter[1]), .ZN(n1159) );
  ND2D0P7BWP40P140HVT U949 ( .A1(n1141), .A2(n1130), .ZN(n1139) );
  ND2D0BWP40P140HVT U950 ( .A1(n1232), .A2(n1231), .ZN(n1233) );
  NR3D1BWP40P140HVT U951 ( .A1(n1356), .A2(n1355), .A3(n1354), .ZN(N19) );
  NR2D0P7BWP40P140HVT U952 ( .A1(o_ready), .A2(o_idle), .ZN(n1114) );
  NR2D0P7BWP40P140HVT U953 ( .A1(n1196), .A2(n1080), .ZN(n1143) );
  INR2D2BWP40P140HVT U954 ( .A1(n1085), .B1(i_lid), .ZN(n1162) );
  ND2D0P7BWP40P140HVT U955 ( .A1(n1231), .A2(soakcounter[10]), .ZN(n1232) );
  CKND0BWP40P140HVT U956 ( .I(n1127), .ZN(n1129) );
  ND2D0P7BWP40P140HVT U957 ( .A1(n1252), .A2(n1079), .ZN(n1196) );
  AN3D0BWP40P140HVT U958 ( .A1(n1217), .A2(soakcounter[8]), .A3(soakcounter[9]), .Z(n1231) );
  NR2D0BWP40P140HVT U959 ( .A1(n1266), .A2(n1265), .ZN(n1267) );
  ND2D0P7BWP40P140HVT U960 ( .A1(n1266), .A2(n1191), .ZN(n1236) );
  ND3D0P7BWP40P140HVT U961 ( .A1(n1331), .A2(n1330), .A3(n1329), .ZN(n1332) );
  ND2OPTPAD8BWP40P140HVT U962 ( .A1(n1065), .A2(n1172), .ZN(n1074) );
  INR2D0BWP40P140HVT U963 ( .A1(rinsecounter[1]), .B1(n1327), .ZN(n1107) );
  NR2OPTPAD4BWP40P140HVT U964 ( .A1(n1175), .A2(n1061), .ZN(n1062) );
  AOI21D0BWP40P140HVT U965 ( .A1(washcounter[3]), .A2(washcounter[4]), .B(
        n1340), .ZN(n1341) );
  INR2D0BWP40P140HVT U966 ( .A1(soakcounter[5]), .B1(n1259), .ZN(n1191) );
  INVD0P7BWP40P140HVT U967 ( .I(soakcounter[3]), .ZN(n1315) );
  NR2D0BWP40P140HVT U968 ( .A1(rinsecounter[2]), .A2(rinsecounter[0]), .ZN(
        n1326) );
  CKND0BWP40P140HVT U969 ( .I(washcounter[0]), .ZN(n1345) );
  ND2D0P7BWP40P140HVT U970 ( .A1(spincounter[1]), .A2(spincounter[0]), .ZN(
        n1094) );
  CKND0BWP40P140HVT U971 ( .I(washcounter[3]), .ZN(n1339) );
  CKND0BWP40P140HVT U972 ( .I(washcounter[1]), .ZN(n1347) );
  NR2D0BWP40P140HVT U973 ( .A1(washcounter[1]), .A2(washcounter[4]), .ZN(n1340) );
  INVD0P7BWP40P140HVT U974 ( .I(rinsecounter[5]), .ZN(n1254) );
  INVD0P7BWP40P140HVT U975 ( .I(i_lid), .ZN(n1161) );
  CKND2D4BWP40P140HVT U976 ( .A1(n1068), .A2(n1179), .ZN(n1076) );
  NR2OPTIBD4BWP40P140HVT U977 ( .A1(PS[3]), .A2(PS[0]), .ZN(n1068) );
  NR2OPTIBD1BWP40P140HVT U978 ( .A1(o_waterinlet), .A2(n1113), .ZN(n1125) );
  ND2D1BWP40P140HVT U979 ( .A1(n1141), .A2(n1135), .ZN(n1137) );
  INR2D1BWP40P140HVT U980 ( .A1(spincounter[5]), .B1(n1137), .ZN(n1272) );
  INVD1BWP40P140HVT U981 ( .I(n1157), .ZN(n1306) );
  ND4D0BWP40P140HVT U982 ( .A1(spincounter[12]), .A2(spincounter[11]), .A3(
        spincounter[10]), .A4(spincounter[9]), .ZN(n1128) );
  NR2OPTIBD1BWP40P140HVT U983 ( .A1(i_start), .A2(i_cancel), .ZN(n1171) );
  INVD1BWP40P140HVT U984 ( .I(soakcounter[0]), .ZN(n1313) );
  AOI21D1BWP40P140HVT U985 ( .A1(n1269), .A2(n1313), .B(n1257), .ZN(n1270) );
  INVD1BWP40P140HVT U986 ( .I(n1263), .ZN(n1269) );
  INR3D0BWP40P140HVT U987 ( .A1(n1363), .B1(n1362), .B2(n1361), .ZN(n1364) );
  ND2D1BWP40P140HVT U988 ( .A1(n1325), .A2(n1112), .ZN(N12) );
  OR4D0BWP40P140HVT U989 ( .A1(soakcounter[6]), .A2(soakcounter[5]), .A3(
        soakcounter[10]), .A4(soakcounter[12]), .Z(n1316) );
  AOI211D0BWP40P140HVT U990 ( .A1(n1339), .A2(washcounter[0]), .B(
        washcounter[14]), .C(washcounter[5]), .ZN(n1342) );
  OR4D0BWP40P140HVT U991 ( .A1(rinsecounter[5]), .A2(rinsecounter[10]), .A3(
        rinsecounter[13]), .A4(rinsecounter[14]), .Z(n1328) );
  INVD1BWP40P140HVT U992 ( .I(n1194), .ZN(n1245) );
  ND2D1BWP40P140HVT U993 ( .A1(n1141), .A2(n1127), .ZN(n1099) );
  ND2D1BWP40P140HVT U994 ( .A1(spincounter[8]), .A2(n1273), .ZN(n1293) );
  NR2OPTIBD1BWP40P140HVT U995 ( .A1(n1156), .A2(n1293), .ZN(n1299) );
  ND2D1BWP40P140HVT U996 ( .A1(spincounter[10]), .A2(n1299), .ZN(n1308) );
  INVD1BWP40P140HVT U997 ( .I(n1099), .ZN(n1273) );
  ND2D1BWP40P140HVT U998 ( .A1(n1133), .A2(spincounter[2]), .ZN(n1279) );
  INR2D1BWP40P140HVT U999 ( .A1(spincounter[3]), .B1(n1279), .ZN(n1278) );
  NR2OPTIBD1BWP40P140HVT U1000 ( .A1(n1309), .A2(n1308), .ZN(n1307) );
  ND2D1BWP40P140HVT U1001 ( .A1(n1124), .A2(n1171), .ZN(n1178) );
  AOI21D1BWP40P140HVT U1002 ( .A1(i_lid), .A2(n1122), .B(n1121), .ZN(n1123) );
  OR2D0BWP40P140HVT U1003 ( .A1(o_waterinlet), .A2(n1115), .Z(n1122) );
  ND2D1BWP40P140HVT U1004 ( .A1(n1141), .A2(n1088), .ZN(n1147) );
  INVD1BWP40P140HVT U1005 ( .I(n1302), .ZN(n1151) );
  INVD1BWP40P140HVT U1006 ( .I(n1102), .ZN(n1100) );
  INR2D1BWP40P140HVT U1007 ( .A1(o_rinse), .B1(i_lid), .ZN(n1101) );
  NR2OPTIBD1BWP40P140HVT U1008 ( .A1(n1103), .A2(rinsecounter[0]), .ZN(n1200)
         );
  MUX2ND0BWP40P140HVT U1009 ( .I0(n1103), .I1(n1194), .S(rinsecounter[0]), 
        .ZN(n107) );
  MUX2ND0BWP40P140HVT U1010 ( .I0(n1271), .I1(n1270), .S(soakcounter[1]), .ZN(
        n109) );
  ND2D0BWP40P140HVT U1011 ( .A1(n1266), .A2(n1259), .ZN(n1258) );
  INVD1BWP40P140HVT U1012 ( .I(o_spin), .ZN(n1117) );
  OAI211D1BWP40P140HVT U1013 ( .A1(n1320), .A2(n1319), .B(n1318), .C(n1317), 
        .ZN(n1321) );
  AOI21D1BWP40P140HVT U1014 ( .A1(n1345), .A2(washcounter[3]), .B(
        washcounter[2]), .ZN(n1349) );
  ND2D1BWP40P140HVT U1015 ( .A1(n1338), .A2(washcounter[2]), .ZN(n1353) );
  AOI31D0BWP40P140HVT U1016 ( .A1(n1360), .A2(spincounter[2]), .A3(
        spincounter[0]), .B(n1359), .ZN(n1361) );
  CKND3BWP40P140HVT U1017 ( .I(PS[3]), .ZN(n1176) );
  INR2D1BWP40P140HVT U1018 ( .A1(rinsecounter[4]), .B1(n1287), .ZN(n1252) );
  INR2D0BWP40P140HVT U1019 ( .A1(rinsecounter[6]), .B1(n1254), .ZN(n1079) );
  INR2D1BWP40P140HVT U1020 ( .A1(rinsecounter[10]), .B1(n1288), .ZN(n1104) );
  INVD1BWP40P140HVT U1021 ( .I(o_idle), .ZN(n1174) );
  INVD1BWP40P140HVT U1022 ( .I(PS[5]), .ZN(n1175) );
  CKND3BWP40P140HVT U1023 ( .I(PS[2]), .ZN(n1179) );
  ND2D1BWP40P140HVT U1024 ( .A1(n1178), .A2(n1171), .ZN(n1181) );
  INVD1BWP40P140HVT U1025 ( .I(washcounter[2]), .ZN(n1346) );
  MUX2ND0BWP40P140HVT U1026 ( .I0(n1263), .I1(n1193), .S(soakcounter[0]), .ZN(
        n122) );
  INVD0P7BWP40P140HVT U1027 ( .I(n1154), .ZN(n1153) );
  AOI211D0BWP40P140HVT U1028 ( .A1(n1309), .A2(n1308), .B(n1307), .C(n1306), 
        .ZN(n145) );
  CKND0BWP40P140HVT U1029 ( .I(n1183), .ZN(n1092) );
  AOI211D0BWP40P140HVT U1030 ( .A1(n1184), .A2(n1183), .B(n1182), .C(n1302), 
        .ZN(n131) );
  CKND0BWP40P140HVT U1031 ( .I(n1276), .ZN(n1111) );
  AOI211D0BWP40P140HVT U1032 ( .A1(n1277), .A2(n1276), .B(n1275), .C(n1302), 
        .ZN(n129) );
  AOI211D0BWP40P140HVT U1033 ( .A1(n1360), .A2(n1279), .B(n1278), .C(n1306), 
        .ZN(n153) );
  CKND0BWP40P140HVT U1034 ( .I(n1304), .ZN(n1150) );
  OAI31D0BWP40P140HVT U1035 ( .A1(rinsecounter[4]), .A2(n1103), .A3(n1287), 
        .B(n1286), .ZN(n103) );
  MUX2ND0BWP40P140HVT U1036 ( .I0(n1256), .I1(n1255), .S(n1254), .ZN(n102) );
  MUX2ND0BWP40P140HVT U1037 ( .I0(n1247), .I1(rinsecounter[6]), .S(n1254), 
        .ZN(n1248) );
  MUX2ND0BWP40P140HVT U1038 ( .I0(n1197), .I1(rinsecounter[8]), .S(n1242), 
        .ZN(n1198) );
  NR2D0BWP40P140HVT U1039 ( .A1(n1196), .A2(rinsecounter[8]), .ZN(n1197) );
  AO22D0BWP40P140HVT U1040 ( .A1(rinsecounter[9]), .A2(n1290), .B1(n1289), 
        .B2(n1143), .Z(n98) );
  MUX2ND0BWP40P140HVT U1041 ( .I0(n1292), .I1(n1291), .S(rinsecounter[10]), 
        .ZN(n97) );
  OR2D0BWP40P140HVT U1042 ( .A1(n1103), .A2(n1288), .Z(n1292) );
  MUX2ND0BWP40P140HVT U1043 ( .I0(n1244), .I1(n1243), .S(n1242), .ZN(n100) );
  OAI31D0BWP40P140HVT U1044 ( .A1(rinsecounter[12]), .A2(n1103), .A3(n1283), 
        .B(n1282), .ZN(n95) );
  MUX2ND0BWP40P140HVT U1045 ( .I0(PS[0]), .I1(n1125), .S(n1178), .ZN(n1126) );
  AOI21D1BWP40P140HVT U1046 ( .A1(n1141), .A2(spincounter[0]), .B(
        spincounter[1]), .ZN(n1089) );
  CKND0BWP40P140HVT U1047 ( .I(washcounter[12]), .ZN(n1305) );
  AOI211D0BWP40P140HVT U1048 ( .A1(n1338), .A2(n1167), .B(n1166), .C(n1302), 
        .ZN(n133) );
  CKND0BWP40P140HVT U1049 ( .I(n1167), .ZN(n1087) );
  AOI211D0BWP40P140HVT U1050 ( .A1(n1346), .A2(n1165), .B(n1164), .C(n1302), 
        .ZN(n135) );
  AOI211D0BWP40P140HVT U1051 ( .A1(n1163), .A2(n1345), .B(n1302), .C(n1162), 
        .ZN(n137) );
  MUX2ND0BWP40P140HVT U1052 ( .I0(soakcounter[2]), .I1(n1250), .S(
        soakcounter[1]), .ZN(n1251) );
  OAI21D0BWP40P140HVT U1053 ( .A1(n1207), .A2(soakcounter[9]), .B(
        soakcounter[8]), .ZN(n1208) );
  MUX2ND0BWP40P140HVT U1054 ( .I0(soakcounter[7]), .I1(n1214), .S(
        soakcounter[6]), .ZN(n1215) );
  NR2D0BWP40P140HVT U1055 ( .A1(n1236), .A2(soakcounter[7]), .ZN(n1214) );
  ND2D0BWP40P140HVT U1056 ( .A1(n1237), .A2(n1239), .ZN(n1238) );
  CKND0BWP40P140HVT U1057 ( .I(soakcounter[5]), .ZN(n1264) );
  OAI21D0BWP40P140HVT U1058 ( .A1(n1260), .A2(soakcounter[5]), .B(
        soakcounter[4]), .ZN(n1261) );
  ND2D0BWP40P140HVT U1059 ( .A1(n1205), .A2(rinsecounter[0]), .ZN(n1204) );
  NR2OPTIBD1BWP40P140HVT U1060 ( .A1(n328), .A2(PS[5]), .ZN(n1058) );
  NR2OPTIBD4BWP40P140HVT U1061 ( .A1(i_mode_1), .A2(i_mode_2), .ZN(n1325) );
  OAI21D0BWP40P140HVT U1062 ( .A1(spincounter[4]), .A2(n1278), .B(n1157), .ZN(
        n1134) );
  XOR2OPTND4BWP40P140HVT U1063 ( .A1(soakcounter[0]), .A2(i_mode_1), .Z(n1324)
         );
  XOR2OPTND4BWP40P140HVT U1064 ( .A1(i_mode_1), .A2(n1059), .Z(n1334) );
  CKND2D8BWP40P140HVT U1065 ( .A1(n1063), .A2(n1062), .ZN(n1310) );
  ND2OPTPAD6BWP40P140HVT U1066 ( .A1(n1311), .A2(spin_done), .ZN(n1312) );
  INVD15BWP40P140HVT U1067 ( .I(n1310), .ZN(o_spin) );
  OR2D4BWP40P140HVT U1068 ( .A1(n1064), .A2(n1076), .Z(n1060) );
  CKND0BWP40P140HVT U1069 ( .I(n1236), .ZN(n1237) );
  CKND0BWP40P140HVT U1070 ( .I(rinsecounter[8]), .ZN(n1199) );
  CKND0BWP40P140HVT U1071 ( .I(washcounter[10]), .ZN(n1298) );
  CKND0BWP40P140HVT U1072 ( .I(soakcounter[9]), .ZN(n1210) );
  CKND2BWP40P140HVT U1073 ( .I(n1076), .ZN(n1063) );
  OR2D4BWP40P140HVT U1074 ( .A1(n328), .A2(PS[1]), .Z(n1061) );
  INVD15BWP40P140HVT U1075 ( .I(n1060), .ZN(o_rinse) );
  CKND6BWP40P140HVT U1076 ( .I(n328), .ZN(n1172) );
  OR2D4BWP40P140HVT U1077 ( .A1(PS[2]), .A2(PS[0]), .Z(n1066) );
  NR2OPTIBD4BWP40P140HVT U1078 ( .A1(n1066), .A2(n1176), .ZN(n1067) );
  IND2D8BWP40P140HVT U1079 ( .A1(n1074), .B1(n1067), .ZN(n1173) );
  ND2OPTPAD2BWP40P140HVT U1080 ( .A1(n1068), .A2(PS[2]), .ZN(n1069) );
  OR2D8BWP40P140HVT U1081 ( .A1(n1074), .A2(n1069), .Z(n1177) );
  NR2OPTIBD8BWP40P140HVT U1082 ( .A1(n1071), .A2(n1070), .ZN(n1072) );
  INVD15BWP40P140HVT U1083 ( .I(n1072), .ZN(o_waterinlet) );
  INVD15BWP40P140HVT U1084 ( .I(n1177), .ZN(o_soak) );
  INVD15BWP40P140HVT U1085 ( .I(n1075), .ZN(o_idle) );
  INVD1BWP40P140HVT U1086 ( .I(PS[1]), .ZN(n1077) );
  INVD15BWP40P140HVT U1087 ( .I(n1180), .ZN(o_ready) );
  INVD15BWP40P140HVT U1088 ( .I(n1173), .ZN(o_wash) );
  ND2OPTIBD2BWP40P140HVT U1089 ( .A1(n1164), .A2(washcounter[3]), .ZN(n1167)
         );
  OAI21D1BWP40P140HVT U1090 ( .A1(n1164), .A2(washcounter[3]), .B(n1151), .ZN(
        n1086) );
  INR2D2BWP40P140HVT U1091 ( .A1(washcounter[4]), .B1(n1167), .ZN(n1166) );
  ND2OPTIBD2BWP40P140HVT U1092 ( .A1(n1166), .A2(washcounter[5]), .ZN(n1183)
         );
  OAI21D1BWP40P140HVT U1093 ( .A1(n1166), .A2(washcounter[5]), .B(n1151), .ZN(
        n1091) );
  INR3D0BWP40P140HVT U1094 ( .A1(spincounter[4]), .B1(n1094), .B2(n1093), .ZN(
        n1135) );
  CKND0BWP40P140HVT U1095 ( .I(spincounter[8]), .ZN(n1098) );
  OAI22D1BWP40P140HVT U1096 ( .A1(wash_done), .A2(n1173), .B1(n1060), .B2(
        rinse_done), .ZN(n1119) );
  OAI21D1BWP40P140HVT U1097 ( .A1(n1117), .A2(spin_done), .B(n1187), .ZN(n1118) );
  OAI21D0P7BWP40P140HVT U1098 ( .A1(n1180), .A2(N12), .B(n1123), .ZN(n1124) );
  INR3D0BWP40P140HVT U1099 ( .A1(spincounter[8]), .B1(n1129), .B2(n1128), .ZN(
        n1130) );
  XNR2UD1BWP40P140HVT U1100 ( .A1(n1141), .A2(spincounter[0]), .ZN(n1142) );
  CKND0BWP40P140HVT U1101 ( .I(spincounter[2]), .ZN(n1146) );
  NR3D0BWP40P140HVT U1102 ( .A1(n1160), .A2(n1159), .A3(n1302), .ZN(n136) );
  OAI22D1BWP40P140HVT U1103 ( .A1(n1181), .A2(n1173), .B1(n1172), .B2(n1178), 
        .ZN(n139) );
  OAI22D1BWP40P140HVT U1104 ( .A1(n1181), .A2(n1060), .B1(n1175), .B2(n1178), 
        .ZN(n158) );
  OAI22D1BWP40P140HVT U1105 ( .A1(n1181), .A2(n1177), .B1(n1176), .B2(n1178), 
        .ZN(n140) );
  OAI22D1BWP40P140HVT U1106 ( .A1(n1181), .A2(n1180), .B1(n1179), .B2(n1178), 
        .ZN(n141) );
  CKND0BWP40P140HVT U1107 ( .I(washcounter[6]), .ZN(n1184) );
  ND2D1BWP40P140HVT U1108 ( .A1(n1263), .A2(n1186), .ZN(n1190) );
  ND3D1BWP40P140HVT U1109 ( .A1(soakcounter[2]), .A2(soakcounter[1]), .A3(
        soakcounter[0]), .ZN(n1265) );
  NR3D0BWP40P140HVT U1110 ( .A1(n1236), .A2(n1239), .A3(n1216), .ZN(n1217) );
  CKND0BWP40P140HVT U1111 ( .I(rinsecounter[2]), .ZN(n1203) );
  INR2D0BWP40P140HVT U1112 ( .A1(rinsecounter[0]), .B1(rinsecounter[2]), .ZN(
        n1201) );
  MUX2ND0BWP40P140HVT U1113 ( .I0(rinsecounter[2]), .I1(n1201), .S(
        rinsecounter[1]), .ZN(n1202) );
  CKND0BWP40P140HVT U1114 ( .I(soakcounter[14]), .ZN(n1226) );
  CKND0BWP40P140HVT U1115 ( .I(soakcounter[10]), .ZN(n1234) );
  AN2D0BWP40P140HVT U1116 ( .A1(n1252), .A2(n1249), .Z(n1247) );
  NR2D0BWP40P140HVT U1117 ( .A1(n1313), .A2(soakcounter[2]), .ZN(n1250) );
  OAI21D1BWP40P140HVT U1118 ( .A1(soakcounter[4]), .A2(soakcounter[5]), .B(
        n1261), .ZN(n1262) );
  ND2D1BWP40P140HVT U1119 ( .A1(n1269), .A2(soakcounter[0]), .ZN(n1271) );
  NR3D0BWP40P140HVT U1120 ( .A1(n1274), .A2(n1273), .A3(n1306), .ZN(n149) );
  CKND0BWP40P140HVT U1121 ( .I(washcounter[8]), .ZN(n1277) );
  NR3D0BWP40P140HVT U1122 ( .A1(n1295), .A2(n1299), .A3(n1306), .ZN(n147) );
  NR3D0BWP40P140HVT U1123 ( .A1(n1301), .A2(n1306), .A3(n1300), .ZN(n146) );
  INVD15BWP40P140HVT U1124 ( .I(n1312), .ZN(o_done) );
  AOI211OPTREPBD2BWP40P140HVT U1125 ( .A1(i_mode_3), .A2(soakcounter[1]), .B(
        i_mode_2), .C(soakcounter[0]), .ZN(n1323) );
  NR4D0BWP40P140HVT U1126 ( .A1(n1314), .A2(n1313), .A3(soakcounter[3]), .A4(
        soakcounter[1]), .ZN(n1320) );
  NR3D0BWP40P140HVT U1127 ( .A1(n1315), .A2(soakcounter[0]), .A3(
        soakcounter[2]), .ZN(n1319) );
  NR4D0BWP40P140HVT U1128 ( .A1(n1316), .A2(soakcounter[4]), .A3(
        soakcounter[11]), .A4(soakcounter[9]), .ZN(n1318) );
  NR4D0BWP40P140HVT U1129 ( .A1(soakcounter[8]), .A2(soakcounter[7]), .A3(
        soakcounter[13]), .A4(soakcounter[14]), .ZN(n1317) );
  AO21D4BWP40P140HVT U1130 ( .A1(i_mode_2), .A2(soakcounter[1]), .B(n1321), 
        .Z(n1322) );
  ND2OPTPAD4BWP40P140HVT U1131 ( .A1(n1325), .A2(i_mode_3), .ZN(n1367) );
  NR3OPTPAD2BWP40P140HVT U1132 ( .A1(i_mode_2), .A2(rinsecounter[1]), .A3(
        rinsecounter[0]), .ZN(n1333) );
  NR4D0BWP40P140HVT U1133 ( .A1(n1328), .A2(rinsecounter[7]), .A3(
        rinsecounter[8]), .A4(rinsecounter[4]), .ZN(n1330) );
  NR4D0BWP40P140HVT U1134 ( .A1(rinsecounter[12]), .A2(rinsecounter[9]), .A3(
        rinsecounter[11]), .A4(rinsecounter[6]), .ZN(n1329) );
  NR2OPTPAD2BWP40P140HVT U1135 ( .A1(n1333), .A2(n1332), .ZN(n1335) );
  AOI21OPTREPBD2BWP40P140HVT U1136 ( .A1(n1367), .A2(rinsecounter[1]), .B(
        n1336), .ZN(N20) );
  XNR2OPTND2BWP40P140HVT U1137 ( .A1(washcounter[2]), .A2(i_mode_1), .ZN(n1356) );
  ND2OPTPAD2BWP40P140HVT U1138 ( .A1(i_mode_2), .A2(washcounter[4]), .ZN(n1337) );
  OAI21OPTREPBD2BWP40P140HVT U1139 ( .A1(washcounter[3]), .A2(i_mode_3), .B(
        n1337), .ZN(n1355) );
  NR4D0BWP40P140HVT U1140 ( .A1(washcounter[13]), .A2(washcounter[11]), .A3(
        washcounter[8]), .A4(washcounter[7]), .ZN(n1344) );
  NR4D0BWP40P140HVT U1141 ( .A1(washcounter[12]), .A2(washcounter[10]), .A3(
        washcounter[9]), .A4(washcounter[6]), .ZN(n1343) );
  NR3D0BWP40P140HVT U1142 ( .A1(n1347), .A2(n1346), .A3(washcounter[0]), .ZN(
        n1348) );
  NR4D0BWP40P140HVT U1143 ( .A1(n1351), .A2(n1350), .A3(n1349), .A4(n1348), 
        .ZN(n1352) );
  XOR2OPTND2BWP40P140HVT U1144 ( .A1(i_mode_1), .A2(spincounter[0]), .Z(n1366)
         );
  NR4D0BWP40P140HVT U1145 ( .A1(spincounter[8]), .A2(spincounter[10]), .A3(
        spincounter[12]), .A4(spincounter[9]), .ZN(n1363) );
  NR4D0BWP40P140HVT U1146 ( .A1(spincounter[11]), .A2(spincounter[14]), .A3(
        spincounter[5]), .A4(spincounter[7]), .ZN(n1358) );
  NR3D0BWP40P140HVT U1147 ( .A1(spincounter[4]), .A2(spincounter[6]), .A3(
        spincounter[13]), .ZN(n1357) );
  NR3D0BWP40P140HVT U1148 ( .A1(n1360), .A2(spincounter[2]), .A3(
        spincounter[0]), .ZN(n1359) );
  OAI31D2BWP40P140HVT U1149 ( .A1(spincounter[1]), .A2(spincounter[0]), .A3(
        i_mode_2), .B(n1364), .ZN(n1365) );
  AOI211OPTREPBD2BWP40P140HVT U1150 ( .A1(n1367), .A2(spincounter[1]), .B(
        n1366), .C(n1365), .ZN(N21) );
endmodule

