function DIVISIONS = hip_BezierDivisions(d, M, N)
%hip_BezierDivisions Method based on Bezier and nDivision
%   Calculates volumes of the structure segments based on the given variables.
%   All the functions are being called with the following function handle:
%   [HEAD, POSTERIOR, BODY, TAIL, valores] = fhandle(d, M, punto);
%   
%   01/2017: GLU: first version
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2017
% Contact: garikoitz@gmail.com

    % From the first time it has to come fitted, so: 
    ShortBezier = hip_fitBezierToCloud_vGari(M, d.orden, d.mydecimate, d.optim);
    
    % Obtain percentage of every segment
    segPerc = N/100;
    




    segmVols = {};
    
    for ii=2:(N-1)
        head_perc = segPerc;
        % Try to do use the same strategy as in pca, obtain head and tail and the
        % rest will be considered as bodies
        % We start from below
        tailbody_perc = 1 - (ii-1)*segPerc;
        tail_perc = 1 - ii*head_perc ;
    
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

        % Now we use the version to fit the plane to a segment of the curve, we give
        % it the previously calculated ShortBezier curve
        [HEAD, POSTERIOR] = hip_fitBezierTgPlane(M, head_point, d.DEBUG, vectTgBezierHead, ShortBezier);
        [BODY, TAIL] = hip_fitBezierTgPlane(POSTERIOR, tail_point, d.DEBUG, vectTgBezierTail, ShortBezier);
        
        if 2==ii; segmVols{1}=HEAD; end;
        if N-1==ii; segmVols{N}=TAIL; end;
        segmVols{ii} = BODY; 
        
    end
    
    
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

    
    % Validate that when segmenting none of the voxels is lost
    sumOfSegments = 0;
    for ii=1:N
        sumOfSegments = sumOfSegments + nnz(segmVols{ii}.vol);
    end
    if ~isequal(nnz(M.vol), sumOfSegments)
        error('Suma trozos not equal total')
    else
        DIVISIONS = segmVols;
    end
    
    
    
    
    
    
end

