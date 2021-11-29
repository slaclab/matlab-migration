function [kname,kstat,kenld,kphas,kfudg,kgain]=FACET_getEnergyProfile(LEMG,tnum)
%
% Get FACET energy profile from LI02 to LI20 (present or historic)
%
% kname = EPICS PV root name for each KLYS
% kstat = ON/OFF status (beam code 10)
% kenld = KLYS ENLD values (MeV)
% kphas = total KLYS phase (deg)
% kfudg = LEM fudge factor for each KLYS
% kgain = total fudged energy gain for each KLYS (MeV)
%
% NOTE: the outputs are [18,8] arrays ... one row per sector; to get
%       a beamline-ordered list, use reshape(k....',[],1)

aidainit
import edu.stanford.slac.aida.lib.da.DaObject;
da=DaObject();

getHist=((nargin>1)&&~isempty(tnum)&&(tnum~=0));
if (getHist)
  dt=datenum('01:00')-datenum('00:00'); % 1 hour
  t1=datestr(tnum-dt,'mm/dd/yyyy HH:MM:SS');
  t2=datestr(tnum,'mm/dd/yyyy HH:MM:SS');
  timerange={t1;t2};
end

% get KLYS complement
% (NOTE: waveform PV created on 8/29/2011 17:40, no history available earlier)
kpv='FCUDKLYS:MCC1:ONBC10SUMY';
if (getHist)
  try
    [arch_times,arch_data]=getHistoryWfm(kpv,timerange);
  catch
    t0='08/29/2011 17:40:00';
    if (datenum(t2)<=datenum(t0))
      error('No FACET KLYS complement data available before %s',t0)
    else
      error('Error retrieving archive waveform! Check status of PV: %s',kpv)
    end
  end

  % find archive closest to (but before) tnum
  % (NOTE: assumes archive happens only when something changes)
  idt=find(arch_times<tnum);
  id=idt(end);
  tact=arch_times(id);
  kstat=arch_data(id,:);
else
  kstat=lcaGet(kpv);
end
kstat=reshape(kstat,8,[])'; % 18 rows (LI02-19) by 8 columns

% construct a list of KLYS names
[Nmicr,Nunit]=size(kstat);
kname=cell(Nmicr,Nunit);
for m=1:Nmicr
  micr=bitid2micr(m+1);
  for n=1:Nunit
    kname{m,n}=sprintf('%s:KLYS:%d',micr,10*n+1);
  end
end

% get KLYS ENLDs for LI02-LI19
kenld=zeros(Nmicr,Nunit);
for m=1:Nmicr
  for n=1:Nunit
    if (kstat(m,n))
      getNow=~getHist;
      if (getHist)
        query=strcat(kname{m,n},':ENLD');
        try
          [tval,bval]=getHistory(query,timerange);
        catch % ENLD not in EPICS Channel Archiver ... get present value
          getNow=true;
        end
      end
      if (getNow)
        query=strcat(SLCname(kname{m,n}),'//ENLD');
        bval=aidaget(query);
      end
      kenld(m,n)=bval(end);
    end
  end
end

% get SBST phases for LI02-LI19
% (NOTE: use feedback phase shifters in LI17 and LI18)
psbst=zeros(18,1);
for n=2:19
  micr=bitid2micr(n);
  if (getHist)
    if (strcmp(micr,'LI17'))
      query='EP01:AMPL:171:VACT'; % feedback
    elseif (strcmp(micr,'LI18'))
      query='EP01:AMPL:181:VACT'; % feedback
    else
      query=sprintf('%s:SBST:1:PDES',micr);
    end
    [tval,bval]=getHistory(query,timerange);
  else
    if (strcmp(micr,'LI17'))
      query='AMPL:EP01:171//VACT'; % feedback
    elseif (strcmp(micr,'LI18'))
      query='AMPL:EP01:181//VACT'; % feedback
    else
      query=sprintf('SBST:%s:1//PDES',micr);
    end
    bval=aidaget(query);
  end
  psbst(n-1)=bval(end);
end

% get KLYS phases for LI02-LI19
% (NOTE: use feedback phase shifters in LI09 ...
%        assume all other KLYS PDES values are zero)
pklys=zeros(size(kstat));
if (kstat(8,1)) % start with LI02
  if (getHist)
    [tval,bval]=getHistory('LI09:PHAS:12:VDES',timerange); % feedback
  else
    bval=aidaget('PHAS:LI09:12//VACT'); % LEM uses VACT
  end
  pklys(8,1)=bval(end);
end
if (kstat(8,2)) % start with LI02
  if (getHist)
    [tval,bval]=getHistory('LI09:PHAS:22:VDES',timerange); % feedback
  else
    bval=aidaget('PHAS:LI09:22//VACT'); % LEM uses VACT
  end
  pklys(8,2)=bval(end);
end

% total phase for each KLYS
kphas=((psbst*ones(1,Nunit))+pklys).*kstat; % degrees

% get LEM fudge factor ... assign fudges to individual KLYS units
fudg=[];
if (getHist)
  query=sprintf('VX00:LEMG:%d:FUDG',LEMG);
  try
    [arch_times,arch_data]=getHistoryWfm(query,timerange);
    bval=arch_data(end,:);
  catch % FUDG for this LEMG not in EPICS Channel Archiver ... get it from SLC History Buffer
    query=sprintf('LEMG:VX00:%d//FUDG',LEMG);
    d=da.getDaValue(query);
    bval=d.getFloats;
  end
else
  query=sprintf('VX00:LEMG:%d:FUDG',LEMG);
  bval=lcaGet(query);
end
switch LEMG
  case 4 % LEMNOCHN
    kfudg=bval(1)*kstat;
  case 5 % LEM_FCET
    id1=(1:72)'; % LEM region 1
    id2=(73:Nmicr*Nunit)'; % LEM region 2
    kfudg=reshape(kstat',[],1);
    kfudg(id1)=bval(1)*kfudg(id1);
    kfudg(id2)=bval(2)*kfudg(id2);
    kfudg=reshape(kfudg,Nunit,Nmicr)';
  otherwise
    error('Unsupported LEMG (unit %d)',LEMG)
end

% compute total energy gain for each KLYS
kgain=kfudg.*kenld.*cos((pi/180)*kphas);

end
