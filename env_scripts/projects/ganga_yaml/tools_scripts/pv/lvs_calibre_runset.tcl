LAYOUT PRIMARY "aes_cipher_top"
LAYOUT PATH "../merge_fill/outputs/aes_cipher_top.merged_fill.gds.gz"
LAYOUT SYSTEM GDSII

SOURCE PRIMARY "aes_cipher_top"
SOURCE PATH "../cdl/outputs/aes_cipher_top.cdl"
SOURCE SYSTEM SPICE

LVS SPICE CULL PRIMITIVE SUBCIRCUITS   YES

VARIABLE POWER_NAME  "VDD" "vdd" 

VARIABLE GROUND_NAME "VSS" "vss" "GND" "gnd" 

INCLUDE "/proj1/pdk/foundries/tsmc/N28/versions/v1.0/metal_stack/1P9M_4X2Y2R/lvs_ruledeck/calibre/calibre.lvs"
