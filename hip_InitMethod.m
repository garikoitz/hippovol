 function d = hip_InitMethod(d);
%hip_InitMethod Initializes filenames, etc. before doing the calculations
%   Initializes the method variables and returns them in order to be able
%   to do the calculations afterwards. 

%   04/2015: GLU: First version as an independent function
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com


% GLU: 2018-01-03: for cc, removing the hemispheres

    switch d.method
        case {'MNI', 'Landmark','PERC'}
            if strcmp(d.orig_datos,'cc')
                d.bblta = ['_' d.lta];    
                d.hemi = {'cc'};
                d.hemivalor4{1} = 1:4;
                d.cabecera = ['   ID   , Total, Head, Body, Tail  '];
                d.formato_valores = ['%4s,  %6d,  %6d,  %6d,  %6d \n'];
            else
                d.bblta = ['_' d.lta];    
                d.hemi = {'lh', 'rh'};
                d.hemivalor4{1} = 1:4; 
                d.hemivalor4{2} = 5:8;
                d.cabecera = ['   ID   , lh_Total, lh_Head, lh_Body, lh_Tail,  ' ...
                              '          rh_Total, rh_Head, rh_Body, rh_Tail'];
                d.formato_valores = ['%4s,  %6d,  %6d,  %6d,  %6d,  ' ...
                                     '%6d,  %6d,  %6d,   %6d \n'];
            end
        case {'nDivisions'}
            if strcmp(d.orig_datos,'cc')
                d.bblta = ['_' d.lta];    
                d.hemi = {'cc'};
                d.hemivalor4{1} = 1:(1+d.howManyN);
                d.cabecera = ['ID,Total'];
                d.formato_valores = ['%4s,%6d'];
                for ii=1:d.howManyN
                    d.cabecera = [d.cabecera ',Div' num2str(ii)];
                    d.formato_valores = [d.formato_valores ',%6d']; 
                end
                d.formato_valores = [d.formato_valores ' \n'];
                
            else
                d.bblta = ['_' d.lta];    
                d.hemi = {'lh', 'rh'};
                d.hemivalor4{1} = 1:(1+d.howManyN);
                d.hemivalor4{2} = (2+d.howManyN):(2+2*d.howManyN);
                
                % Left
                leftCabecera = ['lh_Total'];
                leftFormato = ['%6d'];
                for ii=1:d.howManyN
                    leftCabecera = [leftCabecera ',lh_Div' num2str(ii)];
                    leftFormato  = [leftFormato ',%6d']; 
                end
                % Right
                rightCabecera = ['rh_Total'];
                rightFormato  = ['%6d'];
                for ii=1:d.howManyN
                    rightCabecera = [rightCabecera ',rh_Div' num2str(ii)];
                    rightFormato  = [rightFormato ',%6d']; 
                end
                
                % Both
                d.cabecera = ['ID,' leftCabecera ',' rightCabecera];
                d.formato_valores = ['%4s,' leftFormato ',' rightFormato ' \n'];
                
                
                
                d.cabecera = ['   ID   , lh_Total, lh_Head, lh_Body, lh_Tail,  ' ...
                              '          rh_Total, rh_Head, rh_Body, rh_Tail'];
                d.formato_valores = ['%4s,'  ...
                                     '%6d,  %6d,  %6d,  %6d,  ' ...
                                     '%6d,  %6d,  %6d,   %6d \n'];
            end            
        otherwise
            error('In hip_InitMethod: This is not a recognized METHOD');
    end

 
            
    % Name of the file to store the data.
    switch d.method
        case {'MNI', 'Landmark'}
            fileizena = [d.glm_datos_dir filesep d.structName '_' d.methodName ...
                        '_' d.orig_datos  d.bblta '_' d.sufixName '.csv']; %.txt

            d.cabeceraPERC = ['   ID   lh_PERC   rh_PERC'];
            d.formato_valoresPERC = ['%4s\t  %6d\t  %6d \n'];
            fileizenaPERC = [d.glm_datos_dir filesep d.structName '_' d.methodName ...
                        '_' d.orig_datos  d.bblta '_PERC_' d.sufixName '.txt'];
            d.fileIDPERC = fopen(fileizenaPERC, 'w');
            d.fileizenaPERC = fileizenaPERC;
            fprintf(d.fileIDPERC, '%s \n', d.cabeceraPERC);
            fclose(d.fileIDPERC);
        case {'PERC'}
            fileizena = [d.glm_datos_dir filesep d.structName '_' d.methodName num2str(d.perc) ...
                        '_' d.orig_datos  d.bblta '_' d.sufixName '.csv']; %.txt
        case {'nDivisions'}
            fileizena = [d.glm_datos_dir filesep d.structName '_' d.methodName num2str(d.howManyN) ...
                        '_' d.orig_datos  d.bblta '_' d.sufixName '.csv']; %.txt
        otherwise
            error('In hip_InitMethod: This is not a recognized METHOD');
    end
    

    
    d.fileID = fopen(fileizena, 'w');
    d.fileizena = fileizena;
    fprintf(d.fileID, '%s \n', d.cabecera); % Careful, added a , for csv
    fclose(d.fileID);
    
    
    
    
    
    % When reading Koen (FS 5.3) delete the following volumes before computing
    d.eliminar_list = {'posterior_Left-Cerebral-Cortex.mgz'
                       'posterior_Left-Cerebral-White-Matter.mgz'
                       'posterior_left_hippocampal_fissure.mgz'
                      %'posterior_left_fimbria.mgz'
                      %'posterior_right_fimbria.mgz'
                       'posterior_right_hippocampal_fissure.mgz'
                       'posterior_Right-Cerebral-Cortex.mgz'
                       'posterior_Right-Cerebral-White-Matter.mgz'};
    d.fs6_include_list = {  '201' % alveus
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
                   
                   
    % We create the string with the function name to call to solve this problem
    d.fName = strcat('hip_', d.methodName);
    
    % For Landmark, read the uncal apex landmark
    % Example: filename = 'landmarks_aseg_head_jueces_AA1.txt'
    if(strcmp(d.method, 'Landmark'))
        filename = ['landmarks_' d.orig_datos '_head_jueces' d.bblta '.txt'];
        delimiterIn = ' '; headerlinesIn = 1;
        d.puntos = importdata([d.glm_datos_dir, filesep, filename], ...
                              delimiterIn, headerlinesIn);
    else
         d.puntos = false;
    end
 end

