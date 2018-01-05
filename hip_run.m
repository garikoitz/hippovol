% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com
% hippovol v0.1: - first version online
% hippovol v0.2: - added the option 'manual' for the manual segmentations
% hippovol v0.3: - created option 'fs5' and 'fs6' as well
%                - added option to use existing files with names other than
%                  asegHippo
% hippovol v0.4: - DM 12/4/17 added code to segment corpus callosum (cc) &
%                  code to segment any structure into N segments of same size
%

clear all; close all; clc;

%  %%%% NOTE %%%%: run this script where the subjects folders are stored
basedir = pwd;
% basedir = '~/Documents/BCBL_PROJECTS/MINI/ANALYSIS/freesurferacpc';cd(basedir);% for testing
SUBJECTS_DIR = basedir;
% For testing purposes, change the value in the wildcard so that only selects
% one subject inside this main folder where the subjects are located.


%% SHORT VERSION OPTIONS (see README.md)

% You can use lists in several of the options: this will multiply the amount of
% calculations done per every subject. The written logfiles will store all the
% option specified here. 

% NOTE FOR MANUAL: 
% -- rename all your files so that they start with lh. or rh, this way it
%    will generate a results file with lh and rh separated for statistical
%    analysis. 
% -- in v0.2: ALL SUBJECTS NEED BOTH lh. and rh. 
% --          Put all files in folders with the subject numbers. 

% Wildcard to select all the subjects you are interested. 
% - Structures have to be in folders, and 
% - All structures have to be named the same (e.g.: lh.myHippo.mgz)

sub = dir('XS*'); 
            % Path to file: for freesurfer use 'mri', for manual '' or your file paths
            hipPath = 'mri';
            % The name give to the hippocampi, for ex.: 'asegHippo',
            % 'HC_subject' or corpus callosum, for ex.: 'cc_whole'
            %hipName = 'asegHippo'; 'hippoSfLabels-T1.v10'
            hipName = 'cc_whole';
            % Extension of the file, for ex.: 'mgz', 'nii.gz'
            hipExt  = 'mgz'; 
            
% Origin of the dataset (it has been tested for):
% 'fsaseg': use the results from freesurfer's aseg segmentation. Any version (tested 5.1, 5.3, 6.0).
%           The code expects to find the hippocampi in subjectName/mri/ .
%           The name by default would be ?h.asegHippo.mgz, change it below:

% 'fs5': freesurfer's hipposubfield segmentation, version 5
%         It will add the subfields to create a more detailed hippocampus.
%         You can select the subfields used in the reconstruction in the file
%         hip_sum_hippo_subfields.m
% 'fs6': fs 6's hipposubfield implementation. 
%          Requires specifying isotropic voxel size, 0.33 if fs6-s default or your 
%          acquisition's voxel size (required for volume correction)
% 'manual': manual segmentation binary masks
% 'cc'    : option for fs-s cc, made of the sum of the 5 section 251 252 253 254
%           255, see README
orig_datos   = 'cc';
voxel_size = 0.3333;  % default 0.33 for fs6, otherwise voxelspace 


% Although the default method and that imitates best the manual procedures is
% the 'PCA' method, the 'Bezier' method is available. This method creates a
% curved axis that follows better the c-shape of the hippocampus (see paper).
% There is another option 'Acqu', see below. 

% NOTE: for nDivision, only PCA developed for now
orientations = {'Bezier'};  % Obtain both in the same call using {'Bezier', 'PCA'}

% Percentage of length to segment head. 41.7% was the average on the paper for 
% freesurfer's aseg, but it depends on your biological assumptions. 
% If introduced as a list, it will calculate all the different percentages, for
% example 201:1:800 or [401 451]. It will add the 
Head_Perc_List = 417;

% 1: to write the mgz-s to file. 0: to obtain just the stats. Set it to zero in
% testing mode at first. Write the segments to visualize results and test for
% accuracy as well, or to be used as seeds in functional connectivity or
% tractography. 
WRITE_MGZ = 1;  

% It will prepend it to the stat files and to the mgz files.
%structName = 'HIPPO';
% We will use this struct name to make changes afterwards.
structName = 'HIPPO';  %  'cc'; 

% If we make minor changes we can save them all with different revisions
sufixName = 'v02'; 


% Do we want to use the head-body-tail method, or do we want to segment in N
% same lenght divisions?
% methods = {'PERC', 'Landmark', 'MNI', 'nDivisions'};
methods = {'nDivisions'};
howManyN           = 10;

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
% ComoPost = {'Insausti', 'Tail'}
ComoPost = {'Insausti'};
Rater = {'A', 'B'};


% call hippovol function with these variables
DEBUG=0;    % 1 for showing the plots of the images
orden = 2; % order for Bezier function
mydecimate = 5; % decimation in Bezier function

% It will save the stats in this folder
% hippovol is the name of the script, even though we are segmenting CC, store
% results there
glm_datos_dir = [SUBJECTS_DIR filesep 'hippovol' filesep 'data_01']; 
mat_dirs = [glm_datos_dir filesep 'mats'];
mkdirquiet(glm_datos_dir);
mkdirquiet(mat_dirs);

%% Launch the calculations
% Huge when testing. In normal use it will only launch one process per
% hippocampi

% % If the 'manual' option was used, separate the subjects with the lh and rh
% if strcmp(orig_datos, 'manual')
%     sub = sub(1:(length(sub)/2));
%     for ns = 1:length(sub)
%         sub(ns).name = strrep(sub(ns).name, 'lh.', '')
%     end
% end

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
                if strcmp(method,'PERC');perc=['Perc' num2str(Head_Perc_List(perci))];end;
                if strcmp(method,'nDivisions');perc=['nDivs' num2str(howManyN)];end;
                save([mat_dirs filesep methods{jj} '_' orientations{kk} '_' ...
                      lta_list{ii} '_' perc]);
                fcmd = ['hippovol(''' mat_dirs '/' methods{jj} '_' ...
                        orientations{kk} '_' lta_list{ii} ...
                        '_' perc ''')' ];
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
% hippovol('~/Documents/BCBL_PROJECTS/MINI/ANALYSIS/freesurferacpc/hippovol/data_01/mats/nDivisions_PCA_Acqu_nDivs10')
