function [cost grad]=hip_computeCostAndGrad(DATA,Xa,Xc,Xp,E2,E3,V,nSamples)
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

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

NP=length(Xlist);



NPM=size(DATA,2);
Xm=DATA(1,:)';
Ym=DATA(2,:)';
Zm=DATA(3,:)';

Dx=repmat(Xm,[1 NP])-repmat(Xlist,[NPM 1]);
Dy=repmat(Ym,[1 NP])-repmat(Ylist,[NPM 1]);
Dz=repmat(Zm,[1 NP])-repmat(Zlist,[NPM 1]);
dist2=min(Dx.*Dx+Dy.*Dy+Dz.*Dz,[],2);
cost=sum(dist2)/NPM;

if nargout>1
    epsilon=1e-5;
    grad=zeros(size(V));
    for j=1:length(V)
        Vprob=V;
        Vprob(j)=V(j)+epsilon;
        costPlus=hip_computeCostAndGrad(DATA,Xa,Xc,Xp,E2,E3,Vprob,nSamples);
        Vprob=V;
        Vprob(j)=V(j)-epsilon;
        costMinus=hip_computeCostAndGrad(DATA,Xa,Xc,Xp,E2,E3,Vprob,nSamples);
        grad(j)=(costPlus-costMinus)/(2*epsilon);
    end
end

