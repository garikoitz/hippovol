function [HEAD, POSTERIOR, BODY, TAIL, perc] = hip_AcquLandmarkInsausti(d, M, punto)
%AcquLandmarkInsausti Method based on Acquisition, PERC,  and Insausti
%   Calculates volumes of the hippocampus segments based on the given variables.
%   All the functions are being called with the following function handle:
%   [HEAD, POSTERIOR, BODY, TAIL, valores] = fhandle(d, M, punto);
%   
%   04/2015: GLU: First version as an independent function
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com

    % Convert it to an index
    [Y, X, Z] = ind2sub(size(M.vol),find(M.vol>0));

    % Obtain points of interest
    maximo = max(Z);
    minimo = min(Z);
    largo = (maximo - minimo)+1;
    head_point = punto;
    posterior_largo = head_point - minimo;
    tail_point = round(minimo + 0.5*posterior_largo);
    
    % Which is the percentage of this landmark over the total length?
    perc = (maximo - head_point)/largo;
    
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

    
    % Now that we have used the interpolate method instead of the nearest, we
    % will have values between 0 and 128, and we want to sum all the 128-s as
    % 1-s and the others as percentages, so we will sum x/128 in each case. 
    
    
    
    % Validate that when segmenting none of the voxels is lost
    if ~isequal(nnz(M.vol), nnz(HEAD.vol)+nnz(BODY.vol)+nnz(TAIL.vol))
        error('Suma trozos not equal total')
    end

end

