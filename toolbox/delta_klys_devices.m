%delta_klys_devices(prim,micro,unit,secn,delta,(trimflag))
%
%
%        iok = delta_klys_devices(prim,micro,unit,secn,delta);
%
%        Applies a change in the value specified by 'prim','micro','unit',
%        'secn' by the amount 'delta'.
%
%        Arguments 'prim', 'micro' and 'secn' must be four character strings.
%        Argument 'unit' must be integer and argument 'delta' must
%        be float. Optional global argument 'notrim' disables SLC Control
%        phase trim (applicable to PDES secondary only see examples below).
%
%        Not implemented for all secondaries (intended for use with
%        SBST and KLYS PDES, KPHR and GOLD).
%
%        Also works for a list of N devices where 'prim', 'micro'
%        and 'secn' are (Nx4) matricies filled with appropriate
%        text, 'unit' and 'delta' are vectors of length [1xN],
%
%
%        Example:
%
%        >> prim  = ('SBST','SBST','SBST','SBST');
%        >> micro = ('LI21','LI22','LI23','LI24');
%        >> unit  = (1,1,1,1);
%        >> secn  = ('PDES','PDES','PDES','PDES');
%        >> delta = (35,35,35,35);
%        >> err   = delta_klys_devices(prim,micro,unit,secn,delta);
%
%        Changes the four SBST PDES by 35 deg with associated SLC
%        Control phase trim.
%
%        Example:
%
%        >> prim  = ('SBST','SBST');
%        >> micro = ('LI30','LI30');
%        >> unit  = (1,1);
%        >> secn  = ('PDES','GOLD');
%        >> delta = (-25,25);
%        >> err   = delta_klys_devices(prim,micro,unit,secn,delta,'n');
%
%        Changes SBST 30 PDES by -25 deg and SBST 30 GOLD by +25 deg.
%        SLC Control phase trim associated with PDES change is
%        disabled.
%
%        HVS 2/5/08


function iok = delta_klys_devices(prim,micro,unit,secn,delta,trimflag)
TRIM=''
if nargin==6,
  ans1 = trimflag(1);
  if (upper(ans1)) == 'N',
    TRIM='NO';
  end;
end;

% First do a dry run with no changes so that if java crashes it will
% not leave things scrambled.

%for j=1:length(unit),
%  string = strcat(upper(prim(j,:)),':',upper(micro(j,:)),':',...
%                        int2str(unit(j)),':',upper(secn(j,:)));
%  try
%    oldval=pvaGet(string, AIDA_FLOAT);
%  catch
%    errordlg('Error caught on "da.get" in "delta_klys_devices.m"','da.get error!');
%    iok = 0;
%    return
%  end
%  newval=oldval;
%  try
%    da.setDaValue(string,DaValue(java.lang.Float(newval)));
%  catch
%    errordlg('Error caught on SBST "dry run" phase setting in "delta_klys_devices.m"','da.setDaValue error!');
%    put2log('Error caught on SBST "dry run" phase setting in "delta_klys_devices.m" - da.setDaValue error!');
%    merr = lasterror;
%    merr.message
%    iok = 0;
%    return
%  end
%end;

% Now do it for real.

for j=1:length(unit),
  channel = strcat(upper(prim(j,:)),':',upper(micro(j,:)),':',...
                        int2str(unit(j)),':',upper(secn(j,:)));
  requestBuilder = pvaRequest(channel);
  requestBuilder.returning(AIDA_FLOAT);
  if ~empty(TRIM)
      requestBuilder.with('TRIM', TRIM);
  end
  try
    oldval=requestBuilder.get();
  catch e
    handleExceptions(e, 'in delta_klys_devices.m')
    iok = 0;
    return
  end
  newval=oldval + delta(j);
  if newval>180
     newval=newval-360;
  elseif newval<-180
     newval=newval+360;
  end;
  try
    requestBuilder.set(newval);
  catch e
%    warndlg('Unknown error caught on phase set in "delta_klys_devices.m" - may not be a real problem.','da.setDaValue error');
    handleExceptions(e, 'Unknown error caught on phase set in "delta_klys_devices.m" - may not be a real problem.')
    put2log('Unknown error caught on phase set in "delta_klys_devices.m" - may not be a real problem.');
    merr = lasterror;
    merr.message
    iok = 0;
    return
  end
end;

iok = 1;
