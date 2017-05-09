function [ M ] = hip_sum_hippo_subfieldsfs6(mripath, hemi, discreto, include_list)
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
    
    fileNameIN  = [mripath filesep hemi '.hippoSfLabels-T1.v10.mgz']; 
    fileNameOUT = [mripath filesep hemi '.hippoSfLabels-T1.v10_SOLOHIP.mgz']; 
    labels2extract = strjoin(include_list);
    cmd = ['mri_extract_label ' fileNameIN ' '  labels2extract ' '  fileNameOUT];
    system(cmd)
    % Convert to binary
    % read 1 in order to have a volume
    M = MRIread2([mripath filesep hemi '.hippoSfLabels-T1.v10_SOLOHIP.mgz']);
    
   
    % If we want to return it binarized
    if discreto == 1
        M.vol(M.vol<128)=0;
        M.vol(M.vol>=128)=1;
    end
    
end

