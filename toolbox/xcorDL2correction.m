function xbpmOffset = xcorDL2correction(beamline, xcor_kGm, bendEnergyGeV )
%
% xbpmOffset = xcorDL2correction(xcor_kGm, bendEnergyGeV)
%
% If no arguments are present, this function returns the horizontal orbit
% [mm] at BPMS:LTUH:450 ('HXR') due to horizontal correctores between DL2
% bpms which affects the calculation of the energy deviation.
%
% If exactly one argument is given it must be either 'HXR' or 'SXR', and
% the horizontal orbit correction will apply to the selected beamline.
%
% If three arguments are given it uses xcor_kGm = 1x4 vector of xcor
% strengths, and bendEnergyGeV

% Get R12s
if nargin==0
    beamline = 'HXR';
end

if strcmp(beamline,'HXR')
    xcorPV = {
        'XCOR:LTUH:288'
        'XCOR:LTUH:348'
        'XCOR:LTUH:388'
        'XCOR:LTUH:448'};
    bpmPV = 'BPMS:LTUH:450';
end
if strcmp(beamline,'SXR')
    xcorPV = {
        'XCOR:LTUS:228'
        'XCOR:LTUS:296'
        'XCOR:LTUS:368'
        'XCOR:LTUS:448'};
    bpmPV = 'BPMS:LTUS:370';% design dispersion_x = 0.425 m.
end

% % Aida Method
% aidainit;
% for q=1:length(xcorPV)
%     R        = aidaget({[xcorPV{q} '//R']},'doublea',{['B=' bpmPV]});
%     Rm       = reshape(R,6,6);
%     Rm = cell2mat(Rm)';
%     R12(q) = Rm(1,2);
% end
% R12 = R12';

% % Loos method: takes about 0.3 seconds
model_init('source', 'MATLAB', 'online', 0); % for globals, 0 for matlab
if strcmp(beamline,'HXR')
    R  = model_rMatGet (xcorPV, bpmPV, {'TYPE=EXTANT','BEAMPATH=CU_HXR'},[]);
end
if strcmp(beamline,'SXR')
    R  = model_rMatGet (xcorPV, bpmPV, {'TYPE=EXTANT','BEAMPATH=CU_SXR'},[]);
end
R12 = squeeze(R(1,2,:));


% Get corrector strengths
xcorPVbact = strcat(xcorPV,':BACT');
kGm = lcaGet(xcorPVbact);

switch nargin
    case 0 % no arguments, default to HXR current value
        bendEnergyGeV = lcaGetSmart('BEND:DMPH:400:BDES'); %use dump bend power supply
    case 1 % specifiy beamline, get current values
        if strcmp(beamline,'HXR')
            bendEnergyGeV = lcaGetSmart('BEND:DMPH:400:BDES'); %use dump bend power supply
            
        else
            bendEnergyGeV = lcaGetSmart('BEND:DMPS:400:BDES'); %use dump bend power supply
        end
end % if 2 or 3 arguments are given use the supplied bend energy

if nargin>1
    kGm = xcor_kGm(:); % use the supplied values
end

% Correction to calculated R12 1/25/11 based on R12 measurements.
kGm = 0.75*kGm; % Implemented 1/31/11

theta = 0.3 *0.1*kGm/bendEnergyGeV; % approximate radians of each corrector kick

% Calculate net betatron orbit at last bpm due to all correctors
xArray = R12.*theta;
xbpmOffset = 1000*sum(xArray); % put in mm
