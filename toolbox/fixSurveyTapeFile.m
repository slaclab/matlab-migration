function iss=fixSurveyTapeFile(fname,E)
%
% Kluge to fix erroneous energy values in a MAD SURVEY tape-file. Requires
% that you generate another tape-file type (TWISS, RMAT, ENVELOPE, CHROM)
% in parallel, load it (xtff*2mat), and provide the correct E values to
% this function.

fidi=fopen('survey.tape','r');
fido=fopen('new_survey.tape','w');

m=0;
n=0;
while (true)
  s=fgetl(fidi);
  m=m+1;
  if (~ischar(s)),break,end
  if ((m>2)&&(~isempty(s))&&(~strcmp(' ',s(1)))&&(~strcmp('-',s(1))))
    n=n+1;
    s(115:130)=sprintf('%16.9E',E(n));
  end
  fprintf(fido,'%s\n',s);
end

fclose(fidi);
fclose(fido);

delete(fname)
cmd=sprintf('mv new_survey.tape %s',fname);
[iss,r]=system(cmd);

end