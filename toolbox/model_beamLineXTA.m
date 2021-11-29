function beamLine = model_beamLineXTA()

GUN_XBAND={ ...
'dr' '' 0 []; ...
'dr' 'SOL1X' 0.04615 []; ...
'dr' 'SOL1X' 0.04615 []; ...
'dr' '' 0.4577 []; ...
'mo' 'YAG150X' 0 []; ...
};

XBAND_STRAIGHT={ ...
'dr' '' 0 []; ...
'qu' 'QE01X' 0.05245 [-6.5 0 ]; ...
'mo' 'M' 0 []; ...
'qu' 'QE01X' 0.05245 [-6.5 0 ]; ...
'dr' '' 0.2951 []; ...
'qu' 'QE02X' 0.05245 [3.7 0 ]; ...
'mo' 'M' 0 []; ...
'qu' 'QE02X' 0.05245 [3.7 0 ]; ...
'dr' '' 0.42205 []; ...
'dr' '' 0.42205 []; ...
'qu' 'QE03X' 0.05245 [-3.28 0 ]; ...
'mo' 'M' 0 []; ...
'qu' 'QE03X' 0.05245 [-3.28 0 ]; ...
'dr' '' 0.2951 []; ...
'qu' 'QE04X' 0.05245 [4.605 0 ]; ...
'mo' 'M' 0 []; ...
'qu' 'QE04X' 0.05245 [4.605 0 ]; ...
'mo' 'M' 0 []; ...
'dr' '' 0.41955 []; ...
'mo' 'OTR350X' 0 []; ...
'dr' '' 1.061 []; ...
'mo' 'OTR250X' 0 []; ...
'dr' '' 0.34 []; ...
'mo' 'YAG550X' 0 []; ...
};

XBAND_TOBEND={ ...
'dr' '' 0 []; ...
'qu' 'QE01X' 0.05245 [-6.5 0 ]; ...
'mo' 'M' 0 []; ...
'qu' 'QE01X' 0.05245 [-6.5 0 ]; ...
'dr' '' 0.2951 []; ...
'qu' 'QE02X' 0.05245 [3.7 0 ]; ...
'mo' 'M' 0 []; ...
'qu' 'QE02X' 0.05245 [3.7 0 ]; ...
'dr' '' 0.42205 []; ...
'dr' '' 0.42205 []; ...
'qu' 'QE03X' 0.05245 [-3.28 0 ]; ...
'mo' 'M' 0 []; ...
'qu' 'QE03X' 0.05245 [-3.28 0 ]; ...
'dr' '' 0.2951 []; ...
'qu' 'QE04X' 0.05245 [4.605 0 ]; ...
'mo' 'M' 0 []; ...
'qu' 'QE04X' 0.05245 [4.605 0 ]; ...
'mo' 'M' 0 []; ...
'dr' '' 0.41955 []; ...
'mo' 'M' 0 []; ...
'mo' 'OTR250X1' 0 []; ...
'dr' '' 0.4637 []; ...
'be' 'T' 0.3683 [0.785398 0.0127 0 0 0.391 0 0 ]; ...
'dr' '' 1.03066 []; ...
'mo' 'DNMARK42' 0 []; ...
};

beamLine.GUN_XBAND=GUN_XBAND;
beamLine.XBAND_STRAIGHT=XBAND_STRAIGHT;
beamLine.XBAND_TOBEND=XBAND_TOBEND;