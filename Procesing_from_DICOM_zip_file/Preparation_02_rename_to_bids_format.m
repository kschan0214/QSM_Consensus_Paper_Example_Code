%% Preparation_02_rename_to_bids_format.m
% Rename dcm2niix output to BIDS alike format
% 
% Kwok-shing Chan @ DCCN
% kwokshing.chan@donders.ru.nl
% Date created: 08 Sep 2022
% Compartibility: Matlab R2016b onward due to the use of contains.m
%% main
% directories to work on
work_dir        = fullfile(pwd,'..');
converted_dir   = fullfile(work_dir,'converted/');

vendor          = {'GE' ,'PHILIPS' ,'SIEMENS'};

% loop for all vendors
for curr_vendor = vendor
     
    % get sub directory list from the vendor
    subdirectory_list = dir(fullfile(converted_dir,curr_vendor{1}));
    subdirectory_list = subdirectory_list(~ismember({subdirectory_list(:).name},{'.','..'}));

    for ksubD = 1:length(subdirectory_list)

        % get input directory
        input_dir = fullfile(subdirectory_list(ksubD).folder,subdirectory_list(ksubD).name,'GRE');

        % get JSON filename in order to also access NIFTI name
        json_list = dir(fullfile(input_dir, '*json'));
        for kjson = 1:length(json_list)

            json_fn = json_list(kjson).name;

            % read JSON
            json_txt = fileread( fullfile(input_dir, json_fn));
            json_info = jsondecode(json_txt);

            % check readout polarity
            isBipolar = contains(lower(json_fn),'bipolar');
            if isBipolar
                readout_polarity = 'Bipolar';
            else
                readout_polarity = 'Monopolar';
            end
            % check data type
            if contains(lower(json_fn),'imaginary')
                data_type = 'imaginary';
            elseif contains(lower(json_fn),'real')
                data_type = 'real';
            elseif contains(lower(json_fn),'ph')
                data_type = 'phase';
            else
                data_type = 'mag';
            end
            % check Philips Normalisation method
            if contains(lower(json_fn),'clear')
                norm_method = 'CLEAR';                  % only Philips has this label
            elseif contains(lower(json_fn),'synergy')
                norm_method = 'SYNERGY';                % only Philips has this label
            else
                norm_method = '';                       % otherwise
            end

            % construct BIDs compartible key|value pairs
            subj_label  = 'sub-001';
            ses_label   = ['ses-' curr_vendor{1}];
            acq_label   = ['acq-' readout_polarity norm_method]; % this is atypical string but indicate the main differences without making the name too long
%                         acq_label   = ['acq-' curr_vendor{1} '-' json_info.ProtocolName '-' readout_polarity]; % this is atypical string but more informative to indicate the vendor difference
            echo_label  = ['echo-' num2str(json_info.EchoNumber)];
            part_label  = ['part-' data_type];

            % BIDs compartibale
            BIDsFilebasename = strcat(subj_label,'_',ses_label,'_',acq_label,'_',part_label,'_',echo_label,'_','GRE');

            % replace space by underscore
            BIDsFilebasename            = regexprep(BIDsFilebasename,' ', '_');
            [~,originalFilebasename,~]  = fileparts(json_fn);
            
            % rename both JSON and NIFTI
            if ~strcmp(originalFilebasename,BIDsFilebasename)
                movefile(fullfile(input_dir,[originalFilebasename '.json']),  fullfile(input_dir,[BIDsFilebasename '.json']));
                movefile(fullfile(input_dir,[originalFilebasename '.nii.gz']),fullfile(input_dir,[BIDsFilebasename '.nii.gz']));
            end
        end
    end                
end
