LAYOUT PRIMARY "TEST_BLOCK"
LAYOUT SYSTEM GDSII
DRC SUMMARY REPORT "TEST_BLOCK.summary"
DRC MAXIMUM RESULTS ALL
DRC RESULTS DATABASE "TEST_BLOCK_BEOL.gds" GDSII _BEOL_fill
#DEFINE UserprBoundary

INCLUDE "/proj1/pdk/foundries/tsmc/N28/versions/v1.0/metal_stack/1P9M_4X2Y2R/dummyfill_ruledeck/calibre/Dummy_Metal_Via_Calibre_28nm.13a"

