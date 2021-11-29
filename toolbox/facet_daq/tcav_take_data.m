%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tcav_take_data : function to perform phase scan and
%                  streak beam with TCAV.
%
% --> If no arguments are given, current phase and
%     amplitude settings from the control panel will
%     be used to set phase and amplitude.
%
% streak_amp : amplitude for streaking in MV
% zero_cross : zero crossing phase in deg.
%
% M.Litos - Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function tcav_take_data(streak_amp,zero_cross)

%% setup parameters

% get the streaking amp if not provided
% assuming current amp setpoint is correct
if nargin<1
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
if nargin<2
    zero_cross = lcaGetSmart('TCAV:LI20:2400:PDES');
end
%
% ...or if you really want direct control,
% set it here...
%
% zero_cross = -90; % deg.
%

%% perform phase scan
try
    tcav_phase_scan(zero_cross);
catch err
    tcav_onoff('off');
    tcav_phase(zero_phase);
    tcav_amp(streak_amp);
    error(['Could not complete phase scan. ' ...
           'Resetting TCAV phase and amplitude and turning TCAV off.']);
end

%% streak beam with TCAV
try
    tcav_streak(streak_amp,zero_cross);
catch err
    tcav_onoff('off');
    tcav_phase(zero_phase);
    tcav_amp(streak_amp);
    error(['Could not complete beam streaking. ' ...
           'Resetting TCAV phase and amplitude and turning TCAV off.']);
end

end%function