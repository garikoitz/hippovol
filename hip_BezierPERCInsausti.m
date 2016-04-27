function [HEAD, POSTERIOR, BODY, TAIL] = hip_BezierPERCInsausti(d, M, punto)
%BezierPERCInsausti Method based on Bezier, PERC,  and Insausti
%   Calculates volumes of the hippocampus segments based on the given variables.
%   All the functions are being called with the following function handle:
%   [HEAD, POSTERIOR, BODY, TAIL, valores] = fhandle(d, M, punto);
%   
%   04/2015: GLU: First version as an independent function
%   11/2015: GLU: hip_fitBezierToCloud_vGari was redone, here reflect
%                 changes
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    % From the first time it has to come fitted, so: 
    ShortBezier = hip_fitBezierToCloud_vGari(M, d.orden, d.mydecimate, d.optim);
    
    % Tail is below and head is above
    % According to the paper tail is 20% and head 35%, so body is 45%
    % In any case, we are using Insausti's method, which is 50% of the posterior
    % part of the hippocampus. He says that there is no any biological reason to
    % divide the posterior part, we just use an anatomical landmark to make it
    % reproducible, so if that's the reason, making it always the 50% of the
    % posterior hippocampus I think it is even better. 
    
    % Tail_perc is the 50% of the posterior part
    head_perc = punto/1000;
    tail_perc = (1- head_perc) / 2;
    
    tailbody_perc = 1 - head_perc; % We start from below
    
%     tail_point = ShortBezier(ceil(tail_perc*length(ShortBezier)), :);
%     head_point = ShortBezier(ceil(tailbody_perc*length(ShortBezier)), :);
    
    dists=diff(ShortBezier);
    dists=sqrt(sum(dists.*dists,2));
    distTotal=sum(dists);
    cumDists=cumsum(dists);
    
    distHead=distTotal*tailbody_perc;
    aux=find(cumDists>distHead);
    i1=aux(1)-1;
    i2=aux(1);
    a=(distHead-cumDists(i1))/(cumDists(i2)-cumDists(i1));
    head_point=ShortBezier(i1,:)+a*(ShortBezier(i2,:)-ShortBezier(i1,:));
    vectTgBezierHead = ShortBezier(i1,:) - ShortBezier(i2,:);
    
    distTail=distTotal*tail_perc;
    aux=find(cumDists>distTail);
    i1=aux(1)-1;
    i2=aux(1);
    a=(distTail-cumDists(i1))/(cumDists(i2)-cumDists(i1));
    tail_point=ShortBezier(i1,:)+a*(ShortBezier(i2,:)-ShortBezier(i1,:));
    vectTgBezierTail = ShortBezier(i1,:) - ShortBezier(i2,:);
    
    
    if d.DEBUG > 0
        figure(2)
        isosurface(M.vol);
        hold on;

        plot3(ShortBezier(:,1),ShortBezier(:,2),ShortBezier(:,3),'b.')
        axis([-0 256 -0 256 -0 256]);
    
        axis square
        figure(2)
        plot3(ShortBezier(:,1),ShortBezier(:,2),ShortBezier(:,3),'r.')
        hold on
        plot3(ShortBezier(1,1), ShortBezier(1,2), ShortBezier(1,3), 'b*')
        plot3(ShortBezier(200,1), ShortBezier(200,2), ShortBezier(200,3), 'g*')
        %axis([-0 256 -0 256 -0 256]);
        plot3(tail_point(1), tail_point(2), tail_point(3), 'b*')
        plot3(head_point(1), head_point(2), head_point(3), 'g*')
        hold on; axis([-0 256 -0 256 -0 256]);axis square;
    end

    % Now we use the version to fit the plane to a segment of the curve, we give
    % it the previously calculated ShortBezier curve
    [HEAD, POSTERIOR] = hip_fitBezierTgPlane(M, head_point, d.DEBUG, vectTgBezierHead, ShortBezier);
    [BODY, TAIL] = hip_fitBezierTgPlane(POSTERIOR, tail_point, d.DEBUG, vectTgBezierTail, ShortBezier);
    
    % Validate that when segmenting none of the voxels is lost
    if ~isequal(nnz(M.vol), nnz(HEAD.vol)+nnz(BODY.vol)+nnz(TAIL.vol))
        error('Suma trozos not equal total')
    end

end

