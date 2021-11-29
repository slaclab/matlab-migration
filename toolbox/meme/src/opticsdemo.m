%% OPTICSDEMO demonstrates the use of MEME to get accelerator model data.

% OPTICSDEMO contains demos of the following utilities:
%
% twissGet           Gets Model Optics twiss parameters data
% rmatGet            Gets Model Optics R-mat data
% names              Gets names of Pvs
% rdbGet             Gets model for the whole accelerator, using MEME
%                    method for getting data from Oracle.

%% Twiss of single element

% Get Twiss of a single element:
twiss = twissGet( 'QUAD:LTU1:880:TWISS' )

% What arguments does it support?
help twissGet

% In summary the arguments are as follows.
% Both rmatGet and twissGet support the following arguments:
%   pos = {beg,mid,end} default is end
%   type = {extant, design} default is extant
%   mode = <timing mode> default is 5 (the main 13.5 GeV timing mode)
%   runid = <integer run id>|gold default is gold
%
% rmatGet additionally supports these arguments:
%   b     = name of device to which to calculate transfer matrix (A -> B)
%   posb  = to where in b, if b is given. 

% What are twiss at the middle position of the quad:
twiss = twissGet( 'QUAD:LTU1:880:TWISS','pos','mid' )

% Compare its twiss now to its design twiss, at the middle (as opposed to
% end, which is the default)
twissdes = twissGet( 'QUAD:LTU1:880:TWISS','pos','mid',...
    'type','design' )


%% R-matrix of a single element
rmatGet( 'QUAD:LTU1:880:RMAT' )

% Again all args are suppored. 
% Get the R-matrix at the beginig of the quad, 
% under the 13 GeV timing mode (5) 
%
rmatGet( 'QUAD:LTU1:880:RMAT','mode','5','pos','beg' )

%% Model "timing" modes

% Aside: What is this model mode 5? Ask the model database about
% model modes
lines=rdbGet('MODEL:MODES')

% lines = 
% 
%     labels: {3x1 cell}
%      value: [1x1 struct]

% Using Matlab 2013a and above, that knows tables:

% struct2table(lines.value)
% 
% ans = 
% 
%     mode    line             model_line_name         
%     ____    ____    _________________________________
% 
%      5      1       'Full Machine'                   
%     51      2       'Cathode to Gun Spectrometer'    
%     52      3       'Cathode to 135 MeV Spectrometer'
%     53      4       'Cathode to 52SL2'   

%% Model of whole beampaths

% Get all Twiss of every element 
extant_twiss=rdbGet('MODEL:TWISS:EXTANT:FULLMACHINE');
extant_twiss.value

% ans = 
% 
%                       ordinal: [2543x1 double]
%                  element_name: [2543x1 java.lang.String[]]
%     epics_channel_access_name: [2543x1 java.lang.String[]]
%                    z_position: [2543x1 double]
%                position_index: [2543x1 java.lang.String[]]
%                          leff: [2543x1 double]
%                  total_energy: [2543x1 double]
%                         psi_x: [2543x1 double]
%                        beta_x: [2543x1 double]
%                       alpha_x: [2543x1 double]
%                         eta_x: [2543x1 double]
%                        etap_x: [2543x1 double]
%                         psi_y: [2543x1 double]
%                        beta_y: [2543x1 double]
%                       alpha_y: [2543x1 double]
%                         eta_y: [2543x1 double]
%                        etap_y: [2543x1 double]

% So what are the betas?
extant_twiss.value.beta_x


%% Device and PV Names

% What are the X correctors in the Gun Spectrometer line. To get
% that, I have to know that the Gun Spectrometer line is MAD line
% named "LINE24". Then I ask the directory service:

names('XCOR:%','tag','LIN24','show','dname')

% ans = 
% 
%     'XCOR:IN20:121'
%     'XCOR:IN20:221'
%     'XCOR:IN20:311'
%     'XCOR:IN20:341'
%     'XCOR:IN20:381'
%     'XCOR:IN20:411'
%     'XCOR:IN20:491'
%     'XCOR:IN20:521'
%     'XCOR:IN20:641'
%     'XCOR:IN20:911'
%     'XCOR:IN20:951'

%% R from A to B! 

% Corrctor to BPM. Basis of feedback, bumps, steering etc ...
rmatGet( 'XCOR:IN20:221:RMAT','b','BPMS:UND1:3190','mode','5')

% Quad to wire. Basis of wire scan, emittance scan etc ...
rmatGet( 'QUAD:LTU1:440:RMAT','b','WIRE:LTU1:775','mode','5','pos','mid')


%%  Lattice information (elem names, devices, Z etc)
elementtable=rdbGet('LCLS:ELEMENTINFO');
elementtable.value

% ans = 
% 
%               element: [1270x1 java.lang.String[]]
%          element_type: [1270x1 java.lang.String[]]
%     epics_device_name: [1270x1 java.lang.String[]]
%             s_display: [1270x1 double]
%           obstruction: [1270x1 java.lang.String[]]

% S (Z) positions of model elements and their devices
elementtable.value.epics_device_name
elementtable.value.linacz_m
elementtable.value.element


%% Plot extant and design betas
%
% A nice way to get bigger plot
figure('Position', [300,200,750,550]);
set(gcf,'Color',[1 1 1]);
clf

% Get and plot twiss parameters of all elements as they are right now in machine
extant_twiss=rdbGet('MODEL:TWISS:EXTANT:FULLMACHINE');
plot(extant_twiss.value.z_position, extant_twiss.value.beta_x);
hold on
plot(extant_twiss.value.z_position, extant_twiss.value.beta_y,'m');

% Get design Twiss and compare by plot
design_twiss=rdbGet('MODEL:TWISS:DESIGN:FULLMACHINE');
plot(design_twiss.value.z_position,design_twiss.value.beta_x,'--');
plot(design_twiss.value.z_position,design_twiss.value.beta_y,'m--');

% Add labels
legend('Extant \beta_x','Extant \beta_y','Design \beta_x','Design \beta_y');
xlabel('Z (m)'); ylabel( 'Beta (m)'); title('Extant and Design Betas now in LCLS');
