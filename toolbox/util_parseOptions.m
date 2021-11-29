function opts = util_parseOptions(varargin)
%UTIL_PARSEOPTIONS
%  OPTS = UTIL_PARSEOPTIONS(OPTS, OPTSDEF) copies fields in OPTS into
%  OPTSDEF and returns OPTSDEF. OPTS can also be a parameter/value list
%  which gets passed to STRUCT() to generate OPTS structure. Cell arrays in
%  argument list are put into cells as neccessary to permit scalar OPTS
%  structure.

% Features:

% Input arguments:
%    OPTS: Structure of options or list of parameter/value pairs
%    OPTSDEF: Structure of default options

% Output arguments:
%    OPTS: Structure of options with missing fields added from OPTSDEF

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Check input arguments.
if nargin == 2
    opts=varargin{1};
else
    % Wrap cell around params which are cell arrays to guarantee scalar output
    for j=2:2:numel(varargin)-1
        if iscell(varargin{j}) && numel(varargin{j}) ~= 1, varargin(j)={varargin(j)};end
    end
    opts=struct(varargin{1:end-1});
end
optsdef=varargin{end};

% Loop through OPTS fields and set OPTSDEF fields.
for j=fieldnames(opts)',
    if isfield(optsdef,j)
        optsdef.(j{:})=opts.(j{:});
    end
end
opts=optsdef;
