function [HEAD, POSTERIOR, BODY, TAIL] = hip_PCAPERCInsausti(d, M, punto)
%PCAPERCInsausti Method based on PCA, PERC,  and Insausti
%   Calculates volumes of the hippocampus segments based on the given variables.
%   All the functions are being called with the following function handle:
%   [HEAD, POSTERIOR, BODY, TAIL, valores] = fhandle(d, M, punto);
%   In this case punto it is not the Landmark as in the landmark method, it
%   is the percentage expressed in 1:1000, so before multiplying you should
%   divide the punto value by 1000.
%   
%   04/2015: GLU: First version as an independent function
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com


    % 1.- Change to the PCA coordinates
    % 2.- Obtain the coordinates for the cutting planes
    % 3.- Make the call to the planes


    % Change to index coordinates, so we have a cloud of points
    [Y, X, Z] = ind2sub(size(M.vol),find(M.vol>0));
    
    % These are the coordinates of my data
    X = [X, Y, Z];
    
    %[coeff,score] = pca(X, 'Centered', false); %Ejecuto PCA
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
    PuntoMax = round(meanX + score(IndMax,:,:)*coeff'); 

    if ~(ismember(PuntoMin,X,'rows') && ismember(PuntoMax,X,'rows') )
            error('Maximun and Minimum are not in the structure');
    end

    % Create interest points
    points = [endpts(1,:);endpts(2,:);PuntoMin;PuntoMax;meanX];
    
    % Create  3D line through 2 points
    linePCA1 = createLine3d(endpts(1,:), endpts(2,:));
    
    % Create planes
    PlaneMin = createPlane(PuntoMin,dirVect'); % Point and normal
    PlaneMax = createPlane(PuntoMax,dirVect');
    
    % Compute intersection between plane and a line
    interMin = intersectLinePlane(linePCA1, PlaneMin);
    interMax = intersectLinePlane(linePCA1, PlaneMax); 

    longitud = distancePoints3d(interMin, interMax);
    longitHead = (   punto/1000)    * longitud;
    longitBD   = (1-(punto/1000))/2 * longitud;

    interHead = ((interMax - meanX) * dirVect - longitHead)*dirVect' + meanX;
    interTail = ((interMin - meanX) * dirVect + longitBD)*dirVect' + meanX;

     % create planes
    PlaneHead = createPlane(interHead,dirVect'); % Punto y normal
    PlaneTail = createPlane(interTail,dirVect'); % Punto y normal

    % Go back from the index to the volume
    head_ind = (X(:,3)  - ...
                           ((dirVect(1)*(interHead(1)-X(:,1)) + ... 
                             dirVect(2)*(interHead(2)-X(:,2)))/dirVect(3) + ...
                            interHead(3))   ...
                ) > 0;
            
    notail_ind = (X(:,3) - ...
                    ((dirVect(1)*(interTail(1)-X(:,1)) + ...
                      dirVect(2)*(interTail(2)-X(:,2)))/dirVect(3) + ...
                     interTail(3)) ...   
                  ) > 0;
    body_ind = (~head_ind == notail_ind);

    N = M;
    N.vol = zeros(size(N.vol));
    HEAD = N; POSTERIOR = N; BODY = N; TAIL = N;

    HEAD.vol(sub2ind(size(M.vol), ...
                     X(head_ind,2), X(head_ind,1), X(head_ind,3)))=1; 
    POSTERIOR.vol(sub2ind(size(M.vol), ...
                          X(~head_ind,2), X(~head_ind,1), X(~head_ind,3)))=1; 
    TAIL.vol(sub2ind(size(M.vol), ...
                     X(~notail_ind,2), X(~notail_ind,1), X(~notail_ind,3)))=1;
    BODY.vol(sub2ind(size(M.vol), ...
                     X(body_ind,2), X(body_ind,1), X(body_ind,3)))=1;


    if d.DEBUG > 0
        
        
        
        figure(1), p=patch(isosurface(M.vol)); isonormals(M.vol, p)
        set(p,'FaceColor', [0 0 1], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9); 
        
        figure(2), p=patch(isosurface(HEAD.vol)); isonormals(HEAD.vol, p)
        set(p,'FaceColor', [0 1 0], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9); 
        
        figure(2), p=patch(isosurface(BODY.vol)); isonormals(BODY.vol, p)
        set(p,'FaceColor', [1 0 1], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9); 
        
        figure(2), p=patch(isosurface(TAIL.vol)); isonormals(TAIL.vol, p)
        set(p,'FaceColor', [1 0 0], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9); 
        
        
        axis equal
        hold on
        drawLine3d(linePCA1,'LineWidth',5)
        planePCA1 = medianPlane(endpts(1,:), endpts(2,:));

        drawPlane3d(PlaneHead, 'FaceColor', [0 0 1], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9)
        drawPlane3d(PlaneTail, 'FaceColor', [1 0 0], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9)
    
    end   

    % Validate that when segmenting none of the voxels is lost
    if ~isequal(nnz(M.vol), nnz(HEAD.vol)+nnz(BODY.vol)+nnz(TAIL.vol))
        error('Suma trozos not equal total')
    end

end

