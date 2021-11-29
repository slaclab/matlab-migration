function [bDes, bMax] = bba_corrGet(static, appMode, varargin)

% Real positions of quads, BPMs, undulators, and beam
global quadOff undOff bpmOff corrB xInit girdPos

optsdef=struct( ...
    'init',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

bDes=corrB;
bMax=corrB*0+.01;

if appMode
    pv=static.corrList';
    bDes=nan(2,length(pv));bMax=bDes;
    useY=strncmp(pv,'Y',1);
    pv=[pv;strrep(pv,'X','Y')];
    if any(useY)
        pv([useY;~useY])={''};
    end
    pv=model_nameConvert(pv,'EPICS');
    use=~strcmp(pv,'');
    if nargout < 2
        bDes(use)=control_magnetGet(pv(use),'BDES');
    else
        [d,bDes(use),bMax(use)]=control_magnetGet(pv(use));
    end
end
