function [lta] = hippovol(mat_filename)
% Main function
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

load(mat_filename);
% load('/bcbl/home/public/Gari/PCA/glm/datos_05/mats/PERC_Bezier_Acqu_201')

methodName = strcat(orientation, method, ComoPost);

hip_Data = struct('methodName', methodName(1), ...
                  'method', method, ...
                  'structName', structName, ...
                  'sufixName', sufixName, ...
                  'SUBJECTS_DIR', SUBJECTS_DIR, ...
                  'glm_datos_dir', glm_datos_dir, ...
                  'matDir', mat_dirs, ...
                  'orig_datos', orig_datos, ...
                  'orden', orden, ...
                  'mydecimate', mydecimate, ...
                  'DEBUG', DEBUG, ...
                  'WRITE_MGZ', WRITE_MGZ, ...
                  'subjects', struct(), ...
                  'lta', lta, ...
                  'orientation', orientation, ...
                  'mat_dirs', mat_dirs, ...
                  'optim', optim, ...
                  'perc', perc);
hip_Data.rater = Rater;
hip_Data.subjects = sub;
numSub = length(sub);
hd = hip_InitMethod(hip_Data);

% RESULTADOS = struct('fileizena', hd.fileizena, ...
%                     'sujetos', struct());
%                 
%     for mm = 1:length(hd.subjects)
%        RESULTADOS.sujetos.(hd.subjects(mm).name) = zeros(1,8);
%     end
% Now that we have the data prepared for this particular case of hippovol, now
% we are going to run through all the subjects. 
    
    
    %par
    for nsub = 1:numSub
        % sujetos = sub; % specifying for parfor
        if strcmp(hd.orig_datos, 'manual')
            subject_path = [hd.SUBJECTS_DIR filesep hd.subjects(nsub).name];
        else
            subject_path = [hd.SUBJECTS_DIR filesep hd.subjects(nsub).name filesep 'mri'];
        end
        valores = zeros(1,8); % Initialize each value to zero
        valoresPERC = zeros(1,2);
        % hd.subjects(nsub).name
        % Do it per each hemisphere
        for h=1:length(hd.hemi)
            %% READ THE DATA FOR THIS SUBJECT
            M = hip_readM(hd, subject_path, h);
            % For Landmark, read the uncal apex landmark
            if(strcmp(hd.method, 'Landmark'))
                punto = hd.puntos.data(nsub, h) + 1;
                % Add 1, Matlab starts in 1 and the landmark was given in freeview
                % hd.punto  = punto;   
            elseif(strcmp(hd.method, 'MNI'))
                % BE CAREFUL, the MNI case is just for demo purposes for
                % the paper, but I will leave the code here. The thing is
                % that the total values in the case of the MNI are going to
                % be different since the talairach.lta transformation is
                % affine but not linea, so the total volume will be
                % multiplied by the Jacobian of the talairach
                % transformation matrix. We are interested in the uncal
                % apex cut, and that will be done properly, so in R we will
                % correct the volumes dividing them by the new total and
                % multipliying them by the aseg original volume, so we will
                % have the same total volume and it will maintain the
                % proportions of each of the segments. 
                MNI_Y = -20;
                punto3 = inv(M.vox2ras1) * [1; MNI_Y; 1; 1];
                punto = round(punto3(3)) +1;
                % better thought, it is going to be better to read the
                % talairach.lta in Matlab and make the script writ the
                % correct values. 
                tal = lta_read([subject_path filesep 'transforms' filesep ...
                                'talairach.lta']);
                jacobian = abs(det(tal));
            elseif(strcmp(hd.method, 'PERC'))
                % We will use the punto variable to transmit the percentaje
                % values (usually 35%, but now we are testing 30:0.1:40
                punto = hd.perc;

            else
                error('This is not a recognized METHOD');
            end    

            %% CALCULATIONS DEPENDING ON THE METHOD
            % The name of the function to call has been defined in the
            % hip_InitMethod function
            
            if(strcmp(hd.method, 'MNI'))
                [HEAD, POSTERIOR, BODY, TAIL, perc] = hip_AcquLandmarkInsausti(hd, M, punto); 
                M.vol = M.vol(:) / jacobian;
                HEAD.vol = HEAD.vol(:) / jacobian;
                POSTERIOR.vol = POSTERIOR.vol(:) / jacobian;
                BODY.vol = BODY.vol(:) / jacobian;
                TAIL.vol = TAIL.vol(:) / jacobian;
            elseif(strcmp(hd.method, 'Landmark'))
                % COde for Eugenio's check
                if (strcmp(hd.orientation, 'Bezier'))
                    [HEAD, POSTERIOR, BODY, TAIL, perc] = hip_BezierLandmarkInsausti(hd, M, punto);
                    valoresPERC(h) = perc;
                else
                    [HEAD, POSTERIOR, BODY, TAIL, perc] = hip_AcquLandmarkInsausti(hd, M, punto);
                    valoresPERC(h) = perc;  
                end
            else
                if isdeployed
                    if(strcmp(hd.orientation, 'Bezier'))
                        [HEAD, POSTERIOR, BODY, TAIL] = hip_BezierPERCInsausti(hd, M, punto);
                    elseif(strcmp(hd.orientation, 'PCA'))
                        [HEAD, POSTERIOR, BODY, TAIL] = hip_PCAPERCInsausti(hd, M, punto);
                    end
                else
                    fhandle = str2func(hd.fName);
                    [HEAD, POSTERIOR, BODY, TAIL] = fhandle(hd, M, punto);
                end
            end
                
            if hd.WRITE_MGZ > 0 % == true write the volumes to file
                disp('Calling function to write mgz labels...');
                resp = hip_writeM(HEAD, POSTERIOR, BODY, TAIL, hd, subject_path, h); 
                disp(resp);
            end

            % Save the volumetric values and send them back 
            valores(hd.hemivalor4{h}) = [sum(M.vol(:)),  sum(HEAD.vol(:)), ...
                                         sum(BODY.vol(:)), sum(TAIL.vol(:))];
        end
        % Save results in variable outside parfor to write it afterwards
        % per each subject
        if(strcmp(hd.method, 'PERC'))
            dir4tempMats = [hd.mat_dirs filesep 'perc' num2str(hd.perc)];
            mkdirquiet(dir4tempMats);
            parsave([dir4tempMats filesep hd.subjects(nsub).name '.mat'], valores);
        elseif(strcmp(hd.method, 'Landmark'))
            dir4tempMats = [hd.mat_dirs filesep 'lta_' hd.lta];
            mkdirquiet(dir4tempMats);
            parsave([dir4tempMats filesep hd.subjects(nsub).name '.mat'], valores);
            % Save the percetnage values corresponding to the landmark
            parsave([dir4tempMats filesep hd.subjects(nsub).name '_PERC.mat'], valoresPERC);
        else
            dir4tempMats = [hd.mat_dirs filesep 'lta_' hd.lta];
            mkdirquiet(dir4tempMats);
            parsave([dir4tempMats filesep hd.subjects(nsub).name '.mat'], valores);
        end
    end
    % Now write it:
    fileID = fopen(hd.fileizena, 'a');
    for nn = 1:length(hd.subjects)
        tmp = load([dir4tempMats filesep hd.subjects(nn).name]);
        fprintf(fileID, hd.formato_valores, ...
                hd.subjects(nn).name, tmp.valores);
    end 
    fclose(fileID)
    
    % Save the percetnage values corresponding to the landmark
    if(strcmp(hd.method, 'Landmark'))
       fileIDPERC = fopen(hd.fileizenaPERC, 'a'); 
       for nn = 1:length(hd.subjects)
            tmpPERC = load([dir4tempMats filesep hd.subjects(nn).name '_PERC']);
            fprintf(fileIDPERC, hd.formato_valoresPERC, ...
                hd.subjects(nn).name, tmpPERC.valoresPERC);
       end
       fclose(fileIDPERC)
    end

    % After it has finished with everything delete all .mat files, even the
    % one that made the call and return to hip_run
    rmdir(dir4tempMats, 's');
end

