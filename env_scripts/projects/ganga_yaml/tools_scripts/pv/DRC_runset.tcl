LAYOUT PRIMARY "aes_cipher_top"
LAYOUT SYSTEM GDSII
DRC RESULTS DATABASE "aes_cipher_top.db"
DRC SUMMARY REPORT "aes_cipher_top.summary"
DRC MAXIMUM RESULTS ALL

//#DEFINE WITH_SEALRING       // Turn on if sealring is assembled in chip
//VARIABLE PAD_TEXT  "PAD_pin_name1" "PAD_pin_name2"

#DEFINE UserprBoundary
//#DEFINE DFM               // Turn on to check DFM rules 

INCLUDE "/proj1/pdk/foundries/tsmc/N28/versions/v1.0/metal_stack/1P9M_4X2Y2R/drc_ruledeck/calibre/calibre.drc"
