function [Xlist,Ylist,Zlist]=hip_computeBezierPoints(x_ini,y_ini,z_ini,...
                                                     x_int,y_int,z_int,...
                                                     x_end,y_end,z_end,...
                                                     nSamples)
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com




t=0:1/(nSamples-1):1;
P1=[x_ini;y_ini;z_ini];
P2=[x_int;y_int;z_int];
P3=[x_end;y_end;z_end];

P=repmat((1-t).*(1-t),[3 1]).*repmat(P1,[1,length(t)])+...
    repmat(2*t.*(1-t),[3 1]).*repmat(P2,[1,length(t)])+...
    repmat(t.*t,[3 1]).*repmat(P3,[1,length(t)]);

Xlist=P(1,:);
Ylist=P(2,:);
Zlist=P(3,:);