function M = hip_readM(d, sp, h)
%hip_readM Reads the proper structure
%   Per every subject, construct, lta, etc. we have to read a different volume
%   file from disk, so this small function returns it giving it the proper
%   variables
%   d   = structure with all relevant data to this calculation
%   sp  = Subject_Path: mri path where the hipposubfields are
%   sp = subject_path
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    sel = '';
    if strcmp(d.orig_datos, 'aseg')
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
        LetuHau = char([sp filesep d.hemi{h} '.asegHippo' sel '.mgz']);
        M = MRIread2(LetuHau);
        % In aseg we have 0 and 128 values and we want to have always 0-1
        M.vol = M.vol / 128;
        
    elseif strcmp(d.orig_datos, 'koen')
        M = hip_sum_hippo_subfields(sp, d.hemi{h}, 1, d.eliminar_list);
    elseif strcmp(d.orig_datos, 'eug1')
        sp1 = [sp filesep 'posteriors-fixed-subfields']
        M = hip_sum_hippo_subfields(sp1, d.hemi{h}, 1, d.eliminar_list);
    end


end

