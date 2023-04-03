%% SEPIA_SIEMENS_Monopolar_config.m
%
% Objective:
%   (1) Perform QSM recon based on 'Pipeline_MEDI' pipeline in the consensus paper
%
% Dependencies: 
%   (1) SEPIA v1.2.2.4
%   (2) ROMEO v3.5.6 
%   (3) MEDI
% 
% Data required: 
%   SEPIA-ready multi-echo GRE data from SIEMENS, Monopolar readout
%
% Kwok-shing Chan @ DCCN
% kwokshing.chan@donders.ru.nl
% Date created: 08 Sep 2022
% Date modified: 30 March 2023 (v0.2.1)
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

input           = fullfile(work_dir,'derivatives','SEPIA','SIEMENS','Monopolar','GRE');
output_basename = fullfile(input,'Pipeline_MEDI','sub-001_ses-SIEMENS_acq-Monopolar');
mask_filename   = [''] ;

%% SEPIA main

% add general Path
sepia_addpath;

% General algorithm parameters
algorParam = struct();
algorParam.general.isBET = 1 ;
algorParam.general.fractional_threshold = 0.5 ;
algorParam.general.gradient_threshold = 0 ;
algorParam.general.isInvert = 0 ;
% Total field recovery algorithm parameters
algorParam.unwrap.echoCombMethod = 'ROMEO total field calculation' ;
algorParam.unwrap.offsetCorrect = 'On' ;
algorParam.unwrap.mask = 'SEPIA mask' ;
algorParam.unwrap.qualitymaskThreshold = 0.5 ;
algorParam.unwrap.useRomeoMask = 0 ;
algorParam.unwrap.isEddyCorrect = 0 ;
algorParam.unwrap.isSaveUnwrappedEcho = 0 ;
algorParam.unwrap.excludeMaskThreshold = 0.3 ;
algorParam.unwrap.excludeMethod = 'Weighting map' ;
% Background field removal algorithm parameters
algorParam.bfr.refine_method = 'None' ;
algorParam.bfr.refine_order = 2 ;
algorParam.bfr.erode_before_radius = 1;
algorParam.bfr.erode_radius = 0 ;
algorParam.bfr.method = 'VSHARP' ;
algorParam.bfr.radius = [12:-1:1] ;
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
