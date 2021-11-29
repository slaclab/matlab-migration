function [a, pic]=spatMod_loadDMDimage(ALP_ID,sequenceId,img)

pause on;
a=calllib('alpV42','AlpProjHalt',ALP_ID);
pause(3);

% %flip the 1's and 0's
% pix0=img==0;pix1=img==1;img(pix0)=1;img(pix1)=0;

%put image on sequence
UserArrayPtr=libpointer('voidPtr',img');
[a,pic]=calllib('alpV42','AlpSeqPut',ALP_ID,sequenceId,0,0,UserArrayPtr);
%a=calllib('alpV42','AlpProjControl',ALP_ID,2300,2302)
%project image
a=calllib('alpV42','AlpProjStartCont',ALP_ID,sequenceId);
% [a,proj_state]=calllib('alpV42','AlpProjInquire',ALP_ID,2400,UserVarPtr)%returns 1200 if active

pause off;

