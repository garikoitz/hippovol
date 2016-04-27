function parsave(varargin)
%parsave Saves file inside parfor
%   Detailed explanation goes here
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    savefile = varargin{1}; % first input argument
    for i=2:nargin
        savevar.(inputname(i)) = varargin{i}; % other input arguments
    end
    save(savefile,'-struct','savevar')
end