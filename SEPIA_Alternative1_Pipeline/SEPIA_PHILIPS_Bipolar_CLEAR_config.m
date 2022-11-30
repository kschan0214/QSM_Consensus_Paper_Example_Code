%% SEPIA_PHILIPS_Bipolar_CLEAR_config.m
%
% Objective:
%   (1) Perform QSM recon based on 'Alternative 1' pipeline in the consensus paper
%
% Dependencies: 
%   (1) SEPIA v1.2.0
%   (2) MEDI toolbox
% 
% Data required: 
%   (1) SEPIA-ready multi-echo GRE data from PHILIPS, Bipolar readout,
%   CLEAR normalisation
%   (2) Output files from the 'Standard' pipeline
%
% Kwok-shing Chan @ DCCN
% kwokshing.chan@donders.ru.nl
% Date created: 08 Sep 2022
%
%% Mandatory user input 
% Specify the path of the top directory containing the DICOMs and scripts
% Currently we use a relative path here
% If it doesn't work, or your download the scripts from GitHub, then you
% will have to set specify the path manually

work_dir        = fullfile(pwd,'..','..');

%% Optional user input 
% Input/Output filenames
% You can also specify the directory containing the SEPIA-ready data here

input = struct();
input(1).name   = fullfile(work_dir,'derivatives','SEPIA','PHILIPS','Bipolar_CLEAR','GRE','Pipeline_Standard','sub-001_ses-PHILIPS_acq-BipolarCLEAR_localfield.nii.gz');
input(2).name   = fullfile(work_dir,'derivatives','SEPIA','PHILIPS','Bipolar_CLEAR','GRE','sub-001_ses-PHILIPS_acq-BipolarCLEAR_part-mag_GRE.nii.gz');
input(3).name   = fullfile(work_dir,'derivatives','SEPIA','PHILIPS','Bipolar_CLEAR','GRE','Pipeline_Standard','sub-001_ses-PHILIPS_acq-BipolarCLEAR_weights.nii.gz'); 
input(4).name   = fullfile(work_dir,'derivatives','SEPIA','PHILIPS','Bipolar_CLEAR','GRE','sepia_header.mat');
output_basename = fullfile(work_dir,'derivatives','SEPIA','PHILIPS','Bipolar_CLEAR','GRE','Pipeline_Alternative1','sub-001_ses-PHILIPS_acq-BipolarCLEAR');
mask_filename   = fullfile(work_dir,'derivatives','SEPIA','PHILIPS','Bipolar_CLEAR','GRE','Pipeline_Standard','sub-001_ses-PHILIPS_acq-BipolarCLEAR_mask_QSM.nii.gz');

%%  SEPIA main

% add general Path
sepia_addpath;

algorParam=struct();
% General algorithm parameters
algorParam.general.isBET = 0;
algorParam.general.isInvert = 0;
% QSM algorithm parameters
algorParam.qsm.reference_tissue = 'Brain mask';
algorParam.qsm.method = 'MEDI';
algorParam.qsm.lambda = 2000;
algorParam.qsm.wData = 1;
algorParam.qsm.percentage = 90;
algorParam.qsm.zeropad = [0  0  0];
algorParam.qsm.isSMV = 1;
algorParam.qsm.radius = 5;
algorParam.qsm.merit = 1;
algorParam.qsm.isLambdaCSF = 0;

sepiaIO(input,output_basename,mask_filename,algorParam);
