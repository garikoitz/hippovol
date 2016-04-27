%%%%%%%%%%% 1 %%%%%%%%%%%%%%%    
% Landmarks: From KOEN to ASEG %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change landmarks from Koen to aseg. 

% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    orig_datos = 'aseg';
    fileID = fopen([glm_datos_dir filesep structName '_' methodName '_' orig_datos '_' sufixName '.txt'],'w');
    fprintf(fileID, '%s \n', cabecera);
    % Read coordinates
    if orig_datos == 'aseg'
        filename = [SUBJECTS_DIR filesep 'landmarks_' orig_datos '_head_jueces.txt'];
    elseif orig_datos =='koen'
        filename = [SUBJECTS_DIR filesep 'landmarks_' orig_datos '_head_jueces.txt'];
    elseif orig_datos =='eug1'
        filename = [SUBJECTS_DIR filesep 'landmarks_' orig_datos '_head_jueces.txt'];
    end
    delimiterIn = ' '; headerlinesIn = 1;
    puntos = importdata(filename,delimiterIn,headerlinesIn);
    % NOTE: add +1 for Matlab, we are reading with 0 in FS
    for nsub = 1:length(sub)
        sub(nsub).name 
        methodName
        orig_datos
        workpath = [SUBJECTS_DIR filesep sub(nsub).name filesep 'mri'];
        cd(workpath);
        valores = zeros(1,8); % Initialize volume values per sbject to zero

        for h=1:length(hemi)
            hemi{h}
            
            A = MRIread2([hemi{h} '.asegHippo.mgz']);
            K = sum_hippo_subfields(workpath, hemi{h}, 1, eliminar_list);
            
           
           
            punto = zeros(1,3);
            i = 0;
            for k = hemivalor3{h}
                i = i+1;
                punto(i) = puntos.data(nsub, k);
            end
            
            puntonew = round(inv(K.vox2ras) * A.vox2ras * [punto(1);punto(2);punto(3);1]);
            puntonew(3)
        end
        
    end

