%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tcav_phase_scan : function to perform a phase scan
%                   with TCAV in order to measure
%                   kick strength
%
% zero_cross : zero crossing phase in deg.
%
% M.Litos - Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function tcav_phase_scan(zero_cross,n_step,n_shot,min_phase,max_phase)

%% enable TCAV trigger
tcav_onoff('on');

%% setup parameters

% get the zero crossing if not provided
% assuming current phase setpoint is correct
if nargin<1 || strcmpi(zero_cross,'auto')
    zero_cross = lcaGetSmart('TCAV:LI20:2400:PDES');
end
%
% ...or if you really want direct control,
% set it here...
%
% zero_cross = -90;
%

% number of phase steps
if nargin<2
    n_step = 7;
end

% number of shots per step
if nargin<3
    n_shot = 20;
end

% min phase for scan
if nargin<4
    min_phase = zero_cross-4; % deg.
end

% max phase for scan
if nargin<5
    max_phase = zero_cross+4; % deg.
end

% set parameters
par = E200_Param();
par.camera_config = 15;
par.save_facet    = 1;
par.save_E200     = 1;
par.save_back     = 1;
par.aida_daq      = 0;
par.n_shot        = n_shot;

%% run E200_gen_scan at given zero crossing
try
    E200_gen_scan(@tcav_phase,min_phase,max_phase,n_step,par);
catch err
    tcav_onoff('off');
    tcav_phase(zero_phase);
    error(['Could not complete phase scan. ' ...
           'Resetting TCAV phase and turning TCAV off.']);
end

%% run E200_gen_scan at opposite zero crossing
try
    E200_gen_scan(@tcav_phase,min_phase+180,max_phase+180,n_step,par);
catch err
    tcav_onoff('off');
    tcav_phase(zero_phase);
    error(['Could not complete phase scan. ' ...
           'Resetting TCAV phase and turning TCAV off.']);
end

%% reset phase to zero crossing
tcav_phase(zero_cross);

%% disable TCAV trigger
tcav_onoff('off');

end%function