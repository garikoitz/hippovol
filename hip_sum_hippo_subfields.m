function [ M ] = hip_sum_hippo_subfields(mripath, hemi, discreto, eliminar_list)
%Returns a FS volume adding all the subfields obtained in FS 5.3. It will delete
%the ones in the list below. 

%   OUTPUT:
%       M:  FS Structure
%   INPUTS:
%       Path: path to the posterior_ files
%       hemi: hemisphere
%       discreto = 1: binarized, 0: not binarized, probabilistic values
%       Eliminar_list: list of subfields to eliminate. Use the default below
%   OPTIONS:    
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    
    if nargin < 3
        discreto = 0; % return the probabilistic map
    end
    if nargin<4
        %When reading Koen delete the following
        eliminar_list = {'posterior_Left-Cerebral-Cortex.mgz'
                         'posterior_Left-Cerebral-White-Matter.mgz'
                         'posterior_left_hippocampal_fissure.mgz'
                         'posterior_Right-Cerebral-Cortex.mgz'
                         'posterior_Right-Cerebral-White-Matter.mgz'
                         'posterior_right_hippocampal_fissure.mgz'};
    end
    
    
    % REad the hippo subfields
    if hemi == 'lh'
        temp1 = dir([ mripath filesep 'posterior_l*']); 
        temp2 = dir([ mripath filesep 'posterior_Left-Hip*']); 
        list_hipsubfields = cat(1, temp1, temp2); 
    elseif hemi == 'rh'
        temp3 = dir([ mripath filesep 'posterior_r*']);
        temp4 = dir([ mripath filesep 'posterior_Right-Hip*']);
        list_hipsubfields = cat(1, temp3, temp4);  
    end
    
    d = size(eliminar_list);
    for j = 1:d(1)
        a = size(list_hipsubfields);
        for i = 1:a(1) 
            if isequal(cellstr(list_hipsubfields(i).name),  cellstr(eliminar_list(j)))
                list_hipsubfields(i) = [];
                break
            end
        end    
    end
    size(list_hipsubfields);


    % read 1 in order to have a volume
    M = MRIread2([mripath filesep list_hipsubfields(1).name]);

    % create temporal matrix
    Mtempvol = zeros(size(M.vol));

    % Add the reamining subfields
    % LEFT
    i = 1;
    for nhipsubfield = 1:length(list_hipsubfields)
            %lh_hipsubfields(nhipsubfield).name
            hipposubfield(i) = MRIread2([mripath filesep list_hipsubfields(nhipsubfield).name]);
            Mtempvol = Mtempvol + hipposubfield(i).vol;
            i = i+1;
    end

     % Threshold voxel values
    M.vol = Mtempvol;
   
    % If we want to return it binarized
    if discreto == 1
        M.vol(M.vol<128)=0;
        M.vol(M.vol>=128)=1;
    end
    
end

