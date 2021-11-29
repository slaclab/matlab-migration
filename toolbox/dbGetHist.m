function bval=dbGetHist(pvname,tnum)

% pvname = micr:prim:unit (EPICS-style)

% Try to get bval as an EPICS Channel Archiver BDES value. If that fails,
% try to get it either as an SLC History Buffer BACT value or as an SLC
% Database BDES value. If that fails, set bval=0 and issue a warning.

debug=false;

dt=datenum('01:00')-datenum('00:00'); % 1 hour
t1=datestr(tnum-dt,'mm/dd/yyyy HH:MM:SS');
t2=datestr(tnum,'mm/dd/yyyy HH:MM:SS');
trange={t1;t2};

query=strcat(pvname,':BDES');
try
  [t,d]=getHistory(query,trange);
 %bval=d(end-1);
  bval=d(end);
  if (debug),fprintf('EPICS(%d): %s\n',length(d),query);end
catch
  query=strcat(SLCname(pvname),'//BDES.HIST');
  try
    [t,d]=aidaGetHistory(query,trange);
    [temp,id]=min(abs(datenum(t)-tnum));
    bval=d(id(1));
    if (debug),fprintf('SLC(%d): %s\n',length(d),query);end
  catch
    warning('Failed to get %s',query)
    bval=0;
  end
end

end
