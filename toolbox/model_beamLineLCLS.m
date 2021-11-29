function beamLine = model_beamLineLCLS(varargin)
%MODEL_BEAMLINELCLS
% [BLFULL, BLSP, BL52, BLGS] = MODEL_BEAMLINELCLS(OPTS) Returns beam line
% description list for injector.

% Features:

% Input arguments:
%    OPTS:   Options
%            DESIGN: Default 0, if 0 and model simulation, Laser Heater
%                    optional

% Output arguments:
%    BEAMLINE: Struct of cell arrays of beam line information

% Compatibility: Version 7 and higher
% Called functions: model_beamLineInj, model_beamLineL2, model_beamLineL3,
%                   model_beamLineUnd

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

bl=model_beamLineInj('ALL',varargin{:});
bl.L2=model_beamLineL2;
bl.L3=model_beamLineL3;
% [bl.UN,bl.B5,bl.BS]=model_beamLineUnd;
[bl.UN,bl.BS]=model_beamLineUnd;

beamLine.FullMachine=quadsPatch([bl.IN;bl.DL;bl.B1;bl.L2;bl.B2;bl.L3;bl.UN]);
beamLine.SP=quadsPatch([bl.IN;bl.SP]);
% beamLine.B5=quadsPatch([bl.IN;bl.DL;bl.B1;bl.L2;bl.B2;bl.L3;bl.B5]);
beamLine.GS=quadsPatch(bl.GS);


function bl = quadsPatch(bl)

isQ=strcmp(bl(:,1),'qu') & cellfun('length',bl(:,4)) == 1;
k=[bl{isQ,4}]';k(:,2)=0;
bl(isQ,4)=num2cell(k,2);
