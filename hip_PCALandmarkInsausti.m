function [HEAD, POSTERIOR, BODY, TAIL] = hip_PCALandmarkInsausti(d, M)
%hip_PCALandmarkInsausti Method based on Bezier, PERC,  and Insausti
%   Calculates volumes of the hippocampus segments based on the given variables.
%   All the functions are being called with the following function handle:
%   [HEAD, POSTERIOR, BODY, TAIL, valores] = fhandle(d, M);
%   
%   04/2015: GLU: First version as an independent function
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    disp('IMPLEMENT THIS METHOD');
     
     
     
    HEAD = M; POSTERIOR = M; BODY = M; TAIL = M;
    
    [Y, X, Z] = ind2sub(size(M.vol),find(M.vol>0));
    X = [X, Y, Z]; % These are the coordenates of my data
    [coeff,score] = pca(X); 
    dirVect = coeff(:,1);  % Vector PCA1
    
    head_ind = (X(:,3) - ...
                ((dirVect(1)*(punto(1)-X(:,1)) + ...
                dirVect(2)*(punto(2)-X(:,2)))/dirVect(3) + ...
                punto1(3)) ...
                ) > 0;
   
    HEAD.vol(sub2ind(size(M.vol), ...
                     X(head_ind,2), X(head_ind,1), X(head_ind,3)))=1; 
    POSTERIOR.vol(sub2ind(size(M.vol), ...
                     X(~head_ind,2), X(~head_ind,1), X(~head_ind,3)))=1; 
    

    if d.DEBUG > 0
        meanX = mean(X,1);
        t = [min(score(:,1))-5, max(score(:,1))+5];
        endpts = [meanX + t(1)*dirVect'; meanX + t(2)*dirVect'];
        plot3(endpts(:,1),endpts(:,2),endpts(:,3),'k-');
        maxlim = max(abs(X(:)))*1.1;
        axis([-0 maxlim -0 maxlim -0 maxlim]);
        axis square; grid on;
        view(-9,12);
        hold
        a = nnz(ismember(X, punto1, 'rows'))
        plot3(punto1(1), punto1(2), punto1(3), 'ro')
        plot3(meanX(1), meanX(2), meanX(3), 'gx')
        plot3(X(:,1),X(:,2),X(:,3),'b.');
        figure(2)
        isosurface(M.vol)
        eje1 = 0:maxlim;
        eje2 = 0:maxlim;
        vectz = [0;0;1];
        [orde,absi]=meshgrid(eje1,eje2);
        vert_head = (dirVect(1)*(punto1(1)-ord) + dirVect(2)*(punto1(2)-absi))/dirVect(3) + punto1(3);
        vert_plano_head = (vectz(1)*(punto1(1)-ord) + vectz(2)*(punto1(2)-absi))/vectz(3) + punto1(3);
        mesh(ord,absi,vert_head)
        mesh(ord,absi,vert_plano_head)
        plot3(X(head_ind,1), X(head_ind,2), X(head_ind,3), 'b.');
        plot3(X(~head_ind,1), X(~head_ind,2), X(~head_ind,3), 'r.');
        xlabel('x-axis')
        ylabel('y-axis')
        zlabel('z-axis')
        title('Plano perpendicular al PCA1 pasando por landmarks')
        axis tight
        grid on
        box on
    end
    
    
    
    
    
    
    % Call the function to cut, but remember to do +1 to the points, matlab
    % starts in 1
    [HEAD, POSTERIOR, Bezier, Corte] = hip_fitBezierTgPlane(M, (punto+1), 1);
    
    % Divide the posterior in half
    por_arriba = ceil((0.5/2) * length(Bezier));
    por_abajo = floor((0.5/2) * length(Bezier));
    ShortBezier = Bezier((por_abajo+1):1:(length(Bezier)-por_arriba),:);
    a = nnz(ismember(ShortBezier, Corte, 'rows'));
    if ~a
        error('El punto de corte del plano que pasa por el landmark deber??a estar en ShortBezier')
    end
    donde = ismember(ShortBezier, Corte, 'rows');
    Division = ShortBezier(floor(find(donde)/2), :);
    [BODY, TAIL, Bezier, Corte] = hip_fitBezierTgPlane(POSTERIOR, Division, 1, ShortBezier);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Check that no voxel is missing
    if ~isequal(nnz(M.vol), nnz(HEAD.vol)+nnz(BODY.vol)+nnz(TAIL.vol))
        error('Suma trozos not equal total')
    end
    valores(hemivalor4{h}) = [nnz(M.vol) nnz(HEAD.vol) nnz(BODY.vol) nnz(TAIL.vol)];
    

end

