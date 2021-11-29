function [geom, pvs] = sext_init() 
% [GEOM, PVS] = SEXT_INIT() supplies structs of geometric constants and
% PV names needed for control of the FACET sextupole movers.
%
% Output arguments:
%   GEOM:   Struct containing geometric constants of the entire
%       mover-magnet system.  See Figures 1 and 7 of SLAC-PUB-95-6132 for
%       definitions of each child.  All units are in millimeters.  Rows
%       correspond to mover 2145, 2165, 2335, and 2365 respectively, and 
%       columns cam1, cam2, cam3 or LVDT1, LVDT2, LVDT3 respectively.
%   PVS:    Struct containing PV names for motor drive commands,
%       readbacks, LVDT and rotary pot readbacks, and offset values.
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC


%% Geometry definitions
% rows are mover 1 and mover 2
% columns are cam 1 2 3 or lvdt 1 2 3

% cam radius, design is 31 mm
geom.R = [  31,     31,     31;
            31,     31,     31;
            31,     31,     31;
            31,     31,     31;         
                ];

% cam lift (eccentricity), design is 1/16"
geom.L = [  1.5875, 1.5875, 1.5875;
            1.5875, 1.5875, 1.5875;
            1.5875, 1.5875, 1.5875;
            1.5875, 1.5875, 1.5875;
                ];   

% S1 is half the distance between cam2 and cam3 axes
geom.S1 = [ 34.925;
            34.925;
            34.925;
            34.925;
                ];

% S2 is distance from cam1 axis to midpoint of cam2 and cam3 axes            
geom.S2 = [ 290.5;
            290.5;
            290.5;
            290.5;
                ];

% mover geom (see drawing ID-258-408-00) per M. Kosovsky 3/1/2012

% vertical offset magnet bore to cam axis
geom.c = [  282.0416;
            282.0416;
            282.0416;
            282.0416;
                ];

% vertical offset magnet bore to v block
geom.b = geom.c + geom.S1 - sqrt(2)*mean(geom.R, 2);

% horizontal offset magnet bore to cam2-cam3 midpoint
geom.a = [  139.6238;
            139.6238;
            139.6238;
            139.6238;
                ];
            
% LVDT offsets  per M. Kosovsky 3/5/2012

% labeled "d1/2" in Bowden, x-offsets from magnet center for LVDT 1 and 2
geom.dx = [ 74.55, 89.54;
            74.55, 89.54;
            74.55, 89.54;
            74.55, 89.54;
                ];

% labeled "d2" in Bowden, y-offsets from magnet center for LVDT 3
geom.dy = [ 245.47;
            245.47;
            245.47;
            245.47;
                ];
            

%% PV list

% motor setpoint PVs
pvs.motr = {        'SEXT:LI20:2145:1:MOTR',    'SEXT:LI20:2145:2:MOTR',    'SEXT:LI20:2145:3:MOTR';
                    'SEXT:LI20:2165:1:MOTR',    'SEXT:LI20:2165:2:MOTR',    'SEXT:LI20:2165:3:MOTR';
                    'SEXT:LI20:2335:1:MOTR',    'SEXT:LI20:2335:2:MOTR',    'SEXT:LI20:2335:3:MOTR';
                    'SEXT:LI20:2365:1:MOTR',    'SEXT:LI20:2365:2:MOTR',    'SEXT:LI20:2365:3:MOTR'
                    };
                
% motor readback PVs
pvs.motrrbv = {     'SEXT:LI20:2145:1:MOTR.RBV','SEXT:LI20:2145:2:MOTR.RBV','SEXT:LI20:2145:3:MOTR.RBV';
                    'SEXT:LI20:2165:1:MOTR.RBV','SEXT:LI20:2165:2:MOTR.RBV','SEXT:LI20:2165:3:MOTR.RBV';
                    'SEXT:LI20:2335:1:MOTR.RBV','SEXT:LI20:2335:2:MOTR.RBV','SEXT:LI20:2335:3:MOTR.RBV';
                    'SEXT:LI20:2365:1:MOTR.RBV','SEXT:LI20:2365:2:MOTR.RBV','SEXT:LI20:2365:3:MOTR.RBV';
                    };

% motor offset PVs
pvs.motroffs = {    'SEXT:LI20:2145:1:MOTR.OFF','SEXT:LI20:2145:2:MOTR.OFF','SEXT:LI20:2145:3:MOTR.OFF';
                    'SEXT:LI20:2165:1:MOTR.OFF','SEXT:LI20:2165:2:MOTR.OFF','SEXT:LI20:2165:3:MOTR.OFF';
                    'SEXT:LI20:2335:1:MOTR.OFF','SEXT:LI20:2335:2:MOTR.OFF','SEXT:LI20:2335:3:MOTR.OFF';
                    'SEXT:LI20:2365:1:MOTR.OFF','SEXT:LI20:2365:2:MOTR.OFF','SEXT:LI20:2365:3:MOTR.OFF';
                    };              
                
% LVDT readback PVs
pvs.lvdtraw = {     'SEXT:LI20:2145:1:LVRAW',   'SEXT:LI20:2145:2:LVRAW',   'SEXT:LI20:2145:3:LVRAW';
                    'SEXT:LI20:2165:1:LVRAW',   'SEXT:LI20:2165:2:LVRAW',   'SEXT:LI20:2165:3:LVRAW';
                    'SEXT:LI20:2335:1:LVRAW',   'SEXT:LI20:2335:2:LVRAW',   'SEXT:LI20:2335:3:LVRAW';
                    'SEXT:LI20:2365:1:LVRAW',   'SEXT:LI20:2365:2:LVRAW',   'SEXT:LI20:2365:3:LVRAW';
                    };

pvs.lvdtpos = {     'SEXT:LI20:2145:1:LVPOS',   'SEXT:LI20:2145:2:LVPOS',   'SEXT:LI20:2145:3:LVPOS';
                    'SEXT:LI20:2165:1:LVPOS',   'SEXT:LI20:2165:2:LVPOS',   'SEXT:LI20:2165:3:LVPOS';
                    'SEXT:LI20:2335:1:LVPOS',   'SEXT:LI20:2335:2:LVPOS',   'SEXT:LI20:2335:3:LVPOS';
                    'SEXT:LI20:2365:1:LVPOS',   'SEXT:LI20:2365:2:LVPOS',   'SEXT:LI20:2365:3:LVPOS';
                    };

% rotary pot readbacks
pvs.potraw = {      'SEXT:LI20:2145:1:POTRAW',  'SEXT:LI20:2145:2:POTRAW',  'SEXT:LI20:2145:3:POTRAW';
                    'SEXT:LI20:2165:1:POTRAW',  'SEXT:LI20:2165:2:POTRAW',  'SEXT:LI20:2165:3:POTRAW';
                    'SEXT:LI20:2335:1:POTRAW',  'SEXT:LI20:2335:2:POTRAW',  'SEXT:LI20:2335:3:POTRAW';
                    'SEXT:LI20:2365:1:POTRAW',  'SEXT:LI20:2365:2:POTRAW',  'SEXT:LI20:2365:3:POTRAW';
                    };
                
pvs.potpos = {      'SEXT:LI20:2145:1:POTPOS',  'SEXT:LI20:2145:2:POTPOS',  'SEXT:LI20:2145:3:POTPOS'
                    'SEXT:LI20:2165:1:POTPOS',  'SEXT:LI20:2165:2:POTPOS',  'SEXT:LI20:2165:3:POTPOS';
                    'SEXT:LI20:2335:1:POTPOS',  'SEXT:LI20:2335:2:POTPOS',  'SEXT:LI20:2335:3:POTPOS';
                    'SEXT:LI20:2365:1:POTPOS',  'SEXT:LI20:2365:2:POTPOS',  'SEXT:LI20:2365:3:POTPOS'
                    };
                    
pvs.gold = [        script_setupPV('SIOC:SYS1:ML00:AO554', 'SEXT 2145 X gold',    'mm',   4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO559', 'SEXT 2145 Y gold',    'mm',   4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO564', 'SEXT 2145 Roll gold', 'mrad', 3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO504', 'SEXT 2165 X gold',    'mm',   4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO509', 'SEXT 2165 Y gold',    'mm',   4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO514', 'SEXT 2165 Roll gold', 'mrad', 3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO519', 'SEXT 2335 X gold',    'mm',   4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO524', 'SEXT 2335 Y gold',    'mm',   4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO529', 'SEXT 2335 Roll gold', 'mrad', 3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO569', 'SEXT 2365 X gold',    'mm',   4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO574', 'SEXT 2365 Y gold',    'mm',   4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO579', 'SEXT 2365 Roll gold', 'mrad', 3, 'sext_gui.m'); ...
                    ];                
                
pvs.setpoint = [    script_setupPV('SIOC:SYS1:ML00:AO551', 'SEXT 2145 X setpoint',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO556', 'SEXT 2145 Y setpoint',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO561', 'SEXT 2145 Roll setpoint', 'mrad',   3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO501', 'SEXT 2165 X setpoint',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO506', 'SEXT 2165 Y setpoint',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO511', 'SEXT 2165 Roll setpoint', 'mrad',   3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO516', 'SEXT 2335 X setpoint',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO521', 'SEXT 2335 Y setpoint',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO526', 'SEXT 2335 Roll setpoint', 'mrad',   3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO566', 'SEXT 2365 X setpoint',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO571', 'SEXT 2365 Y setpoint',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO576', 'SEXT 2365 Roll setpoint', 'mrad',   3, 'sext_gui.m'); ...
                    ];


pvs.valid = [       script_setupPV('SIOC:SYS1:ML00:AO531', 'SEXT 2145 setpoint OK',   'bool', 0, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO532', 'SEXT 2165 setpoint OK',   'bool', 0, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO533', 'SEXT 2335 setpoint OK',   'bool', 0, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO534', 'SEXT 2365 setpoint OK',   'bool', 0, 'sext_gui.m'); ...
                    ];
                
pvs.output.lvdt = [ script_setupPV('SIOC:SYS1:ML00:AO552', 'SEXT 2145 X LVDT val',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO557', 'SEXT 2145 Y LVDT val',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO562', 'SEXT 2145 Roll LVDT val', 'mrad',   3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO502', 'SEXT 2165 X LVDT val',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO507', 'SEXT 2165 Y LVDT val',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO512', 'SEXT 2165 Roll LVDT val', 'mrad',   3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO517', 'SEXT 2335 X LVDT val',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO522', 'SEXT 2335 Y LVDT val',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO527', 'SEXT 2335 Roll LVDT val', 'mrad',   3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO567', 'SEXT 2365 X LVDT val',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO572', 'SEXT 2365 Y LVDT val',    'mm',     4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO577', 'SEXT 2365 Roll LVDT val', 'mrad',   3, 'sext_gui.m'); ...
                    ];
                
pvs.output.pots = [ script_setupPV('SIOC:SYS1:ML00:AO553', 'SEXT 2145 X pot val',    'mm', 4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO558', 'SEXT 2145 Y pot val',    'mm', 4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO563', 'SEXT 2145 Roll pot val', 'mrad', 3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO503', 'SEXT 2165 X pot val',    'mm', 4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO508', 'SEXT 2165 Y pot val',    'mm', 4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO513', 'SEXT 2165 Roll pot val', 'mrad', 3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO518', 'SEXT 2335 X pot val',    'mm', 4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO523', 'SEXT 2335 Y pot val',    'mm', 4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO528', 'SEXT 2335 Roll pot val', 'mrad', 3, 'sext_gui.m'); ...
                    script_setupPV('SIOC:SYS1:ML00:AO568', 'SEXT 2365 X pot val',    'mm', 4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO573', 'SEXT 2365 Y pot val',    'mm', 4, 'sext_gui.m'), ...
                    script_setupPV('SIOC:SYS1:ML00:AO578', 'SEXT 2365 Roll pot val', 'mrad', 3, 'sext_gui.m'); ...
                    ];
                
% sextupole bpms
pvs.bpms = {        'BPMS:LI20:2147:X57',       'BPMS:LI20:2147:Y57',   'BPMS:LI20:2147:TMIT57';
                    'BPMS:LI20:2160:X57',       'BPMS:LI20:2160:Y57',   'BPMS:LI20:2160:TMIT57';
                    'BPMS:LI20:2340:X57',       'BPMS:LI20:2340:Y57',   'BPMS:LI20:2340:TMIT57';
                    'BPMS:LI20:2360:X57',       'BPMS:LI20:2360:Y57',   'BPMS:LI20:2360:TMIT57';
                    };

end