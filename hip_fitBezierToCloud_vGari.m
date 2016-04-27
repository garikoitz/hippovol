function P = hip_fitBezierToCloud_vGari(M,L,mydecimate,optim)
%Document it. 
%  
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com
% 
%   04/2015: GLU: First version as an independent function
%   11/2015: GLU: redone from scratch. First I create the PCA and them warp
%                 it. Furthermore, created planes to delimit the length of
%                 Bezier Curve to the total lenght of the hippocampus.

if nargin<3
    mydecimate=1;
end
if nargin<2
    order=2;
end


DEBUG=0;
% DEBUG=1;
nSamples=1000;

M=M.vol>0;


if DEBUG
    % Display the hippocampus with 0.2 transparency
    sizeOfM=size(M);
    figure(1)
    % Do it properly in ind2sub, otherwise the plots and the rest doesn't work
    % p=patch(isosurface(permute(M,[2 1 3]))); isonormals(permute(M,[2 1 3]), p)
    p=patch(isosurface(M)); isonormals(M, p)
    % set(p,'FaceColor', [0 1 0], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.2); 
    set(p,'FaceColor', [0 0 1], 'EdgeColor', [0.5 0.5 0.5], 'facealpha',0.2,'edgealpha',0.9); 
    % set(p,'FaceColor', [0 1 0], 'EdgeColor', [0.5 0.5 0.5]); 
    axis equal
end


% Run PCA and project onto axis to get x_a and x_b
[Y,X,Z]=ind2sub(size(M),find(M));
DATA=[X,Y,Z]';
MU=mean(DATA,2);
COV=cov(DATA');
[V,D]=eig(COV);
[~,idx]=sort(diag(D),'descend');
P=V(:,idx);
E1=P(:,1);
E2=P(:,2);
E3=P(:,3);
B=E1'*(DATA-repmat(MU,[1 size(DATA,2)]));
Xa=MU+E1*min(B);
Xp=MU+E1*max(B);
Xc=0.5*Xa+0.5*Xp;

if DEBUG
    % Xfig = 0.35*Xa+0.65*Xp;
    hold on, plot3([Xa(1) Xp(1)],[Xa(2) Xp(2)],[Xa(3) Xp(3)],'r-','linewidth',6); hold off
    hold on, plot3([Xa(1) Xc(1) Xp(1)],[Xa(2) Xc(2) Xp(2)],[Xa(3) Xc(3) Xp(3)],'k.','markersize',60); hold off
    % hold on, plot3(Xfig,'k.','markersize',60); hold off
end

% stack variables to optimize into a single column vector
% Convention is the following:
% (lambda_a,lambda'_a,lambda_c,lambda'_c,lambda_p,lambda'_p)'
V0=zeros(6,1);
cost0=hip_computeCostAndGrad(DATA,Xa,Xc,Xp,E2,E3,V0,nSamples);

opts=[];  opts.m=20; opts.factr=1; opts.pgtol=1e-2; opts.maxits=5000; opts.x0=V0;
opts.maxTotalIts=100; opts.printEvery=1; opts.errFcn =[]; opts.outputFcn=[];


if optim
    [V,costFinal,info] = fminunc( @(xxx) hip_computeCostAndGrad(DATA, Xa,Xc,Xp,...
                 E2,E3,xxx,nSamples), opts.x0, opts);
else
    [V,costFinal,info] = lbfgsb( @(xxx) hip_computeCostAndGrad(DATA,Xa,Xc,Xp,...
                  E2,E3,xxx,nSamples), -Inf*ones(size(V0)),Inf*ones(size(V0)),opts);
end

% totalTime=toc();
% disp(['The cost of the final fit is: ' num2str(costFinal)]);
% disp(['The optimization took ' num2str(totalTime) ' seconds']);

% Display final fit
x_ini=Xa(1)+V(1)*E2(1)+V(2)*E3(1);
y_ini=Xa(2)+V(1)*E2(2)+V(2)*E3(2);
z_ini=Xa(3)+V(1)*E2(3)+V(2)*E3(3);

x_int=Xc(1)+V(3)*E2(1)+V(4)*E3(1);
y_int=Xc(2)+V(3)*E2(2)+V(4)*E3(2);
z_int=Xc(3)+V(3)*E2(3)+V(4)*E3(3);

x_end=Xp(1)+V(5)*E2(1)+V(6)*E3(1);
y_end=Xp(2)+V(5)*E2(2)+V(6)*E3(2);
z_end=Xp(3)+V(5)*E2(3)+V(6)*E3(3);

[Xlist,Ylist,Zlist]=hip_computeBezierPoints(x_ini,y_ini,z_ini,...
                                            x_int,y_int,z_int,...
                                            x_end,y_end,z_end,...
                                            nSamples);

if DEBUG
    figure(1)
    hold on
    plot3(Xlist,Ylist,Zlist,'b','linewidth',6)
    plot3([x_ini x_int x_end],[y_ini y_int y_end],...
        [z_ini z_int z_end],'g.','markersize',60)

        planeMin = createPlane(Xa', E1');
        planeInt = createPlane(Xc', E1');
        planeMax = createPlane(Xp', E1');
    %     planeFig = createPlane(Xfig', E1');
        drawPlane3d(planeMin, 'b')
        drawPlane3d(planeInt, 'b')
        drawPlane3d(planeMax, 'b')
    %     drawPlane3d(planeFig, 'b')
end    




P3 = [Xlist', Ylist', Zlist'];
Xo = DATA';
XoPad=[Xo ones(size(Xo,1),1)];

for pp=1:size(P3,1)-1
    normal=P3(pp,:)-P3(pp+1,:);
    % normal=normal/norm(normal);
    d=-normal*P3(pp,:)';
    plane=[normal d];
    ab=sum(XoPad.*repmat(plane,[size(XoPad,1) 1]),2);
    if any(ab>0)
        ppmin=pp;
        planemin=plane;
        break;
    end
end

for pp=size(P3,1):-1:2
    normal=P3(pp,:)-P3(pp-1,:);
    % normal=normal/norm(normal);
    d=-normal*P3(pp,:)';
    plane=[normal d];
    ab=sum(XoPad.*repmat(plane,[size(XoPad,1) 1]),2);
    if any(ab>0)
        ppmax=pp;
        planemax=plane;
        break;
    end
end







if DEBUG > 0
    drawPlane3d(planemax, 'b')
    drawPlane3d(planemin, 'b')
    Pfig = P3(370,:);
    Pfigmas1 = P3(371,:);
    PlaneBezFig = medianPlane(Pfig, Pfigmas1);
    drawPlane3d(PlaneBezFig, 'b')
    hold off
    title('Initial (red) and final (blue) positions of the fit')
end

P = P3(ppmin:ppmax, :);




end

