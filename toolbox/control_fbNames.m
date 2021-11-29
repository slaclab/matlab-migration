function fdbkList = control_fbNames(name)

if nargin < 1, name='';end

fancyPV='ACCL:LI22:1:FANCY_PH_CTRL';

listDL2={ ...
    'DUMP:LTUH:970:PNEUMATIC'; ... % TDUND (0=Insert,1=Retract)
    fancyPV; ...                  % Joe's 6x6 feedback
    'FBCK:FB04:LG01:STATE'; ...   % EPICS 6x6 feedback
    'FBCK:LNG9:1:ENABLE'; ...     % DL2 EPICS energy feedback
    'FBCK:LNG8:1:ENABLE'; ...     % DL2 EPICS energy feedback
    'FBCK:FB03:TR04:MODE'; ...    % EPICS Undulator launch feedback
    'FBCK:UND0:1:ENABLE'; ...     % Matlab Undulator launch feedback
    'FBCK:FB03:TR01:MODE'; ...    % EPICS LTU launch feedback
    'FBCK:FB02:TR03:STATE'; ...   % Slow LTU1 launch feedback
    'FBCK:FB02:TR04:STATE'; ...   % Slow LTU2 launch feedback
    'FBCK:LTL0:1:ENABLE'; ...     % Matlab LTU launch feedback
    'FBCK:FB01:TR05:MODE'; ...    % EPICS BSY X launch feedback
    'FBCK:FB05:TR01:MODE';        % EPICS BSY Y launch feedback
%    'FBCK:BSY0:1:ENABLE'; ...     % Matlab BSY launch feedback, Removed 31-May-2017
    'FBCK:FB02:TR02:MODE'; ...    % EPICS LI28 launch feedback
    'FBCK:L280:1:ENABLE'; ...     % Matlab LI28 launch feedback
};

list0={ ...
    'IOC:BSY0:MP01:BYKIKCTL'; ... % MPS BYKIK disable during scan (0=KICK,1=PASS)
    fancyPV; ...                  % Joe's 6x6 feedback
    'FBCK:FB04:LG01:STATE'; ...   % New 6x6 feedback
};

listL3=[list0;{ ...
    'FBCK:LNG9:1:ENABLE'; ...     % DL2 EPICS energy feedback
    'FBCK:LNG8:1:ENABLE'; ...     % DL2 EPICS energy feedback
}];

listL2=[listL3;{ ...
    'FBCK:FB02:TR02:MODE'; ...    % EPICS LI28 launch feedback
    'FBCK:L280:1:ENABLE'; ...     % Matlab LI28 launch feedback
    'FBCK:FB02:TR01:MODE'; ...    % EPICS L3 launch feedback
    'FBCK:L3L0:1:ENABLE'; ...     % Matlab L3 launch feedback
    'FBCK:LNG7:1:ENABLE'; ...     % BC2 EPICS energy feedback
    'FBCK:LNG6:1:ENABLE'; ...     % BC2 EPICS energy feedback
    'FBCK:LNG5:1:ENABLE'; ...     % BC2 EPICS energy feedback
    'FBCK:LNG4:1:ENABLE'; ...     % BC2 EPICS energy feedback
}];

listL1=[listL2;{ ...
    'FBCK:FB01:TR04:MODE'; ...    % EPICS L2 launch feedback
    'FBCK:L2L0:1:ENABLE'; ...     % Matlab L2 launch feedback
    'FBCK:LNG3:1:ENABLE'; ...     % longitudinal feedback in the injector
    'FBCK:LNG2:1:ENABLE'; ...     % longitudinal feedback in the injector
}];

listL0=[listL1;{ ...
    'FBCK:LNG1:1:ENABLE'; ...     % longitudinal feedback in the injector
    'FBCK:LNG0:1:ENABLE'; ...     % longitudinal feedback in the injector
    %'FBCK:FB01:TR02:MODE'; ...    % EPICS injector/SAB launch feedback "Permanently" removed Nov 14, 2018
    % This is a toughie. Could tell this to do the 3-way injector feedback
    % on each feedback. For now, will have it use fanout to keep them in
    % sync with each other.
    %'FBCK:IN20:TR01:MODE'; ...    % EPICS Injector 3-way 1-1 feedback fanout PV
    'FBCK:FB02:TR05:MODE'; ...    % EPICS Injector Launch 1
    'FBCK:FB04:TR04:MODE'; ...    % EPICS Injector Launch 2
    'FBCK:FB03:TR03:MODE'; ...    % EPICS Injector Launch 2
    'FBCK:INL1:1:ENABLE'; ...     % Matlab injector launch feedback
    'FBCK:INL0:1:ENABLE'; ...     % Matlab SAB launch feedback
}];

listL0A=[listL0;{ ...
    'FBCK:FB01:TR01:MODE'; ...    % EPICS gun launch feedback
    'FBCK:B5L0:1:ENABLE'; ...     % Matlab gun launch feedback
}];

listLSR={ ...
    'FBCK:FB01:TR01:MODE'; ...    % EPICS gun launch feedback
    'FBCK:B5L0:1:ENABLE'; ...     % Matlab gun launch feedback
%    'FBCK:FB02:GN01:MODE'; ...    % EPICS charge feedback in the injector
    'FBCK:BCI0:1:ENABLE'; ...     % Matlab charge feedback in the injector
};

listMisc={ ...
    'FBCK:FB01:TR03:MODE'; ...    % EPICS L1X position
    'FBCK:B1L0:1:ENABLE'; ...     % Matlab L1X position
    'FBCK:FB01:TR05:MODE'; ...    % EPICS BSY X launch feedback
    'FBCK:FB05:TR01:MODE';        % EPICS BSY Y launch feedback
%    'FBCK:BSY0:1:ENABLE'; ...     % Matlab BSY launch feedback, removed
%    'FBCK:DL20:1:ENABLE'; ...     % Matlab DL2A launch feedback, obsolete
%    'FBCK:LTU0:1:ENABLE'; ...     % Matlab DL2B launch feedback, obsolete
    'FBCK:FB03:TR01:MODE'; ...    % EPICS LTU launch feedback
    'FBCK:FB02:TR03:STATE'; ...   % Slow LTU1 launch feedback
    'FBCK:FB02:TR04:STATE'; ...   % Slow LTU2 launch feedback
    'FBCK:LTL0:1:ENABLE'; ...     % Matlab LTU launch feedback
    'FBCK:FB03:TR04:MODE'; ...    % EPICS Undulator launch feedback
    'FBCK:UND0:1:ENABLE'; ...     % Matlab Undulator launch feedback
    'SIOC:SYS0:ML00:AO290'; ...   % Joe's DL1 energy feedback
    'SIOC:SYS0:ML00:AO292'; ...   % Joe's BC1 energy feedback
    'SIOC:SYS0:ML00:AO293'; ...   % Joe's BC1 bunch length feedback
    'SIOC:SYS0:ML00:AO294'; ...   % Joe's BC2 energy feedback
    'SIOC:SYS0:ML00:AO295'; ...   % Joe's BC2 peak current feedback
    'SIOC:SYS0:ML00:AO296'; ...   % Joe's LTU/BSY energy feedback
};

listCLTS={ ...
    'FBCK:FB04:TR01:MODE'; ... % LTUS Launch
    'FBCK:FB04:TR02:MODE'; ... % UNDS Launch
    };

listAll=setdiff(unique([listL0A;listLSR;listMisc; listCLTS]),list0(1));

listFake={ ...
    'SIOC:SYS0:ML06:AO666'; ...   % Fake feedback for dev
};

switch name(:,1:min(end,3))
    case 'LAS'
        fdbkList=listLSR;
    case 'L0A'
        fdbkList=listL0A;
    case {'L0B' 'TCA'}
        fdbkList=listL0;
    case {'L1S' 'L1X'}
        fdbkList=listL1;
    case {'L2' '21-' '22-' '23-' '24-'}
        fdbkList=listL2;
    case {'L3' '25-' '26-' '27-' '28-' '29-' '30-'}
        fdbkList=listL3;
    case 'DL2'
        fdbkList=listDL2;
    case ''
        fdbkList=listAll;
    case {'CLT' 'LTU'} % CLTS and LTUS
        fdbkList=listCLTS;    
    otherwise
        fdbkList=listFake;
end
