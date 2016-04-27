function [HEAD, POSTERIOR, BODY, TAIL] = hip_AcquPERCInsausti(d, M, punto)
%AcquPERCInsausti Method based on Acquisition, PERC,  and Insausti
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


    % Convert it to an index
    [Y, X, Z] = ind2sub(size(M.vol),find(M.vol>0));

    % Obtain max, min and length
    maximo = max(Z);
    minimo = min(Z);
    largo = (maximo - minimo)+1;

    % According to Hackert 2002: head 35%, tail 20% and body 45%
    % tail_perc = 0.2; but in out tests we'be seen that 44.2% is better for
    % aseg
    head_perc = punto/1000;
    tailbody_perc = 1 - head_perc; % we start from below
    tail_perc = tailbody_perc/2;
    tail_point = round(minimo + tail_perc*largo);
    head_point = round(maximo - head_perc*largo);

    % Initialize structure segments
    HEAD = M; POSTERIOR = M; BODY = M; TAIL = M;
    
    % Delete 1-s depending on the indexes
    HEAD.vol(:,:,1:(head_point-1))=0;
    POSTERIOR.vol(:,:,head_point:end)=0;
    BODY.vol = POSTERIOR.vol;
    BODY.vol(:,:,1:tail_point)=0;
    TAIL.vol(:,:,(tail_point+1):end)=0;

    if d.DEBUG >0
        N = M;
        N.vol=zeros(size(N.vol));
        N.vol=HEAD.vol + BODY.vol + TAIL.vol;
        if ~isequal(N.vol, M.vol)
            error('La suma de las partes no es igual al original')
        end
    end

    % Obtain statistics and validate that during segmentation not a single voxel
    % went missing
    if ~isequal(nnz(M.vol), nnz(HEAD.vol)+nnz(BODY.vol)+nnz(TAIL.vol))
        error('Suma trozos not equal total')
    end
end

