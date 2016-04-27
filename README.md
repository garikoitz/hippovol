# Automated segmentation of the human hippocampus along its longitudinal axis.

This code was created to automatically segment MRI hippocampal T1-w images. 
The hippocampal images are segmented from the brain either manually or using tools available in the communty such as Freesurfer (already tested) or FSL. 
Althought the main focus of the development of the tool has been the hippocampus, it can be applied to any c-shaped elongated structure, such as the corpus callosum. 

The code has been use to generate all the data in the following paper (if you use this tool please cite it as) :
Lerma-Usabiaga, G., Iglesias, J.E., Insausti, R., Greve, D., & Paz-Alonso. P.M. (2016).
Automated segmentation of the human hippocampus along its longitudinal axis. 
Human Brain Mapping (in Press)



## Requirements and installation:
- git clone this repository (or download the .zip file) and add it to your matlab path. 
- add $FREESURFER_HOME/matlab to your path
- Download and add geom3d (http://www.mathworks.com/matlabcentral/fileexchange/24484-geom3d) to your path.
- In the default version, this software requires that you have the Optimization Toolbox. If you don't have it, you can install L-BFGS-B for free (http://es.mathworks.com/matlabcentral/fileexchange/15061-matlab-interface-for-l-bfgs-b), and change the option in the setup.



## HOT-TO: Short Version
### 1. Obtain the main hippocampal segmentation from Freesurfer's aseg.
  - Extract the hippocampal labels from Freesurfer's aseg. Assuming that you are always located in the SUBJECTS_DIR of your project: 
  - mri_extract_label  <SUBJECT_NAME>/mri/aseg.mgz 17  <SUBJECT_NAME>/mri/lh.asegHippo.mgz
  - mri_extract_label  <SUBJECT_NAME>/mri/aseg.mgz 53  <SUBJECT_NAME>/mri/rh.asegHippo.mgz

  *Sample code (run matlab from command line with FREESURFER_HOME defined): *
```matlab
basedir = pwd;
sub = dir('S_*'); 
hemis = {'lh', 'rh'};
for h=1:2
    hemi = hemis{h};
    for ns=1: length(sub)
        cmd = ['mri_extract_label ' ...
               basedir filesep sub(ns).name filesep 'mri' filesep 'aseg.mgz 17 ' ...
               basedir filesep sub(ns).name filesep 'mri' filesep hemi '.asegHippo.mgz'];
        system(cmd);
    end
end
```
  - This will create the lh.asegHippo.mgz and rh.asegHippo.mgz inside the mri folder of each subject in your experiment. 
  - Do quality check in this step: if aseg didn't do a good job remove the subject. 

### 2. Run the segmentation
  1. Go to the SUBJECTS_DIR in Matlab
  2. Write in the command line: edit hip_run.m
  3. Edit at least the wildcard to detect all your subjects in the folder, the rest of the short version options are explained in the file. 
  4. Run hip_run

OUTPUT: the stat file will be a csv file in SUBJECTS_DIR/hippovol/, and as said before, every subject will have its segmented hippocampus under the mri folder (if the option to save the segmented volumes where chosen, usually we just want the volume). The resulting labels (HEAD, BODY, TAIL, POSTERIOR) will be stored in the same location: in every subjects mri folder with .mgz extension. 



## HOW-TO: Long Version
This code has been used to generate all the data in the above mentioned paper, and it allows to many more options than above. 
Every option should be explained in hip_run.m.
  - NOTE 1: You will have result based on aseg. I've used other options: for example, adding all the hippo-subfields from version FS 5.3, and the resulting hippocampus it is a little bit more refined than the original aseg version. I am waiting for FS6.0, then I will use the results of the new hippo-subfields code to create new and more refined whole hippocampi by default. Will let you know. In any case, the results are usually highly correlated so hopefully you will find similar results with your data. 
  - NOTE 2: It is possible to use the method to rotate the hippocampi, and then select the landmark manually. 
  - NOTE 3: There is a beta version of a compiled and Dockerized version available. We will update it and upload it here. 



## TODOs: 
- Finish documenting long version options in hip_run.m
- Extract hipposubfields with FS6 and create whole hippocampus automatically out of it as a default.
- Publish compiled and Dockerized version










