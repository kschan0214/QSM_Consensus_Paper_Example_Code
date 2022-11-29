%% Preparation_02_rename_to_bids_format.m
% (1) Concatenate multiple 3D volumn multi-echo data into a 4D file
% (2) Create SEPIA header file for each dataset
% Kwok-shing Chan @ DCCN
% kwokshing.chan@donders.ru.nl
% Date created: 08 Sep 2022
% Dependency: SEPIA v1.1.0

%% Step 1: convert 3D volumes into 4D
% add path
sepia_addpath

% directories to work on, adapt 'work_dir' to your location
work_dir        = fullfile(pwd,'..');

converted_dir   = fullfile(work_dir,'converted');
derivatives_dir = fullfile(work_dir,'derivatives');

derivatives_sepia = fullfile(derivatives_dir,'SEPIA');

vendor          = {'GE' ,'PHILIPS' ,'SIEMENS'};

% loop for all vendors
for curr_vendor = vendor
     
    % get sub directory list from the vendor
    subdirectory_list = dir(fullfile(converted_dir,curr_vendor{1}));
    subdirectory_list = subdirectory_list(~ismember({subdirectory_list(:).name},{'.','..'}));

    for ksubD = 1:length(subdirectory_list)

        % get input directory
        input_dir   = fullfile(subdirectory_list(ksubD).folder,subdirectory_list(ksubD).name,'GRE');
        output_dir  = fullfile(derivatives_sepia, curr_vendor{1},subdirectory_list(ksubD).name,'GRE');
        
        mkdir(output_dir)
        
        % get JSON filename in order to also access NIFTI name
        json_list = dir(fullfile(input_dir, '*part-mag*json'));
        
        num_echo = length(json_list);
        
        try
        switch curr_vendor{1}
            case 'GE'
                filename_prefix = extractBefore(json_list(1).name, 'part-mag');
                
                % magnitude
                img = [];
                for kecho = 1:num_echo
                    curr_echo_filename = strcat(filename_prefix, 'part-mag_echo-', num2str(kecho),'_GRE.nii.gz');
                    
                    img = cat(4,img, load_nii_img_only(fullfile(input_dir,curr_echo_filename)));
                end
                output_filename = strcat(filename_prefix, 'part-mag_GRE.nii.gz');
                save_nii_img_only(fullfile(input_dir,curr_echo_filename),fullfile(output_dir,output_filename),img);
                
                % obtain phase from real/imaginary pair
                img_real        = [];
                img_imaginary   = [];
                for kecho = 1:num_echo
                    curr_echo_real_filename         = strcat(filename_prefix, 'part-real_echo-', num2str(kecho),'_GRE.nii.gz');
                    curr_echo_imaginary_filename    = strcat(filename_prefix, 'part-imaginary_echo-', num2str(kecho),'_GRE.nii.gz');
                    
                    tmp_real                    = load_nii_img_only(fullfile(input_dir,curr_echo_real_filename));
                    tmp_imaginary               = load_nii_img_only(fullfile(input_dir,curr_echo_imaginary_filename));
                    tmp_real(:,:,2:2:end)       = -tmp_real(:,:,2:2:end);
                    tmp_imaginary(:,:,2:2:end)  = -tmp_imaginary(:,:,2:2:end);
                    
                    % correct interslice opposite signs
                    img_real        = cat(4,img_real, tmp_real);
                    img_imaginary   = cat(4,img_imaginary, tmp_imaginary);
                    
                end
                img = angle(complex(img_real,img_imaginary));
                
                output_filename = strcat(filename_prefix, 'part-phase_GRE.nii.gz');
                save_nii_img_only(fullfile(input_dir,curr_echo_filename),fullfile(output_dir,output_filename),img);
                
            otherwise
                
                filename_prefix = extractBefore(json_list(1).name, 'part-mag');
                
                % magnitude & phase
                img_mag     = [];
                img_phase   = [];
                for kecho = 1:num_echo
                    curr_echo_mag_filename      = strcat(filename_prefix, 'part-mag_echo-', num2str(kecho),'_GRE.nii.gz');
                    curr_echo_phase_filename    = strcat(filename_prefix, 'part-phase_echo-', num2str(kecho),'_GRE.nii.gz');
                    
                    img_mag     = cat(4,img_mag, load_nii_img_only(fullfile(input_dir,curr_echo_mag_filename)));
                    img_phase   = cat(4,img_phase, load_nii_img_only(fullfile(input_dir,curr_echo_phase_filename)));
                end
                output_mag_filename     = strcat(filename_prefix, 'part-mag_GRE.nii.gz');
                output_phase_filename   = strcat(filename_prefix, 'part-phase_GRE.nii.gz');
                save_nii_img_only(fullfile(input_dir,curr_echo_mag_filename),fullfile(output_dir,output_mag_filename),img_mag);
                save_nii_img_only(fullfile(input_dir,curr_echo_mag_filename),fullfile(output_dir,output_phase_filename),img_phase);
      
        end
        catch
            disp(input_dir)
        end
    end                
end

%% Step 2: save sepia header for each dataset
% loop for all vendors
for curr_vendor = vendor
     
    % get sub directory list from the vendor
    subdirectory_list = dir(fullfile(converted_dir,curr_vendor{1}));
    subdirectory_list = subdirectory_list(~ismember({subdirectory_list(:).name},{'.','..'}));

    for ksubD = 1:length(subdirectory_list)

        % get input directory
        input_dir   = fullfile(subdirectory_list(ksubD).folder,subdirectory_list(ksubD).name,'GRE/');
        output_dir  = fullfile(derivatives_sepia, curr_vendor{1},subdirectory_list(ksubD).name,'GRE/');
        
        try
            
            save_sepia_header(input_dir,[],output_dir);
        
        catch
            disp(input_dir)
        end
    end                
end
