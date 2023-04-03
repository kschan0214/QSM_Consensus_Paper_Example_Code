#! /bin/bash
#
# Convert DICOM images into NIFTI format
#
# Dependencies: (1) ANTs
#
# Creator: Kwok-shing Chan @DCCN
# kwokshing.chan@donders.ru.nl
# Date created: 08 Sep 2022
# Date edit:
################################################################################

export work_dir=/project/3015069.01/pilot/qsmhubTestdata/QSM_consensus_paper/Script_validation/QSM_Consensus_Paper_Example_DICOM_Code_v0.2.1/
export raw_dir=${work_dir}raw/
export scripts_dir=${work_dir}QSM_Consensus_Paper_Example_Code/
export converted_dir=${work_dir}converted/
export derivatives_dir=${work_dir}derivatives/

# pipeline='SEPIA_Pipeline_MEDI'
pipeline='SEPIA_Pipeline_FANSI'

fn=( `ls ${scripts_dir}${pipeline}` )

for curr_fn in "${fn[@]}"; do

echo $curr_fn
matlab_sub --walltime 02:00:00 --mem 10gb ${scripts_dir}${pipeline}/${curr_fn}

done