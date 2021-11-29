%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tcav_streak : function to streak beam with TCAV
%
% streak_amp : amplitude for streaking in MV
% zero_cross : zero crossing phase in deg.
%
% M.Litos - Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function tcav_streak(streak_amp,zero_cross,n_shot)

%% enable TCAV trigger
tcav_onoff('on');

%% setup parameters

% get the streaking amp if not provided
% assuming current amp setpoint is correct
if nargin<1 || strcmpi(streak_amp,'auto')
    streak_amp = lcaGetSmart('TCAV:LI20:2400:ADES');
end
%
% ...or if you really want direct control,
% set it here...
%
% streak_amp = 30; % MV
%

% get the zero crossing if not provided
% assuming current phase setpoint is correct
if nargin<2 || strcmpi(zero_cross,'auto')
    zero_cross = lcaGetSmart('TCAV:LI20:2400:PDES');
end
%
% ...or if you really want direct control,
% set it here...
%
% zero_cross = -90; % deg.
%

% number of shots per amplitude
if nargin<4
    n_shot = 50;
end

% set parameters
par = E200_Param();
par.camera_config = 15;
par.save_facet    = 0;
par.save_E200     = 1;
par.save_back     = 1;
par.aida_daq      = 0;
par.n_shot        = n_shot;

%% streak at zero crossing

% set comment
par.comt_str = ['Taking data with TCAV streaking at amplitude ' num2str(streak_amp) ...
                ' and phase ' num2str(zero_cross)];

% set TCAV phase and amplitude
tcav_phase(zero_cross);
tcav_amp(streak_amp);

% run E200 DAQ
try
    E200_DAQ_2013(par);
catch err
    tcav_onoff('off');
    tcav_amp(streak_amp);
    error(['Could not complete streaking scan. ' ...
           'Resetting TCAV amplitude and turning TCAV off.']);
end

%% streak at zero crossing + 180 deg.

% flip the phase
tcav_phase(zero_cross+180);

% set comment
par.comt_str = ['Taking data with TCAV streaking at amplitude ' num2str(streak_amp) ...
                ' and phase ' num2str(zero_cross+180)];

% run E200 DAQ
try
    E200_DAQ_2013(par);
catch err
    tcav_onoff('off');
    tcav_amp(streak_amp);
    error(['Could not complete streaking scan. ' ...
           'Resetting TCAV amplitude and turning TCAV off.']);
end

%% take data with TCAV off

% reset the phase and turn TCAV trigger off
tcav_phase(zero_cross);

% disable TCAV trigger
tcav_onoff('off');

% set parameters
par.save_facet    =  1;

% set comment
par.comt_str = 'Taking data with TCAV off';

% run E200 DAQ
try
    E200_DAQ_2013(par);
catch err
    tcav_onoff('off');
    tcav_amp(streak_amp);
    error(['Could not complete streaking scan. ' ...
           'Resetting TCAV amplitude and turning TCAV off.']);
end

end%function