%% SEPIA_GE_Monopolar_config.m
%
% Objective:
%   (1) Perform QSM recon based on 'Alternative 2' pipeline in the consensus paper
%
% Dependencies: 
%   (1) SEPIA v1.2.0
%   (2) FANSI toolbox v3
% 
% Data required: 
%   (1) SEPIA-ready multi-echo GRE data from GE, Monopolar readout
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
input(1).name   = fullfile(work_dir,'derivatives','SEPIA','GE','Monopolar','GRE','Pipeline_Standard','sub-001_ses-GE_acq-Monopolar_localfield.nii.gz');
input(2).name   = '';
input(3).name   = fullfile(work_dir,'derivatives','SEPIA','GE','Monopolar','GRE','Pipeline_Standard','sub-001_ses-GE_acq-Monopolar_weights.nii.gz'); 
input(4).name   = fullfile(work_dir,'derivatives','SEPIA','GE','Monopolar','GRE','sepia_header.mat');
output_basename = fullfile(work_dir,'derivatives','SEPIA','GE','Monopolar','GRE','Pipeline_Alternative2','sub-001_ses-GE_acq-Monopolar');
mask_filename   = fullfile(work_dir,'derivatives','SEPIA','GE','Monopolar','GRE','Pipeline_Standard','sub-001_ses-GE_acq-Monopolar_mask_QSM.nii.gz');

%%  SEPIA main

% add general Path
sepia_addpath;

% General algorithm parameters
algorParam = struct();
algorParam.general.isBET = 0 ;
algorParam.general.isInvert = 0 ;
% QSM algorithm parameters
algorParam.qsm.reference_tissue = 'Brain mask' ;
algorParam.qsm.method = 'FANSI' ;
algorParam.qsm.tol = 0.1 ;
algorParam.qsm.maxiter = 400 ;
algorParam.qsm.lambda = 0.0005 ;
algorParam.qsm.mu1 = 0.05 ;
algorParam.qsm.mu2 = 1 ;
algorParam.qsm.solver = 'Non-linear' ;
algorParam.qsm.constraint = 'TV' ;
algorParam.qsm.gradient_mode = 'Vector field' ;
algorParam.qsm.isWeakHarmonic = 1 ;
algorParam.qsm.beta = 150 ;
algorParam.qsm.muh = 3 ;

sepiaIO(input,output_basename,mask_filename,algorParam);
