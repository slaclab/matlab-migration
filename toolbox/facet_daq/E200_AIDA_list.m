% AIDA Variables
AIDA_list = cell(0,1);

% Toroids return TMIT
AIDA_list{end+1,1} = 'TORO:DR13:40';               % RTL Toroid, input charge to linac [times 1E10]
AIDA_list{end+1,1} = 'TORO:LI20:2040';             % S20 Toroid [times 1E10]
AIDA_list{end+1,1} = 'TORO:LI20:2452';             % S20 Toroid [times 1E10]
AIDA_list{end+1,1} = 'TORO:LI20:3163';             % S20 Toroid [times 1E10]
AIDA_list{end+1,1} = 'TORO:LI20:3255';             % S20 Toroid [times 1E10]

% BPMs retrun X, Y, and TMIT
AIDA_list{end+1,1} = 'BPMS:LI10:3448';             % S10 dispersive BPM, eta = 44.31 cm [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI18:801';              % S18 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI18:901';              % S18 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI19:201';              % S19 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI19:301';              % S19 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI19:401';              % S19 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI19:501';              % S19 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI19:601';              % S19 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI19:701';              % S19 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI19:801';              % S19 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI19:901';              % S19 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2050';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2147';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2160';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2223';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2235';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2245';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2261';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2278';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2340';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2360';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:2445';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:3013';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:3036';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:3101';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:3120';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:3156';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:3265';             % S20 BPM [mm, mm, times 1E10]
AIDA_list{end+1,1} = 'BPMS:LI20:3315';             % S20 BPM [mm, mm, times 1E10

% GAPM returns pyro value
%AIDA_list{end+1,1} = 'GAPM:LI18:930';              % S18 Bunch length monitor

% Subboosters return phase
%AIDA_list{end+1,1} = 'SBST:LI02:1';                % S02 Subbooster [absolute degs]

% Klystrons return phase
AIDA_list{end+1,1} = 'KLYS:DR13:1';                % DR13 Klystron [absolute degs]
AIDA_list{end+1,1} = 'KLYS:LI02:91';                % DR13 Klystron [absolute degs]