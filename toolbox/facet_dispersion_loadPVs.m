function facet_dispersion_loadPVs(model,result)

% some model stuff
K=model.K;
N=model.N;
T=model.T;
Z=model.coor(:,3);
rmat=model.rmat;

% create a list of unique Z-locations between exit of chicane and
% spectrometer bend
id1=strmatch('CB1RE',T); % exit of chicane
id2=strmatch('B5D36',T);id2=id2(1)-1; % entrance to spectrometer bend
[dummy,id,dummy]=unique(Z,'first');
idp=intersect(id,id1:id2);
Np=length(idp);
Zp=Z(idp);
Dp=zeros(Np,4);

% propagate DX/DPX/DY/DPY from exit of chicane to each location
R0=rmat(6*id1-5:6*id1,:);
u0=result.D2';
for n=1:Np
  R=rmat(6*idp(n)-5:6*idp(n),:);
  Rp=R/R0;
  u=Rp(1:4,1:4)*u0;
  Dp(n,:)=u';
end

% linearly interpolate the propagated dispersion values
PVlen=10000;
ip=strmatch('INST',K); % experiment IPs
Zi=linspace(Zp(1),Zp(end),PVlen-length(ip))';
Zi=sort([Zi;Z(ip)]);
Di=1e3*interp1(Zp,Dp,Zi,'linear');

% upload propagated/interpolated dispersion values to array PVs
lcaPutSmart('SIOC:SYS1:ML00:FWF33',Zi');      % Z (m)
lcaPutSmart('SIOC:SYS1:ML00:FWF34',Di(:,1)'); % DX (mm)
lcaPutSmart('SIOC:SYS1:ML00:FWF35',Di(:,2)'); % DPX (mrad)
lcaPutSmart('SIOC:SYS1:ML00:FWF36',Di(:,3)'); % DY (mm)
lcaPutSmart('SIOC:SYS1:ML00:FWF37',Di(:,4)'); % DPY (mrad)

% upload fitted BPM dispersion values to PVs
pvlist=[ ...
  strcat(result.mname,':ETA_X'); ...
  strcat(result.mname,':DETA_X'); ...
  strcat(result.mname,':ETA_Y'); ...
  strcat(result.mname,':DETA_Y')];
pvdata=1e3*[ ...
  result.Dm(:,1); ...
  result.dDm(:,1); ...
  result.Dm(:,2); ...
  result.dDm(:,2)];
id=find(~isnan(pvdata));
lcaPutSmart(pvlist(id),pvdata(id))

% upload propagated PROF/WIRE/OTRS/MIRR dispersion values to PVs
pvlist=[];
pvdata=[];
for n=1:length(result.pname)
  ic=strfind(result.pname{n},':');
  if (isempty(ic)),continue,end
  pvlist=[pvlist; ...
    strcat(result.pname(n),':ETA_X'); ...
    strcat(result.pname(n),':ETAP_X'); ...
    strcat(result.pname(n),':ETA_Y'); ...
    strcat(result.pname(n),':ETAP_Y')];
  pvdata=[pvdata;1e3*result.Dp(n,:)'];
end
lcaPutSmart(pvlist,pvdata)

% upload fitted dispersion values at chicane beg/end to PVs
pvlist={ ...
  'SIOC:SYS1:ML00:AO362'; ... %  DX @ B1L_beg (m)
  'SIOC:SYS1:ML00:AO363'; ... % DPX @ B1L_beg (rad)
  'SIOC:SYS1:ML00:AO364'; ... %  DY @ B1L_beg (m)
  'SIOC:SYS1:ML00:AO365'; ... % DPY @ B1L_beg (rad)
  'SIOC:SYS1:ML00:AO367'; ... %  DX @ B1R_end (m)
  'SIOC:SYS1:ML00:AO368'; ... % DPX @ B1R_end (rad)
  'SIOC:SYS1:ML00:AO369'; ... %  DY @ B1R_end (m)
  'SIOC:SYS1:ML00:AO370'; ... % DPY @ B1R_end (rad)
};
pvdata=[result.D1,result.D2]';
lcaPutSmart(pvlist,pvdata)

% upload propagated dispersion values at experiment IPs to PVs
id=[ ...
  strmatch('MIP',result.pname); ...
  strmatch('IP201',result.pname); ...
  strmatch('IP202',result.pname); ...
  strmatch('IP203',result.pname); ...
];
pvlist=[];
pvdata=[];
for n=1:length(id)
  name=result.pname(id(n));
  if (strcmp(name,'MIP'))
    pvlist=[pvlist;{ ...
    'SIOC:SYS1:ML00:AO372'; ... %  DX @ E200 (m)
    'SIOC:SYS1:ML00:AO373'; ... % DPX @ E200 (rad)
    'SIOC:SYS1:ML00:AO374'; ... %  DY @ E200 (m)
    'SIOC:SYS1:ML00:AO375'; ... % DPY @ E200 (rad)
    }];
  elseif (strcmp(name,'IP201'))
    pvlist=[pvlist;{ ...
    'SIOC:SYS1:ML00:AO377'; ... %  DX @ E201 (m)
    'SIOC:SYS1:ML00:AO378'; ... % DPX @ E201 (rad)
    'SIOC:SYS1:ML00:AO379'; ... %  DY @ E201 (m)
    'SIOC:SYS1:ML00:AO380'; ... % DPY @ E201 (rad)
    }];
  elseif (strcmp(name,'IP202'))
    pvlist=[pvlist;{ ...
    'SIOC:SYS1:ML00:AO382'; ... %  DX @ E202 (m)
    'SIOC:SYS1:ML00:AO383'; ... % DPX @ E202 (rad)
    'SIOC:SYS1:ML00:AO384'; ... %  DY @ E202 (m)
    'SIOC:SYS1:ML00:AO385'; ... % DPY @ E202 (rad)
    }];
  elseif (strcmp(name,'IP203'))
    pvlist=[pvlist;{ ...
    'SIOC:SYS1:ML00:AO387'; ... %  DX @ E203 (m)
    'SIOC:SYS1:ML00:AO388'; ... % DPX @ E203 (rad)
    'SIOC:SYS1:ML00:AO389'; ... %  DY @ E203 (m)
    'SIOC:SYS1:ML00:AO390'; ... % DPY @ E203 (rad)
    }];
  end
  pvdata=reshape(result.Dp(id,:)',[],1);
end
lcaPutSmart(pvlist,pvdata)

% upload propagated dispersion values at notch collimator and sYAG to PVs
pvlist={ ...
  'SIOC:SYS1:ML00:AO777'; ... %  DX @ notch collimator (m)
  'SIOC:SYS1:ML00:AO778'; ... % DPX @ notch collimator (rad)
  'SIOC:SYS1:ML00:AO779'; ... %  DY @ notch collimator (m)
  'SIOC:SYS1:ML00:AO780'; ... % DPY @ notch collimator (rad)
  'SIOC:SYS1:ML00:AO782'; ... %  DX @ sYAG (m)
  'SIOC:SYS1:ML00:AO783'; ... % DPX @ sYAG (rad)
  'SIOC:SYS1:ML00:AO784'; ... %  DY @ sYAG (m)
  'SIOC:SYS1:ML00:AO785'; ... % DPY @ sYAG (rad)
};
pvdata=[result.Dcn,result.Dsy]';
lcaPutSmart(pvlist,pvdata)

end