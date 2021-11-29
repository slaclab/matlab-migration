function bba_corrSet(static, deltaCorr, appMode, varargin)

% Real positions of quads, BPMs, undulators, and beam
global quadOff undOff bpmOff corrB xInit girdPos strayB

optsdef=struct( ...
    'abs',0, ...
    'init',0, ...
    'wait',3 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

bDes=bba_corrGet(static,appMode,varargin{:});
bDes=bDes*~opts.abs+deltaCorr;

pv=static.corrList;
useX=strncmp(pv,'X',1) | strncmp(pv,'BX',2);
useY=strncmp(pv,'Y',1) | strncmp(pv,'BY',2);

if opts.init
    bDes=nan(2,length(static.corrList));
    bDes(1,useX)=0;bDes(2,useY)=0;
    if ~any(useY), bDes(2,:)=0;end
    strayB=bDes*0;
end

corrB=bDes;

if appMode
    pv=model_nameConvert(pv,'EPICS');
    if ~any(useY)
        pvY=model_nameConvert(strrep(pv,'X','Y'),'EPICS');
        pvY=strrep(pvY,'YCYL1','YCOR:LTU1:843');
        pvY=strrep(pvY,'YCYL2','YCOR:LTU1:854');
        pv=[pv(useX);pvY];useY=':';
        
    else
        pv=[pv(useX);pv(useY)];
    end
    control_magnetSet(pv,[bDes(1,useX) bDes(2,useY)],'wait',opts.wait);
end
