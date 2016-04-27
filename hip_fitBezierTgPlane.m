function [ ABOVE BELOW Bezier Corte] = hip_fitBezierTgPlane(M, point, DEBUG, vectTgBezier, ShortBezier)
%fitBezierTgPlane takes a freesurfer like structure with a fitted Bezier
%      curve and segments it in the point location with a plane
%      perpendicular to Bezier
%   OUTPUT:
%       ABOVE: values above cutting plane (it is a FS structure ready to be writen)
%       BELOW: values below cutting plane (it is a FS structure ready to be writen)
%       Bezier: Bezier curve, called P as well
%       Corte: It is 
%   INPUTS:
%       M: es el volumen que obtenemos desde MRIread(). Se puede meter MRIread directamente.
%       Point: es el landmark que hemos obtenido viendo los hipocampos, que
%               usaremos para la segmentaci??n
%       DEBUG: 0 para no visualizar, 1 para visualizar figuras
%       ShortBezier: le podemos pasar la curva si ya la tenemos (por ejemplo
%               para cortar el posterior con la misma curva que ten??amos 
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com
    
    % Transform the volume to 0s and 1s
    Mv = (M.vol > 0);
    % Convert to indez in order to have the cloud of points
    % Remember to change the order to X, Y (due to ind2sub)
    [Y,X,Z]=ind2sub(size(M.vol),find(M.vol>0));

    % The normal to the plane is the tangent to Bezier
    normal = vectTgBezier;
    % Create the plane with the normal and the point, and create the index
    % of all the points of the structure above the said plane
    ABOVEind = (Z(:,1)  -  ((normal(1)*(point(1)-X(:,1)) + ...
                normal(2)*(point(2)-Y(:,1)))/normal(3) + point(3))   ) > 0;
    % Create the above and below structure
    ABOVE = M;
    ABOVE.vol = zeros(size(M.vol));
    BELOW = ABOVE;
    % Using the index created above, and sub2ind, revert it to a FS like
    % structure separated between above and below
    ABOVE.vol(sub2ind(size(M.vol), Y(ABOVEind), X(ABOVEind), Z(ABOVEind)))=1;    
    BELOW.vol(sub2ind(size(M.vol), Y(~ABOVEind), X(~ABOVEind), Z(~ABOVEind)))=1;    
    
    if DEBUG > 0
        %Pintamos el plano con un punto y una normal y el resto de puntos
        % formula del plano: a*x+b*y+c*z+d=0
        d = -point*normal';
        [xx,yy]=ndgrid(0:10:size(Mv, 1),0:10:size(Mv, 1));
        z = (-normal(1)*xx - normal(2)*yy - d)/normal(3);
        hold on; surf(xx,yy,z);
        plot3(P(:,1), P(:,2), P(:,3), 'r.')
        hold on
        plot3(MasCercano(1), MasCercano(2), MasCercano(3), 'g*')
        plot3(point(1), point(2), point(3), 'g*')
        %plot3(X(:), Y(:), Z(:), 'b.')
        plot3(X(ABOVEind,1), Y(ABOVEind,1), Z(ABOVEind,1), 'b.');
        plot3(X(~ABOVEind,1), Y(~ABOVEind,1), Z(~ABOVEind,1), 'r.');
        xlabel('x-axis')
        ylabel('y-axis')
        zlabel('z-axis')
        title('Perpendicular plane to Bezier through landmarks')
        axis tight
        grid on
        box on
    end 
end