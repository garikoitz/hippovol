function [HEAD, POSTERIOR, BODY, TAIL, perc] = hip_BezierLandmarkInsausti(d, M, punto)
%BezierLandmarkInsausti Method based on Bezier, PERC,  and Insausti
%   Calculates volumes of the hippocampus segments based on the given variables.
%   All the functions are being called with the following function handle:
%   [HEAD, POSTERIOR, BODY, TAIL, valores] = fhandle(d, M, punto);
%   
%   11/2015: GLU: First version as an independent function
%            we are not using the landmark to segment with a perpendicular
%            plane to the Bzier curve, we would need a 
%            point in space to do so, but following Eugenios suggestion to
%            include in the paper, we are going to check all the rater's
%            landmark planes over and give the percentage where the
%            Bezier's curve is cut with the plane. So beware: 
%            THIS IS AN APROXIMATION
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com





% From the first time it has to come fitted, so: 
    ShortBezier = hip_fitBezierToCloud_vGari(M, d.orden, d.mydecimate, d.optim);
    % What comes in punto is the coronal or Y plane where the raters put
    % their landmark. 
 
    % Generate the distances
    dists=diff(ShortBezier);
    dists=sqrt(sum(dists.*dists,2));
    distTotal=sum(dists);
    cumDists=cumsum(dists);
    
    % Find the first point above the plane
    % As we are using the PCA rotated hippocampi, and we've got the coronal
    % plane where the uncal apex is last visible, we will take the value in
    % Z that is above this value.
    % Just in case sort it by Z
    ShortBezier = sortrows(ShortBezier, 3);
    onlyPosterior=ShortBezier(ShortBezier(:,3) < punto, :);
    distPosterior=cumDists(size(onlyPosterior,1)); 
    
    lastSliceUncal=ShortBezier(size(onlyPosterior,1)+1,:);
    lastSliceUncalNext=ShortBezier(size(onlyPosterior,1)+2,:);
    vectTgBezierHead = lastSliceUncal - lastSliceUncalNext;
    
    
    % Calculate the percentage and send it back
    perc = ((distTotal - distPosterior) / distTotal) * 100;
       
    if d.DEBUG > 0    
        %     Create the plane where the landmark is (just for visualization): 
        P1 = [punto, punto, punto-1];
        P2 = [punto, punto, punto+1];
    
        landmarkPlane = medianPlane(P1,P2);

        figure(1), p=patch(isosurface(M.vol)); 
        isonormals(M.vol, p)

        % set(p,'FaceColor', [0 0 1], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9); 
        % Important: if the code crashes here due to the inability to render
        % transparent data, use this command instead:
        set(p,'FaceColor', [0 1 0], 'EdgeColor', [0.5 0.5 0.5]); 

        axis equal
        hold on
        plot3(ShortBezier(:,1),ShortBezier(:,2),ShortBezier(:,3),...
               'r','linewidth',6)
        hold on;
        drawPlane3d(landmarkPlane, 'r');
        drawPlane3d(BezierPlane, 'b');
    end

    % Now we use the version to fit the plane to a segment of the curve, we give
    % it the previously calculated ShortBezier curve
    % Now we use the version to fit the plane to a segment of the curve, we give
    % it the previously calculated ShortBezier curve
    head_point = [100 100 100]; % We are only interesed in the perc values
    tail_point = [100 100 100];
    [HEAD, POSTERIOR] = hip_fitBezierTgPlane(M, head_point, d.DEBUG, vectTgBezierHead, ShortBezier);
    [BODY, TAIL] = hip_fitBezierTgPlane(POSTERIOR, tail_point, d.DEBUG, vectTgBezierHead, ShortBezier);
    
    % Validate that when segmenting none of the voxels is lost
    if ~isequal(nnz(M.vol), nnz(HEAD.vol)+nnz(BODY.vol)+nnz(TAIL.vol))
        error('Suma trozos not equal total')
    end

end

