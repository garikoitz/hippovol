function M = hip_readM(d, sp, h)
%hip_readM Reads the proper structure
%   Per every subject, construct, lta, etc. we have to read a different volume
%   file from disk, so this small function returns it giving it the proper
%   variables
%   d   = structure with all relevant data to this calculation
%   sp  = Subject_Path: mri path where the hipposubfields are
%   h   = hemi, if relevant
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    sel = '';
    switch d.orig_datos
        case {'fsaseg'}
            hemi1 = d.hemi{h}(1);
            if  strcmp(d.method, 'Landmark')
                rater = d.lta(1);
                meth = d.lta(2:end); 
                if strcmp(meth, 'Acqu')
                    sel = '';
                elseif nnz(strcmp(meth, {'T1', 'T2'}))
                    sel = ['_inter_' hemi1 rater meth(end)];
                elseif nnz(strcmp(meth, {'PCA1', 'PCA2'}))
                    sel = ['_inter_' meth(1:3) d.hemi{h}];
                end
            elseif  strcmp(d.method, 'MNI')
                sel = '_interfloat_MNI';
            else 
                if strcmp(d.lta, 'Acqu')
                    sel = '';
                elseif nnz(strcmp(d.lta, {'A', 'B', 'A1', 'A2', 'B1', 'B2'}))
                    sel = ['_inter_' hemi1 d.lta];
                elseif strcmp(d.lta, 'PCA')
                    sel = ['_inter_' d.lta d.hemi{h}];
                end
            end
            LetuHau = char([sp filesep d.hemi{h} '.' d.hipName sel '.' d.hipExt]);
            M = MRIread2(LetuHau);
            % In aseg we have 0 and 128 values and we want to have always 0-1
            M.vol = M.vol / 128;

        case {'fs5'}
            M = hip_sum_hippo_subfields(sp, d.hemi{h}, 1, d.eliminar_list);
        case {'fs6'}
            M = hip_sum_hippo_subfieldsfs6(sp, d.hemi{h}, 1, d.fs6_include_list, d.hipName);
        case {'manual'}
            LetuHau = char([sp filesep d.hemi{h} '.' d.hipName sel '.' d.hipExt]);
            % [p,f,e] = fileparts(sp);
            % M = MRIread2([p filesep d.hemi{h} '.' f e]);
            M = MRIread2(LetuHau);
            unicos = unique(M.vol); 
            if 2 ~= size(unicos,1) || 1 ~= unicos(2)
                disp('This is not a binary mask, only 0 and 1 values are accepted')
                disp('Converting volume to 0-s and 1-s')
                M.vol(M.vol>0) = 1;
            end
        % DM 12/4/17 cc    
        case {'cc'}
            LetuHau = char([sp filesep d.hipName sel '.' d.hipExt]);
            % [p,f,e] = fileparts(sp);
            % M = MRIread2([p filesep d.hemi{h} '.' f e]);
            M = MRIread2(LetuHau);
            unicos = unique(M.vol); 
            if 2 ~= size(unicos,1) || 1 ~= unicos(2)
                disp('This is not a binary mask, only 0 and 1 values are accepted')
                disp('Converting volume to 0-s and 1-s')
                M.vol(M.vol>0) = 1;
            end
            
        otherwise
            error([d.orig_datos ' does not exist: only aseg, fs5, fs6, cc and manual accepted.'])
    end
end

