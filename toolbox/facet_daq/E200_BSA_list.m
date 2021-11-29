BSA_list = cell(0,2);

BSA_list(end+1,:) = {'PATT:SYS1:1:PULSEID'       , 'BSA PulseID PV'               };

BSA_list(end+1,:) = {'GADC0:LI20:EX01:AI:CH0:'   , 'TORO:LI20:2452 '              };
BSA_list(end+1,:) = {'GADC0:LI20:EX01:AI:CH2:'   , 'TORO:LI20:3163'               };
BSA_list(end+1,:) = {'GADC0:LI20:EX01:AI:CH3:'   , 'TORO:LI20:3255'               };
BSA_list(end+1,:) = {'GADC0:LI20:EX01:CALC:CH0:' , 'TORO:LI20:2452 (cal)'         };
BSA_list(end+1,:) = {'GADC0:LI20:EX01:CALC:CH2:' , 'TORO:LI20:3163 (cal)'         };
BSA_list(end+1,:) = {'GADC0:LI20:EX01:CALC:CH3:' , 'TORO:LI20:3255 (cal)'         };

BSA_list(end+1,:) = {'BPMS:LI20:2445:X'          , 'BPM 2445 X'                   };
BSA_list(end+1,:) = {'BPMS:LI20:2445:Y'          , 'BPM 2445 Y'                   };
BSA_list(end+1,:) = {'BPMS:LI20:2445:TMIT'       , 'BPM 2445 TMIT'                };
BSA_list(end+1,:) = {'BPMS:LI20:3156:X'          , 'BPM 3156 X'                   };
BSA_list(end+1,:) = {'BPMS:LI20:3156:Y'          , 'BPM 3156 Y'                   };
BSA_list(end+1,:) = {'BPMS:LI20:3156:TMIT'       , 'BPM 3156 TMIT'                };
BSA_list(end+1,:) = {'BPMS:LI20:3265:X'          , 'BPM 3265 X'                   };
BSA_list(end+1,:) = {'BPMS:LI20:3265:Y'          , 'BPM 3265 Y'                   };
BSA_list(end+1,:) = {'BPMS:LI20:3265:TMIT'       , 'BPM 3265 TMIT'                };
BSA_list(end+1,:) = {'BPMS:LI20:3315:X'          , 'BPM 3315 X'                   };
BSA_list(end+1,:) = {'BPMS:LI20:3315:Y'          , 'BPM 3315 Y'                   };
BSA_list(end+1,:) = {'BPMS:LI20:3315:TMIT'       , 'BPM 3315 TMIT'                };

BSA_list(end+1,:) = {'BLEN:LI20:3014:BRAW'       , 'BSA Pyro 2013'                };

BSA_list(end+1,:) = {'PMTR:LA20:10:PWR'          , 'Laser power'                  };

BSA_list(end+1,:) = {'IP330:LI20:EX01:CH00'      , 'Humidity in THz'              };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH01'      , 'E201 energy pyro'             };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH02'      , 'E201 ref pyro'                };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH03'      , 'E201 signal pyro'             };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH04'      , 'J16 Laser Diode'              };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH05'      , 'Humidity in tunnel'           };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH06'      , 'Monitor for THz +5V'          };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH07'      , 'EMPTY'                        };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH08'      , 'EMPTY'                        };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH09'      , 'E203 small lin pot'           };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH10'      , 'E203 test'                    };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH11'      , 'E203 front lin pot'           };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH12'      , 'E203 rotary pot'              };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH13'      , 'E203 lin pot battery'         };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH14'      , 'E203 grating position'        };
BSA_list(end+1,:) = {'IP330:LI20:EX01:CH15'      , 'E203 back lin pot'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH00'      , 'RF Power'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH01'      , 'Diode Power'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH02'      , 'Phase'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH03'      , 'Phase x30'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH04'      , 'PID Out'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH05'      , 'Piezo in'            };
%BSA_list(end+1,:) = {'ADC:LA20:10:CH06'      , 'LabMax Vout'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH07'      , 'Temperature 1'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH08'      , 'Humidity 1'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH09'      , 'SS Shutter feedback'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH10'      , 'EPS Shutter Open'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH11'      , 'EPICS Shutter Open'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH12'      , 'Temperature 2'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH13'      , 'Humidity 2'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH14'      , 'Spare'            };
BSA_list(end+1,:) = {'ADC:LA20:10:CH15'      , 'Spare'            };
BSA_list(end+1,:) = {'PMT:LI20:3350:QDCRAW'      , 'Radiation monitor 1'          };
BSA_list(end+1,:) = {'PMT:LI20:3360:QDCRAW'      , 'Radiation monitor 2'          };
