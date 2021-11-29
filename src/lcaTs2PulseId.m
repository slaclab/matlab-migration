function pulseId = lcaTs2PulseId(lcaTS)
tsNsecs = imag(lcaTS);
pulseId = bitand(uint32(tsNsecs), hex2dec('1FFFF'));
