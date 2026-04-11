//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2010  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2010-03-19 16:50:51 +0000 (Fri, 19 Mar 2010) $
//
//      Revision            : $Revision: 134640 $
//
//      Release Information : CORTEX-A5-MPCore-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : DPU parameters (define statements)
//-----------------------------------------------------------------------------

`include "cortexa5params.v"

//-----------------------------------------------------------------------------
// Expansion of the OpCode decode
//----------------------------------------------------------------------------

`define def_0x 2'b00, 2'b01
`define def_1x 2'b10, 2'b11

`define def_0xx 3'b000, 3'b001, 3'b010, 3'b011
`define def_1xx 3'b100, 3'b101, 3'b110, 3'b111
`define def_00x 3'b000, 3'b001
`define def_01x 3'b010, 3'b011
`define def_10x 3'b100, 3'b101

`define def_1xxx 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111
`define def_01xx 4'b0100, 4'b0101, 4'b0110, 4'b0111
`define def_001x 4'b0010, 4'b0011

`define def_0xxx 4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111
`define def_00xx 4'b0000, 4'b0001, 4'b0010, 4'b0011
`define def_10xx 4'b1000, 4'b1001, 4'b1010, 4'b1011
`define def_100x 4'b1000, 4'b1001
`define def_101x 4'b1010, 4'b1011

`define def_x100 4'b0100, 4'b1100
`define def_xx10 4'b0010, 4'b0110, 4'b1010, 4'b1110
`define def_xx11 4'b0011, 4'b0111, 4'b1011, 4'b1111
`define def_xx01 4'b0001, 4'b0101, 4'b1001, 4'b1101
`define def_xxx1 `def_xx01, `def_xx11

`define def_000xx 5'b0_0000, 5'b0_0001, 5'b0_0010, 5'b0_0011
`define def_001xx 5'b0_0100, 5'b0_0101, 5'b0_0110, 5'b0_0111
`define def_100xx 5'b1_0000, 5'b1_0001, 5'b1_0010, 5'b1_0011
`define def_x000x 5'b0_0000, 5'b0_0001, 5'b1_0000, 5'b1_0001
`define def_x001x 5'b0_0010, 5'b0_0011, 5'b1_0010, 5'b1_0011
`define def_x010x 5'b0_0100, 5'b0_0101, 5'b1_0100, 5'b1_0101
`define def_x011x 5'b0_0110, 5'b0_0111, 5'b1_0110, 5'b1_0111
`define def_x100x 5'b0_1000, 5'b0_1001, 5'b1_1000, 5'b1_1001
`define def_x101x 5'b0_1010, 5'b0_1011, 5'b1_1010, 5'b1_1011
`define def_x1100 5'b01100, 5'b11100
`define def_x1101 5'b01101, 5'b11101
`define def_x1110 5'b01110, 5'b11110
`define def_x1111 5'b01111, 5'b11111

`define def_1x_xxxx__p0 6'b10_0000, 6'b10_0001, 6'b10_0010, 6'b10_0011, 6'b10_0100, 6'b10_0101
`define def_1x_xxxx__p1 6'b10_0110, 6'b10_0111, 6'b10_1000, 6'b10_1001, 6'b10_1010, 6'b10_1011
`define def_1x_xxxx__p2 6'b10_1100, 6'b10_1101, 6'b10_1110, 6'b10_1111, 6'b11_0000, 6'b11_0001
`define def_1x_xxxx__p3 6'b11_0010, 6'b11_0011, 6'b11_0100, 6'b11_0101, 6'b11_0110, 6'b11_0111
`define def_1x_xxxx__p4 6'b11_1000, 6'b11_1001, 6'b11_1010, 6'b11_1011, 6'b11_1100, 6'b11_1101
`define def_1x_xxxx__p5 6'b11_1110, 6'b11_1111
`define def_1x_xxxx `def_1x_xxxx__p0, `def_1x_xxxx__p1, `def_1x_xxxx__p2, `def_1x_xxxx__p3, `def_1x_xxxx__p4, `def_1x_xxxx__p5

// 7bit case
`define def_1xx_xxxx_p0 7'b100_0000, 7'b100_0001, 7'b100_0010, 7'b100_0011, 7'b100_0100, 7'b100_0101
`define def_1xx_xxxx_p1 7'b100_0110, 7'b100_0111, 7'b100_1000, 7'b100_1001, 7'b100_1010, 7'b100_1011
`define def_1xx_xxxx_p2 7'b100_1100, 7'b100_1101, 7'b100_1110, 7'b100_1111, 7'b101_0000, 7'b101_0001
`define def_1xx_xxxx_p3 7'b101_0010, 7'b101_0011, 7'b101_0100, 7'b101_0101, 7'b101_0110, 7'b101_0111
`define def_1xx_xxxx_p4 7'b101_1000, 7'b101_1001, 7'b101_1010, 7'b101_1011, 7'b101_1100, 7'b101_1101
`define def_1xx_xxxx_p5 7'b101_1110, 7'b101_1111, 7'b110_0000, 7'b110_0001, 7'b110_0010, 7'b110_0011
`define def_1xx_xxxx_p6 7'b110_0100, 7'b110_0101, 7'b110_0110, 7'b110_0111, 7'b110_1000, 7'b110_1001
`define def_1xx_xxxx_p7 7'b110_1010, 7'b110_1011, 7'b110_1100, 7'b110_1101, 7'b110_1110, 7'b110_1111
`define def_1xx_xxxx_p8 7'b111_0000, 7'b111_0001, 7'b111_0010, 7'b111_0011, 7'b111_0100, 7'b111_0101
`define def_1xx_xxxx_p9 7'b111_0110, 7'b111_0111, 7'b111_1000, 7'b111_1001, 7'b111_1010, 7'b111_1011
`define def_1xx_xxxx_p10 7'b111_1100, 7'b111_1101, 7'b111_1110, 7'b111_1111
`define def_1xx_xxxx `def_1xx_xxxx_p0, `def_1xx_xxxx_p1, `def_1xx_xxxx_p2, `def_1xx_xxxx_p3, `def_1xx_xxxx_p4, `def_1xx_xxxx_p5, \
                     `def_1xx_xxxx_p6, `def_1xx_xxxx_p7, `def_1xx_xxxx_p8, `def_1xx_xxxx_p9, `def_1xx_xxxx_p10


`define def_01x_xxxx_p0 7'b010_0000, 7'b010_0001, 7'b010_0010, 7'b010_0011, 7'b010_0100, 7'b010_0101
`define def_01x_xxxx_p1 7'b010_0110, 7'b010_0111, 7'b010_1000, 7'b010_1001, 7'b010_1010, 7'b010_1011
`define def_01x_xxxx_p2 7'b010_1100, 7'b010_1101, 7'b010_1110, 7'b010_1111, 7'b011_0000, 7'b011_0001
`define def_01x_xxxx_p3 7'b011_0010, 7'b011_0011, 7'b011_0100, 7'b011_0101, 7'b011_0110, 7'b011_0111
`define def_01x_xxxx_p4 7'b011_1000, 7'b011_1001, 7'b011_1010, 7'b011_1011, 7'b011_1100, 7'b011_1101
`define def_01x_xxxx_p5 7'b011_1110, 7'b011_1111
`define def_01x_xxxx `def_01x_xxxx_p0, `def_01x_xxxx_p1, `def_01x_xxxx_p2, `def_01x_xxxx_p3, `def_01x_xxxx_p4, `def_01x_xxxx_p5

`define def_001_xxxx_p0 7'b001_0000, 7'b001_0001, 7'b001_0010, 7'b001_0011, 7'b001_0100, 7'b001_0101
`define def_001_xxxx_p1 7'b001_0110, 7'b001_0111, 7'b001_1000, 7'b001_1001, 7'b001_1010, 7'b001_1011
`define def_001_xxxx_p2 7'b001_1100, 7'b001_1101, 7'b001_1110, 7'b001_1111
`define def_001_xxxx `def_001_xxxx_p0, `def_001_xxxx_p1, `def_001_xxxx_p2

`define def_000_1xxx 7'b000_1000, 7'b000_1001, 7'b000_1010, 7'b000_1011, 7'b000_1100, 7'b000_1101, 7'b000_1110, 7'b000_1111
`define def_000_01xx 7'b000_0100, 7'b000_0101, 7'b000_0110, 7'b000_0111
`define def_000_001x 7'b000_0010, 7'b000_0011

// 8bit case
`define def_0000_01xx 8'b0000_0100, 8'b0000_0101, 8'b0000_0110, 8'b0000_0111
`define def_0000_001x 8'b0000_0010, 8'b0000_0011
`define def_0000_1xx0 8'b0000_1000, 8'b0000_1010, 8'b0000_1100, 8'b0000_1110
`define def_0000_1xx1 8'b0000_1001, 8'b0000_1011, 8'b0000_1101, 8'b0000_1111

`define def_0000_1xxx `def_0000_1xx0, `def_0000_1xx1

`define def_0001_00xx 8'b0001_0000, 8'b0001_0001, 8'b0001_0010, 8'b0001_0011
`define def_0001_01xx 8'b0001_0100, 8'b0001_0101, 8'b0001_0110, 8'b0001_0111
`define def_0001_10xx 8'b0001_1000, 8'b0001_1001, 8'b0001_1010, 8'b0001_1011
`define def_0001_11xx 8'b0001_1100, 8'b0001_1101, 8'b0001_1110, 8'b0001_1111

`define def_0010_00xx 8'b0010_0000, 8'b0010_0001, 8'b0010_0010, 8'b0010_0011
`define def_0010_01xx 8'b0010_0100, 8'b0010_0101, 8'b0010_0110, 8'b0010_0111
`define def_0010_10xx 8'b0010_1000, 8'b0010_1001, 8'b0010_1010, 8'b0010_1011
`define def_0010_11xx 8'b0010_1100, 8'b0010_1101, 8'b0010_1110, 8'b0010_1111

`define def_0011_00xx 8'b0011_0000, 8'b0011_0001, 8'b0011_0010, 8'b0011_0011
`define def_0011_01xx 8'b0011_0100, 8'b0011_0101, 8'b0011_0110, 8'b0011_0111
`define def_0011_10xx 8'b0011_1000, 8'b0011_1001, 8'b0011_1010, 8'b0011_1011
`define def_0011_11xx 8'b0011_1100, 8'b0011_1101, 8'b0011_1110, 8'b0011_1111

`define def_0100_00xx 8'b0100_0000, 8'b0100_0001, 8'b0100_0010, 8'b0100_0011
`define def_0100_01xx 8'b0100_0100, 8'b0100_0101, 8'b0100_0110, 8'b0100_0111
`define def_0100_10xx 8'b0100_1000, 8'b0100_1001, 8'b0100_1010, 8'b0100_1011
`define def_0100_11xx 8'b0100_1100, 8'b0100_1101, 8'b0100_1110, 8'b0100_1111

`define def_0101_00xx 8'b0101_0000, 8'b0101_0001, 8'b0101_0010, 8'b0101_0011
`define def_0101_01xx 8'b0101_0100, 8'b0101_0101, 8'b0101_0110, 8'b0101_0111
`define def_0101_10xx 8'b0101_1000, 8'b0101_1001, 8'b0101_1010, 8'b0101_1011
`define def_0101_11xx 8'b0101_1100, 8'b0101_1101, 8'b0101_1110, 8'b0101_1111

`define def_0110_00xx 8'b0110_0000, 8'b0110_0001, 8'b0110_0010, 8'b0110_0011
`define def_0110_01xx 8'b0110_0100, 8'b0110_0101, 8'b0110_0110, 8'b0110_0111
`define def_0110_10xx 8'b0110_1000, 8'b0110_1001, 8'b0110_1010, 8'b0110_1011
`define def_0110_11xx 8'b0110_1100, 8'b0110_1101, 8'b0110_1110, 8'b0110_1111

`define def_0111_00xx 8'b0111_0000, 8'b0111_0001, 8'b0111_0010, 8'b0111_0011
`define def_0111_01xx 8'b0111_0100, 8'b0111_0101, 8'b0111_0110, 8'b0111_0111
`define def_0111_10xx 8'b0111_1000, 8'b0111_1001, 8'b0111_1010, 8'b0111_1011
`define def_0111_11xx 8'b0111_1100, 8'b0111_1101, 8'b0111_1110, 8'b0111_1111

`define def_1000_00xx 8'b1000_0000, 8'b1000_0001, 8'b1000_0010, 8'b1000_0011
`define def_1000_01xx 8'b1000_0100, 8'b1000_0101, 8'b1000_0110, 8'b1000_0111
`define def_1000_10xx 8'b1000_1000, 8'b1000_1001, 8'b1000_1010, 8'b1000_1011
`define def_1000_11xx 8'b1000_1100, 8'b1000_1101, 8'b1000_1110, 8'b1000_1111

`define def_1001_00xx 8'b1001_0000, 8'b1001_0001, 8'b1001_0010, 8'b1001_0011
`define def_1001_01xx 8'b1001_0100, 8'b1001_0101, 8'b1001_0110, 8'b1001_0111
`define def_1001_10xx 8'b1001_1000, 8'b1001_1001, 8'b1001_1010, 8'b1001_1011
`define def_1001_11xx 8'b1001_1100, 8'b1001_1101, 8'b1001_1110, 8'b1001_1111

`define def_1010_00xx 8'b1010_0000, 8'b1010_0001, 8'b1010_0010, 8'b1010_0011
`define def_1010_01xx 8'b1010_0100, 8'b1010_0101, 8'b1010_0110, 8'b1010_0111
`define def_1010_10xx 8'b1010_1000, 8'b1010_1001, 8'b1010_1010, 8'b1010_1011
`define def_1010_11xx 8'b1010_1100, 8'b1010_1101, 8'b1010_1110, 8'b1010_1111

`define def_1011_00xx 8'b1011_0000, 8'b1011_0001, 8'b1011_0010, 8'b1011_0011
`define def_1011_01xx 8'b1011_0100, 8'b1011_0101, 8'b1011_0110, 8'b1011_0111
`define def_1011_10xx 8'b1011_1000, 8'b1011_1001, 8'b1011_1010, 8'b1011_1011
`define def_1011_11xx 8'b1011_1100, 8'b1011_1101, 8'b1011_1110, 8'b1011_1111

`define def_1100_00xx 8'b1100_0000, 8'b1100_0001, 8'b1100_0010, 8'b1100_0011
`define def_1100_01xx 8'b1100_0100, 8'b1100_0101, 8'b1100_0110, 8'b1100_0111
`define def_1100_10xx 8'b1100_1000, 8'b1100_1001, 8'b1100_1010, 8'b1100_1011
`define def_1100_11xx 8'b1100_1100, 8'b1100_1101, 8'b1100_1110, 8'b1100_1111

`define def_1101_00xx 8'b1101_0000, 8'b1101_0001, 8'b1101_0010, 8'b1101_0011
`define def_1101_01xx 8'b1101_0100, 8'b1101_0101, 8'b1101_0110, 8'b1101_0111
`define def_1101_10xx 8'b1101_1000, 8'b1101_1001, 8'b1101_1010, 8'b1101_1011
`define def_1101_11xx 8'b1101_1100, 8'b1101_1101, 8'b1101_1110, 8'b1101_1111

`define def_1110_00xx 8'b1110_0000, 8'b1110_0001, 8'b1110_0010, 8'b1110_0011
`define def_1110_01xx 8'b1110_0100, 8'b1110_0101, 8'b1110_0110, 8'b1110_0111
`define def_1110_10xx 8'b1110_1000, 8'b1110_1001, 8'b1110_1010, 8'b1110_1011
`define def_1110_11xx 8'b1110_1100, 8'b1110_1101, 8'b1110_1110, 8'b1110_1111

`define def_1111_00xx 8'b1111_0000, 8'b1111_0001, 8'b1111_0010, 8'b1111_0011
`define def_1111_01xx 8'b1111_0100, 8'b1111_0101, 8'b1111_0110, 8'b1111_0111
`define def_1111_10xx 8'b1111_1000, 8'b1111_1001, 8'b1111_1010, 8'b1111_1011
`define def_1111_11xx 8'b1111_1100, 8'b1111_1101, 8'b1111_1110, 8'b1111_1111

`define def_0001_xxxx `def_0001_00xx, `def_0001_01xx, `def_0001_10xx, `def_0001_11xx
`define def_0010_xxxx `def_0010_00xx, `def_0010_01xx, `def_0010_10xx, `def_0010_11xx
`define def_0011_xxxx `def_0011_00xx, `def_0011_01xx, `def_0011_10xx, `def_0011_11xx
`define def_0100_xxxx `def_0100_00xx, `def_0100_01xx, `def_0100_10xx, `def_0100_11xx
`define def_0101_xxxx `def_0101_00xx, `def_0101_01xx, `def_0101_10xx, `def_0101_11xx
`define def_0110_xxxx `def_0110_00xx, `def_0110_01xx, `def_0110_10xx, `def_0110_11xx
`define def_0111_xxxx `def_0111_00xx, `def_0111_01xx, `def_0111_10xx, `def_0111_11xx

`define def_1000_xxxx `def_1000_00xx, `def_1000_01xx, `def_1000_10xx, `def_1000_11xx
`define def_1001_xxxx `def_1001_00xx, `def_1001_01xx, `def_1001_10xx, `def_1001_11xx
`define def_1010_xxxx `def_1010_00xx, `def_1010_01xx, `def_1010_10xx, `def_1010_11xx
`define def_1011_xxxx `def_1011_00xx, `def_1011_01xx, `def_1011_10xx, `def_1011_11xx
`define def_1100_xxxx `def_1100_00xx, `def_1100_01xx, `def_1100_10xx, `def_1100_11xx
`define def_1101_xxxx `def_1101_00xx, `def_1101_01xx, `def_1101_10xx, `def_1101_11xx
`define def_1110_xxxx `def_1110_00xx, `def_1110_01xx, `def_1110_10xx, `def_1110_11xx
`define def_1111_xxxx `def_1111_00xx, `def_1111_01xx, `def_1111_10xx, `def_1111_11xx

`define def_1xxx_xxxx `def_1000_xxxx, `def_1001_xxxx, `def_1010_xxxx, `def_1011_xxxx, \
                      `def_1100_xxxx, `def_1101_xxxx, `def_1110_xxxx, `def_1111_xxxx
`define def_01xx_xxxx `def_0100_xxxx, `def_0101_xxxx, `def_0110_xxxx, `def_0111_xxxx
`define def_001x_xxxx `def_0010_xxxx, `def_0011_xxxx

//-----------------------------------------------------------------------------
// Register number defines
//-----------------------------------------------------------------------------

// Programmer's model (virtual) addresses:
`define CA5_VADDR_R00 4'b0000
`define CA5_VADDR_R01 4'b0001
`define CA5_VADDR_R02 4'b0010
`define CA5_VADDR_R03 4'b0011
`define CA5_VADDR_R04 4'b0100
`define CA5_VADDR_R05 4'b0101
`define CA5_VADDR_R06 4'b0110
`define CA5_VADDR_R07 4'b0111
`define CA5_VADDR_R08 4'b1000
`define CA5_VADDR_R09 4'b1001
`define CA5_VADDR_R10 4'b1010
`define CA5_VADDR_R11 4'b1011
`define CA5_VADDR_R12 4'b1100
`define CA5_VADDR_R13 4'b1101
`define CA5_VADDR_R14 4'b1110
`define CA5_VADDR_R15 4'b1111

// Physical register addresses
`define CA5_ADDR_R00     5'b0_0000 // User or System mode
`define CA5_ADDR_R01     5'b0_0001 // User or System mode
`define CA5_ADDR_R02     5'b0_0010 // User or System mode
`define CA5_ADDR_R03     5'b0_0011 // User or System mode
`define CA5_ADDR_R04     5'b0_0100 // User or System mode
`define CA5_ADDR_R05     5'b0_0101 // User or System mode
`define CA5_ADDR_R06     5'b0_0110 // User or System mode
`define CA5_ADDR_R07     5'b0_0111 // User or System mode
`define CA5_ADDR_R08     5'b0_1000 // User or System mode
`define CA5_ADDR_R09     5'b0_1001 // User or System mode
`define CA5_ADDR_R10     5'b0_1010 // User or System mode
`define CA5_ADDR_R11     5'b0_1011 // User or System mode
`define CA5_ADDR_R12     5'b0_1100 // User or System mode
`define CA5_ADDR_R13     5'b0_1101 // User or System mode
`define CA5_ADDR_R14     5'b0_1110 // User or System mode
`define CA5_ADDR_R13_IRQ 5'b1_0000 // IRQ mode
`define CA5_ADDR_R14_IRQ 5'b1_0001 // IRQ mode
`define CA5_ADDR_R13_SVC 5'b1_0010 // Supervisor mode
`define CA5_ADDR_R14_SVC 5'b1_0011 // Supervisor mode
`define CA5_ADDR_R13_ABT 5'b1_0100 // Abort mode
`define CA5_ADDR_R14_ABT 5'b1_0101 // Abort mode
`define CA5_ADDR_R13_UND 5'b1_0110 // Undef mode
`define CA5_ADDR_R14_UND 5'b1_0111 // Undef mode
`define CA5_ADDR_R08_FIQ 5'b1_1000 // FIQ mode
`define CA5_ADDR_R09_FIQ 5'b1_1001 // FIQ mode
`define CA5_ADDR_R10_FIQ 5'b1_1010 // FIQ mode
`define CA5_ADDR_R11_FIQ 5'b1_1011 // FIQ mode
`define CA5_ADDR_R12_FIQ 5'b1_1100 // FIQ mode
`define CA5_ADDR_R13_FIQ 5'b1_1101 // FIQ mode
`define CA5_ADDR_R14_FIQ 5'b1_1110 // FIQ mode
`define CA5_ADDR_R13_MON 5'b0_1111 // Monitor mode
`define CA5_ADDR_R14_MON 5'b1_1111 // Monitor mode

// Bit positions for one-hot encodings
`define CA5_ADDR_BIT_R00 0
`define CA5_ADDR_BIT_R01 1
`define CA5_ADDR_BIT_R02 2
`define CA5_ADDR_BIT_R03 3
`define CA5_ADDR_BIT_R04 4
`define CA5_ADDR_BIT_R05 5
`define CA5_ADDR_BIT_R06 6
`define CA5_ADDR_BIT_R07 7
`define CA5_ADDR_BIT_R08 8
`define CA5_ADDR_BIT_R09 9
`define CA5_ADDR_BIT_R10 10
`define CA5_ADDR_BIT_R11 11
`define CA5_ADDR_BIT_R12 12
`define CA5_ADDR_BIT_R13 13
`define CA5_ADDR_BIT_R14 14
`define CA5_ADDR_BIT_R13_IRQ 16
`define CA5_ADDR_BIT_R14_IRQ 17
`define CA5_ADDR_BIT_R13_SVC 18
`define CA5_ADDR_BIT_R14_SVC 19
`define CA5_ADDR_BIT_R13_ABT 20
`define CA5_ADDR_BIT_R14_ABT 21
`define CA5_ADDR_BIT_R13_UND 22
`define CA5_ADDR_BIT_R14_UND 23
`define CA5_ADDR_BIT_R08_FIQ 24
`define CA5_ADDR_BIT_R09_FIQ 25
`define CA5_ADDR_BIT_R10_FIQ 26
`define CA5_ADDR_BIT_R11_FIQ 27
`define CA5_ADDR_BIT_R12_FIQ 28
`define CA5_ADDR_BIT_R13_FIQ 29
`define CA5_ADDR_BIT_R14_FIQ 30
`define CA5_ADDR_BIT_R13_MON 15
`define CA5_ADDR_BIT_R14_MON 31

//-----------------------------------------------------------------------------
// Define which execution pipline the micro instruction should be sent to.
// Need to define one bit per execution pipeline to allow for faster decoding
// in the decode stage when mapping the micro instruction packet from the
// decoders to the target execution pipeline.
//-----------------------------------------------------------------------------
`define CA5_EX_PIPE_NULL        5'b00000 //if no valid instruction
`define CA5_EX_PIPE_ALU         5'b00001
`define CA5_EX_PIPE_STR         5'b00010
`define CA5_EX_PIPE_BR          5'b01000
`define CA5_EX_PIPE_LSU         5'b10000
`define CA5_EX_PIPE_W 5

`define CA5_EX_PIPE_ALU_BIT     0
`define CA5_EX_PIPE_STR_BIT     1
`define CA5_EX_PIPE_MAC_BIT     2
`define CA5_EX_PIPE_BR_BIT      3
`define CA5_EX_PIPE_DCU_BIT     4

//-----------------------------------------------------------------------------
//Define instruction type
//-----------------------------------------------------------------------------
`define CA5_INSTR_TYPE_W              4
`define CA5_INSTR_TYPE_NULL           4'b0000
`define CA5_INSTR_TYPE_SVC            4'b0001
`define CA5_INSTR_TYPE_UNDEF          4'b0010
`define CA5_INSTR_TYPE_FABORT         4'b0011
`define CA5_INSTR_TYPE_BKPT           4'b0100
`define CA5_INSTR_TYPE_HW_BKPT        4'b0101
`define CA5_INSTR_TYPE_VEC_BKPT       4'b0110
`define CA5_INSTR_TYPE_VEC_HW_BKPT    4'b0111
`define CA5_INSTR_TYPE_ISB            4'b1000
`define CA5_INSTR_TYPE_SMC            4'b1001
`define CA5_INSTR_TYPE_UNDEF_VEC      4'b1010
`define CA5_INSTR_TYPE_INDIRECT_HEAD  4'b1011
`define CA5_INSTR_TYPE_WFI            4'b1100
`define CA5_INSTR_TYPE_WFE            4'b1101
`define CA5_INSTR_TYPE_SEV            4'b1110
`define CA5_INSTR_TYPE_EXPT_RTN_HEAD  4'b1111

//-----------------------------------------------------------------------------
// Encoding for LU operations.
//-----------------------------------------------------------------------------

`define CA5_LU_CTL_ADD          4'b0000  // Add
`define CA5_LU_CTL_SUB          4'b0001  // Subtract, reverse subtract
`define CA5_LU_CTL_ADC          4'b0010  // Add with carry
`define CA5_LU_CTL_SBC          4'b0011  // Subtract, reverse subtract with carry

`define CA5_LU_CTL_BIC          4'b0100  // A AND NOT(B)
`define CA5_LU_CTL_MVN          4'b0101  // Invert B
`define CA5_LU_CTL_EOR          4'b0110  // A EOR B
`define CA5_LU_CTL_AND          4'b1000  // A AND B
`define CA5_LU_CTL_MVB          4'b1010  // MOV B
`define CA5_LU_CTL_MVA          4'b1100  // MOV A Overloaded!
`define CA5_LU_CTL_ORR          4'b1110  // A ORR B
`define CA5_LU_CTL_ORN          4'b1101  // A ORR ~B

`define CA5_LU_CTL_CLZ          4'b0111  // Used to choose the output from the CLZ
                                     // logic.
`define CA5_LU_CTL_GEN_SAT      4'b1001  // Used to choose the output from the
                                     // saturation logic
`define CA5_LU_CTL_EXTRACT      4'b1011  // Used to choose the output from the
                                     // extract/extend logic
`define CA5_LU_CTL_MASKSEL      4'b1111  // Used to choose the output from the
                                     // masking/selection logic.

// Mask generation information used within the LU for SEL, PKHBT, PKHTB,
// MOVT, MOVW instructions
`define CA5_ALU_LU_MASK_SEL       3'b001


//-----------------------------------------------------------------------------
// Encoding for integer multiplier
//-----------------------------------------------------------------------------

`define CA5_MULT_TYPE_ACCONLY 3'b000

`define CA5_MULT_TYPE_USAD    3'b001

`define CA5_MULT_TYPE_16x16   3'b100
`define CA5_MULT_TYPE_32x32   3'b101
`define CA5_MULT_TYPE_2x16x16 3'b110
`define CA5_MULT_TYPE_32x16   3'b111

//------------------------------------------------------------------------------------
//               DPU ALU Pipeline
//------------------------------------------------------------------------------------
// ===========================
// Basic ALU ops
// [3:0] => AU_LU_OPCODE:
//          -------------
//          For the LU, the 4-bt encodes the Logic Instruction.
//          For the AU, bits[1:0] is used to identify how the CFlag is to be
//          used in the DP operation.
//
//          ALU_CARRYIN_CTL[1:0] =
//          ---------------------
//          00 => AU CarryIn = 0.
//          01 => AU Carryin = 1 (to form the 2's complement of the Boperand)
//          10 => AU CarryIn = CFlag
//          11 => AU CarryIn = ~CFlag
//
// [6:4]   => Ex1_SEL_SHF_A: Select RF_R2 or RF_R0 or PC as the source operand.
//            001 : PC
//            010 : RF_R0
//            100 : RF_R2
//
// [10:7]  => Ex1_SEL_SHF_B: Select Imm2, Imm1, RF_R3 or RF_R0 as the source
//                           operand
//            0001: RF_R0
//            0010: RF_R3
//            0100: Imm1
//            1000: Imm2
//
// [13:11] => Ex1_SEL_SHF_C: Select Imm2, Imm1 or RF_R0 as the source
//            operand.
//            001: RF_R0
//            010: Imm1
//            100: Imm2
//
// [14]    => ALU operation with destination being R15.
//            Therefore need to copy SPSR_mode to CPSR.
//
// [15]    => MSR instruction executing in the ALU pipeline.
//            NOTE: This will not be required anymore. The clean solution
//            would have been to carry this down the alu pipeline and use it
//            in the ex2 stage to bypass the data from the Boperand_Ex2 to
//            the {CC, GE} Flags. However, this wastes 3 FFs of area and
//            furthermore, this information is alredy sent down the cpst
//            pipeline and hence available. Thus we can tap off from the Ex2
//            stage of the cpsr pipeline to achieve the same functionality.
//
// [18:16]: ALU_OP_COMP: which of the three source operands needs to be inverted
//                       to generate the 1's complement.
//
//                   000: No complement required.
//                   001: EX1_SEL_SHF_A source
//                   010: EX1_SEL_SHF_B source
//                   100: EX1_SEL_SHF_C source
//                   if any of these three bits is set, then two things need
//                   to be done.
//                       1) form the 1's complement of the operand
//                       2) Set the CarryIn to the AU to 1.
//                       This then generates the 2's complement of the
//                       operand, required for the SUB instruction.
//
// [19]:    Flag Setting ID
//          0 => Instr_0 is flag setting
//          1 => Instr_1 is flag setting
//
// [21:20]: FlagID
//           00: no flag setting operation.
//           01: no flag setting operation.
//           10: flag setting - update CC flags.
//           11: flag setting - update GE flags
//
// [22]    : Flag Setting Instr to PC. Flag setting instruction which updates
//           the PC.
//
// [23]    : Next_CFLag_value
//           ----------------
//              0 - default: Nxt_CFLag value is calculated as normal.
//              1 - Nxt_CFlag value = shifter operand.
//
//

//----------------------
// Control Bus Widths
//----------------------
`define CA5_BR_PIPECTL_W 6

// ==========================================================================
// We need control signals for defining the Mux select for {SHF_A, SHF_B,
// SHF_C}  in the Ex1 stage of the ALU pipeline. This is because these muxes
// have multiple inputs from the RF read ports or the immediate values.
//
// SHF_A : Non-forwarding inputs are {RF_READ_R0}
// SHF_B : Non-forwarding inputs are {RF_READ_R1, Immediates}
// SHF_C : Non-forwarding inputs are {RF_READ_R2, Immediate}
//

`define CA5_SEL_SHF_A_W 2
`define CA5_SEL_SHF_B_W 2
`define CA5_SEL_SHF_C_W 2

`define CA5_SEL_SHF_A_ZERO      2'b00
`define CA5_SEL_SHF_A_R0        2'b01
`define CA5_SEL_SHF_A_PC        2'b10
`define CA5_SEL_SHF_A_FR1       2'b11

`define CA5_SEL_SHF_B_ZERO      2'b00
`define CA5_SEL_SHF_B_R1        2'b01
`define CA5_SEL_SHF_B_PC        2'b10
`define CA5_SEL_SHF_B_IMM_DATA  2'b11

`define CA5_SEL_SHF_C_ZERO      2'b00
`define CA5_SEL_SHF_C_R2        2'b01
`define CA5_SEL_SHF_C_IMM_SHIFT 2'b10
`define CA5_SEL_SHF_C_16        2'b11

`define CA5_SEL_MSK_B_IMM_DATA  1'b1

`define CA5_ZERO_MASK           3'b000
`define CA5_COMB_MASK           3'b001
`define CA5_SNGL_MASK           3'b010
`define CA5_TOP_MASK            3'b011
`define CA5_BOT_MASK            3'b100
`define CA5_ALU_MASK_OTHERS     3'b101, 3'b110, 3'b111

`define CA5_REV_MUX_NORMAL      3'b000
`define CA5_REV_MUX_REV         3'b010
`define CA5_REV_MUX_REVSH       3'b011
`define CA5_REV_MUX_REV16       3'b001
`define CA5_REV_MUX_RBIT        3'b100
`define CA5_REV_MUX_SAT_DBL     3'b101
`define CA5_REV_MUX_DUP8        3'b110
`define CA5_REV_MUX_DUP16       3'b111

// Defines for STR_S mux selection.
`define CA5_SEL_STR_S_ZERO      3'b000
`define CA5_SEL_STR_S_R2        3'b001
`define CA5_SEL_STR_S_PC        3'b010
`define CA5_SEL_STR_S_FR0       3'b011
`define CA5_SEL_STR_S_JAZ_STK   3'b100
`define CA5_SEL_STR_S_W 3

`define CA5_ALU_OP_COMP_NULL    2'b00
`define CA5_ALU_OP_COMP_SHF_B   2'b10
`define CA5_ALU_OP_COMP_W 2

`define CA5_NULL                1'b0    //value not required.

//---------------------------------
// SHift operations in the ALU
// pipeline
//---------------------------------

`define CA5_ALU_EX1_CTL_SHIFT_MOD_BITS 3:2
`define CA5_ALU_EX1_CTL_SHIFT_OP_BITS 1:0

`define CA5_SHIFT_OP_ASR     2'b10
`define CA5_SHIFT_OP_LSL     2'b00
`define CA5_SHIFT_OP_LSR     2'b01
`define CA5_SHIFT_OP_ROR     2'b11
`define CA5_SHIFT_OP_W 2

`define CA5_SHIFT_MOD_NONE        2'b00
`define CA5_SHIFT_MOD_32_FOR_0    2'b01
`define CA5_SHIFT_MOD_RRX_FOR_0   2'b10
`define CA5_SHIFT_MOD_5BIT        2'b11
`define CA5_SHIFT_MOD_W 2

//------------------------------------------------------------------------------------
// DPU Branch Pipeline Control
//------------------------------------------------------------------------------------
// =========================
// Basic control information
// =========================
//

//which address to read in decode stage.
`define CA5_READ_RTN_ADDR_DE               2'b01
`define CA5_READ_IMM_OFFSET_DE             2'b10
`define CA5_READ_ZERO_DE                   2'b00

//which type of br pipeline force
`define CA5_BR_NO_BRANCH                   3'b000
`define CA5_BR_DIRECT                      3'b001
`define CA5_BR_PREFETCH_FLUSH              3'b010
`define CA5_BR_INDIRECT_TBB                3'b011
`define CA5_BR_INDIRECT_THUMBEE            3'b100
`define CA5_BR_INDIRECT_DP                 3'b101
`define CA5_BR_INDIRECT_ST                 3'b110
`define CA5_BR_INDIRECT_LD                 3'b111

//Whether we need to force PFU. DP operations to the
//PC will not be capable of asserting the necessary
//force through computations done in the branch pipe,
//so it has to be statically generated from decode.
`define CA5_RET_FORCE                      1'b1
`define CA5_NO_RET_FORCE                   1'b0

//defines derived from the above
`define CA5_BR_DO_NOTHING                  {`CA5_READ_ZERO_DE,       `CA5_NO_RET_FORCE, `CA5_BR_NO_BRANCH}
`define CA5_BR_USE_OFFSET_ONLY             {`CA5_READ_IMM_OFFSET_DE, `CA5_NO_RET_FORCE, `CA5_BR_DIRECT}

//Types of branches used during decode of direct branches
`define CA5_STANDARD_BRANCH                2'b00
`define CA5_ILLEGAL_BX_IMM                 2'b01
`define CA5_BRANCH_AND_LINK                2'b10
`define CA5_BRANCH_AND_LINK_WITH_EXCHANGE  2'b11

//Branch predictability - used in both direct and indirect branch decode
`define CA5_IS_NOT_PREDICTABLE             1'b0
`define CA5_IS_PREDICTABLE                 1'b1

//Miscellaneous signals for direct branch decode
`define CA5_RF_RD_EN_IMMED_BR              4'b0000
`define CA5_BR_OFFSET_BITS                 23:0
`define CA5_H_BIT                          24
`define CA5_TAKEN_PRED_BIT                 25
`define CA5_EXCHANGE_BIT                   26

//Some defines used to signal the type of branch.
`define CA5_IS_NOT_RETURN                  1'b0
`define CA5_IS_RETURN                      1'b1
`define CA5_IS_NOT_CALL                    1'b0
`define CA5_IS_CALL                        1'b1
`define CA5_IS_DIRECT                      1'b1
`define CA5_IS_NOT_DIRECT                  1'b0

//Return address valid encodings.
`define CA5_RETURN_ADDR_VALID              1'b1
`define CA5_RETURN_ADDR_INVALID            1'b0

//may be depricated. Valids are now set in the arbiter based on ex_pipe encodings
`define CA5_RF_RD_SPECIAL_BR               4'b0000
`define CA5_BR_IS_NOT_VALID                1'b0
`define CA5_BR_IS_VALID                    1'b1

`define CA5_BR_X_BIT_W                     2
`define CA5_BX_RM_VALID                    2'b10
`define CA5_BX_IMM_VALID_FROM_ARM          2'b01   //going into thumb
`define CA5_BX_IMM_VALID_FROM_THUMB        2'b11   //going into ARM

`define CA5_LDR_U_BIT 23
`define CA5_LDR_SHIFT_LSL 2'b00
`define CA5_LDR_SHIFT_BITS 6:5
`define CA5_LDR_SHIFT_IMM_BITS 11:7
`define CA5_LDR_OFFSET_12_BITS 11:0
`define CA5_LDR_RD_BITS 15:12
`define CA5_LDR_RN_BITS 19:16
`define CA5_LDR_RM_BITS 3:0

// Other defines
`define CA5_REG_UNUSED 4'b0000

//---------------------------------------------------------------------------

// Defines for the architectural modes:
`define CA5_MODE_USR    4'b0000
`define CA5_MODE_FIQ    4'b0001
`define CA5_MODE_IRQ    4'b0010
`define CA5_MODE_SVC    4'b0011
`define CA5_MODE_ABT    4'b0111
`define CA5_MODE_UND    4'b1011
`define CA5_MODE_SYS    4'b1111
`define CA5_MODE_MON    4'b0110
`define CA5_MODE_NONUSE 4'b0100, 4'b0101, 4'b1000, 4'b1001, 4'b1010, 4'b1100, 4'b1101, 4'b1110
`define CA5_MODE_X      4'bxxxx

`define CA5_FULL_MODE_USR    5'b10000
`define CA5_FULL_MODE_FIQ    5'b10001
`define CA5_FULL_MODE_IRQ    5'b10010
`define CA5_FULL_MODE_SVC    5'b10011
`define CA5_FULL_MODE_ABT    5'b10111
`define CA5_FULL_MODE_UND    5'b11011
`define CA5_FULL_MODE_SYS    5'b11111
`define CA5_FULL_MODE_MON    5'b10110
`define CA5_FULL_MODE_NONUSE 5'b00000, 5'b00001, 5'b00010, 5'b00011, 5'b00100, 5'b00101, 5'b00110, 5'b00111, \
                             5'b01000, 5'b01001, 5'b01010, 5'b01011, 5'b01100, 5'b01101, 5'b01110, 5'b01111, \
                             5'b10100, 5'b10101, 5'b11000, 5'b11001, 5'b11010, 5'b11100, 5'b11101, 5'b11110
`define CA5_FULL_MODE_X      5'bxxxxx

// Defines for the architectural condition codes:
`define CA5_CC_EQ 4'b0000
`define CA5_CC_NE 4'b0001
`define CA5_CC_CS 4'b0010
`define CA5_CC_CC 4'b0011
`define CA5_CC_MI 4'b0100
`define CA5_CC_PL 4'b0101
`define CA5_CC_VS 4'b0110
`define CA5_CC_VC 4'b0111
`define CA5_CC_HI 4'b1000
`define CA5_CC_LS 4'b1001
`define CA5_CC_GE 4'b1010
`define CA5_CC_LT 4'b1011
`define CA5_CC_GT 4'b1100
`define CA5_CC_LE 4'b1101
`define CA5_CC_AL 4'b1110
`define CA5_CC_NV 4'b1111
`define CA5_CC_AL_or_NV 3'b111

`define CA5_CC_FLAGS_N    3
`define CA5_CC_FLAGS_Z    2
`define CA5_CC_FLAGS_C    1
`define CA5_CC_FLAGS_V    0

// AGU control params

// Defines for DCU_A mux selection
`define CA5_SEL_DCU_A_ZERO    2'b00 // Read a zero
`define CA5_SEL_DCU_A_R0      2'b01 // RF source data
`define CA5_SEL_DCU_A_PC      2'b10 // PC for current instruction
`define CA5_SEL_DCU_A_MUL     2'b11 // Use previous address, load/store multiple
`define CA5_SEL_DCU_A_W 2

// Defines for DCU_B mux selection.
`define CA5_SEL_DCU_B_ZERO    3'b000 // B op = Zero.
`define CA5_SEL_DCU_B_R1      3'b001 // RF source data
`define CA5_SEL_DCU_B_IMM_LS  3'b010 // 32-bit immediate (actually imm_dp)
`define CA5_SEL_DCU_B_X32     3'b011 // Misaligned single load/store
`define CA5_SEL_DCU_B_1       3'b100 // +1 for Neon stores
`define CA5_SEL_DCU_B_2       3'b101 // +2 for Neon stores
`define CA5_SEL_DCU_B_MUL     3'b110 // +/- 4 for load/store multiple.
`define CA5_SEL_DCU_B_SH      3'b111 // Fwd path: SH
`define CA5_SEL_DCU_B_W 3

// Compressed defines for DCU_A / DCU_B forwarding mux selection
`define CA5_SEL_FWD_DCU_A_W 3
`define CA5_SEL_FWD_DCU_B_W 3

//----------------------------------------------------------------------------
// immed_valid_offset_field_de_o[5:0]
//
// Overview
// --------
// Valid offset field indicator. This value should be used for clock gating in
// immed_offset_de_o[11:0] register down control pipeline signals.
//

`define CA5_FIELD_NULL            2'b00  // Indicate data field is unexpected.
`define CA5_FIELD_32_1            2'b01  // Used for T2 32bit immediate data
                                         // SBZ[31:24],valid[23:16],
                                         // SBZ[15:8], valid[7:0]
`define CA5_FIELD_32_2            2'b10  // Used for T2 32bit immediate data
                                         // valid[31:24],SBZ[23:16],
                                         // valid[15:8], SBZ[7:0]
`define CA5_FIELD_32_3            2'b11  // Used for T2 32bit immediate data
                                         // valid[31:24],valid[23:16],
                                         // valid[15:8], valid[7:0]
`define CA5_FIELD_X               2'bxx
`define CA5_FIELD_x               2'bxx

// Encodings to indicate where data is generated by an instruction.
// Used for the forwarding logic and the mux to the write port.
`define CA5_RF_WR_SRC_NONE     4'b0000
`define CA5_RF_WR_SRC_ALU      4'b0001
`define CA5_RF_WR_SRC_LSU      4'b0010
`define CA5_RF_WR_SRC_DCU_ALU  4'b0011
`define CA5_RF_WR_SRC_CPSR     4'b0100
`define CA5_RF_WR_SRC_MAC_LO   4'b0101
`define CA5_RF_WR_SRC_MAC_HI   4'b0110
`define CA5_RF_WR_SRC_MAC_BOTH 4'b0111
`define CA5_RF_WR_SRC_STR      4'b1000
`define CA5_RF_WR_SRC_CP       4'b1001
`define CA5_RF_WR_SRC_STREX    4'b1010
`define CA5_RF_WR_SRC_FPSYS    4'b1011
`define CA5_RF_WR_SRC_ALU_STR  4'b1100
`define CA5_RF_WR_SRC_SPSR     4'b1101
`define CA5_RF_WR_SRC_ILLEGAL  4'b1110, 4'b1111
`define CA5_RF_WR_SRC_W 4
`define CA5_RF_WR_SRC_ALL_W 8

// When write data becomes available for forwarding
`define CA5_RF_WR_WHEN_LATE_WR  2'b11
`define CA5_RF_WR_WHEN_EARLY_WR 2'b01   // LSU ops
`define CA5_RF_WR_WHEN_EX2      2'b00

// CA5_RF_WR_WHEN_W 2 bits per port (4 total)
`define CA5_RF_WR_WHEN_W     2
`define CA5_RF_WR_WHEN_ALL_W 4

// When read data is needed in the data path
`define CA5_RF_RD_NEED_EARLY_ISS 3'b111
`define CA5_RF_RD_NEED_LATE_ISS  3'b110
`define CA5_RF_RD_NEED_EX1       3'b100
`define CA5_RF_RD_NEED_EX2       3'b000

// CA5_RF_RD_NEED_W 3 bits per port (12 total)
`define CA5_RF_RD_NEED_W     3
`define CA5_RF_RD_NEED_ALL_W 9

// Floating point write controls
`define CA5_RF_FWR_WHEN_F3  1'b0
`define CA5_RF_FWR_WHEN_F5  1'b1

`define CA5_RF_FRD_NEED_W     2
`define CA5_RF_FRD_NEED_F1    2'b11
`define CA5_RF_FRD_NEED_F2    2'b10
`define CA5_RF_FRD_NEED_F3    2'b00

`define CA5_RF_FWR_SRC_W       4
`define CA5_RF_FWR_SRC_NONE    4'b0000
`define CA5_RF_FWR_SRC_DP_MOV  4'b0001
`define CA5_RF_FWR_SRC_NEON_LD 4'b0101
`define CA5_RF_FWR_SRC_FAD_Q   4'b0010
`define CA5_RF_FWR_SRC_FML_Q   4'b0011
`define CA5_RF_FWR_SRC_LSU     4'b0100
`define CA5_RF_FWR_SRC_STR     4'b0110
`define CA5_RF_FWR_SRC_SP_MOV  4'b0111
`define CA5_RF_FWR_SRC_LD_PREV 4'b1000
`define CA5_RF_FWR_SRC_ALU     4'b1001

// Where to forward from
`define CA5_FWD_W0       3'b000
`define CA5_FWD_W1       3'b001
`define CA5_FWD_ALU_EX2  3'b010
`define CA5_FWD_NULL     3'b100
`define CA5_FWD_DIV      3'b101
`define CA5_FWD_FR1      3'b110
`define CA5_FWD_FR2      3'b111
`define CA5_FWD_ILLEGAL  3'b011
`define CA5_FWD_XS       3'bxxx

//------------------------------------------
//       LS related defines
//------------------------------------------

`define CA5_LS_INSTR_TYPE_W             4

`define CA5_LS_INSTR_SINGLE             4'b0000
`define CA5_LS_INSTR_PLD                4'b0001
`define CA5_LS_INSTR_NON_CP15_BARRIER   4'b0010
`define CA5_LS_INSTR_LDC_STC            4'b0011
`define CA5_LS_INSTR_RFE_SRS            4'b0100
`define CA5_LS_INSTR_CLREX              4'b0101
`define CA5_LS_INSTR_EXCL_SGL           4'b0110
`define CA5_LS_INSTR_SWP                4'b0111
`define CA5_LS_INSTR_MULTIPLE           4'b1000
`define CA5_LS_INSTR_SIGN_EXT           4'b1001
`define CA5_LS_INSTR_EXCL_MULT          4'b1110
`define CA5_LS_INSTR_VFP_NEON_SGL       4'b1010
`define CA5_LS_INSTR_VFP_NEON_MULT      4'b1011
`define CA5_LS_INSTR_JAZELLE            4'b1111

//------------------------------------------
//       CP related defines
//------------------------------------------

//defines for the performance monitor event counter to make the case assignment complete.
`define CA5_PMN_SEL_OTHERS \
                                            8'h16, 8'h17, 8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1E, 8'h1F, \
  8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27, 8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2E, 8'h2F, \
  8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37, 8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3E, 8'h3F, \
  8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h46, 8'h47, 8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4E, 8'h4F, \
  8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h56, 8'h57, 8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5E, 8'h5F, \
  8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h66, 8'h67, 8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6E, 8'h6F, \
  8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h76, 8'h77, 8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7E, 8'h7F, \
  8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85,               8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8E, 8'h8F, \
  8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h96, 8'h97, 8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9E, 8'h9F, \
  8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA6, 8'hA7, 8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAE, 8'hAF, \
  8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB6, 8'hB7, 8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBE, 8'hBF, \
                                                                        8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCE, 8'hCF, \
  8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD6, 8'hD7, 8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDE, 8'hDF, \
  8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE6, 8'hE7, 8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEE, 8'hEF, \
  8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF6, 8'hF7, 8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFE, 8'hFF

//defines for the CP register encoding
`define CA5_CRN0_MIDR             7'b0000001
`define CA5_CRN0_CTR              7'b0000010
`define CA5_CRN0_TLBTR            7'b0000011
`define CA5_CRN0_MPIDR            7'b0000100
`define CA5_CRN0_ID_PFR0          7'b0000101
`define CA5_CRN0_ID_PFR1          7'b0000110
`define CA5_CRN0_ID_DFR0          7'b0000111
`define CA5_CRN0_ID_MMFR0         7'b0001000
`define CA5_CRN0_ID_MMFR1         7'b0001001
`define CA5_CRN0_ID_MMFR2         7'b0001010
`define CA5_CRN0_ID_MMFR3         7'b0001011
`define CA5_CRN0_ID_ISAR0         7'b0001100
`define CA5_CRN0_ID_ISAR1         7'b0001101
`define CA5_CRN0_ID_ISAR2         7'b0001110
`define CA5_CRN0_ID_ISAR3         7'b0001111
`define CA5_CRN0_ID_ISAR4         7'b0010000
`define CA5_CRN0_ID_CCSIDR        7'b0010001
`define CA5_CRN0_ID_CLIDR         7'b0010010
`define CA5_CRN0_CSSELR           7'b0010011
`define CA5_CRN1_SCTLR            7'b0010100
`define CA5_CRN1_ACTLR            7'b0010101
`define CA5_CRN1_CPACR            7'b0010110
`define CA5_CRN1_SCR              7'b0010111
`define CA5_CRN1_SDER             7'b0011000
`define CA5_CRN1_NSACR            7'b0011001
`define CA5_CRN1_VCR              7'b1001100
`define CA5_CRN5_DFSR             7'b0011010
`define CA5_CRN5_IFSR             7'b0011011
`define CA5_CRN6_DFAR             7'b0011100
`define CA5_CRN6_IFAR             7'b0011101
`define CA5_CRN7_WFI              7'b0011110
`define CA5_CRN7_ICIMVAU          7'b1011110
`define CA5_CRN7_ISB              7'b0011111
`define CA5_CRN9_PMCR             7'b0100000
`define CA5_CRN9_PMNCNTENSET      7'b0100001
`define CA5_CRN9_PMNCNTENCLR      7'b0100010
`define CA5_CRN9_PMOVSR           7'b0100011
`define CA5_CRN9_PMSWINC          7'b0100100
`define CA5_CRN9_PMSELR           7'b0100101
`define CA5_CRN9_PMCCNTR          7'b0100110
`define CA5_CRN9_PMXEVTYPER       7'b0100111
`define CA5_CRN9_PMXEVCNTR        7'b0101000
`define CA5_CRN9_PMUSERENR        7'b0101001
`define CA5_CRN9_PMINTENSET       7'b0101010
`define CA5_CRN9_PMINTENCLR       7'b0101011
`define CA5_CRN9_PMCEID0          7'b1001101
`define CA5_CRN12_VBAR            7'b0101100
`define CA5_CRN12_MVBAR           7'b0101101
`define CA5_CRN12_ISR             7'b0101110
`define CA5_CRN12_VIR             7'b1001011
`define CA5_CRN13_CID             7'b0111111
`define CA5_CRN13_TPIDRURW        7'b0101111
`define CA5_CRN13_TPIDRURO        7'b0110000
`define CA5_CRN13_TPIDRPRW        7'b0110001
`define CA5_CRN15_CSOR            7'b0110010
`define CA5_CP14_DBG_DIDR         7'b0110011
`define CA5_CP14_DBG_DRAR         7'b0110100
`define CA5_CP14_DBG_DSAR         7'b0110101
`define CA5_CP14_DBG_DSCR_INT     7'b0110110
`define CA5_CP14_DBG_DTR_INT      7'b0110111
`define CA5_CP14_JIDR             7'b0111000
`define CA5_CP14_JMFR             7'b0111000
`define CA5_CP14_JOSCR            7'b0111001
`define CA5_CP14_JMCR             7'b0111010
`define CA5_CP14_JPR              7'b0111011
`define CA5_CP14_JCOTTR           7'b0111100
`define CA5_CP14_TEECR            7'b0111101
`define CA5_CP14_TEEHBR           7'b0111110
`define CA5_CP14_DBG_DSCR_FLAGS   7'b1000000
`define CA5_CP14_DBG_WFAR         7'b1000001
`define CA5_CP14_DBG_DTRRX_EXT    7'b1000010
`define CA5_CP14_DBG_DSCR_EXT     7'b1000011
`define CA5_CP14_DBG_DTRTX_EXT    7'b1000100
`define CA5_CP14_DBG_PRCR         7'b1000101
`define CA5_CP14_DBG_PRSR         7'b1000110
`define CA5_CP14_DBG_CLAIMSET     7'b1000111
`define CA5_CP14_DBG_CLAIMCLR     7'b1001000
`define CA5_CP14_DBG_AUTHSTATUS   7'b1001001
`define CA5_CP14_DBG_DEVID        7'b1001010
`define CA5_CP14_DBG_DRCR         7'b1001111
`define CA5_CP15_CBAR             7'b1001110
`define CA5_CP15_MRC_EXTERNAL     7'b1111111

//----------------------------------------------------------------------------
// Pipeline Control Signals
//----------------------------------------------------------------------------

`define CA5_ALU_FLAG_SET_W                   2
`define CA5_ALU_RD_IS_R15_W                  1
`define CA5_ALU_EX1_XTRACT_TYP_W             2
`define CA5_ALU_EX1_XTRACT_TYP_BITS          5:4
`define CA5_ALU_EX1_SIGN_XTEND_W             1
`define CA5_ALU_EX1_SIGN_XTEND_BITS          6
`define CA5_ALU_EX1_XTRCT_VAL_W              1
`define CA5_ALU_EX1_XTRCT_VAL_BITS           7
`define CA5_ALU_EX1_MASK_SEL_W               3
`define CA5_ALU_EX1_MASK_SEL_BITS            10:8
`define CA5_ALU_EX1_REV_TYPE_W               3
`define CA5_ALU_EX1_REV_TYPE_BITS            13:11

`define CA5_LU_CTL_W 4
`define CA5_ALU_AU_CARRY_LU_OPCODE_W `CA5_LU_CTL_W
`define CA5_ALU_EX2_CTL_LU_CTL_BITS          3:0
`define CA5_ALU_EX2_CTL_OP_COMP_SHF_A_BIT    4
`define CA5_ALU_EX2_CTL_OP_COMP_SHF_B_BIT    5
`define CA5_ALU_EX2_CTL_FLAG_ID_BITS         7:6
`define CA5_SIMD_ADDSUBX_W                   1
`define CA5_ALU_EX2_CTL_SIMD_ADD_SUB_X_BITS  8
`define CA5_ALU_EX2_VALID_SIMD_W             1
`define CA5_ALU_EX2_CTL_VALID_SIMD_BITS      9
`define CA5_ALU_EX2_SIMD_SIZE_W              1
`define CA5_ALU_EX2_CTL_SIMD_SIZE_BITS       10
`define CA5_ALU_EX2_SIMD_HALVING_W           1
`define CA5_ALU_EX2_CTL_HALVING_BITS         11
`define CA5_ALU_EX2_SIMD_SIGN_ARTH_W         1
`define CA5_ALU_EX2_SIMD_SIGN_ARTH_BITS      12
`define CA5_ALU_EX2_SEL_VALID_W              1
`define CA5_ALU_EX2_SEL_VALID_BITS           13
`define CA5_ALU_EX2_CBZ_BYPASS_W             1
`define CA5_ALU_EX2_CBZ_BYPASS_BITS          14
`define CA5_ALU_EX2_SIGN_REPLICATE_W         1
`define CA5_ALU_EX2_SIGN_REPLICATE_BITS      15
`define CA5_ALU_EX2_ARRAY_CHECK_W            1
`define CA5_ALU_EX2_ARRAY_CHECK_BITS         16

`define CA5_SIMD_SAT_VALID_W                 1
`define CA5_ALU_WR_CTL_SAT_VALID_BITS        0

// Define widths for the generic datapath control busses
//                               0
`define CA5_DP_WR_CTL_W  (`CA5_SIMD_SAT_VALID_W)

`define CA5_DP_EX2_CTL_W (`CA5_ALU_EX2_ARRAY_CHECK_W + `CA5_ALU_EX2_SIGN_REPLICATE_W + `CA5_ALU_EX2_CBZ_BYPASS_W +           \
                          `CA5_ALU_EX2_SEL_VALID_W + `CA5_ALU_EX2_SIMD_SIGN_ARTH_W + `CA5_ALU_EX2_SIMD_HALVING_W +           \
                          `CA5_ALU_EX2_SIMD_SIZE_W + `CA5_ALU_EX2_VALID_SIMD_W + `CA5_SIMD_ADDSUBX_W + `CA5_ALU_FLAG_SET_W + \
                          `CA5_ALU_OP_COMP_W + `CA5_ALU_AU_CARRY_LU_OPCODE_W)
`define CA5_DP_EX2_CTL_LOW (`CA5_ALU_OP_COMP_W + `CA5_ALU_AU_CARRY_LU_OPCODE_W)
`define CA5_DP_EX2_CTL_HIGH (`CA5_DP_EX2_CTL_W - `CA5_DP_EX2_CTL_LOW)

`define CA5_ALU_EX1_CTL_W (`CA5_ALU_EX1_REV_TYPE_W + `CA5_ALU_EX1_MASK_SEL_W + `CA5_ALU_EX1_XTRCT_VAL_W +            \
                           `CA5_ALU_EX1_SIGN_XTEND_W + `CA5_ALU_EX1_XTRACT_TYP_W + `CA5_SHIFT_MOD_W + `CA5_SHIFT_OP_W)

// Define widths for the MAC control busses
`define CA5_MAC_ISS_CTL_W 10

// Define the width of the overall datapath control bus
`define CA5_DP_PIPECTL_W (`CA5_DP_WR_CTL_W + `CA5_DP_EX2_CTL_W + `CA5_ALU_EX1_CTL_W + `CA5_MAC_ISS_CTL_W)

// Define how the various control busses are contained within the overall
// datapath control bus
`define CA5_DP_PIPECTL_DP_WR_CTL_BITS   (`CA5_DP_PIPECTL_W-1):(`CA5_DP_EX2_CTL_W+`CA5_ALU_EX1_CTL_W+`CA5_MAC_ISS_CTL_W)
`define CA5_DP_PIPECTL_DP_EX2_CTL_BITS  (`CA5_DP_EX2_CTL_W+`CA5_ALU_EX1_CTL_W+`CA5_MAC_ISS_CTL_W-1):(`CA5_ALU_EX1_CTL_W+`CA5_MAC_ISS_CTL_W)
`define CA5_DP_PIPECTL_ALU_EX1_CTL_BITS (`CA5_ALU_EX1_CTL_W+`CA5_MAC_ISS_CTL_W-1):(`CA5_MAC_ISS_CTL_W)
`define CA5_DP_PIPECTL_MAC_ISS_CTL_BITS (`CA5_MAC_ISS_CTL_W-1):0

//------------------------------------------------------------------------------
// Immediate generator control signals
//------------------------------------------------------------------------------

// ============================================
// CA5_IMM_SHIFT_W: shift value to shifter in ex1. 5bit
// CA5_IMM_DATA_W: immediate data,
//             the maximum valid bit width is 24bit(Branch instruction)
//             the minimun valaid bit width is 8bit(ARM immediate).
// CA5_IMM_DATA_FIELD_W: See immed_valid_offset_field_de_o[5:0]
//
`define CA5_IMM_SHIFT_W 5
`define CA5_IMM_DATA_W 17
`define CA5_IMM_DATA_FIELD_W 2

//----------------------------------------------------------------------------
// Params for Exception logic: type and status
//----------------------------------------------------------------------------

`define CA5_EXPT_TYPE_W                   5
`define CA5_EXPT_TYPE_EXIT_HALT           5'b00000
`define CA5_EXPT_TYPE_RESET               5'b01000
`define CA5_EXPT_TYPE_DATA_ABORT          5'b01100
`define CA5_EXPT_TYPE_DATA_ABORT_MON      5'b11100
`define CA5_EXPT_TYPE_FIQ                 5'b01111
`define CA5_EXPT_TYPE_FIQ_MON             5'b11111
`define CA5_EXPT_TYPE_IRQ                 5'b01110
`define CA5_EXPT_TYPE_IRQ_MON             5'b11110
`define CA5_EXPT_TYPE_IMPRECISE_ABORT     5'b00100
`define CA5_EXPT_TYPE_IMPRECISE_ABORT_MON 5'b10100
`define CA5_EXPT_TYPE_PREFETCH_ABORT      5'b01011
`define CA5_EXPT_TYPE_PREFETCH_ABORT_MON  5'b11011
`define CA5_EXPT_TYPE_SVC                 5'b01010
`define CA5_EXPT_TYPE_UNDEF               5'b01001
`define CA5_EXPT_TYPE_IBKPT               5'b10011
`define CA5_EXPT_TYPE_ENTER_HW_HALT       5'b00001
`define CA5_EXPT_TYPE_ENTER_SW_HALT       5'b10001
`define CA5_EXPT_TYPE_NULL_POINTER        5'b00101
`define CA5_EXPT_TYPE_NULL_POINTER_2ND    5'b00110
`define CA5_EXPT_TYPE_ARRAY_BOUNDS        5'b10101
`define CA5_EXPT_TYPE_ARRAY_BOUNDS_2ND    5'b10110
`define CA5_EXPT_TYPE_SMC                 5'b00010
`define CA5_EXPT_TYPE_ENTER_JAZELLE       5'b10111

`define CA5_ETM_EXPT_TYPE_W               4
`define CA5_ETM_EXPT_TYPE_NULL            4'b0000
`define CA5_ETM_EXPT_TYPE_DATA_ABORT      4'b1100
`define CA5_ETM_EXPT_TYPE_FIQ             4'b1111
`define CA5_ETM_EXPT_TYPE_IRQ             4'b1110
`define CA5_ETM_EXPT_TYPE_IMPRECISE_ABORT 4'b0100
`define CA5_ETM_EXPT_TYPE_PREFETCH_ABORT  4'b1011
`define CA5_ETM_EXPT_TYPE_SVC             4'b1010
`define CA5_ETM_EXPT_TYPE_SMC             4'b0010
`define CA5_ETM_EXPT_TYPE_UNDEF           4'b1001
`define CA5_ETM_EXPT_TYPE_IBKPT           4'b1011
`define CA5_ETM_EXPT_TYPE_HALT            4'b0001
`define CA5_ETM_EXPT_TYPE_GENERIC         4'b1101
`define CA5_ETM_EXPT_TYPE_JAZELLE         4'b0101
`define CA5_ETM_EXPT_TYPE_RESET           4'b1000
`define CA5_ETM_EXPT_TYPE_X               4'bxxxx

`define CA5_EXPT_FLAG_W 18
`define CA5_EXPT_DATA_ABORT_BIT      `CA5_EXPT_FLAG_W-1
`define CA5_EXPT_FIQ_BIT             `CA5_EXPT_FLAG_W-2
`define CA5_EXPT_IRQ_BIT             `CA5_EXPT_FLAG_W-3
`define CA5_EXPT_RESET_BIT           `CA5_EXPT_FLAG_W-4
`define CA5_EXPT_IMPRECISE_ABORT_BIT `CA5_EXPT_FLAG_W-5
`define CA5_EXPT_PREFETCH_ABORT_BIT  `CA5_EXPT_FLAG_W-6
`define CA5_EXPT_SVC_BIT             `CA5_EXPT_FLAG_W-7
`define CA5_EXPT_SMC_BIT             `CA5_EXPT_FLAG_W-8
`define CA5_EXPT_UNDEF_BIT           `CA5_EXPT_FLAG_W-9
`define CA5_EXPT_IBKPT_BIT           `CA5_EXPT_FLAG_W-10
`define CA5_EXPT_ENTER_HW_HALT_BIT   `CA5_EXPT_FLAG_W-11
`define CA5_EXPT_ENTER_SW_HALT_BIT   `CA5_EXPT_FLAG_W-12
`define CA5_EXPT_WPT_DATA_ABORT_BIT  `CA5_EXPT_FLAG_W-13
`define CA5_EXPT_VECTOR_CATCH_BIT    `CA5_EXPT_FLAG_W-14
`define CA5_EXPT_HW_IBKPT_BIT        `CA5_EXPT_FLAG_W-15
`define CA5_EXPT_NULL_POINTER_BIT    `CA5_EXPT_FLAG_W-16
`define CA5_EXPT_ARRAY_BOUNDS_BIT    `CA5_EXPT_FLAG_W-17
`define CA5_EXPT_ENTER_JAZELLE_BIT   `CA5_EXPT_FLAG_W-18

`define CA5_EXPT_DATA_ABORT_REQ        18'b10_0000_0000_0000_0000
`define CA5_EXPT_FIQ_REQ               18'b01_0000_0000_0000_0000
`define CA5_EXPT_IRQ_REQ               18'b00_1000_0000_0000_0000
`define CA5_EXPT_IMPRECISE_ABORT_REQ   18'b00_0100_0000_0000_0000
`define CA5_EXPT_RESET_REQ             18'b00_0010_0000_0000_0000
`define CA5_EXPT_PREFETCH_ABORT_REQ    18'b00_0001_0000_0000_0000
`define CA5_EXPT_SVC_REQ               18'b00_0000_1000_0000_0000
`define CA5_EXPT_SMC_REQ               18'b00_0000_0100_0000_0000
`define CA5_EXPT_UNDEF_REQ             18'b00_0000_0010_0000_0000
`define CA5_EXPT_IBKPT_REQ             18'b00_0000_0001_0000_0000
`define CA5_EXPT_ENTER_HW_HALT_REQ     18'b00_0000_0000_1000_0000
`define CA5_EXPT_ENTER_SW_HALT_REQ     18'b00_0000_0000_0100_0000
`define CA5_EXPT_WPT_DATA_ABORT_REQ    18'b00_0000_0000_0010_0000
`define CA5_EXPT_VECTOR_CATCH_REQ      18'b00_0000_0000_0001_0000
`define CA5_EXPT_HW_IBKPT_REQ          18'b00_0000_0000_0000_1000
`define CA5_EXPT_NULL_POINTER_REQ      18'b00_0000_0000_0000_0100
`define CA5_EXPT_ARRAY_BOUNDS_REQ      18'b00_0000_0000_0000_0010
`define CA5_EXPT_ENTER_JAZELLE_REQ     18'b00_0000_0000_0000_0001
`define CA5_EXPT_NULL_REQ              {`CA5_EXPT_FLAG_W{1'b0}}
`define CA5_EXPT_X_REQ                 {`CA5_EXPT_FLAG_W{1'bx}}

//-----------------------------------------------------------------------------
// CPSR Params
//-----------------------------------------------------------------------------
// Definitions of the bits within the stored PSR registers

`define CA5_CPSR_RET_W 27
`define CA5_CPSR_RET_N_BITS 26
`define CA5_CPSR_RET_Z_BITS 25
`define CA5_CPSR_RET_C_BITS 24
`define CA5_CPSR_RET_V_BITS 23
`define CA5_CPSR_RET_Q_BITS 22
`define CA5_CPSR_RET_NZCV_BITS 26:23
`define CA5_CPSR_RET_CV_BITS 24:23
`define CA5_CPSR_RET_NZCVQ_BITS 26:22
`define CA5_CPSR_RET_IT_LOW_BITS 21:20  // Bottom two mask bits
`define CA5_CPSR_RET_J_BITS 19
`define CA5_CPSR_RET_GE_BITS 18:15
`define CA5_CPSR_RET_IT_COND_BITS 14:11 // All four condition bits
`define CA5_CPSR_RET_IT_HIGH_BITS 10:9  // Top two mask bits
`define CA5_CPSR_RET_IT_HICM_BITS 14:9  // Condition and top two mask bits
`define CA5_CPSR_RET_EAIF_BITS 8:5
`define CA5_CPSR_RET_E_BITS 8
`define CA5_CPSR_RET_A_BITS 7
`define CA5_CPSR_RET_I_BITS 6
`define CA5_CPSR_RET_F_BITS 5
`define CA5_CPSR_RET_T_BITS 4
`define CA5_CPSR_RET_MODE_BITS 3:0

`define CA5_CPSR_RET_T_BYTE `CA5_CPSR_RET_N_BITS:`CA5_CPSR_RET_J_BITS
`define CA5_CPSR_RET_H_BYTE `CA5_CPSR_RET_GE_BITS
`define CA5_CPSR_RET_L_BYTE 14:`CA5_CPSR_RET_A_BITS
`define CA5_CPSR_RET_B_BYTE `CA5_CPSR_RET_I_BITS:0

`define CA5_SPSR_RET_W 28
`define CA5_SPSR_RET_N_BITS 27
`define CA5_SPSR_RET_Z_BITS 26
`define CA5_SPSR_RET_C_BITS 25
`define CA5_SPSR_RET_V_BITS 24
`define CA5_SPSR_RET_Q_BITS 23
`define CA5_SPSR_RET_NZCV_BITS 27:24
`define CA5_SPSR_RET_CVQ_BITS 25:23
`define CA5_SPSR_RET_NZCVQ_BITS 27:23
`define CA5_SPSR_RET_IT_LOW_BITS 22:21
`define CA5_SPSR_RET_J_BITS 20
`define CA5_SPSR_RET_GE_BITS 19:16
`define CA5_SPSR_RET_IT_COND_BITS 15:12
`define CA5_SPSR_RET_IT_HIGH_BITS 11:10
`define CA5_SPSR_RET_IT_HICM_BITS 15:10
`define CA5_SPSR_RET_EAIF_BITS 9:6
`define CA5_SPSR_RET_E_BITS 9
`define CA5_SPSR_RET_A_BITS 8
`define CA5_SPSR_RET_I_BITS 7
`define CA5_SPSR_RET_F_BITS 6
`define CA5_SPSR_RET_T_BITS 5
`define CA5_SPSR_RET_MODE_BITS 4:0

`define CA5_SPSR_RET_T_BYTE `CA5_SPSR_RET_N_BITS:`CA5_SPSR_RET_J_BITS
`define CA5_SPSR_RET_H_BYTE `CA5_SPSR_RET_GE_BITS
`define CA5_SPSR_RET_L_BYTE 15:`CA5_SPSR_RET_A_BITS
`define CA5_SPSR_RET_B_BYTE `CA5_SPSR_RET_I_BITS:0

// Definitions of the bits within the architectural PSR registers
`define CA5_PSR_ARCH_N_BITS 31
`define CA5_PSR_ARCH_Z_BITS 30
`define CA5_PSR_ARCH_C_BITS 29
`define CA5_PSR_ARCH_V_BITS 28
`define CA5_PSR_ARCH_Q_BITS 27
`define CA5_PSR_ARCH_NZCV_BITS 31:28
`define CA5_PSR_ARCH_NZCVQ_BITS 31:27
`define CA5_PSR_ARCH_IT_LOW_BITS 26:25
`define CA5_PSR_ARCH_J_BITS 24
`define CA5_PSR_ARCH_GE_BITS 19:16
`define CA5_PSR_ARCH_IT_COND_BITS 15:12
`define CA5_PSR_ARCH_IT_HIGH_BITS 11:10
`define CA5_PSR_ARCH_IT_HICM_BITS 15:10
`define CA5_PSR_ARCH_EAIF_BITS 9:6
`define CA5_PSR_ARCH_E_BITS 9
`define CA5_PSR_ARCH_A_BITS 8
`define CA5_PSR_ARCH_I_BITS 7
`define CA5_PSR_ARCH_F_BITS 6
`define CA5_PSR_ARCH_T_BITS 5
`define CA5_PSR_ARCH_MODE_BITS 4:0

// Definitions for the CPSR control signals
// Separate definitions for each section of the CPSR, because they do not all
// need all the possible values (thus the widths of the signals can be
// reduced compared to using the same defines for all)
`define CA5_SEL_CPSR_SRC_W            4
`define CA5_SEL_CPSR_SRC_CPSR         4'b0000
`define CA5_SEL_CPSR_SRC_FORCE        4'b0001
`define CA5_SEL_CPSR_SRC_DP           4'b0010
`define CA5_SEL_CPSR_SRC_MUL          4'b0011
`define CA5_SEL_CPSR_SRC_LOAD_DATA    4'b0100
`define CA5_SEL_CPSR_SRC_SPSR         4'b0101
`define CA5_SEL_CPSR_SRC_CCFLAGS      4'b0110
`define CA5_SEL_CPSR_SRC_DSCR         4'b0111
`define CA5_SEL_CPSR_SRC_QFLAG        4'b1000
`define CA5_SEL_CPSR_SRC_JBIT         4'b1001
`define CA5_SEL_CPSR_SRC_RFE          4'b1010
`define CA5_SEL_CPSR_SRC_BLX          4'b1011

`define CA5_SEL_CPSR_EN_W             6
`define CA5_SEL_CPSR_EN_CPSR          6'b00_0000
`define CA5_SEL_CPSR_EN_IT            6'b00_0001
`define CA5_SEL_CPSR_EN_T             6'b00_0010
`define CA5_SEL_CPSR_EN_E             6'b00_0011
`define CA5_SEL_CPSR_EN_JT            6'b00_0100
`define CA5_SEL_CPSR_EN_JTIM          6'b00_0101
`define CA5_SEL_CPSR_EN_JTAIM         6'b00_0110
`define CA5_SEL_CPSR_EN_JTAIFM        6'b00_0111
`define CA5_SEL_CPSR_EN_GE            6'b00_1000
`define CA5_SEL_CPSR_EN_J             6'b00_1001
`define CA5_SEL_CPSR_EN_Q             6'b00_1010
`define CA5_SEL_CPSR_EN_CC            6'b00_1011
`define CA5_SEL_CPSR_EN_SPSR          6'b00_1100
`define CA5_SEL_CPSR_EN_NZ            6'b00_1101

`define CA5_SEL_MRS_CPSR_RET          1'b0
`define CA5_SEL_MRS_SPSR_RET          1'b1

//---------------------------------------------------------------------
//  SIMD specific defines
//---------------------------------------------------------------------
`define CA5_SIMD_SIGNED_SAT_ARITH    3'b001
`define CA5_SIMD_SIGNED_ARITH        3'b000
`define CA5_SIMD_SIGNED_HALF_ARITH   3'b010
`define CA5_SIMD_UNSIGNED_ARITH      3'b100
`define CA5_SIMD_UNSIGNED_HALF_ARITH 3'b110
`define CA5_SIMD_UNSIGNED_SAT_ARITH  3'b101
`define CA5_SIMD_X                   3'b000, 3'b100
`define CA5_SIMD_SIZE_16              1'b1
`define CA5_SIMD_SIZE_8               1'b0

`define CA5_MEDIA_SIGNED_SAT_ARITH    3'b010
`define CA5_MEDIA_SIGNED_ARITH        3'b001
`define CA5_MEDIA_SIGNED_HALF_ARITH   3'b011
`define CA5_MEDIA_UNSIGNED_ARITH      3'b101
`define CA5_MEDIA_UNSIGNED_HALF_ARITH 3'b111
`define CA5_MEDIA_UNSIGNED_SAT_ARITH  3'b110
`define CA5_MEDIA_X                   3'b000, 3'b100

`define CA5_EXTRACT_LS_BYTE     2'b11
`define CA5_EXTRACT_LS_HWORD    2'b01
`define CA5_EXTRACT_TWO_BYTES   2'b10
`define CA5_EXTRACT_OTHERS      2'b00

//---------------------------------------------------------------------
// Sat defines
//---------------------------------------------------------------------
`define CA5_SAT_POS_VALUE 32'h7fff_ffff
`define CA5_SAT_NEG_VALUE 32'h8000_0000

//---------------------------------------------------------------------
// FPU defines
//---------------------------------------------------------------------

`define CA5_FP_RF_ADDR_W   (NEON_0 ?  5 :  4)
`define CA5_FP_RF_ADDR_L_W (NEON_0 ? 32 : 16)

// FPU register defines
`define CA5_FPU_ADDR_R00 5'b0_0000
`define CA5_FPU_ADDR_R01 5'b0_0001
`define CA5_FPU_ADDR_R02 5'b0_0010
`define CA5_FPU_ADDR_R03 5'b0_0011
`define CA5_FPU_ADDR_R04 5'b0_0100
`define CA5_FPU_ADDR_R05 5'b0_0101
`define CA5_FPU_ADDR_R06 5'b0_0110
`define CA5_FPU_ADDR_R07 5'b0_0111
`define CA5_FPU_ADDR_R08 5'b0_1000
`define CA5_FPU_ADDR_R09 5'b0_1001
`define CA5_FPU_ADDR_R10 5'b0_1010
`define CA5_FPU_ADDR_R11 5'b0_1011
`define CA5_FPU_ADDR_R12 5'b0_1100
`define CA5_FPU_ADDR_R13 5'b0_1101
`define CA5_FPU_ADDR_R14 5'b0_1110
`define CA5_FPU_ADDR_R15 5'b0_1111
`define CA5_FPU_ADDR_R16 5'b1_0000
`define CA5_FPU_ADDR_R17 5'b1_0001
`define CA5_FPU_ADDR_R18 5'b1_0010
`define CA5_FPU_ADDR_R19 5'b1_0011
`define CA5_FPU_ADDR_R20 5'b1_0100
`define CA5_FPU_ADDR_R21 5'b1_0101
`define CA5_FPU_ADDR_R22 5'b1_0110
`define CA5_FPU_ADDR_R23 5'b1_0111
`define CA5_FPU_ADDR_R24 5'b1_1000
`define CA5_FPU_ADDR_R25 5'b1_1001
`define CA5_FPU_ADDR_R26 5'b1_1010
`define CA5_FPU_ADDR_R27 5'b1_1011
`define CA5_FPU_ADDR_R28 5'b1_1100
`define CA5_FPU_ADDR_R29 5'b1_1101
`define CA5_FPU_ADDR_R30 5'b1_1110
`define CA5_FPU_ADDR_R31 5'b1_1111

// FPU read mux defines
`define CA5_SEL_FML_A_W 1
`define CA5_SEL_FML_A_ZERO 1'b0
`define CA5_SEL_FML_A_FR0  1'b1

`define CA5_SEL_FML_B_W 2
`define CA5_SEL_FML_B_ZERO 2'b00
`define CA5_SEL_FML_B_FR1  2'b01
`define CA5_SEL_FML_B_PREV 2'b11

`define CA5_SEL_FML_C_W 1
`define CA5_SEL_FML_C_ZERO 1'b0
`define CA5_SEL_FML_C_FR2  1'b1

`define CA5_SEL_FAD_A_W 2
`define CA5_SEL_FAD_A_ZERO  2'b00
`define CA5_SEL_FAD_A_FR2   2'b01
`define CA5_SEL_FAD_A_TWO   2'b10
`define CA5_SEL_FAD_A_THREE 2'b11

`define CA5_SEL_FAD_B_W 2
`define CA5_SEL_FAD_B_ZERO  2'b00
`define CA5_SEL_FAD_B_FR1   2'b01
`define CA5_SEL_FAD_B_IMM   2'b10
`define CA5_SEL_FAD_B_FML_Q 2'b11

`define CA5_SEL_FAD_C_W 2
`define CA5_SEL_FAD_C_ZERO  2'b00
`define CA5_SEL_FAD_C_FR0   2'b01
`define CA5_SEL_FAD_C_IMM   2'b10

// FPU forwarding mux defines
`define CA5_FWD_FW0_F3     3'b010
`define CA5_FWD_FW0_F4     3'b001
`define CA5_FWD_FW0_F5     3'b100
`define CA5_FWD_FW1_F5     3'b101
`define CA5_FWD_MUL        3'b111
`define CA5_FWD_FNULL      3'b000

// FP operand unpack types
`define CA5_FP_FORMAT_F32   3'b000
`define CA5_FP_FORMAT_F64   3'b001
`define CA5_FP_FORMAT_F16_B 3'b010
`define CA5_FP_FORMAT_F16_T 3'b011
`define CA5_FP_FORMAT_S16   3'b110
`define CA5_FP_FORMAT_U16   3'b111
`define CA5_FP_FORMAT_S32   3'b100
`define CA5_FP_FORMAT_U32   3'b101

// Floating point system register defines
`define CA5_FPEXC_W 2
`define CA5_FPEXC_EN_BITS  1
`define CA5_FPEXC_DEX_BITS 0

`define CA5_FPEXC_ST_EN_BITS  18
`define CA5_FPEXC_ST_DEX_BITS 17

`define CA5_FPSCR_ARCH_NZCV_BITS    31:28
`define CA5_FPSCR_ARCH_QC_BITS      27
`define CA5_FPSCR_ARCH_AHP_BITS     26
`define CA5_FPSCR_ARCH_DN_BITS      25
`define CA5_FPSCR_ARCH_FZ_BITS      24
`define CA5_FPSCR_ARCH_RMODE_BITS   23:22
`define CA5_FPSCR_ARCH_STRIDE_BITS  21:20
`define CA5_FPSCR_ARCH_LEN_BITS     18:16
`define CA5_FPSCR_ARCH_IDC_BITS     7
`define CA5_FPSCR_ARCH_IXC_BITS     4
`define CA5_FPSCR_ARCH_UFC_BITS     3
`define CA5_FPSCR_ARCH_OFC_BITS     2
`define CA5_FPSCR_ARCH_DZC_BITS     1
`define CA5_FPSCR_ARCH_IOC_BITS     0

`define CA5_FPEXC_ARCH_EN_BITS  30
`define CA5_FPEXC_ARCH_DEX_BITS 29

`define CA5_FPSCR_W (NEON_0 ? 21 : 20)
`define CA5_FPSCR_FP_BITS         19:0
`define CA5_FPSCR_QC_BITS         20    // Put on end to make configurability easier
`define CA5_FPSCR_NZCV_BITS       19:16
`define CA5_FPSCR_AHP_BITS        15
`define CA5_FPSCR_DN_BITS         14
`define CA5_FPSCR_FZ_BITS         13
`define CA5_FPSCR_RMODE_BITS      12:11
`define CA5_FPSCR_STRIDE_BITS     10:9
`define CA5_FPSCR_CONFIG_BITS     15:9
`define CA5_FPSCR_LEN_BITS        8:6
`define CA5_FPSCR_FP_XFLAGS_BITS  5:0

`define CA5_FPSCR_IDC_BITS 5
`define CA5_FPSCR_IXC_BITS 4
`define CA5_FPSCR_UFC_BITS 3
`define CA5_FPSCR_OFC_BITS 2
`define CA5_FPSCR_DZC_BITS 1
`define CA5_FPSCR_IOC_BITS 0

`define CA5_XFLAGS_W (NEON_0 ? 7 : 6)
`define CA5_XFLAGS_QC_BITS  6
`define CA5_XFLAGS_IDC_BITS `CA5_FPSCR_IDC_BITS
`define CA5_XFLAGS_IXC_BITS `CA5_FPSCR_IXC_BITS
`define CA5_XFLAGS_UFC_BITS `CA5_FPSCR_UFC_BITS
`define CA5_XFLAGS_OFC_BITS `CA5_FPSCR_OFC_BITS
`define CA5_XFLAGS_DZC_BITS `CA5_FPSCR_DZC_BITS
`define CA5_XFLAGS_IOC_BITS `CA5_FPSCR_IOC_BITS

`define CA5_XFLAGS_FP_BITS  `CA5_FPSCR_FP_XFLAGS_BITS

`define CA5_FP_CFLAG_SRC_W 2
`define CA5_FP_CFLAG_SRC_FPSCR  2'b00
`define CA5_FP_CFLAG_SRC_STR    2'b01
`define CA5_FP_CFLAG_SRC_ALU    2'b10

`define CA5_FP_XFLAG_SRC_W 3
`define CA5_FP_XFLAG_SRC_FPSCR  3'b000
`define CA5_FP_XFLAG_SRC_STR    3'b100
`define CA5_FP_XFLAG_SRC_MUL    3'b001
`define CA5_FP_XFLAG_SRC_ALU    3'b010

`define CA5_FP_SYSREG_ADDR_W 3
`define CA5_FP_SYSREG_ADDR_NONE  3'b000
`define CA5_FP_SYSREG_ADDR_FPEXC 3'b100
`define CA5_FP_SYSREG_ADDR_FPSCR 3'b001
`define CA5_FP_SYSREG_ADDR_FPSID 3'b010
`define CA5_FP_SYSREG_ADDR_MVFR0 3'b111
`define CA5_FP_SYSREG_ADDR_MVFR1 3'b110

//----------------------------------------------------------------------------
// FPU Pipeline Control Signals
//----------------------------------------------------------------------------

`define CA5_FP_EX_PIPE_ADD                    0
`define CA5_FP_EX_PIPE_MUL                    1

`define CA5_FP_EX_PIPE_W                      2

`define CA5_FP_ADD_FIXED_POINT_W              1
`define CA5_FP_ADD_FIXED_POINT_BITS           0
`define CA5_FP_ADD_QNAN_EXCEP_W               1
`define CA5_FP_ADD_QNAN_EXCEP_BITS            1
`define CA5_FP_ADD_CMP_W                      1
`define CA5_FP_ADD_CMP_BITS                   2
`define CA5_FP_ADD_ABS_NEG_W                  1
`define CA5_FP_ADD_ABS_NEG_BITS               3
`define CA5_FP_ADD_NEGATE_W                   2
`define CA5_FP_ADD_NEGATE_BITS                5:4
`define CA5_FP_ADD_OUT_FORMAT_W               3
`define CA5_FP_ADD_OUT_FORMAT_BITS            8:6
`define CA5_FP_ADD_IN_FORMAT_W                3
`define CA5_FP_ADD_IN_FORMAT_BITS             11:9

`define CA5_FP_NEON_ADD_NEON_INT_SEL_W        1
`define CA5_FP_NEON_ADD_NEON_INT_SEL_BITS     12
`define CA5_FP_NEON_ADD_NEON_MUX_SEL_W        2
`define CA5_FP_NEON_ADD_NEON_MUX_SEL_BITS     14:13
`define CA5_FP_NEON_ADD_LU_CTL_W              4
`define CA5_FP_NEON_ADD_LU_CTL_BITS           18:15
`define CA5_FP_NEON_ADD_SIZE_SEL_W            2
`define CA5_FP_NEON_ADD_SIZE_SEL_BITS         20:19
`define CA5_FP_NEON_ADD_PERM_SEL_W            4
`define CA5_FP_NEON_ADD_PERM_SEL_BITS         24:21
`define CA5_FP_NEON_ADD_VTB_CYCLE_W           1
`define CA5_FP_NEON_ADD_VTB_CYCLE_BITS        25
`define CA5_FP_NEON_ADD_UNSIGNED_OP_W         1
`define CA5_FP_NEON_ADD_UNSIGNED_OP_BITS      26
`define CA5_FP_NEON_ADD_FCTN_SEL_W            4
`define CA5_FP_NEON_ADD_FCTN_SEL_BITS         30:27
`define CA5_FP_NEON_ADD_WIDTH_OP_SEL_W        3
`define CA5_FP_NEON_ADD_WIDTH_OP_SEL_BITS     33:31
`define CA5_FP_NEON_ADD_SAT_OP_SEL_W          2
`define CA5_FP_NEON_ADD_SAT_OP_SEL_BITS       35:34
`define CA5_FP_NEON_ADD_VTST_OP_SEL_W         1
`define CA5_FP_NEON_ADD_VTST_OP_SEL_BITS      36
`define CA5_FP_NEON_ADD_MASK_SEL_W            1
`define CA5_FP_NEON_ADD_MASK_SEL_BITS         37

`define CA5_FP_MUL_NEG_SQRT_W                 1
`define CA5_FP_MUL_NEG_SQRT_BITS              0
`define CA5_FP_MUL_DIVIDE_W                   1
`define CA5_FP_MUL_DIVIDE_BITS                1
`define CA5_FP_MUL_PRECISION_W                1
`define CA5_FP_MUL_PRECISION_BITS             2
`define CA5_FP_MUL_ACCUMULATE_W               1
`define CA5_FP_MUL_ACCUMULATE_BITS            3
`define CA5_FP_MUL_FUSED_MAC_W                1
`define CA5_FP_MUL_FUSED_MAC_BITS             4

`define CA5_FP_MUL_NEON_INT_OP_W              1
`define CA5_FP_MUL_NEON_INT_OP_BITS           5
`define CA5_FP_MUL_NEON_FIXUP_W               1
`define CA5_FP_MUL_NEON_FIXUP_BITS            6
`define CA5_FP_MUL_NEON_SAT_DBL_W             1
`define CA5_FP_MUL_NEON_SAT_DBL_BITS          7
`define CA5_FP_MUL_NEON_ROUND_W               1
`define CA5_FP_MUL_NEON_ROUND_BITS            8
`define CA5_FP_MUL_NEON_TYPE_W                3
`define CA5_FP_MUL_NEON_TYPE_BITS             11:9
`define CA5_FP_MUL_NEON_OUT_FMT_W             3
`define CA5_FP_MUL_NEON_OUT_FMT_BITS          14:12
`define CA5_FP_MUL_NEON_INV_IS_ZERO_W         1
`define CA5_FP_MUL_NEON_INV_IS_ZERO_BITS      15

`define CA5_NEON_VLD_PERM_EN_W                1
`define CA5_NEON_VLD_PERM_EN_BITS             0
`define CA5_NEON_VLD_DUP_W                    1
`define CA5_NEON_VLD_DUP_BITS                 1
`define CA5_NEON_VLD_INSERT_POS_W             2
`define CA5_NEON_VLD_INSERT_POS_BITS          3:2
`define CA5_NEON_VLD_PERM_SELECT_W            2
`define CA5_NEON_VLD_PERM_SELECT_BITS         5:4

// Define widths for the datapath control busses
`define CA5_FP_NEON_ADD_CTL_W (NEON_0 ? `CA5_FP_NEON_ADD_NEON_INT_SEL_W + `CA5_FP_NEON_ADD_NEON_MUX_SEL_W + `CA5_FP_NEON_ADD_LU_CTL_W +   \
                                        `CA5_FP_NEON_ADD_SIZE_SEL_W + `CA5_FP_NEON_ADD_PERM_SEL_W + `CA5_FP_NEON_ADD_VTB_CYCLE_W +        \
                                        `CA5_FP_NEON_ADD_UNSIGNED_OP_W + `CA5_FP_NEON_ADD_FCTN_SEL_W + `CA5_FP_NEON_ADD_WIDTH_OP_SEL_W +  \
                                        `CA5_FP_NEON_ADD_SAT_OP_SEL_W + `CA5_FP_NEON_ADD_VTST_OP_SEL_W + `CA5_FP_NEON_ADD_MASK_SEL_W : 0)

`define CA5_FP_ADD_CTL_W  (`CA5_FP_NEON_ADD_CTL_W + `CA5_FP_ADD_IN_FORMAT_W + `CA5_FP_ADD_OUT_FORMAT_W + `CA5_FP_ADD_NEGATE_W + \
                           `CA5_FP_ADD_ABS_NEG_W + `CA5_FP_ADD_CMP_W + `CA5_FP_ADD_QNAN_EXCEP_W + `CA5_FP_ADD_FIXED_POINT_W)

`define CA5_FP_NEON_MUL_CTL_W (NEON_0 ? `CA5_FP_MUL_NEON_INV_IS_ZERO_W + `CA5_FP_MUL_NEON_OUT_FMT_W + `CA5_FP_MUL_NEON_TYPE_W + \
                                        `CA5_FP_MUL_NEON_ROUND_W + `CA5_FP_MUL_NEON_SAT_DBL_W + `CA5_FP_MUL_NEON_FIXUP_W +      \
                                        `CA5_FP_MUL_NEON_INT_OP_W : 0)
`define CA5_FP_MUL_CTL_W  (`CA5_FP_NEON_MUL_CTL_W + `CA5_FP_MUL_FUSED_MAC_W + `CA5_FP_MUL_ACCUMULATE_W + `CA5_FP_MUL_PRECISION_W + `CA5_FP_MUL_DIVIDE_W + `CA5_FP_MUL_NEG_SQRT_W)

`define CA5_NEON_VLD_CTL_W (`CA5_NEON_VLD_PERM_SELECT_W + `CA5_NEON_VLD_INSERT_POS_W + `CA5_NEON_VLD_DUP_W + `CA5_NEON_VLD_PERM_EN_W)

`define CA5_FP_PIPECTL_ACCSGN_BITS            4

`define CA5_FP_PIPECTL_FORCE_RN_W             1
`define CA5_FP_PIPECTL_FORCE_RN_BITS          (`CA5_FP_MUL_CTL_W + `CA5_FP_ADD_CTL_W)
`define CA5_FP_PIPECTL_FORCE_RZ_W             1
`define CA5_FP_PIPECTL_FORCE_RZ_BITS          (`CA5_FP_MUL_CTL_W + `CA5_FP_ADD_CTL_W + 1)
`define CA5_FP_PIPECTL_FORCE_DN_FZ_W          1
`define CA5_FP_PIPECTL_FORCE_DN_FZ_BITS       (`CA5_FP_MUL_CTL_W + `CA5_FP_ADD_CTL_W + 2)

// Define the width of the overall FP datapath control bus
`define CA5_FP_PIPECTL_TOP_W ((NEON_0 ? `CA5_NEON_VLD_CTL_W + `CA5_FP_PIPECTL_FORCE_DN_FZ_W : 0) + `CA5_FP_PIPECTL_FORCE_RZ_W + \
                              `CA5_FP_PIPECTL_FORCE_RN_W + `CA5_FP_MUL_CTL_W)
`define CA5_FP_PIPECTL_W     (`CA5_FP_PIPECTL_TOP_W + `CA5_FP_ADD_CTL_W)

// Define how the various control busses are contained within the overall
// datapath control bus
`define CA5_FP_PIPECTL_TOP_BITS     (`CA5_FP_PIPECTL_W-1):(`CA5_FP_ADD_CTL_W)
`define CA5_FP_PIPECTL_MUL_CTL_BITS (`CA5_FP_MUL_CTL_W+`CA5_FP_ADD_CTL_W-1):(`CA5_FP_ADD_CTL_W)
`define CA5_FP_PIPECTL_ADD_CTL_BITS (`CA5_FP_ADD_CTL_W-1):0

`define CA5_FP_PIPECTL_NEON_VLD_BITS (`CA5_FP_PIPECTL_W-1):(`CA5_FP_PIPECTL_FORCE_DN_FZ_W + `CA5_FP_PIPECTL_FORCE_RZ_W +    \
                                                            `CA5_FP_PIPECTL_FORCE_RN_W + `CA5_FP_MUL_CTL_W + `CA5_FP_ADD_CTL_W)

//----------------------------------------------------------------------------
// Neon defines
//----------------------------------------------------------------------------

`define CA5_NEON_LD_PERM_8_0        4'b0000
`define CA5_NEON_LD_PERM_8_1        4'b0001
`define CA5_NEON_LD_PERM_8_2        4'b0010
`define CA5_NEON_LD_PERM_8_3        4'b0011

`define CA5_NEON_LD_PERM_16_0       4'b0100
`define CA5_NEON_LD_PERM_16_1       4'b0101
`define CA5_NEON_LD_PERM_16_2       4'b0110
`define CA5_NEON_LD_PERM_16_3       4'b0111

`define CA5_NEON_LD_PERM_32         4'b1000

`define CA5_NEON_LD_PERM_64         4'b1100

`define CA5_NEON_MUL_TYPE_U8        3'b000
`define CA5_NEON_MUL_TYPE_S8        3'b001
`define CA5_NEON_MUL_TYPE_16        3'b010
`define CA5_NEON_MUL_TYPE_16_LO     3'b100
`define CA5_NEON_MUL_TYPE_16_HI     3'b101
`define CA5_NEON_MUL_TYPE_I32       3'b011

`define CA5_NEON_MUL_OUT_FMT_64     3'b000
`define CA5_NEON_MUL_OUT_FMT_32_L   3'b001
`define CA5_NEON_MUL_OUT_FMT_32_H   3'b010
`define CA5_NEON_MUL_OUT_FMT_4_8    3'b011
`define CA5_NEON_MUL_OUT_FMT_4_16   3'b100
`define CA5_NEON_MUL_OUT_FMT_2_32   3'b101
`define CA5_NEON_MUL_OUT_FMT_2_16_H 3'b110
`define CA5_NEON_MUL_OUT_FMT_VREC   3'b111


//----------------------------------------------------------------------------
// Neon LU defines
//----------------------------------------------------------------------------

`define CA5_NEON_SAT_NONE           2'b00
`define CA5_NEON_SAT_ADD            2'b01
`define CA5_NEON_SAT_SHF_SIGNED     2'b10
`define CA5_NEON_SAT_SHF_UNSIGNED   2'b11

`define CA5_NEON_LU_AND   4'b0001
`define CA5_NEON_LU_BIC   4'b0010
`define CA5_NEON_LU_BIF   4'b0011
`define CA5_NEON_LU_BIT   4'b0100
`define CA5_NEON_LU_BSL   4'b0101
`define CA5_NEON_LU_EOR   4'b0110
`define CA5_NEON_LU_MOV   4'b0111
`define CA5_NEON_LU_MVN   4'b1000
`define CA5_NEON_LU_ORN   4'b1001
`define CA5_NEON_LU_ORR   4'b1010
`define CA5_NEON_LU_VCGT  4'b1100
`define CA5_NEON_LU_VCEQ  4'b1101

//----------------------------------------------------------------------------
// Jazelle DBX defines
//----------------------------------------------------------------------------

`define CA5_JAZ_STATE_W 5
