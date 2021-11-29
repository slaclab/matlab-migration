function[] = calBpmFiltHxrHelper()

% Define corrector structure elements
f1 = 'xcor'; val1 = [];
f2 = 'ycor'; val2 = [];
f3 = 'xcorpv';  val3 = []; 
f4 = 'ycorpv';  val4 = []; 
f5 = 'rx';      val5 = []; 
f6 = 'ry';      val6 = 0; 

corstruct = struct( f1, val1, f2, val2, f3, val3, f4, val4, f5, val5, f6, val6);

% Define BPM structure elements
f1 = 'name'; val1 = []; % BPM name
f2 = 'cor';  val2 = corstruct;
    
bpmstruct = struct( f1, val1, f2, val2 );

model_init( 'source', 'MATLAB' );
beampath = 'CU_HXR';
beampathstr = ['BEAMPATH=' beampath];

scanbpms = [];
[scanbpms] = init_cor_wrapper('XCOR:UNDH:2080', 'YCOR:UNDH:2080', 'BPMS:UNDH:2190', beampathstr, scanbpms, bpmstruct);
[scanbpms] = init_cor_wrapper('XCOR:UNDH:2380', 'YCOR:UNDH:2380', 'BPMS:UNDH:2490', beampathstr, scanbpms, bpmstruct);
[scanbpms] = init_cor_wrapper('XCOR:UNDH:2480', 'YCOR:UNDH:2480', 'BPMS:UNDH:2590', beampathstr, scanbpms, bpmstruct);
[scanbpms] = init_cor_wrapper('XCOR:UNDH:2580', 'YCOR:UNDH:2580', 'BPMS:UNDH:2690', beampathstr, scanbpms, bpmstruct);
[scanbpms] = init_cor_wrapper('XCOR:UNDH:2680', 'YCOR:UNDH:2680', 'BPMS:UNDH:2790', beampathstr, scanbpms, bpmstruct);
[scanbpms] = init_cor_wrapper('XCOR:UNDH:2780', 'YCOR:UNDH:2780', 'BPMS:UNDH:2890', beampathstr, scanbpms, bpmstruct);
[scanbpms] = init_cor_wrapper('XCOR:UNDH:2880', 'YCOR:UNDH:2880', 'BPMS:UNDH:2990', beampathstr, scanbpms, bpmstruct);

save 'calBpmFiltHxr.mat'

end

function[scanbpms] = init_cor_wrapper(xcor, ycor, bpm, beampathstr, scanbpms, bpmstruct)
[rval, cor] = init_cor(xcor, ycor, bpm, beampathstr);
if ( ~rval )
    newbpm = bpmstruct;
    newbpm.name = bpm;
    newbpm.cor = cor;
    scanbpms = [scanbpms, newbpm];
end
end

function[rval, cor] = init_cor(xcor, ycor, bpm, beampathstr)
rval = -1;
% Get R-matrix from corrector to BPM, to calculate corrector settings
rMat = model_rMatGet( xcor, bpm,{beampathstr,'TYPE=EXTANT'} );
rx = rMat(1,2);
rMat = model_rMatGet( ycor, bpm,{beampathstr,'TYPE=EXTANT'} );
ry = rMat(3,4);

if ( (rx == 0) || isnan(rx) )
    disp( 'XCOR bad model. Quitting' );
    return;
elseif ( (ry == 0) || isnan(ry) )
    disp( 'YCOR bad model. Quitting' );
    return;
end

cor.xcor = xcor;
cor.ycor = ycor;
cor.xcorpv = [xcor ':BCTRL'];
cor.ycorpv = [ycor ':BCTRL'];
% try
%     bpmst.xcor_i = lcaGet( bpmst.xcorpv );
%     bpmst.ycor_i = lcaGet( bpmst.ycorpv );
% catch
%     disp( ['Failed to read ' bpmst.xcorpv ' and/or ' bpmst.ycorpv '. Abort.'] );
%     return;
% end
cor.rx = rx;
cor.ry = ry;
rval = 0;

end
% % model_init( 'source', 'MATLAB' );
% % beampath = 'CU_HXR';
% % beampathstr = ['BEAMPATH=' beampath];
% % E = model_rMatGet( 'RFB07', [], {beampathstr,'TYPE=EXTANT'},'EN' ); % Get energy at first BPM
% % E = E(1);
% % 
% % E = 10 % temporary
% % 
% % C = 33.35640952; % Cb, Magnetic rigidity, for calculating deflection
% % 
% % bpms = {'BPMS:LTUH:910', 'BPMS:LTUH:960','BPMS:UNDH:1305','BPMS:UNDH:1390','BPMS:UNDH:1490', ...
% %     'BPMS:UNDH:1590','BPMS:UNDH:1690','BPMS:UNDH:1790','BPMS:UNDH:1890','BPMS:UNDH:1990', ...
% %     'BPMS:UNDH:2090','BPMS:UNDH:2190','BPMS:UNDH:2290','BPMS:UNDH:2390','BPMS:UNDH:2490', ...
% %     'BPMS:UNDH:2590','BPMS:UNDH:2690','BPMS:UNDH:2790','BPMS:UNDH:2890','BPMS:UNDH:2990', ...
% %     'BPMS:UNDH:3090','BPMS:UNDH:3190','BPMS:UNDH:3290','BPMS:UNDH:3390','BPMS:UNDH:3490', ...
% %     'BPMS:UNDH:3590','BPMS:UNDH:3690','BPMS:UNDH:3790','BPMS:UNDH:3890','BPMS:UNDH:3990', ...
% %     'BPMS:UNDH:4090','BPMS:UNDH:4190','BPMS:UNDH:4290','BPMS:UNDH:4390','BPMS:UNDH:4490', ...
% %     'BPMS:UNDH:4590','BPMS:UNDH:4690','BPMS:UNDH:5190'
% %     };
% % nbpms = length( bpms ); 
% % 
% % xcor='XCOR:LTUH:818'
% % ycor='YCOR:LTUH:837'
% % disp( 'Assume 50 um move at RFBHX13' );
% % move = 50e-6 % meters
% % rMat = model_rMatGet( xcor, 'BPMS:UNDH:1390', {'BEAMPATH=CU_HXR','TYPE=EXTANT'} );
% % rx = rMat(1,2)
% % rMat = model_rMatGet( ycor, 'BPMS:UNDH:1390', {'BEAMPATH=CU_HXR','TYPE=EXTANT'} );
% % ry = rMat(3,4)
% % 
% % xbctrl = move * C*E/rx;
% % ybctrl = move * C*E/ry;
% % 
% % rx = zeros( nbpms );
% % ry = zeros( nbpms );
% % xmove = zeros( nbpms );
% % ymove = zeros( nbpms );
% % 
% % for n = 1:nbpms
% %     rMat = model_rMatGet( xcor, bpms{n}, {'BEAMPATH=CU_HXR','TYPE=EXTANT'} );
% %     rx(n) = rMat(1,2);
% %     rMat = model_rMatGet( ycor, bpms{n}, {'BEAMPATH=CU_HXR','TYPE=EXTANT'} );
% %     ry(n) = rMat(3,4);
% %     xmove(n) = xbctrl * rx(n) / C / E;
% %     ymove(n) = ybctrl * ry(n) / C / E;
% %     disp( [bpms{n} ' ' num2str(rx(n),'%.1f') ' '  num2str(1e6*xmove(n),'%.1f') ' um  ' num2str(ry(n),'%.1f') ' ' num2str(1e6*ymove(n),'%.1f') ' um'] );
% % end


% >> calBpmFiltHelper
% Warning: PV (KLYS:LI26:31:BEAMCODE1_STAT) with alarm status: UDF (severity INVALID)
% E =
%     0.0040
% E =
%     10
% xcor =
% XCOR:LTUH:818
% ycor =
% YCOR:LTUH:837
% Assume 50 um move at RFBHX13
% move =
%    5.0000e-05
% rx =
%    32.5394
% ry =
%    21.5261
% BPMS:LTUH:910 20.0 30.8 um  16.6 38.6 um
% BPMS:LTUH:960 23.6 36.2 um  17.8 41.4 um
% BPMS:UNDH:1305 28.3 43.4 um  19.5 45.2 um
% BPMS:UNDH:1390 32.5 50.0 um  21.5 50.0 um
% BPMS:UNDH:1490 23.0 35.3 um  32.3 74.9 um
% BPMS:UNDH:1590 22.8 35.0 um  29.5 68.5 um
% BPMS:UNDH:1690 12.7 19.5 um  38.6 89.7 um
% BPMS:UNDH:1790 7.9 12.2 um  31.5 73.1 um
% BPMS:UNDH:1890 -0.5 -0.7 um  37.3 86.5 um
% BPMS:UNDH:1990 -8.7 -13.4 um  27.2 63.2 um
% BPMS:UNDH:2090 -13.5 -20.7 um  28.4 66.0 um
% BPMS:UNDH:2190 -23.5 -36.1 um  17.4 40.5 um
% BPMS:UNDH:2290 -23.6 -36.3 um  13.8 32.1 um
% BPMS:UNDH:2390 -33.2 -51.0 um  4.2 9.7 um
% BPMS:UNDH:2490 -28.5 -43.8 um  -3.5 -8.2 um
% BPMS:UNDH:2590 -35.3 -54.3 um  -9.9 -23.1 um
% BPMS:UNDH:2690 -27.0 -41.4 um  -20.2 -46.8 um
% BPMS:UNDH:2790 -29.5 -45.4 um  -22.0 -51.2 um
% BPMS:UNDH:2890 -19.4 -29.8 um  -32.7 -76.1 um
% BPMS:UNDH:2990 -17.3 -26.6 um  -29.7 -69.0 um
% BPMS:UNDH:3090 -7.6 -11.7 um  -38.8 -90.0 um
% BPMS:UNDH:3190 -1.3 -2.0 um  -31.4 -73.0 um
% BPMS:UNDH:3290 5.8 9.0 um  -37.0 -85.9 um
% BPMS:UNDH:3390 15.0 23.1 um  -26.8 -62.3 um
% BPMS:UNDH:3490 18.0 27.7 um  -27.8 -64.5 um
% BPMS:UNDH:3590 28.0 43.0 um  -16.8 -39.1 um
% BPMS:UNDH:3690 26.1 40.1 um  -13.0 -30.2 um
% BPMS:UNDH:3790 34.6 53.2 um  -3.5 -8.0 um
% BPMS:UNDH:3890 28.3 43.5 um  4.4 10.2 um
% BPMS:UNDH:3990 33.4 51.3 um  10.6 24.7 um
% BPMS:UNDH:4090 24.1 37.0 um  20.9 48.6 um
% BPMS:UNDH:4190 24.7 37.9 um  22.6 52.4 um
% BPMS:UNDH:4290 14.5 22.2 um  33.2 77.2 um
% BPMS:UNDH:4390 10.4 15.9 um  30.0 69.6 um
% BPMS:UNDH:4490 1.6 2.4 um  38.9 90.3 um
% BPMS:UNDH:4590 -6.3 -9.7 um  31.3 72.8 um
% BPMS:UNDH:4690 -11.7 -18.0 um  36.5 84.8 um
% BPMS:UNDH:5190 -68.1 -104.6 um  -38.4 -89.3 um

