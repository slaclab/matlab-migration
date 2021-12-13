function root_names = getBSAnames(arg)
% lists BSA root names in alphabetical order

% Optional arg:
%   arg.aida  - Use Aida even if LCLS
%   arg.epics - Remove SLC Names (may be obsolete)
%   arg.sortz - iff LCLS Sort BSA Names on "Z" position

[ system, accelerator ] = getSystem;

if ~isequal(accelerator,'LCLS') || ((nargin > 0) && isfield(arg,'aida'))
    v = pvaGet([ accelerator ':BSA.rootnames' ]);
    remove_slc = 0;
    if nargin == 1
        if isfield(arg,'epics')
            remove_slc = 1;
        end
    end
    root_names = v.get('name');
    if remove_slc
        pared_root_names = cell(0);
        for i = 1 : length(root_names)
            root = char(root_names(i));
            add_to_list = 1;
            if isequal('L',root(1:1))
                if isequal('I',root(2:2))
                    add_to_list = 0;
                end
            end
            if add_to_list
                pared_root_names{end+1} = root_names(i);
            end
        end
        root_names = pared_root_names;
    end

else
    % Get list from meme
    if ((nargin > 0) && isfield(arg,'sortz'))
        root_names = char(meme_names('s','ds','sort','z','tag','LCLS.BSA.rootnames'));
    else
        root_names = char(meme_names('s','ds','tag','LCLS.BSA.rootnames'));
    end
end
