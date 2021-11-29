function fbWriteConfigFile()
% ---- write the configuration file in XML format

%get the configuration data
config = getappdata(0,'Config_structure');

% create a new dom object
docNode = com.mathworks.xml.XMLUtils.createDocument(config.feedbackName);
docRootNode = docNode.getDocumentElement;
% add some comments
docRootNode.appendChild(docNode.createComment(...
    'this is the configuration file for the Injector_Launch feedback system'));
% add the feedback name
thisElement = docNode.createElement('feedback_system');
thisElement.setAttribute('name', config.feedbackName);
thisElement.setAttribute('acro', config.feedbackAcro);
thisElement.setAttribute('num', config.feedbackNum);
thisElement.appendChild(docNode.createComment('the feedback system name'));
docRootNode.appendChild(thisElement);
% add the filename
thisElement = docNode.createElement('config_file');
thisElement.setAttribute('name', config.filename);
thisElement.appendChild(docNode.createComment('this configuration file name'));
docRootNode.appendChild(thisElement);
% add the reference (gold) orbit filename
if strcmp(config.reforbitName, '0') ~= 1 
    thisElement = docNode.createElement('ref_orbit_file');
    thisElement.setAttribute('name', config.reforbitName);
    thisElement.appendChild(docNode.createComment('the reference orbit file name'));
    docRootNode.appendChild(thisElement);
end
% add the initloopfucntion name
thisElement = docNode.createElement('initloop_function');
thisElement.setAttribute('name', config.initloopfcnName);
thisElement.appendChild(docNode.createComment('the initloop function name'));
docRootNode.appendChild(thisElement);
% add the timerfucntion name
thisElement = docNode.createElement('timer_function');
thisElement.setAttribute('name', config.timer.fcnName);
thisElement.appendChild(docNode.createComment('the timer function name'));
docRootNode.appendChild(thisElement);
% add the timer period
thisElement = docNode.createElement('timer_period');
thisElement.setAttribute('seconds', num2str(config.timer.period) );
thisElement.appendChild(docNode.createComment('the timer period (can be any value > 0.001)'));
docRootNode.appendChild(thisElement);
% add the time max iteration count
thisElement = docNode.createElement(num2str('timer_iterations'));
thisElement.setAttribute('count', num2str(config.timer.max));
thisElement.appendChild(docNode.createComment('the timer iteration count (Inf = forever)'));
docRootNode.appendChild(thisElement);

if ~strcmp(config.matrix.fFcnName, '0' )
    % add the f matrix fucntion name
    thisElement = docNode.createElement('matrixF_function');
    thisElement.setAttribute('name', config.matrix.fFcnName);
    thisElement.appendChild(docNode.createComment('the F matrix calculation function'));
    docRootNode.appendChild(thisElement);
end

% store the F matrix values
test=any(config.matrix.f);
if any(test)
    node = docNode.createElement('FMatrix');
    docRootNode.appendChild(node);
    node.appendChild(docNode.createComment('edit the following F Matrix values as necessary'));
    [r,c] = size(config.matrix.f);
    for i=1:r
        thisElement = docNode.createElement(['row' num2str(i)]);
        for j=1:c
            thisElement.setAttribute(['F' num2str(i) num2str(j)], num2str(config.matrix.f(i,j) ));
        end
        node.appendChild(thisElement);
    end
end

if ~strcmp(config.matrix.gFcnName,'0' )
    % add the g matrix fucntion name
    thisElement = docNode.createElement('matrixG_function');
    thisElement.setAttribute('name', config.matrix.gFcnName);
    thisElement.appendChild(docNode.createComment('the G matrix calculation function'));
    docRootNode.appendChild(thisElement);
end
    
% store the G matrix values
test=any(config.matrix.g);
if any(test)
    node = docNode.createElement('GMatrix');
    docRootNode.appendChild(node);
    node.appendChild(docNode.createComment('edit the following G Matrix values as necessary'));
    [r, c] = size(config.matrix.g);
    for i=1:r
        thisElement = docNode.createElement(['row' num2str(i)]);
        for j=1:c
            thisElement.setAttribute(['G' num2str(i) num2str(j)], num2str(config.matrix.g(i,j)) );
        end
        node.appendChild(thisElement);
    end
end

% store the matrix params, if they exist 
if strcmpi(config.matrix.params.visible, 'on')
    thisElement = docNode.createElement('matrixParams');
    thisElement.appendChild(docNode.createComment('edit the following parameters values as necessary'));
    docRootNode.appendChild(thisElement);
    thisElement = docNode.createElement('scalarParams');
    thisElement.setAttribute('N', num2str(config.matrix.params.N ));
    thisElement.setAttribute('Sz0', num2str(config.matrix.params.Sz0));
    thisElement.setAttribute('Sd0', num2str(config.matrix.params.Sd0));
    thisElement.setAttribute('Eg', num2str(config.matrix.params.Eg));
    docRootNode.appendChild(thisElement);
    thisElement = docNode.createElement('Ev');
    for j=1:length(config.matrix.params.Ev)
        thisElement.setAttribute(['E1' num2str(j)], num2str(config.matrix.params.Ev(1,j) ));
    end
    docRootNode.appendChild(thisElement);
    thisElement = docNode.createElement('R56v');
    for j=1:length(config.matrix.params.R56v)
        thisElement.setAttribute(['R1' num2str(j)], num2str(config.matrix.params.R56v(1,j) ));
    end
    docRootNode.appendChild(thisElement);
    thisElement = docNode.createElement('T566v');
    for j=1:length(config.matrix.params.T566v)
        thisElement.setAttribute(['T1' num2str(j)], num2str(config.matrix.params.T566v(1,j) ));
    end
    docRootNode.appendChild(thisElement);
    thisElement = docNode.createElement('phiv');
    for j=1:length(config.matrix.params.phiv)
        thisElement.setAttribute(['p1' num2str(j)], num2str(config.matrix.params.phiv(1,j) ));
    end
    docRootNode.appendChild(thisElement);
end

% store the state setpoints, 
node = docNode.createElement('allstateSPs');
docRootNode.appendChild(node);
node.appendChild(docNode.createComment('edit the following State Setpoint values as necessary'));
for i=1:length(config.states.SPs)
    thisElement = docNode.createElement('stateSP');
    thisElement.setAttribute('name', config.states.names(i) );
    node.appendChild(thisElement);
end

% now add all possible state storage PVs for this feedback system
node = docNode.createElement('allstatePVs');
docRootNode.appendChild(node);
node.appendChild(docNode.createComment('state storage PVs must correspond to states in the same order'));
for i=1:length(config.states.allstatePVs)
    thisElement = docNode.createElement('statePV');
    thisElement.setAttribute('name', config.states.allstatePVs(i));
    node.appendChild(thisElement);
end

% now add all possible state setpoint storage PVs for this feedback system
node = docNode.createElement('allspPVs');
docRootNode.appendChild(node);
node.appendChild(docNode.createComment('state setpoint storage PVs must correspond to states in the same order'));
for i=1:length(config.states.allspPVs)
    thisElement = docNode.createElement('spPV');
    thisElement.setAttribute('name', config.states.allspPVs(i));
    node.appendChild(thisElement);
end

% add the state PV name
thisElement = docNode.createElement('fbck_state_PV');
thisElement.setAttribute('name', char(config.states.statePV));
thisElement.appendChild(docNode.createComment('name of overall ON/OFF state PV'));
docRootNode.appendChild(thisElement);
% add the proportional gain value
thisElement = docNode.createElement('proportional_gain');
thisElement.setAttribute('value', num2str(config.states.pGain));
thisElement.appendChild(docNode.createComment('value of proportional gain'));
docRootNode.appendChild(thisElement);
% add the integral gain value
thisElement = docNode.createElement('integral_gain');
thisElement.setAttribute('value', num2str(config.states.iGain));
thisElement.appendChild(docNode.createComment('value of integral gain'));
docRootNode.appendChild(thisElement);
% add the max errdata value
thisElement = docNode.createElement('err_data_buffer');
thisElement.setAttribute('size', num2str(config.states.maxerrs));
thisElement.appendChild(docNode.createComment('size of error data buffer for integral gain calc.'));
docRootNode.appendChild(thisElement);

% now add all possible control PVs for this feedback system
node = docNode.createElement('allctrlPVs');
docRootNode.appendChild(node);
node.appendChild(docNode.createComment('control PVs must correspond to actuator PVs in the same order'));
for i=1:length(config.ctrl.allctrlPVs)
    thisElement = docNode.createElement('ctrlPV');
    thisElement.setAttribute('name', config.ctrl.allctrlPVs(i));
    node.appendChild(thisElement);
end

% now add all possible actuator PVs for this feedback system
node = docNode.createElement('allactPVs');
docRootNode.appendChild(node);
node.appendChild(docNode.createComment('edit the following list of actuator PVs as necessary'));
for i=1:length(config.act.allactPVs)
    thisElement = docNode.createElement('actPV');
    thisElement.setAttribute('name', config.act.allactPVs(i));
%    thisElement.setAttribute('energy', num2str(config.act.energy(i)));
    node.appendChild(thisElement);
end

% now add all possible actuator readback PVs for this feedback system
node = docNode.createElement('allrbPVs');
docRootNode.appendChild(node);
node.appendChild(docNode.createComment('readback PVs must correspond to actuator PVs in the same order'));
for i=1:length(config.act.allrbPVs)
    thisElement = docNode.createElement('rbPV');
    thisElement.setAttribute('name', config.act.allrbPVs(i));
    node.appendChild(thisElement);
end

% now add all possible actuator storage PVs for this feedback system
node = docNode.createElement('allactStorePVs');
docRootNode.appendChild(node);
node.appendChild(docNode.createComment('actuator storage PVs must correspond to actuator PVs in the same order'));
for i=1:length(config.act.allstorePVs)
    thisElement = docNode.createElement('storePV');
    thisElement.setAttribute('name', config.act.allstorePVs(i));
    node.appendChild(thisElement);
end

% now add all possible measurement PVs for this feedback system
node = docNode.createElement('allmeasPVs');
docRootNode.appendChild(node);
node.appendChild(docNode.createComment('edit the following list of measurement PVs as necessary'));
for i=1:length(config.meas.allmeasPVs)
    thisElement = docNode.createElement('measPV');
    thisElement.setAttribute('name', config.meas.allmeasPVs(i));
    node.appendChild(thisElement);
end

% now add all possible res PVs for this feedback system
node = docNode.createElement('allresPVs');
docRootNode.appendChild(node);
node.appendChild(docNode.createComment('resolution PVs must correspond to measurement PVs in the same order'));
for i=1:length(config.meas.allresPVs)
    thisElement = docNode.createElement('resPV');
    thisElement.setAttribute('name', config.meas.allresPVs(i));
    node.appendChild(thisElement);
end

% now add all possible meas storage PVs for this feedback system
node = docNode.createElement('allmeasStorePVs');
docRootNode.appendChild(node);
node.appendChild(docNode.createComment('measurement storage PVs must correspond to measurement PVs in the same order'));
for i=1:length(config.meas.allstorePVs)
    thisElement = docNode.createElement('storePV');
    thisElement.setAttribute('name', config.meas.allstorePVs(i));
    node.appendChild(thisElement);
end


% change to the $MATLABDATAFILES path to write the file
file = sprintf ('%s/Feedback/%s', getenv('MATLABDATAFILES'), config.filename );
% Save the  XML configuration document.
xmlwrite(file,docNode);
