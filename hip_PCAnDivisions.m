function DIVISIONS = hip_PCAnDivisions(d, M, N)
%PCAPERCInsausti Method based on PCA, PERC,  and Insausti
%   Calculates volumes of the hippocampus segments based on the given variables.
%   
%   01/2017: GLU: First version
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% Stanford University
% 2017
% Contact: garikoitz@gmail.com

    % Change to index coordinates, so we have a cloud of points
    [Y, X, Z] = ind2sub(size(M.vol),find(M.vol>0));
    
    % These are the coordinates of my data
    X = [X, Y, Z];
    
    % Check that we are using the pca function for matlab, just in case
    if ~strfind(which('pca'),matlabroot)
        disp(['Using pca.m in ' which('pca')])
        error('check that you are using the correct pca.m function') 
    end
    
    % [coeff,score] = pca(X, 'Centered', false); %Ejecuto PCA
    % Execute Matlab's PCA code
    [coeff,score] = pca(X);
    % Obtain PCA1
    dirVect = coeff(:,1);
    meanX = mean(X,1);

    % Calculate the minimuns over the PCA1 and add to the extremes to visualize
    t = [min(score(:,1))-5, max(score(:,1))+5]; 
    endpts = [meanX + t(1)*dirVect'; meanX + t(2)*dirVect'];

    [PMin,IndMin] = min(score(:,1));
    [PMax,IndMax] = max(score(:,1));
    
    % Most extreme points for plane
    PuntoMin =  round(meanX + score(IndMin,:,:)*coeff'); 
    PuntoMax =  round(meanX + score(IndMax,:,:)*coeff'); 

    if ~(ismember(PuntoMin,X,'rows') && ismember(PuntoMax,X,'rows') )
            error('Maximun and Minimum are not in the structure');
    end
    
    % Create  3D line through 2 points
    linePCA1 = createLine3d(endpts(1,:), endpts(2,:));
    
    % Create planes
    PlaneMin = createPlane(PuntoMin,dirVect'); % Point and normal
    PlaneMax = createPlane(PuntoMax,dirVect');
    
    % Compute intersection between plane and a line
    interMin = intersectLinePlane(linePCA1, PlaneMin);
    interMax = intersectLinePlane(linePCA1, PlaneMax); 

    % Obtain length of the structure
    longitud = distancePoints3d(interMin, interMax);
    
    % Obtain the length of every segment or division
    longitSegment = longitud/N;
    
    % Obtain the coordinates of the intermediate N-1 points
    interPoints = [interMax];
    segmentPlanes = {};
    for ii=1:(N-1)
        % find points
        tmp = ((interPoints(ii,:)-meanX) * dirVect-longitSegment)*dirVect'+meanX;
        % Store points
        interPoints = [interPoints; tmp];
        % create planes and store them
        segmentPlanes{ii} = createPlane(interPoints(ii,:),dirVect');
    end
    interPoints = [interPoints; interMin];
    segmentPlanes{N}   = createPlane(interPoints(N,:),dirVect');
    segmentPlanes{N+1} = createPlane(interPoints(N+1,:),dirVect');
    
   

    % Go back from the index to the volume
    % I had to hack it in order to handle the manual ones in a different
    % direction. 
    % Make it generic
    % DM 12/4/17 added 'cc' option to 1st case
    switch d.orig_datos
        case {'fs6', 'fs5', 'fsaseg', 'cc'}
            x = 1;
            y = 2;
            z = 3;
        case {'manual'}
            x = 1;
            y = 3;
            z = 2;
        otherwise
            error('This orientation is not implemented');
    end
    % Create volume place-holder
    tmpM = M;
    tmpM.vol = zeros(size(tmpM.vol));
    % Obtain index
    segmIndex = {};
    segmVOLS  = {};
    for ii=1:N-2
        interHead = interPoints(ii+1,:);
        interTail = interPoints(ii+2,:);
        [head_ind,notail_ind] = hip_PCAind(dirVect,interHead,interTail,X,x,y,z);
        % Do the first one, like the head
        if   1==ii; 
            segmIndex{1} = head_ind;
            segmVOLS{1}  = tmpM;
            segmVOLS{1}.vol(sub2ind(size(M.vol), ...
                     X(segmIndex{1},y), X(segmIndex{1},x), X(segmIndex{1},z)))=1; 
        end;
        % Do the last one, like the tail
        if N-2==ii; 
            segmIndex{N}= ~notail_ind;
            segmVOLS{N}  = tmpM;
            segmVOLS{N}.vol(sub2ind(size(M.vol), ...
                     X(segmIndex{N},y), X(segmIndex{N},x), X(segmIndex{N},z)))=1; 
        end;
        % Do the rest, like several different bodies
        segmIndex{ii+1} = (~head_ind == notail_ind);
        segmVOLS{ii+1}  = tmpM;
        segmVOLS{ii+1}.vol(sub2ind(size(M.vol), ...
                     X(segmIndex{ii+1},y), X(segmIndex{ii+1},x), X(segmIndex{ii+1},z)))=1; 
    end
    
    
    
    if d.DEBUG > 0
        
        
        % Before segmentation
        figure(1), p=patch(isosurface(M.vol)); isonormals(M.vol, p)
        set(p,'FaceColor', [0 0 1], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9); 
        
        % axis equal
        hold on
        drawLine3d(linePCA1,'LineWidth',5)
        % drawPoint3d(endpts(1,:));
        % drawPoint3d(endpts(2,:));
        drawPoint3d(PuntoMin,'MarkerFaceColor','g','MarkerSize',10);
        drawPoint3d(PuntoMax,'MarkerFaceColor','g','MarkerSize',10);
        % drawPoint3d(meanX);
        planeMeanX = createPlane(meanX, dirVect');
        % drawPlane3d(planeMeanX)
        drawPoint3d(interMin,'MarkerFaceColor','r','MarkerSize',10);
        drawPoint3d(interMax,'MarkerFaceColor','r','MarkerSize',10);
%         drawPlane3d(PlaneHead)
%         drawPlane3d(PlaneTail)
        drawPoint3d(interHead,'MarkerFaceColor','r','MarkerSize',10);
        drawPoint3d(interTail,'MarkerFaceColor','g','MarkerSize',10);
        
        
        
        % After segmmentation
        for ii=1:N
            % figure(2), 
            p=patch(isosurface(segmVOLS{ii}.vol)); isonormals(segmVOLS{ii}.vol, p)
            set(p,'FaceColor', [ii/N ii/N ii/N], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9); 
            hold on
        end
        
        
        axis equal
        hold on
        drawLine3d(linePCA1,'LineWidth',5)
        planePCA1 = medianPlane(endpts(1,:), endpts(2,:));
        % drawPlane3d(PlaneHead);
        % drawPlane3d(PlaneTail);

        % drawPlane3d(PlaneHead, 'FaceColor', [0 0 1], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9)
        % drawPlane3d(PlaneTail, 'FaceColor', [1 0 0], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9)
    
    end   

    % Validate that when segmenting none of the voxels is lost
    sumOfSegments = 0;
    for ii=1:N
        sumOfSegments = sumOfSegments + nnz(segmVOLS{ii}.vol);
    end
    if ~isequal(nnz(M.vol), sumOfSegments)
        error('Suma trozos not equal total')
    else
        DIVISIONS = segmVOLS;
    end

end

