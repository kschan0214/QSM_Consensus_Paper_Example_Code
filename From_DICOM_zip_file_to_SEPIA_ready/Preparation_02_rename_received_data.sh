#! /bin/bash
#
# Convert DICOM images into NIFTI format
#
# Tested on OS: (1) Linux CentOS 7; (2) macOS 12.6
#
# Creator: Kwok-shing Chan @DCCN
# kwokshing.chan@donders.ru.nl
# Date created: 08 Sep 2022
# Date edit:
################################################################################

############### User input ###############
# Specify the path of the top directory containing the DICOMs and scripts
# Currently we use a relative path here
# If it doesn't work, or your download the scripts from GitHub, then you will have to set specify the path manually
export work_dir=$(pwd)/../../
############### End of user input ##########

# DICOM image will be stored in raw directory
export raw_dir=${work_dir}raw/

vendor=( 'GE' 'PHILIPS' 'SIEMENS' )

# create raw dir for DICOM
mkdir ${raw_dir}

# unzip file
unzip ${work_dir}QSM_CONSENSUS_DATA.zip -d ${work_dir}

# move files from unzipped directory to raw directory
mv ${work_dir}QSM_CONSENSUS_DATA/* ${raw_dir}
# remove unzipped directory
rmdir ${work_dir}QSM_CONSENSUS_DATA

# rename and restructure the content of the DICOMs in the raw directory
mv ${raw_dir}GE/BIPOLAR_8E ${raw_dir}GE/Bipolar
mv ${raw_dir}GE/MONOPOLAR_6E ${raw_dir}GE/Monopolar
mv ${raw_dir}PHILLIPS ${raw_dir}PHILIPS
mv ${raw_dir}PHILIPS/CLEAR/BIPOLAR_7E ${raw_dir}PHILIPS/Bipolar_CLEAR
mv ${raw_dir}PHILIPS/CLEAR/MONOPOLAR_5E ${raw_dir}PHILIPS/Monopolar_CLEAR
mv ${raw_dir}PHILIPS/SYNERGY/BIPOLAR_7E ${raw_dir}PHILIPS/Bipolar_SYNERGY
mv ${raw_dir}PHILIPS/SYNERGY/MONOPOLAR_5E ${raw_dir}PHILIPS/Monopolar_SYNERGY
mv ${raw_dir}SIEMENS/BIPOLAR_7E ${raw_dir}SIEMENS/Bipolar
mv ${raw_dir}SIEMENS/MONOPOLAR_5E ${raw_dir}SIEMENS/Monopolar
# remove empty folders
rm -rf ${raw_dir}PHILIPS/CLEAR
rm -rf ${raw_dir}PHILIPS/SYNERGY
