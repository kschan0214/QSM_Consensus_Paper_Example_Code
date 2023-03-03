#! /bin/bash
#
# Convert DICOM images into NIFTI format
#
# Tested on OS: (1) Linux CentOS 7; (2) macOS 12.6
# Dependencies: (1) dcm2niix (tested on version 1.0.20220720)
#
# Creator: Kwok-shing Chan @DCCN
# kwokshing.chan@donders.ru.nl
# Date created: 08 Sep 2022
# Date edit:
################################################################################

##### User input #####
# Specify the path of the top directory containing the DICOMs and scripts
# Currently we use a relative path here
# If it doesn't work, or your download the scripts from GitHub, then you will have to set specify the path manually
export work_dir=$(pwd)/../../
##### End of user input #####

export raw_dir=${work_dir}raw/
export converted_dir=${work_dir}converted/

vendor=( 'GE' 'PHILIPS' 'SIEMENS' )

## loop through all vendors
for curr_vendor in "${vendor[@]}"; do
echo ${curr_vendor}

## loop through all sub-directories for all vendors
for sub_dir in ${raw_dir}$curr_vendor/*; do

## get basename of sub-directory without full path
sub_dir_name=`basename ${sub_dir}`
sub_dir_name=${sub_dir_name}
echo ${sub_dir_name}

# create new output sub-directory
out_dir=${converted_dir}${curr_vendor}/${sub_dir_name}/GRE
mkdir -p ${out_dir}
echo $out_dir

## convert DICOM to compressed NIfTI
dcm2niix -z y -o ${out_dir} ${sub_dir}

done
done

