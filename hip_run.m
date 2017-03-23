% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com
% hippovol v0.1: - first version online
% hippovol v0.2: - added the option 'manual' for the manual segmentations
%                -                     created option 'fs5' and 'fs6' as well

clear all; close all; clc;


%% SHORT VERSION OPTIONS (see README.md)

% You can use lists in several of the options: this will multiply the amount of
% calculations done per every subject. The written logfiles will store all the
% option specified here. 

% NOTE FOR MANUAL: 
% -- rename all your files so that they start with lh. or rh, this way it
%    will generate a results file with lh and rh separated for statistical
%    analysis. 
% -- in v0.2: ALL SUBJECTS NEED BOTH lh. and rh. 

% Wildcard to select all the subjects you are interested. 
sub = dir('*h.HC_*'); 
% sub = dir('S_*'); 



% Although the default method and that imitates best the manual procedures is
% the 'PCA' method, the 'Bezier' method is available. This method creates a
% curved axis that follows better the c-shape of the hippocampus (see paper).
% There is another option 'Acqu', see below. 
orientations = {'PCA'};  % Obtain both in the same call using {'Bezier', 'PCA'}

% Percentage of length to segment head. 41.7% was the average on the paper for 
% freesurfer's aseg, but it depends on your biological assumptions. 
% If introduced as a list, it will calculate all the different percentages, for
% example 201:1:800 or [401 451]. It will add the 
Head_Perc_List = 417; 

% 1: to write the mgz-s to file. 0: to obtain just the stats. Set it to zero in
% testing mode at first. Write the segments to visualize results and test for
% accuracy as well, or to be used as seeds in functional connectivity or
% tractography. 
WRITE_MGZ = 0;  

% It will prepend it to the stat files and to the mgz files.
structName = 'HIPPO'; 

% If we make minor changes we can save them all with different revisions
sufixName = 'v01'; 

% END OF SHORT VERSION OPTIONS




%% LONG VERSION OPTIONS  (see README.md)

% It has a long for below because this software has been used to obtain all the
% different options for the experiment. Right now with the default options the
% for loops only generate one launch (x N subjects), but it can be used to
% launch M x N processess. 


% TODO: document all options with more detail. 

basedir = pwd;
cluster = 0;  % Do not use HPC for now. 
optim = 1; % 1: use matlab's internal fmninunc, 0: use lbfsg in cluster 

% loop over those methods
% lta_list = {'Acqu','A', 'B', 'A1','B1','A2', 'B2','PCA'};
lta_list = {'Acqu'};
MNI_lta_list = {'MNI'}; % Use it for the MNI case
% landmark_lta_list = {'AAcqu', 'BAcqu', 'AT1','BT1','AT2', 'BT2', ...
%                                        'APCA1','BPCA1', 'APCA2','BPCA2'};
landmark_lta_list = {'APCA1','BPCA1', 'APCA2','BPCA2'};
% Explain orientation 'Acqu'.
% methods = {'PERC', 'Landmark', 'MNI'};
methods = {'PERC'};
% ComoPost = {'Insausti', 'Tail'}
ComoPost = {'Insausti'};
Rater = {'A', 'B'};


% call hippovol function with these variables
DEBUG=0;    % 1 for showing the plots of the images
orden = 2; % order for Bezier function
mydecimate = 5; % decimation in Bezier function

% It has been tested for:
% 'fsaseg': use the results from freesurfer's aseg segmentation. any version
% 'fs5': freesurfer's hipposubfield segmentation, version 5
% 'fs6': fs 6's hipposubfield implementation, recommended but not tested yet. It will be the default when tested. 
% 'manual': manual segmentation binary masks
orig_datos   = 'manual';
SUBJECTS_DIR = basedir;

% It will save the stats in this folder
glm_datos_dir = [SUBJECTS_DIR filesep 'hippovol' filesep 'data_01']; 
mat_dirs = [glm_datos_dir filesep 'mats'];
mkdirquiet(glm_datos_dir);
mkdirquiet(mat_dirs);

%% Launch the calculations
% Huge for used when testing. In normal use it will only launch one process per
% hippocampi

% If the 'manual' option was used, separate the subjects with the lh and rh
if strcmp(orig_datos, 'manual')
    sub = sub(1:(length(sub)/2));
    for ns = 1:length(sub)
        sub(ns).name = strrep(sub(ns).name, 'lh.', '')
    end
end

for jj=1:length(methods)
    method = methods{jj};
    if strcmp(method, 'Landmark')
            lta_list = landmark_lta_list;
    elseif strcmp(method, 'MNI')
            lta_list = MNI_lta_list;
    end
    for kk=1:length(orientations)
        orientation = orientations{kk};
        for ii=1:length(lta_list)
            lta = lta_list{ii};
            for perci=1:length(Head_Perc_List)  
                perc = Head_Perc_List(perci);
                save([mat_dirs filesep methods{jj} '_' orientations{kk} '_' ...
                      lta_list{ii} '_' num2str(Head_Perc_List(perci))]);
                fcmd = ['hippovol(''' mat_dirs '/' methods{jj} '_' ...
                        orientations{kk} '_' lta_list{ii} ...
                        '_' num2str(Head_Perc_List(perci)) ''')' ];
                if cluster
                    % -nojvm removed so that matlabpool is working
                    cmd = ['matlab -nosplash -nodesktop -nodisplay  -r ""' ...
                           fcmd ';exit""'];
                    spcmd = ['qsub -q all.q $mySH/RunMatlab.sh "' cmd '"']
                    [status,result] = system(spcmd);
                else
                    eval(fcmd);
                end
                cd(basedir);
            end
        end
    end
end

% example:
% hippovol('/bcbl/home/public/Gari/PCA/glm/datos_05/mats/PERC_Bezier_Acqu_422')
