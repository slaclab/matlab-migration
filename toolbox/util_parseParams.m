function [param, idPar] = util_parseParams(param, paramDef, nArg)
%UTIL_PARSEPARAMS
%  OPTS = UTIL_PARSEPARAMS(PARAM, PARAMDEF, NARG) picks NARG parameters
%  from PARAM which match default parameter list PARAMDEF. Remaining
%  entries are filled from non-matched items from PARAMDEF.

% Features:

% Input arguments:
%    PARAM:    String or cell string array of parameter names
%    PARAMDEF: Cell string array of default parameter names
%    NARG:     Number of output arguments in calling function

% Output arguments:
%    PARAM: Matched parameter names
%    ID:    Index of matched names in PARAMDEF

% Compatibility: Version 2007b, 2012a, 2014b
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Check input arguments.
if isempty(param), param={};end
[is1,id1]=ismember(param,paramDef);
[d,id2]=setdiff(paramDef,param);
idPar=[id1(is1) sort(id2(:))'];
idPar(numel(paramDef)+1:end)=[];
param=paramDef(idPar(1:min(max(1,nArg),numel(paramDef))));
