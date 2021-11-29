%-------------------------------------------------------------------------%
% Non BSA EPICS PVs
nonBSA_list = cell(0,3);

% Stores lca name and comment in the same entry
nonBSA_list(end+1,:) = {'PATT:SYS1:1:PULSEIDBR'                 ,  'Non BSA PulseID PV'                                ,  'PATT:SYS1:1:PULSEIDBR'                } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO007'                  ,  'Non BSA Pyro'                                      ,  'SIOC:SYS1:ML00:AO007'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO028'                  ,  'Non BSA Pyro updating with spyro.m at 1 Hz'        ,  'SIOC:SYS1:ML00:AO028'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO019'                  ,  'Non BSA S02 Gap monitor'                           ,  'SIOC:SYS1:ML00:AO019'                 } ;

nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO011'                  ,  'LI02-LI10 e_gain [MeV]'                            ,  'SIOC:SYS1:ML00:AO011'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO012'                  ,  'LI02-LI10 chirp [MeV]'                             ,  'SIOC:SYS1:ML00:AO012'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO013'                  ,  'LI02-LI10 eff. phase [deg]'                        ,  'SIOC:SYS1:ML00:AO013'                 } ;

nonBSA_list(end+1,:) = {'DR12:PHAS:61:VDES'                     ,  'Phase ramp set [deg]'                              ,  'DR12:PHAS:61:VDES'                    } ;
nonBSA_list(end+1,:) = {'DR12:PHAS:61:VACT'                     ,  'Phase ramp read back [deg]'                        ,  'DR12:PHAS:61:VACT'                    } ;
nonBSA_list(end+1,:) = {'DR13:AMPL:11:VDES'                     ,  'Compressor amplitude set [deg]'                    ,  'DR13:AMPL:11:VDES'                    } ;
nonBSA_list(end+1,:) = {'DR13:AMPL:11:VACT'                     ,  'Compressor amplitude read back [deg]'              ,  'DR13:AMPL:11:VACT'                    } ;
nonBSA_list(end+1,:) = {'DR13:TORO:40:DATA'                     ,  'NRTL Charge'                                       ,  'DR13:TORO:40:DATA'                    } ;
nonBSA_list(end+1,:) = {'DR13:KLYS:1:PDES'                      ,  'NRTL Phase Setting'                                ,  'DR13:KLYS:1:PDES'                     } ;
nonBSA_list(end+1,:) = {'DR13:KLYS:1:PHAS'                      ,  'NRTL Phase Setting'                                ,  'DR13:KLYS:1:PHAS'                     } ;

nonBSA_list(end+1,:) = {'LI20:LGPS:2060:BDES'                   ,  'Q1ER [kG]'                                         ,  'LI20:LGPS:2060:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:2441:BDES'                   ,  'Q1ER-BOOST [kG]'                                   ,  'LI20:LGPS:2441:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:3011:BDES'                   ,  'QFF 1 [kG]'                                        ,  'LI20:LGPS:3011:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:QUAD:3015:BDES'                   ,  'QS2 (Skew Quad) [kG]'                              ,  'LI20:QUAD:3015:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:3031:BDES'                   ,  'QFF 2 [kG]'                                        ,  'LI20:LGPS:3031:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:3091:BDES'                   ,  'QFF 4 [kG]'                                        ,  'LI20:LGPS:3091:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:3141:BDES'                   ,  'QFF 5 [kG]'                                        ,  'LI20:LGPS:3141:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:3151:BDES'                   ,  'QFF 6 [kG]'                                        ,  'LI20:LGPS:3151:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:3204:BDES'                   ,  'QS 0  [kG]'                                        ,  'LI20:LGPS:3204:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:3261:BDES'                   ,  'QS 1  [kG]'                                        ,  'LI20:LGPS:3261:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:3311:BDES'                   ,  'QS 2  [kG]'                                        ,  'LI20:LGPS:3311:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:3330:BDES'                   ,  'Spectrometer dipole magnet [kG m]'                 ,  'LI20:LGPS:3330:BDES'                  } ;

nonBSA_list(end+1,:) = {'TCAV:LI20:2400:Q_ADJUST'               ,  'TCAV desired Q'                                    ,  'TCAV:LI20:2400:Q_ADJUST'              } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:I_ADJUST'               ,  'TCAV desired I'                                    ,  'TCAV:LI20:2400:I_ADJUST'              } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML02:AO002'                  ,  ' <-deprecated-> TCAV phase [deg]'                  ,  'SIOC:SYS1:ML02:AO002'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML02:AO003'                  ,  ' <-deprecated-> TCAV amplitude [a.u.]'             ,  'SIOC:SYS1:ML02:AO003'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML02:AO004'                  ,  ' <-deprecated-> TCAV calculated power [MW]'        ,  'SIOC:SYS1:ML02:AO004'                 } ;

nonBSA_list(end+1,:) = {'TCAV:LI20:2400:PDES'                   ,  'TCAV desired phase [deg]'                          ,  'TCAV:LI20:2400:PDES'                  } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:ADES'                   ,  'TCAV desired kick amp [MV]'                        ,  'TCAV:LI20:2400:ADES'                  } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:S_PV'                   ,  'TCAV "slow" avg. phase [deg]'                      ,  'TCAV:LI20:2400:S_PV'                  } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:S_AV'                   ,  'TCAV "slow" avg. kick amp [MV]'                    ,  'TCAV:LI20:2400:S_AV'                  } ;

nonBSA_list(end+1,:) = {'TCAV:LI20:2400:0:S_PACTUAL'            ,  'TCAV PAD: XTCAV In - Phase [deg]'                  ,  'TCAV:LI20:2400:0:S_PACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:0:S_AACTUAL'            ,  'TCAV PAD: XTCAV In - Voltage [MV]'                 ,  'TCAV:LI20:2400:0:S_AACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:0:S_WACTUAL'            ,  'TCAV PAD: XTCAV In - Power[MW]'                    ,  'TCAV:LI20:2400:0:S_WACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:1:S_PACTUAL'            ,  'TCAV PAD: XTCAV Out - Phase [deg]'                 ,  'TCAV:LI20:2400:1:S_PACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:1:S_AACTUAL'            ,  'TCAV PAD: XTCAV Out - Voltage [MV]'                ,  'TCAV:LI20:2400:1:S_AACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:1:S_WACTUAL'            ,  'TCAV PAD: XTCAV Out - Power[MW]'                   ,  'TCAV:LI20:2400:1:S_WACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:2:S_PACTUAL'            ,  'TCAV PAD: Waveguide Ref - Phase [deg]'             ,  'TCAV:LI20:2400:2:S_PACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:2:S_AACTUAL'            ,  'TCAV PAD: Waveguide Ref - Voltage [MV]'            ,  'TCAV:LI20:2400:2:S_AACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:2:S_WACTUAL'            ,  'TCAV PAD: Waveguide Ref - Power[MW]'               ,  'TCAV:LI20:2400:2:S_WACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:3:S_PACTUAL'            ,  'TCAV PAD: X-Band Ref - Phase [deg]'                ,  'TCAV:LI20:2400:3:S_PACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:3:S_AACTUAL'            ,  'TCAV PAD: X-Band Ref - Voltage [MV]'               ,  'TCAV:LI20:2400:3:S_AACTUAL'           } ;
nonBSA_list(end+1,:) = {'TCAV:LI20:2400:3:S_WACTUAL'            ,  'TCAV PAD: X-Band Ref - Power[MW]'                  ,  'TCAV:LI20:2400:3:S_WACTUAL'           } ;
nonBSA_list(end+1,:) = {'KLYS:LI20:K4:0:S_PACTUAL'              ,  'KLY PAD: PAC Out - Phase [deg]'                    ,  'KLYS:LI20:K4:0:S_PACTUAL'             } ;
nonBSA_list(end+1,:) = {'KLYS:LI20:K4:0:S_AACTUAL'              ,  'KLY PAD: PAC Out - Voltage [MV]'                   ,  'KLYS:LI20:K4:0:S_AACTUAL'             } ;
nonBSA_list(end+1,:) = {'KLYS:LI20:K4:0:S_WACTUAL'              ,  'KLY PAD: PAC Out - Power [MW]'                     ,  'KLYS:LI20:K4:0:S_WACTUAL'             } ;
nonBSA_list(end+1,:) = {'KLYS:LI20:K4:1:S_PACTUAL'              ,  'KLY PAD: Kly Drive - Phase [deg]'                  ,  'KLYS:LI20:K4:1:S_PACTUAL'             } ;
nonBSA_list(end+1,:) = {'KLYS:LI20:K4:1:S_AACTUAL'              ,  'KLY PAD: Kly Drive - Voltage [MV]'                 ,  'KLYS:LI20:K4:1:S_AACTUAL'             } ;
nonBSA_list(end+1,:) = {'KLYS:LI20:K4:1:S_WACTUAL'              ,  'KLY PAD: Kly Drive - Power [MW]'                   ,  'KLYS:LI20:K4:1:S_WACTUAL'             } ;
nonBSA_list(end+1,:) = {'KLYS:LI20:K4:2:S_SACTUAL'              ,  'KLY PAD: Kly Beam V - Voltage[MV]'                 ,  'KLYS:LI20:K4:2:S_SACTUAL'             } ;
nonBSA_list(end+1,:) = {'KLYS:LI20:K4:3:S_PACTUAL'              ,  'KLY PAD: Kly Fwd - Phase [deg]'                    ,  'KLYS:LI20:K4:3:S_PACTUAL'             } ;
nonBSA_list(end+1,:) = {'KLYS:LI20:K4:3:S_AACTUAL'              ,  'KLY PAD: Kly Fwd - Voltage [MV]'                   ,  'KLYS:LI20:K4:3:S_AACTUAL'             } ;
nonBSA_list(end+1,:) = {'KLYS:LI20:K4:3:S_WACTUAL'              ,  'KLY PAD: Kly Fwd - Power [MW]'                     ,  'KLYS:LI20:K4:3:S_WACTUAL'             } ;

nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO074'                  ,  'S20 Energy relative to 20.35 GeV readback [MeV]'   ,  'SIOC:SYS1:ML00:AO074'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO079'                  ,  'S20 Energy relative to 20.35 GeV setpoint [MeV]'   ,  'SIOC:SYS1:ML00:AO079'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO099'                  ,  'EP01 ENGY.MKB knob value [deg]'                    ,  'SIOC:SYS1:ML00:AO099'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO061'                  ,  'EP01 Energy relative to 20.35 GeV setpoint [MeV]'  ,  'SIOC:SYS1:ML00:AO061'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO063'                  ,  'EP01 Energy relative to 20.35 GeV readback [MeV]'  ,  'SIOC:SYS1:ML00:AO063'                 } ;

nonBSA_list(end+1,:) = {'COLL:LI20:2070:MOTR'                   ,  'Notch Jaw 2, Fine Y motion'                        ,  'COLL:LI20:2070:MOTR'                  } ;
nonBSA_list(end+1,:) = {'COLL:LI20:2071:MOTR'                   ,  'Notch Jaw 3, X motion'                             ,  'COLL:LI20:2071:MOTR'                  } ;
nonBSA_list(end+1,:) = {'COLL:LI20:2072:MOTR'                   ,  'Notch Jaw 4, Coarse Y motion'                      ,  'COLL:LI20:2072:MOTR'                  } ;
nonBSA_list(end+1,:) = {'COLL:LI20:2073:MOTR'                   ,  'Notch Jaw 5, Rotation [deg]'                       ,  'COLL:LI20:2073:MOTR'                  } ;

nonBSA_list(end+1,:) = {'COLL:LI20:2069:MOTR'                   ,  'Notch X motion'                                    ,  'COLL:LI20:2069:MOTR'                  } ;
nonBSA_list(end+1,:) = {'COLL:LI20:2085:MOTR'                   ,  'Left Jaw'                                          ,  'COLL:LI20:2085:MOTR'                  } ;
nonBSA_list(end+1,:) = {'COLL:LI20:2086:MOTR'                   ,  'Right Jaw'                                         ,  'COLL:LI20:2086:MOTR'                  } ;
nonBSA_list(end+1,:) = {'COLL:LI20:2085:MOTR:GETGAP'            ,  'Jaw Gap width'                                     ,  'COLL:LI20:2085:MOTR:GETGAP'           } ;
nonBSA_list(end+1,:) = {'COLL:LI20:2085:MOTR:GETCENTER'         ,  'Jaw Gap Center'                                    ,  'COLL:LI20:2085:MOTR:GETCENTER'        } ;

nonBSA_list(end+1,:) = {'EVNT:SYS1:1:INJECTRATE'                ,  'Rate to Linac [Hz]'                                ,  'EVNT:SYS1:1:INJECTRATE'               } ;
nonBSA_list(end+1,:) = {'EVNT:SYS1:1:SCAVRATE'                  ,  'Rate to scav line [Hz]'                            ,  'EVNT:SYS1:1:SCAVRATE'                 } ;
nonBSA_list(end+1,:) = {'EVNT:SYS1:1:BEAMRATE'                  ,  'Rate to FACET [Hz]'                                ,  'EVNT:SYS1:1:BEAMRATE'                 } ;
nonBSA_list(end+1,:) = {'EVNT:SYS1:1:POSITRONRATE'              ,  'Positron Rate to FACET [Hz]'                       ,  'EVNT:SYS1:1:POSITRONRATE'             } ;

nonBSA_list(end+1,:) = {'YAGS:LI20:2434:MOTR'                   ,  'YAG Position'                                      ,  'YAGS:LI20:2434:MOTR'                  } ;
nonBSA_list(end+1,:) = {'OTRS:LI20:3070:MOTR'                   ,  'USTHz foil position'                               ,  'OTRS:LI20:3070:MOTR'                  } ;
nonBSA_list(end+1,:) = {'OTRS:LI20:3075:MOTR'                   ,  'DSTHz foil position'                               ,  'OTRS:LI20:3075:MOTR'                  } ;
nonBSA_list(end+1,:) = {'OTRS:LI20:3158:MOTR'                   ,  'USOTR foil position'                               ,  'OTRS:LI20:3158:MOTR'                  } ;
nonBSA_list(end+1,:) = {'OTRS:LI20:3175:MOTR'                   ,  'Spoiler Foil position'                             ,  'OTRS:LI20:3175:MOTR'                  } ;
nonBSA_list(end+1,:) = {'OTRS:LI20:3180:MOTR'                   ,  'IPOTR foil position'                               ,  'OTRS:LI20:3180:MOTR'                  } ;
nonBSA_list(end+1,:) = {'OTRS:LI20:3206:MOTR'                   ,  'DSOTR foil position'                               ,  'OTRS:LI20:3206:MOTR'                  } ;
nonBSA_list(end+1,:) = {'OTRS:LI20:3202:MOTR'                   ,  'IP2A foil position'                                ,  'OTRS:LI20:3202:MOTR'                  } ;
nonBSA_list(end+1,:) = {'OTRS:LI20:3230:MOTR'                   ,  'IP2B foil position'                                ,  'OTRS:LI20:3230:MOTR'                  } ;

nonBSA_list(end+1,:) = {'OVEN:LI20:3185:TC1'                    ,  'Oven Temp 1 [C]'                                   ,  'OVEN:LI20:3185:TC1'                   } ;
nonBSA_list(end+1,:) = {'OVEN:LI20:3185:TC2'                    ,  'Oven Temp 2 [C]'                                   ,  'OVEN:LI20:3185:TC2'                   } ;
nonBSA_list(end+1,:) = {'OVEN:LI20:3185:TC3'                    ,  'Oven Temp 3 [C]'                                   ,  'OVEN:LI20:3185:TC3'                   } ;
nonBSA_list(end+1,:) = {'OVEN:LI20:3185:TC4'                    ,  'Oven Temp 4 [C]'                                   ,  'OVEN:LI20:3185:TC4'                   } ;
nonBSA_list(end+1,:) = {'OVEN:LI20:3185:TC5'                    ,  'Oven Temp 5 [C]'                                   ,  'OVEN:LI20:3185:TC5'                   } ;
nonBSA_list(end+1,:) = {'BMLN:LI20:3184:TEMP'                   ,  'Oven Temp ETC1 [C]'                                ,  'BMLN:LI20:3184:TEMP'                  } ;
nonBSA_list(end+1,:) = {'BMLN:LI20:3186:TEMP'                   ,  'Oven Temp ETC2 [C]'                                ,  'BMLN:LI20:3186:TEMP'                  } ;
nonBSA_list(end+1,:) = {'OVEN:LI20:3185:H2OTEMP1'               ,  'Water jacket temp [C]'                             ,  'OVEN:LI20:3185:H2OTEMP1'              } ;
nonBSA_list(end+1,:) = {'OVEN:LI20:3185:H2OTEMP2'               ,  'Water jacket temp [C]'                             ,  'OVEN:LI20:3185:H2OTEMP2'              } ;
nonBSA_list(end+1,:) = {'OVEN:LI20:3185:PWRSUPPLY_V2'           ,  'Oven Voltage [V]'                                  ,  'OVEN:LI20:3185:PWRSUPPLY_V2'          } ;
nonBSA_list(end+1,:) = {'OVEN:LI20:3185:PWRSUPPLY_I2'           ,  'Oven Current [A]'                                  ,  'OVEN:LI20:3185:PWRSUPPLY_I2'          } ;
nonBSA_list(end+1,:) = {'OVEN:LI20:3185:PWRSUPPLY_W2'           ,  'Oven Power [W]'                                    ,  'OVEN:LI20:3185:PWRSUPPLY_W2'          } ;

nonBSA_list(end+1,:) = {'VGCM:LI20:M3201:PMONRAW'               ,  'CM Gauge [1000 Torr]'                              ,  'VGCM:LI20:M3201:PMONRAW'              } ;
nonBSA_list(end+1,:) = {'VGCM:LI20:M3202:PMONRAW'               ,  'CM Gauge [100 Torr]'                               ,  'VGCM:LI20:M3202:PMONRAW'              } ;
nonBSA_list(end+1,:) = {'VGCM:LI20:M3203:PMONRAW'               ,  'CM Gauge [10 Torr]'                                ,  'VGCM:LI20:M3203:PMONRAW'              } ;

nonBSA_list(end+1,:) = {'OVEN:LI20:3185:MOTR'                   ,  'Oven motor position'                               ,  'OVEN:LI20:3185:MOTR'                  } ;

% XPS controllers
nonBSA_list(end+1,:) = {'XPS:LI20:MC01:M1.RBV'                  ,  char(lcaGet('XPS:LI20:MC01:M1.DESC'))               ,  'XPS:LI20:MC01:M1.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC01:M2.RBV'                  ,  char(lcaGet('XPS:LI20:MC01:M2.DESC'))               ,  'XPS:LI20:MC01:M2.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC01:M3.RBV'                  ,  char(lcaGet('XPS:LI20:MC01:M3.DESC'))               ,  'XPS:LI20:MC01:M3.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC01:M4.RBV'                  ,  char(lcaGet('XPS:LI20:MC01:M4.DESC'))               ,  'XPS:LI20:MC01:M4.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC01:M5.RBV'                  ,  char(lcaGet('XPS:LI20:MC01:M5.DESC'))               ,  'XPS:LI20:MC01:M5.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC01:M6.RBV'                  ,  char(lcaGet('XPS:LI20:MC01:M6.DESC'))               ,  'XPS:LI20:MC01:M6.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC01:M7.RBV'                  ,  char(lcaGet('XPS:LI20:MC01:M7.DESC'))               ,  'XPS:LI20:MC01:M7.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC01:M8.RBV'                  ,  char(lcaGet('XPS:LI20:MC01:M8.DESC'))               ,  'XPS:LI20:MC01:M8.RBV'                 } ;

nonBSA_list(end+1,:) = {'XPS:LI20:MC02:M1.RBV'                  ,  char(lcaGet('XPS:LI20:MC02:M1.DESC'))               ,  'XPS:LI20:MC02:M1.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC02:M2.RBV'                  ,  char(lcaGet('XPS:LI20:MC02:M2.DESC'))               ,  'XPS:LI20:MC02:M2.RBV'                 } ;
%nonBSA_list(end+1,:) = {'XPS:LI20:MC02:M3.RBV'                  ,  char(lcaGet('XPS:LI20:MC02:M3.DESC'))               ,  'XPS:LI20:MC02:M3.RBV'                 } ;
%nonBSA_list(end+1,:) = {'XPS:LI20:MC02:M4.RBV'                  ,  char(lcaGet('XPS:LI20:MC02:M4.DESC'))               ,  'XPS:LI20:MC02:M4.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC02:M5.RBV'                  ,  char(lcaGet('XPS:LI20:MC02:M5.DESC'))               ,  'XPS:LI20:MC02:M5.RBV'                 } ;
%nonBSA_list(end+1,:) = {'XPS:LI20:MC02:M6.RBV'                  ,  char(lcaGet('XPS:LI20:MC02:M6.DESC'))               ,  'XPS:LI20:MC02:M6.RBV'                 } ;
%nonBSA_list(end+1,:) = {'XPS:LI20:MC02:M7.RBV'                  ,  char(lcaGet('XPS:LI20:MC02:M7.DESC'))               ,  'XPS:LI20:MC02:M7.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC02:M8.RBV'                  ,  char(lcaGet('XPS:LI20:MC02:M8.DESC'))               ,  'XPS:LI20:MC02:M8.RBV'                 } ;

nonBSA_list(end+1,:) = {'XPS:LI20:MC03:M1.RBV'                  ,  char(lcaGet('XPS:LI20:MC03:M1.DESC'))               ,  'XPS:LI20:MC03:M1.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC03:M2.RBV'                  ,  char(lcaGet('XPS:LI20:MC03:M2.DESC'))               ,  'XPS:LI20:MC03:M2.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC03:M3.RBV'                  ,  char(lcaGet('XPS:LI20:MC03:M3.DESC'))               ,  'XPS:LI20:MC03:M3.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC03:M4.RBV'                  ,  char(lcaGet('XPS:LI20:MC03:M4.DESC'))               ,  'XPS:LI20:MC03:M4.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC03:M5.RBV'                  ,  char(lcaGet('XPS:LI20:MC03:M5.DESC'))               ,  'XPS:LI20:MC03:M5.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC03:M6.RBV'                  ,  char(lcaGet('XPS:LI20:MC03:M6.DESC'))               ,  'XPS:LI20:MC03:M6.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC03:M7.RBV'                  ,  char(lcaGet('XPS:LI20:MC03:M7.DESC'))               ,  'XPS:LI20:MC03:M7.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC03:M8.RBV'                  ,  char(lcaGet('XPS:LI20:MC03:M8.DESC'))               ,  'XPS:LI20:MC03:M8.RBV'                 } ;

nonBSA_list(end+1,:) = {'XPS:LI20:MC04:M1.RBV'                  ,  char(lcaGet('XPS:LI20:MC04:M1.DESC'))               ,  'XPS:LI20:MC04:M1.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC04:M2.RBV'                  ,  char(lcaGet('XPS:LI20:MC04:M2.DESC'))               ,  'XPS:LI20:MC04:M2.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC04:M3.RBV'                  ,  char(lcaGet('XPS:LI20:MC04:M3.DESC'))               ,  'XPS:LI20:MC04:M3.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC04:M4.RBV'                  ,  char(lcaGet('XPS:LI20:MC04:M4.DESC'))               ,  'XPS:LI20:MC04:M4.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC04:M5.RBV'                  ,  char(lcaGet('XPS:LI20:MC04:M5.DESC'))               ,  'XPS:LI20:MC04:M5.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC04:M6.RBV'                  ,  char(lcaGet('XPS:LI20:MC04:M6.DESC'))               ,  'XPS:LI20:MC04:M6.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC04:M7.RBV'                  ,  char(lcaGet('XPS:LI20:MC04:M7.DESC'))               ,  'XPS:LI20:MC04:M7.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC04:M8.RBV'                  ,  char(lcaGet('XPS:LI20:MC04:M8.DESC'))               ,  'XPS:LI20:MC04:M8.RBV'                 } ;

nonBSA_list(end+1,:) = {'XPS:LI20:MC05:M1.RBV'                  ,  char(lcaGet('XPS:LI20:MC05:M1.DESC'))               ,  'XPS:LI20:MC05:M1.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC05:M2.RBV'                  ,  char(lcaGet('XPS:LI20:MC05:M2.DESC'))               ,  'XPS:LI20:MC05:M2.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC05:M3.RBV'                  ,  char(lcaGet('XPS:LI20:MC05:M3.DESC'))               ,  'XPS:LI20:MC05:M3.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC05:M4.RBV'                  ,  char(lcaGet('XPS:LI20:MC05:M4.DESC'))               ,  'XPS:LI20:MC05:M4.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC05:M5.RBV'                  ,  char(lcaGet('XPS:LI20:MC05:M5.DESC'))               ,  'XPS:LI20:MC05:M5.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC05:M6.RBV'                  ,  char(lcaGet('XPS:LI20:MC05:M6.DESC'))               ,  'XPS:LI20:MC05:M6.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC05:M7.RBV'                  ,  char(lcaGet('XPS:LI20:MC05:M7.DESC'))               ,  'XPS:LI20:MC05:M7.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LI20:MC05:M8.RBV'                  ,  char(lcaGet('XPS:LI20:MC05:M8.DESC'))               ,  'XPS:LI20:MC05:M8.RBV'                 } ;

nonBSA_list(end+1,:) = {'XPS:LA20:LS24:M1.RBV'                  ,  char(lcaGet('XPS:LA20:LS24:M1.DESC'))               ,  'XPS:LA20:LS24:M1.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LA20:LS24:M2.RBV'                  ,  char(lcaGet('XPS:LA20:LS24:M2.DESC'))               ,  'XPS:LA20:LS24:M2.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LA20:LS24:M3.RBV'                  ,  char(lcaGet('XPS:LA20:LS24:M3.DESC'))               ,  'XPS:LA20:LS24:M3.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LA20:LS24:M4.RBV'                  ,  char(lcaGet('XPS:LA20:LS24:M4.DESC'))               ,  'XPS:LA20:LS24:M4.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LA20:LS24:M5.RBV'                  ,  char(lcaGet('XPS:LA20:LS24:M5.DESC'))               ,  'XPS:LA20:LS24:M5.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LA20:LS24:M6.RBV'                  ,  char(lcaGet('XPS:LA20:LS24:M6.DESC'))               ,  'XPS:LA20:LS24:M6.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LA20:LS24:M7.RBV'                  ,  char(lcaGet('XPS:LA20:LS24:M7.DESC'))               ,  'XPS:LA20:LS24:M7.RBV'                 } ;
nonBSA_list(end+1,:) = {'XPS:LA20:LS24:M8.RBV'                  ,  char(lcaGet('XPS:LA20:LS24:M8.DESC'))               ,  'XPS:LA20:LS24:M8.RBV'                 } ;

% Pico motors
nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:M0:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:M0:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:M0:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:M0:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:M0:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:M0:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:M0:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:M0:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:M0:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:M0:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:M0:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:M0:CH4:MOTOR.RBV'      } ;

nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:S1:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:S1:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:S1:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:S1:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:S1:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:S1:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:S1:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:S1:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:S1:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:S1:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:S1:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:S1:CH4:MOTOR.RBV'      } ;

nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:S2:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:S2:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:S2:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:S2:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:S2:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:S2:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:S2:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:S2:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:S2:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC06:S2:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC06:S2:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC06:S2:CH4:MOTOR.RBV'      } ;

nonBSA_list(end+1,:) = {'MOTR:LI20:MC07:M0:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC07:M0:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC07:M0:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC07:M0:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC07:M0:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC07:M0:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC07:M0:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC07:M0:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC07:M0:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC07:M0:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC07:M0:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC07:M0:CH4:MOTOR.RBV'      } ;

nonBSA_list(end+1,:) = {'MOTR:LI20:MC07:S1:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC07:S1:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC07:S1:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC07:S1:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC07:S1:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC07:S1:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC07:S1:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC07:S1:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC07:S1:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC07:S1:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC07:S1:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC07:S1:CH4:MOTOR.RBV'      } ;

nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:M0:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:M0:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:M0:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:M0:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:M0:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:M0:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:M0:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:M0:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:M0:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:M0:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:M0:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:M0:CH4:MOTOR.RBV'      } ;

nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:S1:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:S1:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:S1:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:S1:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:S1:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:S1:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:S1:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:S1:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:S1:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:S1:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:S1:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:S1:CH4:MOTOR.RBV'      } ;

nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:S2:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:S2:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:S2:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:S2:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:S2:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:S2:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:S2:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:S2:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:S2:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC08:S2:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC08:S2:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC08:S2:CH4:MOTOR.RBV'      } ;

nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:M0:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:M0:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:M0:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:M0:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:M0:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:M0:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:M0:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:M0:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:M0:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:M0:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:M0:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:M0:CH4:MOTOR.RBV'      } ;

nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:S1:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:S1:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:S1:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:S1:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:S1:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:S1:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:S1:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:S1:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:S1:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:S1:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:S1:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:S1:CH4:MOTOR.RBV'      } ;

nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:S2:CH1:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:S2:CH1:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:S2:CH1:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:S2:CH2:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:S2:CH2:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:S2:CH2:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:S2:CH3:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:S2:CH3:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:S2:CH3:MOTOR.RBV'      } ;
nonBSA_list(end+1,:) = {'MOTR:LI20:MC09:S2:CH4:MOTOR.RBV'       ,  char(lcaGet('MOTR:LI20:MC09:S2:CH4:MOTOR.DESC'))    ,  'MOTR:LI20:MC09:S2:CH4:MOTOR.RBV'      } ;

% Sextupole movers- GUI must be run for these to update
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO501'                  ,  'SEXT 2165 X setpoint'                              ,  'SIOC:SYS1:ML00:AO501'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO503'                  ,  'SEXT 2165 X pot val'                               ,  'SIOC:SYS1:ML00:AO503'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO506'                  ,  'SEXT 2165 Y setpoint'                              ,  'SIOC:SYS1:ML00:AO506'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO508'                  ,  'SEXT 2165 Y pot val'                               ,  'SIOC:SYS1:ML00:AO508'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO511'                  ,  'SEXT 2165 Roll setpoint'                           ,  'SIOC:SYS1:ML00:AO511'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO513'                  ,  'SEXT 2165 Roll pot val'                            ,  'SIOC:SYS1:ML00:AO513'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO516'                  ,  'SEXT 2335 X setpoint'                              ,  'SIOC:SYS1:ML00:AO516'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO518'                  ,  'SEXT 2335 X pot val'                               ,  'SIOC:SYS1:ML00:AO518'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO521'                  ,  'SEXT 2335 Y setpoint'                              ,  'SIOC:SYS1:ML00:AO521'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO523'                  ,  'SEXT 2335 Y pot val'                               ,  'SIOC:SYS1:ML00:AO523'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO526'                  ,  'SEXT 2335 Roll setpoint'                           ,  'SIOC:SYS1:ML00:AO526'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO528'                  ,  'SEXT 2335 Roll pot val'                            ,  'SIOC:SYS1:ML00:AO528'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO551'                  ,  'SEXT 2145 X setpoint'                              ,  'SIOC:SYS1:ML00:AO551'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO553'                  ,  'SEXT 2145 X pot val'                               ,  'SIOC:SYS1:ML00:AO553'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO556'                  ,  'SEXT 2145 Y setpoint'                              ,  'SIOC:SYS1:ML00:AO556'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO558'                  ,  'SEXT 2145 Y pot val'                               ,  'SIOC:SYS1:ML00:AO558'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO561'                  ,  'SEXT 2145 Roll setpoint'                           ,  'SIOC:SYS1:ML00:AO561'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO563'                  ,  'SEXT 2145 Roll pot val'                            ,  'SIOC:SYS1:ML00:AO563'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO566'                  ,  'SEXT 2365 X setpoint'                              ,  'SIOC:SYS1:ML00:AO566'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO568'                  ,  'SEXT 2365 X pot val'                               ,  'SIOC:SYS1:ML00:AO568'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO571'                  ,  'SEXT 2365 Y setpoint'                              ,  'SIOC:SYS1:ML00:AO571'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO573'                  ,  'SEXT 2365 Y pot val'                               ,  'SIOC:SYS1:ML00:AO573'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO576'                  ,  'SEXT 2365 Roll setpoint'                           ,  'SIOC:SYS1:ML00:AO576'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO578'                  ,  'SEXT 2365 Roll pot val'                            ,  'SIOC:SYS1:ML00:AO578'                 } ;
% Sextupole strengths
nonBSA_list(end+1,:) = {'LI20:LGPS:2145:BDES'                   ,  'SXTS 2145 [kG/m?]'                                 ,  'LI20:LGPS:2145:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:2165:BDES'                   ,  'SXTS 2165 [kG/m?]'                                 ,  'LI20:LGPS:2165:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:2195:BDES'                   ,  'SXTS 2195 [kG/m?]'                                 ,  'LI20:LGPS:2195:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:2275:BDES'                   ,  'SXTS 2275 [kG/m?]'                                 ,  'LI20:LGPS:2275:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:2335:BDES'                   ,  'SXTS 2335 [kG/m?]'                                 ,  'LI20:LGPS:2335:BDES'                  } ;
nonBSA_list(end+1,:) = {'LI20:LGPS:2365:BDES'                   ,  'SXTS 2365 [kG/m?]'                                 ,  'LI20:LGPS:2365:BDES'                  } ;

% Nate's EPICS -> AIDA TORO calibration
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO033'                  ,  'GADC CH0 -> TORO 2452 Slope'                       ,  'SIOC:SYS1:ML00:AO033'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO034'                  ,  'GADC CH0 -> TORO 2452 Offset'                      ,  'SIOC:SYS1:ML00:AO034'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO035'                  ,  'GADC CH2 -> TORO 3163 Slope'                       ,  'SIOC:SYS1:ML00:AO035'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO036'                  ,  'GADC CH2 -> TORO 3163 Offset'                      ,  'SIOC:SYS1:ML00:AO036'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO037'                  ,  'GADC CH3 -> TORO 3255 Slope'                       ,  'SIOC:SYS1:ML00:AO037'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO038'                  ,  'GADC CH3 -> TORO 3255 Offset'                      ,  'SIOC:SYS1:ML00:AO038'                 } ;

% Spencer's EPICS -> AIDA calibration
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO001'                  ,  'BPM 2445 X SLOPE'                                  ,  'SIOC:SYS1:ML01:AO001'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO002'                  ,  'BPM 2445 X OFFSET'                                 ,  'SIOC:SYS1:ML01:AO002'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO003'                  ,  'BPM 2445 Y SLOPE'                                  ,  'SIOC:SYS1:ML01:AO003'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO004'                  ,  'BPM 2445 Y OFFSET'                                 ,  'SIOC:SYS1:ML01:AO004'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO005'                  ,  'BPM 2445 TMIT SLOPE'                               ,  'SIOC:SYS1:ML01:AO005'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO006'                  ,  'BPM 2445 TMIT OFFSET'                              ,  'SIOC:SYS1:ML01:AO006'                 } ;

nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO007'                  ,  'BPM 3156 X SLOPE'                                  ,  'SIOC:SYS1:ML01:AO007'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO008'                  ,  'BPM 3156 X OFFSET'                                 ,  'SIOC:SYS1:ML01:AO008'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO009'                  ,  'BPM 3156 Y SLOPE'                                  ,  'SIOC:SYS1:ML01:AO009'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO010'                  ,  'BPM 3156 Y OFFSET'                                 ,  'SIOC:SYS1:ML01:AO010'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO011'                  ,  'BPM 3156 TMIT SLOPE'                               ,  'SIOC:SYS1:ML01:AO011'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO012'                  ,  'BPM 3156 TMIT OFFSET'                              ,  'SIOC:SYS1:ML01:AO012'                 } ;

nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO013'                  ,  'BPM 3265 X SLOPE'                                  ,  'SIOC:SYS1:ML01:AO013'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO014'                  ,  'BPM 3265 X OFFSET'                                 ,  'SIOC:SYS1:ML01:AO014'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO015'                  ,  'BPM 3265 Y SLOPE'                                  ,  'SIOC:SYS1:ML01:AO015'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO016'                  ,  'BPM 3265 Y OFFSET'                                 ,  'SIOC:SYS1:ML01:AO016'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO017'                  ,  'BPM 3265 TMIT SLOPE'                               ,  'SIOC:SYS1:ML01:AO017'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO018'                  ,  'BPM 3265 TMIT OFFSET'                              ,  'SIOC:SYS1:ML01:AO018'                 } ;

nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO019'                  ,  'BPM 3315 X SLOPE'                                  ,  'SIOC:SYS1:ML01:AO019'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO020'                  ,  'BPM 3315 X OFFSET'                                 ,  'SIOC:SYS1:ML01:AO020'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO021'                  ,  'BPM 3315 Y SLOPE'                                  ,  'SIOC:SYS1:ML01:AO021'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO022'                  ,  'BPM 3315 Y OFFSET'                                 ,  'SIOC:SYS1:ML01:AO022'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO023'                  ,  'BPM 3315 TMIT SLOPE'                               ,  'SIOC:SYS1:ML01:AO023'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO024'                  ,  'BPM 3315 TMIT OFFSET'                              ,  'SIOC:SYS1:ML01:AO024'                 } ;

nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO025'                  ,  'TORO 2452 TMIT SLOPE'                              ,  'SIOC:SYS1:ML01:AO025'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO026'                  ,  'TORO 2452 TMIT OFFSET'                             ,  'SIOC:SYS1:ML01:AO026'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO027'                  ,  'TORO 3163 TMIT SLOPE'                              ,  'SIOC:SYS1:ML01:AO027'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO028'                  ,  'TORO 3163 TMIT OFFSET'                             ,  'SIOC:SYS1:ML01:AO028'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO029'                  ,  'TORO 3255 TMIT SLOPE'                              ,  'SIOC:SYS1:ML01:AO029'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO030'                  ,  'TORO 3255 TMIT OFFSET'                             ,  'SIOC:SYS1:ML01:AO030'                 } ;

% Waist and beta info from Glen/Nate
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO351'                  ,  'X Waist Z'                                         ,  'SIOC:SYS1:ML00:AO351'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO352'                  ,  'Beta X'                                            ,  'SIOC:SYS1:ML00:AO352'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO353'                  ,  'Y Waist Z'                                         ,  'SIOC:SYS1:ML00:AO353'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO354'                  ,  'Beta Y'                                            ,  'SIOC:SYS1:ML00:AO354'                 } ;

% YAG Lineout Info
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO751'                  ,  'YAG Line Low'                                      ,  'SIOC:SYS1:ML00:AO751'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO752'                  ,  'YAG Line High'                                     ,  'SIOC:SYS1:ML00:AO752'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO753'                  ,  'YAG Line Left'                                     ,  'SIOC:SYS1:ML00:AO753'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO754'                  ,  'YAG Line Right'                                    ,  'SIOC:SYS1:ML00:AO754'                 } ;

% Notch and YAG Dispersion from dispersion scan
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO776'                  ,  'Notch z'                                           ,  'SIOC:SYS1:ML00:AO776'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO777'                  ,  'Notch eta_x'                                       ,  'SIOC:SYS1:ML00:AO777'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO778'                  ,  'Notch eta_x"'                                      ,  'SIOC:SYS1:ML00:AO778'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO779'                  ,  'Notch eta_y'                                       ,  'SIOC:SYS1:ML00:AO779'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO780'                  ,  'Notch eta_y"'                                      ,  'SIOC:SYS1:ML00:AO780'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO781'                  ,  'SYAG z'                                            ,  'SIOC:SYS1:ML00:AO781'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO782'                  ,  'SYAG eta_x'                                        ,  'SIOC:SYS1:ML00:AO782'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO783'                  ,  'SYAG eta_x"'                                       ,  'SIOC:SYS1:ML00:AO783'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO784'                  ,  'SYAG eta_y'                                        ,  'SIOC:SYS1:ML00:AO784'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO785'                  ,  'SYAG eta_y"'                                       ,  'SIOC:SYS1:ML00:AO785'                 } ;

% Dispersion at YAG
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO855'                  ,  'Dispersion at sYAG'                                ,  'SIOC:SYS1:ML00:AO855'                 } ;

% NDR Info
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO851'                  ,  'Last time measured'                                ,  'SIOC:SYS1:ML00:AO851'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO852'                  ,  'Gap Voltage'                                       ,  'SIOC:SYS1:ML00:AO852'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO853'                  ,  'Charge'                                            ,  'SIOC:SYS1:ML00:AO853'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO854'                  ,  'Bunch Length'                                      ,  'SIOC:SYS1:ML00:AO854'                 } ;

% LiTrack Simulation Parameters
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO801'                  ,  'NDR Z0'                                            ,  'SIOC:SYS1:ML00:AO801'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO802'                  ,  'NDR D0'                                            ,  'SIOC:SYS1:ML00:AO802'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO803'                  ,  'NDR NPART'                                         ,  'SIOC:SYS1:ML00:AO803'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO804'                  ,  'NDR ASYM'                                          ,  'SIOC:SYS1:ML00:AO804'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO805'                  ,  'NRTL AMPL'                                         ,  'SIOC:SYS1:ML00:AO805'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO806'                  ,  'NRTL PHAS'                                         ,  'SIOC:SYS1:ML00:AO806'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO807'                  ,  'NRTL R56'                                          ,  'SIOC:SYS1:ML00:AO807'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO808'                  ,  'NRTL T566'                                         ,  'SIOC:SYS1:ML00:AO808'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO809'                  ,  'PHAS 2-10'                                         ,  'SIOC:SYS1:ML00:AO809'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO810'                  ,  'PHAS 11-20'                                        ,  'SIOC:SYS1:ML00:AO810'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO811'                  ,  'PHAS RAMP'                                         ,  'SIOC:SYS1:ML00:AO811'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO812'                  ,  'LI20 BETA'                                         ,  'SIOC:SYS1:ML00:AO812'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO813'                  ,  'LI20 R56'                                          ,  'SIOC:SYS1:ML00:AO813'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO814'                  ,  'LI20 T166'                                         ,  'SIOC:SYS1:ML00:AO814'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO835'                  ,  'LI20 HI E CUT'                                     ,  'SIOC:SYS1:ML00:AO835'                 } ;

% LiTrack Bunch Parameters
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO816'                  ,  'YAG FWHM'                                          ,  'SIOC:SYS1:ML00:AO816'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO817'                  ,  'YAG RMS'                                           ,  'SIOC:SYS1:ML00:AO817'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO818'                  ,  'ENERGY OFFSET'                                     ,  'SIOC:SYS1:ML00:AO818'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO819'                  ,  'Li YAG FWHM'                                       ,  'SIOC:SYS1:ML00:AO819'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO820'                  ,  'Li YAG RMS'                                        ,  'SIOC:SYS1:ML00:AO820'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO821'                  ,  'Li PROF FWHM/2.35'                                 ,  'SIOC:SYS1:ML00:AO821'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO822'                  ,  'Li PROF RMS'                                       ,  'SIOC:SYS1:ML00:AO822'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO823'                  ,  'Li PROF RMS w/15% FLOOR CUT'                       ,  'SIOC:SYS1:ML00:AO823'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO833'                  ,  'Li PEAK CURRENT'                                   ,  'SIOC:SYS1:ML00:AO833'                 } ;

% LiTrack Calculations
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:CALC801'                ,  'Calculated NDR bunch length'                       ,  'SIOC:SYS1:ML00:CALC801'               } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:CALC805'                ,  'Adjusted NRTL AMPL'                                ,  'SIOC:SYS1:ML00:CALC805'               } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:CALC806'                ,  'NRTL Phase offset'                                 ,  'SIOC:SYS1:ML00:CALC806'               } ;

% E200 Display Info
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO061'                  ,  'E200 CEGAIN Max Energy 1'                          ,  'SIOC:SYS1:ML01:AO061'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO062'                  ,  'E200 CEGAIN Max Energy 2'                          ,  'SIOC:SYS1:ML01:AO062'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO063'                  ,  'E200 CEGAIN Max Energy 3'                          ,  'SIOC:SYS1:ML01:AO063'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO064'                  ,  'E200 CEGAIN Acc Charge'                            ,  'SIOC:SYS1:ML01:AO064'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO065'                  ,  'E200 CEGAIN Unaffected Charge'                     ,  'SIOC:SYS1:ML01:AO065'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO066'                  ,  'E200 CELOSS Min Energy'                            ,  'SIOC:SYS1:ML01:AO066'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO067'                  ,  'E200 CELOSS Dec Charge'                            ,  'SIOC:SYS1:ML01:AO067'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO068'                  ,  'E200 CELOSS Unaffected Charge'                     ,  'SIOC:SYS1:ML01:AO068'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO069'                  ,  'E200 BETAL Gamma Yield'                            ,  'SIOC:SYS1:ML01:AO069'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO070'                  ,  'E200 BETAL Gamma Max'                              ,  'SIOC:SYS1:ML01:AO070'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO071'                  ,  'E200 BETAL Gamma Div'                              ,  'SIOC:SYS1:ML01:AO071'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO072'                  ,  'E200 Excess Charge'                                ,  'SIOC:SYS1:ML01:AO072'                 } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML01:AO073'                  ,  'E200 Transformer'                                  ,  'SIOC:SYS1:ML01:AO073'                 } ;

% Laser PVs
nonBSA_list(end+1,:) = {'PMTR:LA20:10:PWR1H'                    ,  '1 Hz Laser Power'                                  ,  'PMTR:LA20:10:PWR1H'                   } ;
nonBSA_list(end+1,:) = {'PMTR:LA20:10:PWRBR'                    ,  'Beam Rate Laser Power'                             ,  'PMTR:LA20:10:PWRBR'                   } ;
nonBSA_list(end+1,:) = {'PMTR:LA20:10:PWR_RAW'                  ,  'RAW POWER'                                         ,  'PMTR:LA20:10:PWR_RAW'                 } ;
nonBSA_list(end+1,:) = {'OSC:LA20:10:FREQ_SP'                   ,  'Coarse Oscillator Frequency'                       ,  'OSC:LA20:10:FREQ_SP'                  } ;
nonBSA_list(end+1,:) = {'OSC:LA20:10:FREQ_RBCK'                 ,  'Coarse Oscillator Readback'                        ,  'OSC:LA20:10:FREQ_RBCK'                } ;
nonBSA_list(end+1,:) = {'OSC:LA20:10:PD_CH1_RF_PWR_AVG'         ,  'Avg. RF power'                                     ,  'OSC:LA20:10:PD_CH1_RF_PWR_AVG'        } ;
nonBSA_list(end+1,:) = {'OSC:LA20:10:PD_CH1_RF_PWR_STD'         ,  'RMS RF power'                                      ,  'OSC:LA20:10:PD_CH1_RF_PWR_STD'        } ;
nonBSA_list(end+1,:) = {'OSC:LA20:10:PD_CH1_DIODE_PWR_AVG'      ,  'Avg. Diode power'                                  ,  'OSC:LA20:10:PD_CH1_DIODE_PWR_AVG'     } ;
nonBSA_list(end+1,:) = {'OSC:LA20:10:PD_CH1_DIODE_PWR_STD'      ,  'RMS Diode power'                                   ,  'OSC:LA20:10:PD_CH1_DIODE_PWR_STD'     } ;
nonBSA_list(end+1,:) = {'UTIC:LA20:10:GetMeasMean'              ,  'Mean time interval counter'                        ,  'UTIC:LA20:10:GetMeasMean'             } ;
nonBSA_list(end+1,:) = {'VGXX:LI20:L3185:P'                     ,  'Pressure at compressor box'                        ,  'VGXX:LI20:L3185:P'                    } ;

nonBSA_list(end+1,:) = {'TRIG:LA20:LS24:TDES'                   ,  'Pace Maker 10Hz'                                   ,  'TRIG:LA20:LS24:TDES'                  } ;
nonBSA_list(end+1,:) = {'TRIG:LA20:LS25:TDES'                   ,  'SDG Gate'                                          ,  'TRIG:LA20:LS25:TDES'                  } ;
nonBSA_list(end+1,:) = {'TRIG:LA20:LS26:TDES'                   ,  'Time Interval Counter'                             ,  'TRIG:LA20:LS26:TDES'                  } ;
nonBSA_list(end+1,:) = {'TRIG:LA20:LS27:TDES'                   ,  'Legend 120 Hz'                                     ,  'TRIG:LA20:LS27:TDES'                  } ;
nonBSA_list(end+1,:) = {'TRIG:LA20:LS24:TWID'                   ,  'Pace Maker 10Hz width'                             ,  'TRIG:LA20:LS24:TWID'                  } ;
nonBSA_list(end+1,:) = {'TRIG:LA20:LS25:TWID'                   ,  'SDG Gate width'                                    ,  'TRIG:LA20:LS25:TWID'                  } ;
nonBSA_list(end+1,:) = {'TRIG:LA20:LS26:TWID'                   ,  'Time Interval Counter width'                       ,  'TRIG:LA20:LS26:TWID'                  } ;
nonBSA_list(end+1,:) = {'TRIG:LA20:LS27:TWID'                   ,  'Legend 120 Hz width'                               ,  'TRIG:LA20:LS27:TWID'                  } ;
nonBSA_list(end+1,:) = {'OSC:LA20:10:FS_TGT_TIME'               ,  'Target time'                                       ,  'OSC:LA20:10:FS_TGT_TIME'              } ;
nonBSA_list(end+1,:) = {'UTIC:LA20:10:GetOffsetInvMeasMean_ns'  ,  'readback time'                                     ,  'UTIC:LA20:10:GetOffsetInvMeasMean_ns' } ;

% E217 PVs
nonBSA_list(end+1,:) = {'EVR:LI20:EX01:EVENT14CTRL.ENM'         ,  'Trigger rate for the helium solenoid'              ,  'sol_trig_rate'                        } ;
nonBSA_list(end+1,:) = {'TRIG:LI20:EX01:FP2_TCTL.RVAL'          ,  'Trigger state of helium solenoid'                  ,  'sol_trig_on_off'                      } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO194'                  ,  'Integrated Shots for helium jet'                   ,  'sol_shot_counter'                     } ;
nonBSA_list(end+1,:) = {'APC:LI20:EX02:24VOUT_3.RVAL'           ,  'PV for hydrogen filter state'                      ,  'h2_filter'                            } ;
nonBSA_list(end+1,:) = {'APC:LI20:EX02:24VOUT_4.RVAL'           ,  'PV for helium filter state'                        ,  'he_filter'                            } ;
nonBSA_list(end+1,:) = {'VGCM:LI20:M3204:P'                     ,  'Helium cylinder pressure value'                    ,  'P_he_cyl'                             } ;
nonBSA_list(end+1,:) = {'TRIG:LI20:EX01:FP2_TWID'               ,  'Gate timing for helium solenoid'                   ,  'sol_TTL_gate'                         } ;
nonBSA_list(end+1,:) = {'TRIG:LI20:EX01:FP2_TDES'               ,  'Delay for helium solenoid wrt beam'                ,  'sol_TTL_beam_delay'                   } ;

% E210 PVs
nonBSA_list(end+1,:) = {'APC:LI20:EX02:24VOUT_10.RVAL'               ,  'Blueglass filter state'                            ,  'e210_bg_filter'                       } ;
nonBSA_list(end+1,:) = {'APC:LI20:EX02:24VOUT_2.RVAL'                ,  'Hydrogen filter state'                             ,  'e210_h2_filter'                       } ;
nonBSA_list(end+1,:) = {'APC:LI20:EX02:24VOUT_1.RVAL'                ,  'Helium filter state'                               ,  'e210_he_filter'                       } ;
nonBSA_list(end+1,:) = {'APC:LI20:EX02:24VOUT_8.RVAL'                ,  'ND filter state IPOTR3'                            ,  'e210_ipotr3_nd_filter'                } ;
nonBSA_list(end+1,:) = {'APC:LI20:EX02:24VOUT_7.RVAL'                ,  'probe block state'                                 ,  'e210_probe_block'                     } ;
nonBSA_list(end+1,:) = {'APC:LI20:EX02:24VOUT_9.RVAL'                ,  'main block state'                                  ,  'e210_main_block'                      } ;
nonBSA_list(end+1,:) = {'OVEN:LI20:3185:TEMP8'                  ,  'air temperature [degC]'                            ,  'e210_temperature'                     } ;
% nonBSA_list(end+1,:) = {''                                    ,  'density [cm-3]'                                    ,  'e210_density'                         } ;
nonBSA_list(end+1,:) = {'XPS:LA20:LS24:M1.RBV'                  ,  'waveplate angle [deg]'                             ,  'e210_waveplate_setting'               } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML03:CALC003'                ,  'waveplate transmission [percent]'                  ,  'e210_waveplate_transmission'          } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML03:CALC004'                ,  'laser energy into transport [mJ]'                  ,  'e210_laser_energy_transport'          } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML03:CALC002'                ,  'laser energy at OAP [mJ]'                          ,  'e210_laser_energy_OAP'                } ;
% nonBSA_list(end+1,:) = {''                                    ,  'EOS jitter [fs]'                                   ,  'e210_eos_jitter'                      } ;


% QS external PVs used by set_QS0_imaging_CUBEX_ELANEX
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO794'                  ,  'QS image energy (set_QS0_imaging_CUBEX_ELANEX)'                                   ,  'QS_ENERGY'                } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML00:AO795'                  ,  'QS object plane (set_QS0_imaging_CUBEX_ELANEX)'                                   ,  'QS_OBJECT_PLANE'          } ;

% QS external PVs used by set_QS_trim
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML03:AO001'                  ,  'QS object plane (set_QS_trim)'                                   ,  'SIOC:SYS1:ML03:AO001'                            } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML03:AO002'                  ,  'QS image plane (set_QS_trim)'                                   ,  'SIOC:SYS1:ML03:AO002'                      } ;
nonBSA_list(end+1,:) = {'SIOC:SYS1:ML03:AO003'                  ,  'QS energy set point (set_QS_trim)'                                   ,  'SIOC:SYS1:ML03:AO003' } ;
