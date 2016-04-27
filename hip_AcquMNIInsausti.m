function [HEAD, POSTERIOR, BODY, TAIL] = hip_AcquMNIInsausti(d, M, sp)
%hip_AcquMNIInsausti Method based on MNI/Talairach Transformation, Landmark,  and Insausti
%   Calculates volumes of the hippocampus segments based on the given variables.
%   All the functions are being called with the following function handle:
%   [HEAD, POSTERIOR, BODY, TAIL, valores] = fhandle(d, M, sp);
%   
%   07/2015: GLU: First version as an independent function
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com


   % We have 8 different limits for the divisions (4 divisions x 2 hemis-s),
   % deMaster & Ghetti report different Y coordinates due to the tilt in the
   % MNI305 brain.
   

   % We use the following data:
   % HEMI |    head    |   ext_head   |    ext_tail    |     tail   |
   % -----+------------+--------------+----------------+------------|
   % Left |+inf    -20 |-21        -27|-28          -35|-36     -inf|
   % Right|+inf    -18 |-19        -25|-26          -33|-34     -inf|
   % 


   % Create table and read it
   % hemi head_limit tail_limit
   boundaries_head{1} = -20; % left hemi
   boundaries_tail{1} = -36;
   boundaries_head{2} = -18; % right hemi
   boundaries_tail{2} = -34;

   % Read  
    HEAD = M; POSTERIOR = M; BODY = M; TAIL = M;

   % We want it RAS so that we can use the followint formula from FS wiki:
   % mni305 = TalXFM*A.vox2ras1 * [i;j;k;1]
   TalXFM = xfm_read([sp filesep 'transforms' filesep 'talairach.xfm']);

   [I, J, K] = size(M.vol); % Leemos el tama??o de cada hippo-subfield, que es siempre el mismo, pero lo inicializo siempre por si acaso.
   % Optimize this code (we will use it just for the paper but...)
       for i=1:I
            for j=1:J
                for k=1:K
                   % In every voxel calculate the coordinate and do the if to
                   % decide if I leave it as it was or make it 0.
                   MNI305 = TalXFM * M.vox2ras1 * [i;j;k;1]; 
                   if MNI305(2) <  boundaries_head{h} HEAD.vol(i,j,k) = 0;end
                   if MNI305(2) >= boundaries_head{h} POSTERIOR.vol(i,j,k) = 0;end
                   if MNI305(2) >= boundaries_head{h} BODY.vol(i,j,k) = 0; end
                   if MNI305(2) <= boundaries_tail{h} BODY.vol(i,j,k) = 0; end
                   if MNI305(2) >  boundaries_tail{h} TAIL.vol(i,j,k) = 0; end
                end 
            end 
       end 

   
        N = M;
        N.vol=zeros(size(N.vol));
        N.vol=HEAD.vol + BODY.vol + TAIL.vol;
        if ~isequal(N.vol, M.vol)
            error('Sum of the parts not equal to original')
        end
   
   

    % Check that no voxel has been lost
    if ~isequal(nnz(M.vol), nnz(HEAD.vol)+nnz(BODY.vol)+nnz(TAIL.vol))
        error('Sum of the parts not equal to original')
    end
    % NOTE: 
    % The Talairach/MNI coordinate-based segmentation entailed an additional 
    % step relative to the two previous methods. Since the FS package already 
    % provides the transformation matrix of the Talairach space 
    % (i.e., talairach.lta), we used it to convert left and right hippocampus. 
    % Once in the transformed space, the coordinate to separate anterior from 
    % posterior hippocampus is always the same (i.e., Y = -20) in the Talairach 
    % space (Poppenk et al., 2013). And, as in the previous methods, 
    % the remaining section posterior hippocampal section was divided in half 
    % to obtain the body and tail. Nevertheless, it is important to indicate 
    % that the Talairach/MNI coordinate-based segmentation has the inherent 
    % caveat that the Talairach transform is affine and not lineal. 
    % To solve this issue, the head, body and tail volumes obtained with this 
    % method were divided by the Jacobian of the transformation matrix to scale
    % them back to the original hippocampal volume values. 

end

