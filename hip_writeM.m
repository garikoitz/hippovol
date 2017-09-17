function resp = hip_writeM(HEAD, POSTERIOR, BODY, TAIL, d, sp, h)
% hip_writeM It writes the modified hippocampus in sections for visualization
% purposes
% If you need volume values don't write the file to disk.
%
% (C) Garikoitz Lerma-Usabiaga
% BCBL. Basque Center on Cognition, Brain and Language. 
% 2016
% Contact: garikoitz@gmail.com
    

% TODO, use: 
%        try
%           statement, ..., statement, 
%        CATCH ME
%           statement, ..., statement 
%        END
%  
%     Normally, only the statements between the try and CATCH are executed.
%     However, if an error occurs while executing any of the statements, the
%     error is captured into an object, ME, of class MException, and the 
%     statements between the CATCH and END are executed. If an error occurs 
%     within the CATCH statements, execution stops, unless caught by another 
%     try...CATCH block. The ME argument is optional. 
if(strcmp(d.method, 'PERC'))
    ForName = char([d.methodName '.' d.orig_datos '.'  d.hemi{h} '.' num2str(d.perc)]);
elseif(strcmp(d.method, 'Landmark'))
    ForName = char([d.methodName '.' d.orig_datos '.'  d.hemi{h} '.' d.bblta]);
else        
    ForName = char([d.methodName '.' d.orig_datos '.'  d.hemi{h} '.' d.bblta]);
end
    disp(['Writing files...']);
    MRIwrite(HEAD,      char([sp filesep ForName '.head.hippovol_' d.sufixName '.mgz']));
    MRIwrite(POSTERIOR, char([sp filesep ForName '.posterior.hippovol_' d.sufixName '.mgz']));
    MRIwrite(BODY,      char([sp filesep ForName '.body.hippovol_' d.sufixName '.mgz']));
    MRIwrite(TAIL,      char([sp filesep ForName '.tail.hippovol_' d.sufixName '.mgz']));
    resp = 'DONE';
    disp(['... finished writing files in ' sp]);
end

