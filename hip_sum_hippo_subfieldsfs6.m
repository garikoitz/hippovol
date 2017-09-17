function [ M ] = hip_sum_hippo_subfieldsfs6(mripath, hemi, discreto, include_list, hipName)
% Returns a FS volume extracting the labels from the hippocampal-subfields results file. 

%   OUTPUT:
%       M:  FS Structure
%   INPUTS:
%       Path: path to the ?h.hippoSfLabels-T1.v10.mgz  files
%       hemi: hemisphere
%       Include_list: list of subfields to include. Use the default below. Edit
%                     in hip_InitMethod.m
%   OPTIONS:    
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2017
% Contact: garikoitz@gmail.com
    if nargin < 4
        discreto = 1;
    end
    
    
    if nargin < 4
        %When reading Koen delete the following
        fs6_include_list={  '201' % alveus
                            '203' % parasubiculum
                            '204' % presubiculum
                            '205' % subiculum
                            '206' % CA1
                            '207' % CA2
                            '208' % CA3
                            '209' % CA4
                            '210' % GC-DG
                            % '211' % HATA
                            '212' % fimbria
                            '214' % molecular_layer_HP
                            % '215' % hippocampal_fissure
                            '226' % HP_tail
                            };
    end
    
    
    % Extract the hippo subfields
    
    fileNameIN  = [mripath filesep hemi '.' hipName '.mgz']; 
    fileNameOUT = [mripath filesep hemi '.' hipName '_SOLOHIP.mgz']; 
    labels2extract = strjoin(include_list);
    cmd = ['mri_extract_label ' fileNameIN ' '  labels2extract ' '  fileNameOUT];
    system(cmd)
    % Convert to binary
    % read 1 in order to have a volume
    if exist(fileNameOUT, 'file')
        % When using fs6 default 0.33 (non VoxelSpace) files, I've seen that they
        % are changed from LIA orientation to LIP. 
        % Check if the file is LIP, if so, change it to LIA
        [status,result] = system(['mri_info --orientation ' fileNameOUT]);
        if strcmp(result(1:3), 'LIP')
            system(['mri_convert --out_orientation LIA ' fileNameOUT ' ' mripath filesep hemi '.temp.mgz'])
            % delete fileNameOUT;
            movefile([mripath filesep hemi '.temp.mgz'], fileNameOUT)
        end
        
        M = MRIread2(fileNameOUT);
        
    else
        error(['Could not find file: ' fileNameOUT ', most probable cause is that mri_extract_label could not execute. Make sure that Freesurfer is installed and in the path. In Mac you might need to start Matlab from the command line to be able to read the environment variables. If it does not work harcode the whole path of the mri_extract_label file in your system. This is the code it is trying to run if you need to launch it manually, the important thing is to have a binay hippocampus: ' cmd])
    end
   
    
    
    
    
    
    % If we want to return it binarized
    if discreto == 1
        M.vol(M.vol<128)=0;
        M.vol(M.vol>=128)=1;
    end
    
end

