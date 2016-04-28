# Automated segmentation of the human hippocampus along its longitudinal axis.

This code was created to automatically segment MRI hippocampal T1-w images. 
The hippocampal images are segmented from the brain either manually or using tools available in the communty such as Freesurfer (already tested) or FSL. 
Althought the main focus of the development of the tool has been the hippocampus, it can be applied to any c-shaped elongated structure, such as the corpus callosum. 

The code has been use to generate all the data in the following paper (if you use this tool please cite it as):
 > Lerma-Usabiaga, G., Iglesias, J.E., Insausti, R., Greve, D., & Paz-Alonso. P.M. (2016). Automated segmentation of the human hippocampus along its longitudinal axis. Human Brain Mapping (in Press)
If you have any questions please write an email to: 
 > Garikoitz Lerma-Usabiaga: garikoitz@gmail.com



## Requirements and installation:
- git clone this repository (or download the .zip file) and add it to your matlab path. 
- add $FREESURFER_HOME/matlab to your path
- Download and add geom3d (http://www.mathworks.com/matlabcentral/fileexchange/24484-geom3d) to your path.
- In the default version, this software requires that you have the Optimization Toolbox. If you don't have it, you can install L-BFGS-B for free (http://es.mathworks.com/matlabcentral/fileexchange/15061-matlab-interface-for-l-bfgs-b), and change the option in the setup.



## HOW-TO: Short Version
### 1. Obtain the main hippocampal segmentation from Freesurfer's aseg.
  - Extract the hippocampal labels from Freesurfer's aseg. Assuming that you are always located in the SUBJECTS_DIR of your project: 
  - mri_extract_label  <SUBJECT_NAME>/mri/aseg.mgz 17  <SUBJECT_NAME>/mri/lh.asegHippo.mgz
  - mri_extract_label  <SUBJECT_NAME>/mri/aseg.mgz 53  <SUBJECT_NAME>/mri/rh.asegHippo.mgz

  *Sample code to extract the aseg hippocampi (run matlab from command line with FREESURFER_HOME defined):*
```matlab
basedir = pwd;
sub = dir('S_*');  % Edit the wildcard to select your subjects 
hemis = {'lh', 'rh'};
labelNos = {'17', '53'};
for h=1:2
    hemi = hemis{h};
    label = labelNos{h};
    for ns=1: length(sub)
        cmd = ['mri_extract_label ' ...
               basedir filesep sub(ns).name filesep 'mri' filesep 'aseg.mgz ' label ' ' ...
               basedir filesep sub(ns).name filesep 'mri' filesep hemi '.asegHippo.mgz'];
        system(cmd);
    end
end
```
  - This will create the lh.asegHippo.mgz and rh.asegHippo.mgz inside the mri folder of each subject in your experiment. 
  - Do quality check in this step: if aseg didn't do a good job remove the subject. 

### 2. Run the segmentation
  1. Go to the SUBJECTS_DIR in Matlab
  2. Write in the command line: `edit hip_run.m`
  3. Edit at least the wildcard to detect all your subjects in the folder, the rest of the short version options are explained in the file. 
  4. Run hip_run

OUTPUT: 
  - The stat file will be a csv file in SUBJECTS_DIR/hippovol/. The name of the file will differ depending on the options used.
  - If the option to write the volumes was selected, every subject will have its segmented hippocampus under the mri folder. The resulting labels (HEAD, BODY, TAIL, POSTERIOR) will be stored in every subjects mri folder with .mgz extension. 



## HOW-TO: Long Version (to do)
This code has been used to generate all the data in the above mentioned paper, and it allows the selection of many more options, but almost for everybody the short version should be enough. 

Every available option in the Long Version should be explained in the Long Version section of hip_run.m.

  - NOTE 1: You will be able to select other methods than aseg. We've already used other options: for example, adding all the hippo-subfields from version FS 5.3. The resulting hippocampus is a little bit more refined than the original aseg version. When FS 6.0 is out we will use the results of the new hippo-subfields code to create new and more refined whole hippocampi by default.  
  - NOTE 2: It is possible to use the method to rotate the hippocampi, and then select the landmark manually. It will be explained how to write an .csv file with the landmark values and how to perform the segmentation using these values. 
  - NOTE 3: There is a beta version of a compiled and Dockerized version available. We will update it and upload it here after the FS 6.0 version is updated. 



## TODOs: 
- Finish documenting long version options in hip_run.m
- Extract hipposubfields with FS6 and create whole hippocampus automatically out of it as a default.
- Publish compiled and Dockerized version










