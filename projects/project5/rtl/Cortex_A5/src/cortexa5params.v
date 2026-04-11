//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2010  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2010-08-20 09:33:38 +0100 (Fri, 20 Aug 2010) $
//
//      Revision            : $Revision: 146307 $
//
//      Release Information : CORTEX-A5-MPCore-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Global defines for cortexa5 CPU
//
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
//-----------------------------------------------------------------------------

// ID values are derived from these defines.  Those marked * potentially need
// incrementing on revisions
`define CA5_REVISION 4'b0001        // * the "p" part of eg. r1p0
`define CA5_VARIANT  4'b0000        // * the "r" part of eg. r1p0
`define CA5_PERPH_REVISION 4'b0001      // * a number incremented on every revision/patch
`define CA5_PERPH_REV_AND 4'b0000       // * ID incremented by manufacturer on ECO fixes
`define CA5_VFP_REVISION `CA5_PERPH_REVISION// * Revision of VFP

`define CA5_IMPLEMENTOR 8'h41      // ARM
`define CA5_ARCH_REVISED 4'hf      // Refer to v7 ID scheme
`define CA5_PART_NUM_11_8 4'hc // Cortex
`define CA5_PART_NUM_7_0 8'h05 // A5
`define CA5_VFP_SUBARCH 7'b000_0010// v3 architecture with v2 common subarchitecture
`define CA5_VFP_PART_NUM 8'h30     // Cortex A
`define CA5_VFP_VARIANT 4'h5       // (Cortex-A)5
`define CA5_JAZ_SUBARCH_MAJ 8'h00  // Jazelle v1.x
`define CA5_JAZ_SUBARCH_MIN 4'h1   // (Jazelle v1).1

//Values for Read only "ID" style CP registers
//--------------------------------------------

//ID Code Register (MIDR)
`define CA5_IDCR_READ_VALUE(rev) {`CA5_IMPLEMENTOR,`CA5_VARIANT,`CA5_ARCH_REVISED,`CA5_PART_NUM_11_8,`CA5_PART_NUM_7_0,rev}

//Debug ID Register
// for DIDR_READ_VALUE see below - DIDR defined there

//Cache Type Register
`define CA5_CTR_READ_VALUE    32'h83338003

//MPU Type Register - MPUTR_READ_VALUE defined in ca5dpu_cp_registers.v

// Multi Processor ID Register
// For a uniprocessor, the cluster and cpu ids will be zero,
// but including them in the ID removes a lint warning
`define CA5_MPIDR_READ_VALUE(cluster_id,cpu_id)  (MULTIPROCESSOR ? {20'h80000, cluster_id[3:0], 6'h00, cpu_id[1:0]} \
                                                             : {20'hc0000, cluster_id[3:0], 6'h00, cpu_id[1:0]})

`define CA5_CLIDR_READ_VALUE 32'h09200003

`define CA5_COMP0ID_RD_VAL 32'h0000000D
`define CA5_COMP1ID_RD_VAL 32'h00000090
`define CA5_COMP2ID_RD_VAL 32'h00000005
`define CA5_COMP3ID_RD_VAL 32'h000000B1

`define CA5_PMU_PART_NUM 12'h9A5

// extended ID register set values
`define CA5_ID_PFR0_READ_VALUE  32'h00001231
`define CA5_ID_PFR1_READ_VALUE  32'h00000011
`define CA5_ID_DFR0_READ_VALUE  32'h02010444
`define CA5_ID_AFR0_READ_VALUE  32'h00000000
  
`define CA5_ID_MMFR0_READ_VALUE (MULTIPROCESSOR ? 32'h00100103 : 32'h00100003)
`define CA5_ID_MMFR1_READ_VALUE 32'h40000000
`define CA5_ID_MMFR2_READ_VALUE 32'h01230000
`define CA5_ID_MMFR3_READ_VALUE 32'h00102211
`define CA5_ID_ISAR0_READ_VALUE 32'h00101111
`define CA5_ID_ISAR1_READ_VALUE 32'h13112111
`define CA5_ID_ISAR2_READ_VALUE 32'h21232041
`define CA5_ID_ISAR3_READ_VALUE 32'h11112131
`define CA5_ID_ISAR4_READ_VALUE 32'h00011142
`define CA5_ID_ISAR5_READ_VALUE 32'h00000000
`define CA5_ID_FCSE_READ_VALUE  32'h00000000

`define CA5_PMCFGR_READ_VALUE   32'h0009DF02
`define CA5_PMCEID0_READ_VALUE  32'h003fffff

`define CA5_FPSID_READ_VALUE(rev) {`CA5_IMPLEMENTOR,1'b0,`CA5_VFP_SUBARCH,`CA5_VFP_PART_NUM,`CA5_VFP_VARIANT,rev[3:0]}
`define CA5_MVFR0_READ_VALUE (NEON_0 ? 32'h10110222 : 32'h10110221)
`define CA5_MVFR1_READ_VALUE (NEON_0 ? 32'h11111111 : 32'h11000011)

`define CA5_JIDR_READ_VALUE {`CA5_ARCH_REVISED,`CA5_IMPLEMENTOR,`CA5_JAZ_SUBARCH_MAJ,`CA5_JAZ_SUBARCH_MIN,1'b0,1'b1,6'd10}

// ----------------------------------
// Debug Register offsets
// ----------------------------------

`define CA5_DBG_DIDR        11'h000 //(13'h0_000>>2) // Debug ID Register.
`define CA5_DBG_WFAR        11'h006 //(13'h0_018>>2) // Watchpoint Fault Address Register.
`define CA5_DBG_VCR         11'h007 //(13'h0_01C>>2) // Vector Catch Register.
`define CA5_DBG_ECR         11'h009 //(13'h0_024>>2) // Event Catch Register.
`define CA5_DBG_DSCCR       11'h00A //(13'h0_028>>2) // Debug State Cache Control Register.
`define CA5_DBG_DSMCR       11'h00B //(13'h0_02C>>2) // Debug State MMU Control Register.
`define CA5_DBG_DTRRXext    11'h020 //(13'h0_080>>2) // Host -> Target Data Transfer Register.
`define CA5_DBG_ITR         11'h021 //(13'h0_084>>2) // Instruction Transfer Register.
`define CA5_DBG_DSCRext     11'h022 //(13'h0_088>>2) // Debug Status and Control Register.
`define CA5_DBG_DTRTXext    11'h023 //(13'h0_08C>>2) // Target -> Host Data Transfer Register.
`define CA5_DBG_DRCR        11'h024 //(13'h0_090>>2) // Debug Run Control Register.
`define CA5_DBG_PCSR        11'h028 //(13'h0_0A0>>2) // Program Counter Sampling Register.
`define CA5_DBG_CIDSR       11'h029 //(13'h0_0A4>>2) // Context ID Sampling Register.
`define CA5_DBG_VIDSR       11'h02A //(13'h0_0A8>>2) // VMID Sampling Register.
// `define CA5_DBG_BVRy/-  (13'h0_100-13'h0_13C) // Breakpoint Value Registers/RESERVED.
`define CA5_DBG_BVR0        11'h040 //(13'h0_100>>2) // Breakpoint Value Register 0
`define CA5_DBG_BVR1        11'h041 //(13'h0_104>>2) // Breakpoint Value Register 1
`define CA5_DBG_BVR2        11'h042 //(13'h0_108>>2) // Breakpoint Value Register 2
`define CA5_DBG_BVR3        11'h043 //(13'h0_10C>>2) // Breakpoint Value Register 3
`define CA5_DBG_BVR4        11'h044 //(13'h0_110>>2) // Breakpoint Value Register 4
`define CA5_DBG_BVR5        11'h045 //(13'h0_114>>2) // Breakpoint Value Register 5
`define CA5_DBG_BVR6        11'h046 //(13'h0_118>>2) // Breakpoint Value Register 6
`define CA5_DBG_BVR7        11'h047 //(13'h0_11C>>2) // Breakpoint Value Register 7
// `define CA5_DBG_BCRy/-  (13'h0_140-13'h0_17C) // Breakpoint Control Registers/RESERVED.
`define CA5_DBG_BCR0        11'h050 //(13'h0_140>>2) // Breakpoint Control Register 0
`define CA5_DBG_BCR1        11'h051 //(13'h0_144>>2) // Breakpoint Control Register 1
`define CA5_DBG_BCR2        11'h052 //(13'h0_148>>2) // Breakpoint Control Register 2
`define CA5_DBG_BCR3        11'h053 //(13'h0_14C>>2) // Breakpoint Control Register 3
`define CA5_DBG_BCR4        11'h054 //(13'h0_150>>2) // Breakpoint Control Register 4
`define CA5_DBG_BCR5        11'h055 //(13'h0_154>>2) // Breakpoint Control Register 5
`define CA5_DBG_BCR6        11'h056 //(13'h0_158>>2) // Breakpoint Control Register 6
`define CA5_DBG_BCR7        11'h057 //(13'h0_15C>>2) // Breakpoint Control Register 7
// `define CA5_DBG_WVRy/-  (13'h0_180-13'h0_1BC) // Watchpoint Value Registers/RESERVED.
`define CA5_DBG_WVR0        11'h060 //(13'h0_180>>2) // Watchpoint Value Register 0
`define CA5_DBG_WVR1        11'h061 //(13'h0_184>>2) // Watchpoint Value Register 1
`define CA5_DBG_WVR2        11'h062 //(13'h0_188>>2) // Watchpoint Value Register 2
`define CA5_DBG_WVR3        11'h063 //(13'h0_18C>>2) // Watchpoint Value Register 3
`define CA5_DBG_WVR4        11'h064 //(13'h0_190>>2) // Watchpoint Value Register 4
`define CA5_DBG_WVR5        11'h065 //(13'h0_194>>2) // Watchpoint Value Register 5
`define CA5_DBG_WVR6        11'h066 //(13'h0_198>>2) // Watchpoint Value Register 6
`define CA5_DBG_WVR7        11'h067 //(13'h0_19C>>2) // Watchpoint Value Register 7
// `define CA5_DBG_WCRy/-  (13'h0_1C0-13'h0_1FC) // Watchpoint Control Registers/RESERVED.
`define CA5_DBG_WCR0        11'h070 //(13'h0_1C0>>2) // Watchpoint Control Register 0
`define CA5_DBG_WCR1        11'h071 //(13'h0_1C4>>2) // Watchpoint Control Register 1
`define CA5_DBG_WCR2        11'h072 //(13'h0_1C8>>2) // Watchpoint Control Register 2
`define CA5_DBG_WCR3        11'h073 //(13'h0_1CC>>2) // Watchpoint Control Register 3
`define CA5_DBG_WCR4        11'h074 //(13'h0_1D0>>2) // Watchpoint Control Register 4
`define CA5_DBG_WCR5        11'h075 //(13'h0_1D4>>2) // Watchpoint Control Register 5
`define CA5_DBG_WCR6        11'h076 //(13'h0_1D8>>2) // Watchpoint Control Register 6
`define CA5_DBG_WCR7        11'h077 //(13'h0_1DC>>2) // Watchpoint Control Register 7
`define CA5_DBG_OSLAR       11'h0C0 //(13'h0_300>>2) // OS Lock Access Register.
`define CA5_DBG_OSLSR       11'h0C1 //(13'h0_304>>2) // OS Lock Status Register.
`define CA5_DBG_OSSRR       11'h0C2 //(13'h0_308>>2) // OS Save/Restore Register.
`define CA5_DBG_PRCR        11'h0C4 //(13'h0_310>>2) // Device Power-down & Reset Control Register.
`define CA5_DBG_PRSR        11'h0C5 //(13'h0_314>>2) // Device Power-down & Reset Status Register.
`define CA5_DBG_MIDR        11'h340 //(13'h0_D00>>2) //
`define CA5_DBG_CTR         11'h341 //(13'h0_D04>>2) //
`define CA5_DBG_TCMTR       11'h342 //(13'h0_D08>>2) //
`define CA5_DBG_TLBTR       11'h343 //(13'h0_D0C>>2) //
`define CA5_DBG_MPUIR       11'h344 //(13'h0_D10>>2) // Not applicable to VMSA memory system
`define CA5_DBG_MPIDR       11'h345 //(13'h0_D14>>2) //
`define CA5_DBG_RESERVED    11'h346 //(13'h0_D18>>2) //
`define CA5_DBG_FEATID      11'h347 //(13'h0_D1C>>2) //
`define CA5_DBG_ID_PFR0     11'h348 //(13'h0_D20>>2) //
`define CA5_DBG_ID_PFR1     11'h349 //(13'h0_D24>>2) //
`define CA5_DBG_ID_DFR0     11'h34A //(13'h0_D28>>2) //
`define CA5_DBG_ID_AFR0     11'h34B //(13'h0_D2C>>2) //
`define CA5_DBG_ID_MMFR0    11'h34C //(13'h0_D30>>2) //
`define CA5_DBG_ID_MMFR1    11'h34D //(13'h0_D34>>2) //
`define CA5_DBG_ID_MMFR2    11'h34E //(13'h0_D38>>2) //
`define CA5_DBG_ID_MMFR3    11'h34F //(13'h0_D3C>>2) //
`define CA5_DBG_ID_ISAR0    11'h350 //(13'h0_D40>>2) //
`define CA5_DBG_ID_ISAR1    11'h351 //(13'h0_D44>>2) //
`define CA5_DBG_ID_ISAR2    11'h352 //(13'h0_D48>>2) //
`define CA5_DBG_ID_ISAR3    11'h353 //(13'h0_D4C>>2) //
`define CA5_DBG_ID_ISAR4    11'h354 //(13'h0_D50>>2) //
`define CA5_DBG_ID_ISAR5    11'h355 //(13'h0_D54>>2) //
`define CA5_DBG_ITETMIF     11'h3B6 //(13'h0_ed8>>2) // Integration register (ETM interface - Read Only)
`define CA5_DBG_ITMISCOUT   11'h3BE //(13'h0_ef8>>2) // Integration register (Misc signals - Write Only)
`define CA5_DBG_ITMISCIN    11'h3BF //(13'h0_efc>>2) // Integration register (ETMWFI Pending - Write Only)
`define CA5_DBG_ITCTRL      11'h3C0 //(13'h0_f00>>2) // Integration Mode Control register
`define CA5_DBG_CLAIMSET    11'h3E8 //(13'h0_fa0>>2) // Claim Tag Set Register
`define CA5_DBG_CLAIMCLR    11'h3E9 //(13'h0_fa4>>2) // Claim Tag Clear Register
`define CA5_DBG_LAR         11'h3EC //(13'h0_fb0>>2) // Lock Access Register
`define CA5_DBG_LSR         11'h3ED //(13'h0_fb4>>2) // Lock Status Register
`define CA5_DBG_AUTHSTATUS  11'h3EE //(13'h0_fb8>>2) // Authentication Status Register
`define CA5_DBG_DEVID       11'h3F2 //(13'h0_fc8>>2) // Debug Device ID Register
`define CA5_DBG_DEVTYPE     11'h3F3 //(13'h0_fcc>>2) // Device Type Register
`define CA5_DBG_PID4        11'h3F4 //(13'h0_fd0>>2) // Peripheral ID4 register
`define CA5_DBG_PID0        11'h3F8 //(13'h0_fe0>>2) // Peripheral ID0 register
`define CA5_DBG_PID1        11'h3F9 //(13'h0_fe4>>2) // Peripheral ID1 register
`define CA5_DBG_PID2        11'h3FA //(13'h0_fe8>>2) // Peripheral ID2 register
`define CA5_DBG_PID3        11'h3FB //(13'h0_fec>>2) // Peripheral ID3 register
`define CA5_DBG_CID0        11'h3FC //(13'h0_ff0>>2) // Component ID0 register
`define CA5_DBG_CID1        11'h3FD //(13'h0_ff4>>2) // Component ID1 register
`define CA5_DBG_CID2        11'h3FE //(13'h0_ff8>>2) // Component ID2 register
`define CA5_DBG_CID3        11'h3FF //(13'h0_ffc>>2) // Component ID3 register

// ----------------------------------
// PMU Register offsets
// ----------------------------------

`define CA5_PMU_PM0EVCNTR   11'h400 //(13'h1_000>>2) // PM0 Counter Register
`define CA5_PMU_PM1EVCNTR   11'h401 //(13'h1_004>>2) // PM1 Counter Register
`define CA5_PMU_PMCCNTR     11'h41F //(13'h1_07C>>2) // Cycle Count Register
`define CA5_PMU_PM0EVTYPER  11'h500 //(13'h1_400>>2) // PM0 Event Type Register
`define CA5_PMU_PM1EVTYPER  11'h501 //(13'h1_404>>2) // PM1 Event Type Register
`define CA5_PMU_PMCCFILTR   11'h51F //(13'h1_47C>>2) // Cycle Count Filter Control Register
`define CA5_PMU_PMCNTENSET  11'h700 //(13'h1_C00>>2) // Count Enable Set Register
`define CA5_PMU_PMCNTENCLR  11'h708 //(13'h1_C20>>2) // Count Enable Clear Register
`define CA5_PMU_PMINTENSET  11'h710 //(13'h1_C40>>2) // Interrupt Enable Set Register
`define CA5_PMU_PMINTENCLR  11'h718 //(13'h1_C60>>2) // Interrupt Enable Clear Register
`define CA5_PMU_PMOVSR      11'h720 //(13'h1_C80>>2) // Overflow Flag Status Register
`define CA5_PMU_PMSWINC     11'h728 //(13'h1_CA0>>2) // Software Increment Register
`define CA5_PMU_PMCFGR      11'h780 //(13'h1_E00>>2) // Configuration Register
`define CA5_PMU_PMCR        11'h781 //(13'h1_E04>>2) // Control Register
`define CA5_PMU_PMUSERENR   11'h782 //(13'h1_E08>>2) // User Enable Register
`define CA5_PMU_PMCEID0     11'h788 //(13'h1_E20>>2) // Common Event Identification Register
`define CA5_PMU_LAR         11'h7EC //(13'h1_FB0>>2) // Lock Access Register
`define CA5_PMU_LSR         11'h7ED //(13'h1_FB4>>2) // Lock Status Register
`define CA5_PMU_AUTHSTATUS  11'h7EE //(13'h1_FB8>>2) // Authentication Status Register
`define CA5_PMU_DEVTYPE     11'h7F3 //(13'h1_FCC>>2) // Device Type Register
`define CA5_PMU_PID4        11'h7F4 //(13'h1_FD0>>2) // Peripheral ID4 register
`define CA5_PMU_PID0        11'h7F8 //(13'h1_FE0>>2) // Peripheral ID0 register
`define CA5_PMU_PID1        11'h7F9 //(13'h1_FE4>>2) // Peripheral ID1 register
`define CA5_PMU_PID2        11'h7FA //(13'h1_FE8>>2) // Peripheral ID2 register
`define CA5_PMU_PID3        11'h7FB //(13'h1_FEC>>2) // Peripheral ID3 register
`define CA5_PMU_CID0        11'h7FC //(13'h1_FF0>>2) // Component ID0 register
`define CA5_PMU_CID1        11'h7FD //(13'h1_FF4>>2) // Component ID1 register
`define CA5_PMU_CID2        11'h7FE //(13'h1_FF8>>2) // Component ID2 register
`define CA5_PMU_CID3        11'h7FF //(13'h1_FFC>>2) // Component ID3 register

// ----------------------------------
// Debug Identification Register DIDR
// ----------------------------------

`define CA5_DBG_VER     4'b0011 // Debug architecture version ARMv7.0, with CP14 interface
`define CA5_NUM_BRP_CID 4'h0    // Number of Break point Register Pairs with context ID comparison capability -1
                            // Note: 4'b0000 => 1 register pair. For details
                            // please refer to the v7debug architecture spec.

`define CA5_NUM_BRP 4'h2        // Number of implemented Breakpoint Pairs -1
`define CA5_NUM_WRP 4'h1        // Number of implemented Watchpoint Register Pair -1

//                                                          [11:8]  - reserved (RAZ)---------------------------
//                                                          [12]    - Security extensions implemented----     |
//                                                          [13]    - PCSR implemented--------------    |     |
//                                                          [14]    - No Secure User Halting Debug |    |     |
//                                                          [15]    - DBGDEVID implemented    |    |    |     |
//                                                                                       |    |    |    |     |
`define CA5_DIDR_READ_VALUE(rev) {`CA5_NUM_WRP,`CA5_NUM_BRP,`CA5_NUM_BRP_CID,`CA5_DBG_VER,1'b1,1'b1,1'b1,1'b1,4'b0000,`CA5_VARIANT,rev}

`define CA5_DBGDEVID_READ_VALUE  32'h00000f13

// --------------
// OVL assertions (also defined in std_ovl_defines.h)
// --------------

// severity_level parameter (first parameter in list)
`define OVL_FATAL   0
`define OVL_ERROR   1
`define OVL_WARNING 2
`define OVL_INFO    3

// property_type (aka options) parameter (parameter just before the message string)
`define OVL_ASSERT 0
`define OVL_ASSUME 1

//----------------------------------
// D-side and I-side Fault Encodings
//---------------------------------

`define CA5_FAULT_ALIGNMENT          5'b00001 // Alignment fault (D-side only)
`define CA5_FAULT_ICACHE_MAINTENANCE 5'b00100 // Instruction cache maintenance fault
`define CA5_FAULT_PAGEWALK_EXT1_DEC  5'b01100 // External abort on 1st level descriptor (Decode)
`define CA5_FAULT_PAGEWALK_EXT1_SLV  5'b11100 // External abort on 1st level descriptor (Slave)
`define CA5_FAULT_PAGEWALK_EXT2_DEC  5'b01110 // External abort on 2nd level descriptor (Decode)
`define CA5_FAULT_PAGEWALK_EXT2_SLV  5'b11110 // External abort on 2nd level descriptor (Slave)
`define CA5_FAULT_TRANSLATION_SEC    5'b00101 // Translation fault on a section
`define CA5_FAULT_TRANSLATION_PAGE   5'b00111 // Translation fault on a page
`define CA5_FAULT_ACCESS_SEC         5'b00011 // Access flag fault on a section
`define CA5_FAULT_ACCESS_PAGE        5'b00110 // Access flag fault on a page
`define CA5_FAULT_DOMAIN_SEC         5'b01001 // Domain fault on a section
`define CA5_FAULT_DOMAIN_PAGE        5'b01011 // Domain fault on a page
`define CA5_FAULT_PERMISSION_SEC     5'b01101 // Permission fault on a section
`define CA5_FAULT_PERMISSION_PAGE    5'b01111 // Permission fault on a page
`define CA5_FAULT_EXT_DEC            5'b01000 // External AXI decode error
`define CA5_FAULT_EXT_SLV            5'b11000 // External AXI slave error

//-----------------------------------------------------------------------------
// Memory attribute decoding
//-----------------------------------------------------------------------------

`define CA5_MEM_NORMAL(attrs)    (attrs[0])
`define CA5_MEM_DEV(attrs)       (~attrs[0] & ~attrs[3])
`define CA5_MEM_SO(attrs)        (~attrs[0] & attrs[3])
`define CA5_MEM_CACHEABLE(attrs) (attrs[2])
`define CA5_MEM_NC(attrs)        (attrs[0] & ~attrs[2])
`define CA5_MEM_SHAREABLE(attrs) (attrs[1])

// DPU/DCU interface defines
`define CA5_LDST_SIZE_BYTE    2'b00 // Byte        (8-bits)  - LDRB
`define CA5_LDST_SIZE_HWORD   2'b01 // Half word   (16-bits) - LDRH
`define CA5_LDST_SIZE_WORD    2'b10 // Word        (32-bits) - LDR/LDM/FLDS/FLDMS
`define CA5_LDST_SIZE_NONUSE0 2'b11
`define CA5_LDST_SIZE_X       2'bxx

// ----------
// RAM widths
// ----------

// Instruction Cache
`define CA5_IDATA_RAM_ADDR_W  12
`define CA5_IDATA_RAM_W       72
`define CA5_IDATA_WEN_W        8
`define CA5_ITAG_RAM_ADDR_W   10
`define CA5_ITAG_RAM_W        24

// Data Cache
`define CA5_DDATA_RAM_ADDR_W  12
`define CA5_DDATA_RAM_W       32
`define CA5_DDATA_WEN_W        4
`define CA5_DTAG_RAM_ADDR_W    9
`define CA5_DTAG_RAM_W        26
`define CA5_DDIRTY_RAM_ADDR_W  9
`define CA5_DDIRTY_RAM_W      12

// TLB
`define CA5_TLB_RAM_ADDR_W     6
`define CA5_TLB_RAM_W         63

// -----------
// Cache sizes
// -----------

`define CA5_SIZE_4K  4'b0000 // 4KB
`define CA5_SIZE_8K  4'b0001 // 8KB
`define CA5_SIZE_16K 4'b0011 // 16KB
`define CA5_SIZE_32K 4'b0111 // 32KB
`define CA5_SIZE_64K 4'b1111 // 64KB

// ---------------------------
// Maximum interrupts and CPUs
// ---------------------------

`define CA5_MAX_NUM_INTS 224
`define CA5_MAX_NUM_CPUS 4

// -------------
// AXI encodings
// -------------

`define CA5_RESP_OKAY   2'b00
`define CA5_RESP_EXOKAY 2'b01
`define CA5_RESP_SLVERR 2'b10
`define CA5_RESP_DECERR 2'b11
 
// -----------------------------------------------
// Helper defines for RTL configuration parameters
// -----------------------------------------------

`define genif(a)    generate if (a) begin
`define genelsif(a) end else if (a) begin
`define genelse     end else begin
`define genendif    end endgenerate

// Max and min macros for two parameters
`define max(a,b)    ((a)>=(b) ? (a) : (b))
`define min(a,b)    ((a)<=(b) ? (a) : (b))

// Max macro for three parameters (to avoid nested macros)
`define max3(a,b,c)   ((a)>=(b) ? (((a)>=(c) ? (a) : (c))) : (((b)>=(c) ? (b) : (c))))

// log2 function for integers from 2 to 256 (inclusive).  Results are rounded up.
// Returns 1 for inputs less than 2 and -1 for inputs greater than 256.
`define log2(a)     (((a)<=2) ? 1 : ((a)<=4) ? 2 : ((a)<=8) ? 3 : ((a)<=16) ? 4 : ((a)<=32) ? 5 : ((a)<=64) ? 6 : ((a)<=128) ? 7 : ((a)<=256) ? 8 : -1)

//-----------------------------------------------------------------------------
// RTL configuration parameters for different units
//----------------------------------------------------------------------------

`define NORAM_PARAM_DECL #(parameter MULTIPROCESSOR = 1'b0, parameter NUM_CPUS = 4, parameter L2_CACHE_PRESENT = 1'b0, parameter FPU_0 = 1'b0, parameter NEON_0 = 1'b0, parameter JAZELLE_0 = 1'b0, parameter INOPTIONS = 0, parameter OUTOPTIONS = 0)
`define NORAM_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR), .NUM_CPUS(NUM_CPUS), .L2_CACHE_PRESENT(L2_CACHE_PRESENT), .FPU_0(FPU_0), .NEON_0(NEON_0), .JAZELLE_0(JAZELLE_0), .INOPTIONS(INOPTIONS), .OUTOPTIONS(OUTOPTIONS))

// Based on NORAM_PARAM_DECL. Includes CPU number for individual RAM size configuration
`define MP_CORE_PARAM_DECL #(parameter MULTIPROCESSOR = 1'b0, parameter NUM_CPUS = 4, parameter CPU_NUMBER = 0, parameter L2_CACHE_PRESENT = 1'b0, parameter FPU_0 = 1'b0, parameter NEON_0 = 1'b0, parameter JAZELLE_0 = 1'b0, parameter INOPTIONS = 0, parameter OUTOPTIONS = 0)

`define MP_CORE0_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR), .NUM_CPUS(NUM_CPUS), .CPU_NUMBER(0), .L2_CACHE_PRESENT(L2_CACHE_PRESENT), .FPU_0(FPU_0), .NEON_0(NEON_0), .JAZELLE_0(JAZELLE_0), .INOPTIONS(INOPTIONS), .OUTOPTIONS(OUTOPTIONS))
`define MP_CORE1_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR), .NUM_CPUS(NUM_CPUS), .CPU_NUMBER(1), .L2_CACHE_PRESENT(L2_CACHE_PRESENT), .FPU_0(FPU_1), .NEON_0(NEON_1), .JAZELLE_0(JAZELLE_1), .INOPTIONS(INOPTIONS), .OUTOPTIONS(OUTOPTIONS))
`define MP_CORE2_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR), .NUM_CPUS(NUM_CPUS), .CPU_NUMBER(2), .L2_CACHE_PRESENT(L2_CACHE_PRESENT), .FPU_0(FPU_2), .NEON_0(NEON_2), .JAZELLE_0(JAZELLE_2), .INOPTIONS(INOPTIONS), .OUTOPTIONS(OUTOPTIONS))
`define MP_CORE3_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR), .NUM_CPUS(NUM_CPUS), .CPU_NUMBER(3), .L2_CACHE_PRESENT(L2_CACHE_PRESENT), .FPU_0(FPU_3), .NEON_0(NEON_3), .JAZELLE_0(JAZELLE_3), .INOPTIONS(INOPTIONS), .OUTOPTIONS(OUTOPTIONS))


`define BIU_PARAM_DECL #(parameter MULTIPROCESSOR = 1'b0)
`define BIU_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR))

`define DPU_PARAM_DECL #(parameter MULTIPROCESSOR = 1'b0, parameter FPU_0 = 1'b0, parameter NEON_0 = 1'b0, parameter JAZELLE_0 = 1'b0)
`define DPU_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR), .FPU_0(FPU_0), .NEON_0(NEON_0), .JAZELLE_0(JAZELLE_0))

`define ICU_PARAM_DECL #(parameter MULTIPROCESSOR = 1'b0, parameter JAZELLE_0 = 1'b0)
`define ICU_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR), .JAZELLE_0(JAZELLE_0))

`define DCU_PARAM_DECL #(parameter MULTIPROCESSOR = 1'b0, parameter NUM_CPUS = 4, parameter L2_CACHE_PRESENT = 1'b0)
`define DCU_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR), .NUM_CPUS(NUM_CPUS), .L2_CACHE_PRESENT(L2_CACHE_PRESENT))

`define PFU_PARAM_DECL #(parameter JAZELLE_0 = 1'b0)
`define PFU_PARAM_INST #(.JAZELLE_0(JAZELLE_0))

`define TLB_PARAM_DECL #(parameter MULTIPROCESSOR = 1'b0, parameter JAZELLE_0 = 1'b0)
`define TLB_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR), .JAZELLE_0(JAZELLE_0))

`define SCU_PARAM_DECL #(parameter NUM_CPUS = 4, parameter L2_CACHE_PRESENT = 1'b0, parameter TWO_AXI_MASTERS = 1'b0, parameter NUM_INTS = 32, parameter ACP_PRESENT = 0)
`define SCU_PARAM_INST #(.NUM_CPUS(NUM_CPUS), .L2_CACHE_PRESENT(L2_CACHE_PRESENT), .TWO_AXI_MASTERS(TWO_AXI_MASTERS), .NUM_INTS(NUM_INTS), .ACP_PRESENT(ACP_PRESENT))

`define STB_PARAM_DECL #(parameter MULTIPROCESSOR = 1'b0, parameter NUM_CPUS = 4, parameter L2_CACHE_PRESENT = 1'b0)
`define STB_PARAM_INST #(.MULTIPROCESSOR(MULTIPROCESSOR), .NUM_CPUS(NUM_CPUS), .L2_CACHE_PRESENT(L2_CACHE_PRESENT))

`define MP_PARAM_DECL #(parameter ACP_PRESENT = 1'b1, parameter NUM_CPUS = 1, parameter NUM_INTS = 32, parameter TWO_AXI_MASTERS = 1, parameter FPU_0 = 0, parameter NEON_0 = 0, parameter JAZELLE_0 = 0, parameter FPU_1 = 0, parameter NEON_1 = 0, parameter JAZELLE_1 = 0, parameter FPU_2 = 0, parameter NEON_2 = 0, parameter JAZELLE_2 = 0, parameter FPU_3 = 0, parameter NEON_3 = 0, parameter JAZELLE_3 = 0)

`define RAM_PARAM_DECL #(parameter CPU_NUMBER = 0)
`define RAM_PARAM_INST #(.CPU_NUMBER(CPU_NUMBER))
