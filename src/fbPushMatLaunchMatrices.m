function [G,F] = fbPushMatLaunchMatrices(name,varargin)
% function fbPushMatLaunchMatrices(name,[noprompt])
%     Gets launch matrices using fbGetMatLaunchMatrices then prompts for
%     the user to push these to the F and G matrix waveforms.
%
%     Optional input NOPROMPT (logical): Default 0. If 1, the script will
%     execute, push the matrices, and if FB running it will stop/start as
%     well. Exception MSGBOXes still popup.
if isempty(varargin)
    noprompt=0;
else
    noprompt = varargin{1};
    disp(['Pushing updated ' name ' matrices without review upon request...'])
end;
[othername,~,ispv] = lcaGetSmart([name ':NAME']);
if iscell(othername),othername = othername{:};end
if ~ispv
    msgbox(['Could not find name for ' name '. Does this FB exist?'],'Matlab FB Matrices')
    return
end
[G, F] = fbGetMatLaunchMatrices(name)
if isempty(G) || isempty(F)
    msgbox(['Could not compute matrices for ' othername '--' name '. Check Matlab workspace before clicking OK for errors. Doing nothing.'],...
        'Matlab FB Matrices');
    return
end
[FGold] = lcaGetSmart(strcat(name,{':FMATRIX',':GMATRIX'}));
F2 = reshape(F,1,numel(F));
G2 = reshape(G,1,numel(G));
if ~noprompt
    figure
    subplot(2,1,1)
    plot(1:numel(F2),FGold(1,1:numel(F2)),...
        1:numel(F2),F2);
    xlim([1 numel(F2)]);
    title([othername ' -- ' name])
    ylabel('F')
    legend('Old WF,','New WF')
    enhance_plot;
    subplot(2,1,2)
    plot(1:numel(G2),FGold(2,1:numel(G2)),...
        1:numel(G2),G2);
    ylabel('G')
    xlim([1 numel(G2)]);
    enhance_plot;

    msg=sprintf('Matrices calculated:\n\n');
    msg=sprintf('%sGMatrix: %s\n\n', msg, mat2str(G));
    msg=sprintf('%sFMatrix: %s\n\n', msg, mat2str(F));
    msg=sprintf('%sDo you want to update the matrices?', msg);
    button = questdlg(msg,[othername ' ' ...
                        'Matrices'],'Yes','No','No');
    switch button
      case 'Yes',  
       disp_log(['Pushing new F and G matrices for ' name]);
       lcaPutSmart([name ':GMATRIX'],G2);
       lcaPutSmart([name ':FMATRIX'],F2);
       if lcaGetSmart([name ':STATE'],1,'double');
           button = questdlg([othername ' is currently running, but needs to be stop/started for the new matrices to take effect. Would you like me to do this now?'],...
               [othername ' Matrices'],'Yes','No','No');
           if strcmp(button,'Yes')
               disp_log(['Stop/Starting ' name]);
               lcaPutSmart([name ':STATE'],0);
               pause(0.5);
               lcaPutSmart([name ':STATE'],1);
           end
       end
    end
else
    disp_log(['Pushing new F and G matrices for ' name ' without review']);
     lcaPutSmart([name ':GMATRIX'],G2);
     lcaPutSmart([name ':FMATRIX'],F2);
   if lcaGetSmart([name ':STATE'],1,'double');
       disp_log(['Stop/Starting ' name]);
       lcaPutSmart([name ':STATE'],0);
       pause(0.5);
       lcaPutSmart([name ':STATE'],1);
   end
end

exit;