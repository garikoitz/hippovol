function [ M ] = cc_sum(mripath, discreto)
% Returns a FS volume extracting the labels from the hippocampal-subfields results file. 

%   OUTPUT:
%       M:  FS Structure
%   INPUTS:
%       Path: path to the cc_whole.mgz  file (extract whole corpus
%       callosum)
%       hemi: removed var b/c no hemisphere with cc data
%       Include_list: removed var b/c whole cc will be used
%   OPTIONS:    
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2017
% Contact: garikoitz@gmail.com
% DM cc 12/11/17 - adapted from hip_sum_hippo_subfields.m
    % we want a binary output for the CC
        discreto = 1;

     
    
    % Extract the hippo subfields
    
    %fileNameIN  = [mripath filesep 'CC_whole.mgz']; 
    %fileNameOUT = [mripath filesep 'CC_whole_bin.mgz']; 
    %labels2extract = strjoin(include_list);
    %cmd = ['mri_extract_label ' fileNameIN ' '  labels2extract ' '  fileNameOUT];
    %system(cmd)
    % Convert to binary
    % read 1 in order to have a volume
    M = MRIread2([mripath filesep 'CC_whole.mgz']);
    
   
    % If we want to return it binarized
    if discreto == 1
        M.vol(M.vol<128)=0;
        M.vol(M.vol>=128)=1;
    end
    
end

