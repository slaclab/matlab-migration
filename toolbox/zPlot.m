function [name, val] = zPlot(prim, secn, region, varargin)
%ZPLOT
% [NAME, VAL] = ZPLOT(PRIM, SECN, REGION, OPTS) Z-plot facility for
% modelled devices, other devices will appear at z=0. Finds all PVs with
% primaries PRIM in regions REGION, e.g. {'L2' 'L3'} and obtains value of
% secondary SECN ans then creates stem plot. Both PRIM and SECN can be
% multiple items, different SECNs are plotted with different colors.

% Features:

% Input arguments:
%    PRIM:   Char or cellstr (array) of primary names, e.g. 'QUAD'
%    SECN:   Char or cellstr (array) of secondary tags, e.g. 'BDES'
%    REGION: Optional parameter for accelerator areas, default full, e.g. 'L2'
%    OPTS:   Options
%            DELAY: Default 0, plot once, if > 0, plot in loop with this delay

% Output arguments:
%    NAME: List of names found
%    VAL:  List of values plotted

% Compatibility: Version 7 and higher
% Called functions: util_parseOptions, model_nameRegion, model_rMatGet, lca*

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'delay',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

if nargin < 3, region=[];end
[name,id,isSLC]=model_nameRegion(prim,region);
secn=cellstr(secn);
z=model_rMatGet(name,[],[],'Z');
pv=cell(numel(name),numel(secn));
for j=1:numel(secn), pv(:,j)=strcat(name,':',secn(j));end
egu='';
if ~all(isSLC)
    egu=lcaGetSmart([strtok(pv{1},'.') '.EGU']);
    if isnumeric(egu), egu='';end
end

lcaSetSeverityWarnLevel(4);
[val,ts]=lcaGetSmart(pv(:),0,'double');
if all(isnan(val))
  [val,ts]=lcaGetSmart(pv(:),0,'char');
  val=str2num(char(val));
end
stem(z,reshape(val,[],numel(secn)),'.','MarkerEdgeColor','r','MarkerSize',15);
xlabel('z Position  (m)');
ylabel(strcat(secn,'  (',egu,')'));
prim=cellstr(prim);
tStr=['Z-Plot ' sprintf('%s ',prim{:})];
title([tStr datestr(lca2matlabTime(ts(1)))]);

while opts.delay
    [val,ts]=lcaGetSmart(pv(:),0,'double');
    stem(z,reshape(val,[],numel(secn)),'.','MarkerEdgeColor','r','MarkerSize',15);
    xlabel('z Position  (m)');
    ylabel(strcat(secn,'  (',egu,')'));
%    set(1,'Name',['Z-Plot Display ' datestr(lca2matlabTime(ts(1)))]);
    title([tStr datestr(lca2matlabTime(ts(1)))]);
    pause(opts.delay);
    drawnow;
end
