################Script to merge dummy fill GDS with design GDS
##Inputs, user to specify
set feol_fill_gds ../../feol_fill/outputs/TEST_BLOCK_FEOL.gds
set beol_fill_gds ../../beol_fill/outputs/TEST_BLOCK_BEOL.gds
set out_gds ../outputs/TEST_BLOCK.merged_fill.gds.gz


##dont modify below
set topcell [ layout peek $design_gds -topcell ]
set tmp_feol DM_feol.[pid]
set tmp_beol DM_beol.[pid]
set tmp_fill DM_fill.[pid]



set cmd "layout filemerge -infile \{ -name $feol_fill_gds -suffix \"_DM_feol_fill\" \} -out $tmp_feol"
eval $cmd
set cmd "layout filemerge -infile \{ -name $beol_fill_gds -suffix \"_DM_beol_fill\" \} -out $tmp_beol"
eval $cmd
layout filemerge -createtop $topcell -out $tmp_fill -in $tmp_feol -in $tmp_beol
layout filemerge -in $tmp_fill -in $design_gds -out $out_gds
exit

