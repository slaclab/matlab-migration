function colList = gui_indexColor(indexName)
%GUI_INDEXCOLOR
%  GUI_INDEXCOLOR(INDEXNAME) returns background color for selected facility
%  names INDEXNAME.

% Input arguments:
%    INDEXNAME: Name(s) of facilities (LCLS, FACET, NLCTA, LCLSII)

% Output arguments:
%    COLLIST: List of color triplets [Nx3]

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Get default background color.
col0=get(0,'DefaultuicontrolBackgroundColor');

% Define color hues for index names.
colList={ ...
    'LCLS'   [ 0   0   0]; ... % LCLS
    'FACET'  [ 1  .4 -.2]; ... % FACET
    'LCLS2'  [ 1  -1   0]; ... % LCLS-II
    'LCLS3'  [ 0   1  -1]; ... % LCLS-III
    'NLCTA'  [-1   0   1]; ... % NLCTA
    'SPEAR'  [ 1   0  -1]; ... % SPEAR
    'XTA'    [-1   1   0]; ... % X Test facility
    'ASTA'   [ 0  -1   1]; ... % ASTA
    ''       [ 0   0   0]; ... % Default
};

% Rescale colors as small offsets from default.
colList(:,2)=num2cell(min(.09*vertcat(colList{:,2})+repmat(col0,size(colList,1),1),1),2);

% Match names.
[is,id]=ismember(indexName,colList(:,1));

% Use default color if not found.
id(~is)=1;

% Return colors for selected facilities.
colList=vertcat(colList{id,2});

