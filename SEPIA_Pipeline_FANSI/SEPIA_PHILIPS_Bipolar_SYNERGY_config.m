%% SEPIA_PHILIPS_Bipolar_SYNERGY_config.m
%
% Objective:
%   (1) Perform QSM recon based on 'Pipeline_FANSI' pipeline in the consensus paper
%
% Dependencies: 
%   (1) SEPIA v1.2.2.4
%   (2) ROMEO v3.5.6 
%   (3) FANSI v3
% 
% Data required: 
%   SEPIA-ready multi-echo GRE data from PHILIPS, Bipolar readout, SYNERGY normalisation
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

input           = fullfile(work_dir,'derivatives','SEPIA','PHILIPS','Bipolar_SYNERGY','GRE');
output_basename = fullfile(input,'Pipeline_FANSI','sub-001_ses-PHILIPS_acq-BipolarSYNERGY');
mask_filename   = [''] ;

%% SEPIA Main

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
algorParam.unwrap.isEddyCorrect = 1 ;
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
algorParam.qsm.isGPU = 0 ;
algorParam.qsm.isWeakHarmonic = 1 ;
algorParam.qsm.beta = 150 ;
algorParam.qsm.muh = 3 ;

sepiaIO(input,output_basename,mask_filename,algorParam);
