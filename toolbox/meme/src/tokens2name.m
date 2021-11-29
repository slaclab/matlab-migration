function [NAME] = tokens2name(varargin)
%% tokens2name constructs SLAC control system names from their composite parts.
%
% INPUTS:
% tokens2name may be given 2, 3 or 4 arguments. where given:
%   2 arguments: 
%      tokens2name assumes 
%         1st argument is (one or more) entities (aka device names)
%         2nd argument is (one or more) attributes (aka secondaries). 
%      It constructs instance names (aka PV names) in the SLAC naming convension. Examples:
%               tokens2name('QUAD:IN20:642','BACT')
%               tokens2name('QUAD:IN20:371',{'BDES','BACT'})
%               tokens2name({'QUAD:IN20:371','QUAD:IN20:642'},'BDES')
%               tokens2name({'QUAD:IN20:371','QUAD:IN20:642'},{'BDES','BACT'})
%                
%   3 arguments: 
%      tokens2name assumes 
%         1st argument is (one or more) types aka primaries
%         2nd argument is (one or more) areas aka micros
%         3rd argument is (one or more) units aka location identifiers
%      It constructs entity (aka device) names. Examples:
%
%   4 arguments: 
%      tokens2name assumes 
%         1st argument is (one or more) types aka primaries
%         2nd argument is (one or more) areas aka micros
%         3rd argument is (one or more) units aka location identifiers
%         4th argument is (one or more) attributes, aka secondaries
%      It constructs instance names (aka PV names) names. Examples:
% 

if ( nargin == 2 )
    entity=cellstr(varargin{1});entity=entity(:);
    attribute=cellstr(varargin{2});attribute=attribute(:);
    name=strcat(strcat(entity,{':'}),attribute(1));
    Nattribute=length(attribute);
    if ( Nattribute > 1 )
        for iAttribute = 2:Nattribute
            name=[name,strcat(strcat(entity,{':'}),attribute(iAttribute))];
        end
    end
    NAME=name;
elseif ( nargin >= 3 )
    prim=cellstr(varargin{1});prim=prim(:);
    micro=cellstr(varargin{2});micro=micro(:);
    unit=cellstr(varargin{3});unit=unit(:);
    NAME=strcat(prim,{':'},micro,{':'},unit);
    if ( nargin == 4 )
        secn=cellstr(varargin{4});secn=secn(:);
        NAME=strcat(NAME,{':'},secn);
    end
end


