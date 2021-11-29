function showALHdisable()
%funcion showALHdisable()
%Lists alarm hadler channels that are disabled.


%

% William Colocho, Dec. 2008
showRedALHpvs(false)


%Gets all bad channel list from /u1/lcls/alh/badALHpvListFP
% % Get List of PVs from configuration files
% system(['grep "FP  /LOG" /usr/local/lcls/tools/ChannelWatcher', ...
%     '/config/SIOC-SYS0-AL00.cwConfig > /tmp/alhPVs']);
% system(['grep "FP  /LOG" /usr/local/lcls/tools/ChannelWatcher', ...
%     '/config/SIOC-SYS0-AL01.cwConfig >> /tmp/alhPVs']);
% fid1 = fopen('/tmp/alhPVs','r');
% pvList = textscan(fid1,'%s %*s'); pvList = pvList{:};
% fclose(fid1);
% 
% fid2 = fopen('/u1/lcls/alh/badALHpvListFP');
% badPvList = textscan(fid2,'%s'); badPvList = badPvList{:};
% fclose(fid2);
% 
% %Remove bad Channels
% pvList = unique(pvList); % Some entries are repeated!
% [C, iA, iB] = intersect(badPvList,pvList);  %#ok<NASGU>
% pvList(iB) = [];
% newList = pvList;
% 
% %Get and display status of ALH PVs.
% status = lcaGet(newList);
% disableIndx = strmatch('Off',status);
% fprintf('\nList of ALH channels disabled:\n\n')
% disp(newList(disableIndx));
end
