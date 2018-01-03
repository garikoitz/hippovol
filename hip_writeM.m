function resp = hip_writeM(HEAD, POSTERIOR, BODY, TAIL, d, sp, h)
% hip_writeM It writes the modified hippocampus in sections for visualization
% purposes
% If you need volume values don't write the file to disk.
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com
    


switch d.method
    case {'Landmark'}
        ForName = char([d.methodName '.' d.orig_datos '.'  d.hemi{h} '.' d.bblta]);
    case {'PERC'}
        ForName = char([d.methodName '.' d.orig_datos '.'  d.hemi{h} '.' num2str(d.perc)]);
    case {'MNI'}
        ForName = char([d.methodName '.' d.orig_datos '.'  d.hemi{h} '.' d.bblta]);
    case {'nDivisions'}
        ForName = char([d.methodName '.' d.orig_datos '.'  d.hemi{h} '.xxOf' num2str(d.howManyN)]);
    otherwise
        error('In hip_InitMethod: This is not a recognized METHOD');
end
disp(['Writing files...']);
MRIwrite(HEAD,      char([sp filesep ForName '.head.hippovol_' d.sufixName '.mgz']));
MRIwrite(POSTERIOR, char([sp filesep ForName '.posterior.hippovol_' d.sufixName '.mgz']));
MRIwrite(BODY,      char([sp filesep ForName '.body.hippovol_' d.sufixName '.mgz']));
MRIwrite(TAIL,      char([sp filesep ForName '.tail.hippovol_' d.sufixName '.mgz']));
resp = 'DONE';
disp(['... finished writing files in ' sp]);


end


