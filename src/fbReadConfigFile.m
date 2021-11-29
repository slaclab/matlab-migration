function newconfig = fbReadConfigFile(filename)
%--- creat the initial config structure, then read the config file
%--- and fill the configuration structure 
% filename   the config file name
% newconfig  the configuration structure

    
%  create initial structure 
if length(filename)>=1
    config.filename = filename;
else
    config.filename = 'config.xml';
end
config.feedbackName = 'Injector_Launch';
config.feedbackAcro = 'INL';
config.feedbackNum = '0';
config.initloopfcnName = 'initLoopStructure';
config.maxerrs = 100;
config.reforbitName = '0';
config.states.PVs = [];
config.states.names = [];
config.states.chosennames = [];
config.states.SPs = [];
config.states.limits = [];
config.states.num = 0;
config.states.allstatePVs = [];
config.states.chosenstatePVs = [];
config.states.allspPVs = [];
config.states.chosenspPVs = [];
config.states.allspmnPVs = [];
config.states.allspstdPVs = [];
config.states.pGain = 0;
config.states.iGain = 0;
config.states.statePV = 'STATE';
config.ctrl.allctrlPVs = [];
config.ctrl.PVs = [];
config.act.allactPVs = [];
config.act.PVs = [];
config.act.chosenactPVs = [];
config.act.limits = [];
config.act.energy = [];
config.act.allrbPVs = [];
config.act.allstorePVs = [];
config.act.chosenstorePVs = [];
config.meas.allmeasPVs = [];
config.meas.allresPVs = [];
config.meas.PVs = [];
config.meas.chosenmeasPVs = [];
config.meas.allstorePVs = [];
config.meas.chosenstorePVs = [];
config.meas.limits = [];
config.meas.dispersion = [];
config.check.chkPVs = [];
config.check.limit = 1e9;
config.timer.fcnName = 'fbckTimerFcn';
config.timer.period = 1.0;
config.timer.max =inf;
config.matrix.fFcnName = '0';
config.matrix.f = [];
config.matrix.gFcnName = '0';
config.matrix.g = [];
config.matrix.params.N = 6.25E9;   %these are 8 params for high energy 
config.matrix.params.Sz0 = 0.831;  %longitudinal matrix calculation
config.matrix.params.Sd0 = 0.05;
config.matrix.params.Eg = 0.006; 
config.matrix.params.Ev = [0.135 0.268 0.250 4.54 14.1];
R56v = [0.0063 0 -0.0390 -0.0247 0.00013];
config.matrix.params.R56v = R56v;
config.matrix.params.T566v= [0.1400 0 -1.5*R56v(3) -1.5*R56v(4) 0.0063];
config.matrix.params.phiv = [-1.4 -25.0 -160 -40.8 -10.];
%initialize to OFF, it will be set to on if there are params in the config
%file
config.matrix.params.visible = 'off';
config.configchanged = 0;

try
   % now parse the file
    file = sprintf ('%s/Feedback/%s', getenv('MATLABDATAFILES'), config.filename); 
   xDoc = xmlread(file);
catch
   dbstack;
   err = lasterror;
   errordlg(err.message);
   rethrow(lasterror);
end

% get the feedback loop name
nodeList = xDoc.getElementsByTagName('feedback_system');
child = nodeList.item(0);
config.feedbackName = char(child.getAttribute('name'));
config.feedbackAcro = char(child.getAttribute('acro'));
config.feedbackNum = char(child.getAttribute('num'));

% get the configuration file name
nodeList = xDoc.getElementsByTagName('config_file');
child = nodeList.item(0);
config.filename = char(child.getAttribute('name'));

% get the reference orbit file name
nodeList = xDoc.getElementsByTagName('ref_orbit_file');
if (nodeList.getLength()>0)
    child = nodeList.item(0);
    config.reforbitName = char(child.getAttribute('name'));
else
    config.reforbitName = '0';
end

% get the initloop function name
nodeList = xDoc.getElementsByTagName('initloop_function');
child = nodeList.item(0);
config.initloopfcnName = char(child.getAttribute('name'));

% get the timer function name
nodeList = xDoc.getElementsByTagName('timer_function');
child = nodeList.item(0);
config.timer.fcnName = char(child.getAttribute('name'));

% get the timer period in seconds
nodeList = xDoc.getElementsByTagName('timer_period');
child = nodeList.item(0);
config.timer.period = str2num(child.getAttribute('seconds'));

% get the timer iteration count
nodeList = xDoc.getElementsByTagName('timer_iterations');
child = nodeList.item(0);
config.timer.max = str2num(child.getAttribute('count'));

%create the timer
config.fbckTimer = timer; %create the timer

% get the f matrix function name
nodeList = xDoc.getElementsByTagName('matrixF_function');
if (nodeList.getLength()>0)
    child = nodeList.item(0);
    config.matrix.fFcnName = char(child.getAttribute('name'));
else
    config.matrix.fFcnName = '0';
end

% get the F matrix values
nodes = xDoc.getElementsByTagName('FMatrix');
% there is only one node, get it's children and store matrix info
if (nodes.getLength()>0)
    node = nodes.item(0);
    childNode = node.getFirstChild;
    i=0;
    while ~isempty(childNode)
        %Filter out text, comments, and processing instructions.
        if childNode.getNodeType == childNode.ELEMENT_NODE
            i = i+1;
            j=0;
            n_atts = childNode.getAttributes().getLength();
            while j<n_atts
                j=j+1;
                config.matrix.f(i,j) = str2num(childNode.getAttribute(['F' num2str(i) num2str(j)]));
            end
        end  % End IF
        childNode = childNode.getNextSibling;
    end %end WHILE
else
    config.matrix.f = [];
end  % End IF

% get the G matrix function name
nodeList = xDoc.getElementsByTagName('matrixG_function');
if (nodeList.getLength()>0)
    child = nodeList.item(0);
    config.matrix.gFcnName = char(child.getAttribute('name'));
else
    config.matrix.gFcnName = '0';
end

% get the G matrix values
nodes = xDoc.getElementsByTagName('GMatrix');
% there is only one node, get it's children and store matrix info
if (nodes.getLength()>0)
    node = nodes.item(0);
    childNode = node.getFirstChild;
    i=0;
    while ~isempty(childNode)
        %Filter out text, comments, and processing instructions.
        if childNode.getNodeType == childNode.ELEMENT_NODE
            i = i+1;
            j=0;
            n_atts = childNode.getAttributes().getLength();
            while j<n_atts
                j=j+1;
                config.matrix.g(i,j) = str2num(childNode.getAttribute(['G' num2str(i) num2str(j)]));
            end
        end  % End IF
        childNode = childNode.getNextSibling;
    end % end WHILE
else
    config.matrix.g = [];
end  % End if

% get the matrix parameters, if they exist in the file
nodes = xDoc.getElementsByTagName('matrixParams');
if (nodes.getLength()>0)
    config.matrix.params.visible = 'on';
    % get the scalar params
    nodeList = xDoc.getElementsByTagName('scalarParams');
    child = nodeList.item(0);
    config.matrix.params.N = str2num(child.getAttribute('N'));
    config.matrix.params.Sz0 = str2num(child.getAttribute('Sz0'));
    config.matrix.params.Sd0 = str2num(child.getAttribute('Sd0'));
    config.matrix.params.Eg = str2num(child.getAttribute('Eg'));
    nodes = xDoc.getElementsByTagName('Ev');
    childNode = nodes.item(0);
    n_atts = childNode.getAttributes().getLength();
    for i=1:n_atts
        config.matrix.params.Ev(1,i) = str2num(childNode.getAttribute(['E1' num2str(i)]));
    end
    nodes = xDoc.getElementsByTagName('R56v');
    childNode = nodes.item(0);
    n_atts = childNode.getAttributes().getLength();
    for i=1:n_atts
        config.matrix.params.R56v(1,i) = str2num(childNode.getAttribute(['R1' num2str(i)]));
    end
    nodes = xDoc.getElementsByTagName('T566v');
    childNode = nodes.item(0);
    n_atts = childNode.getAttributes().getLength();
    for i=1:n_atts
        config.matrix.params.T566v(1,i) = str2num(childNode.getAttribute(['T1' num2str(i)]));
    end
    nodes = xDoc.getElementsByTagName('phiv');
    childNode = nodes.item(0);
    n_atts = childNode.getAttributes().getLength();
    for i=1:n_atts
        config.matrix.params.phiv(1,i) = str2num(childNode.getAttribute(['p1' num2str(i)]));
    end
else
    config.matrix.params.visible = 'off';
end

% get all state related PVs 
nodes = xDoc.getElementsByTagName('allstateSPs');
if (nodes.getLength()>0)
   % there is only one node, get it's children and store PV info
   node = nodes.item(0);
   childNode = node.getFirstChild;
   i=0;
   while ~isempty(childNode)
      %Filter out text, comments, and processing instructions.
      if childNode.getNodeType == childNode.ELEMENT_NODE
         i = i+1;
         config.states.names{i,1} = char(childNode.getAttribute('name'));
      end  % End IF
      childNode = childNode.getNextSibling;
   end  % End WHILE
   config.states.num = i;

   % get all state storage PV elements.
   nodes = xDoc.getElementsByTagName('allstatePVs');
   % there is only one node, get it's children and store PV info
   node = nodes.item(0);
   childNode = node.getFirstChild;
   i=0;
   while ~isempty(childNode)
      %Filter out text, comments, and processing instructions.
      if childNode.getNodeType == childNode.ELEMENT_NODE
         i = i+1;
         config.states.allstatePVs{i,1} = char(childNode.getAttribute('name'));
      end  % End IF
      childNode = childNode.getNextSibling;
   end  % End WHILE

   % get all state stepoint storage PV elements.
   nodes = xDoc.getElementsByTagName('allspPVs');
   % there is only one node, get it's children and store PV info
   node = nodes.item(0);
   childNode = node.getFirstChild;
   i=0;
   while ~isempty(childNode)
      %Filter out text, comments, and processing instructions.
      if childNode.getNodeType == childNode.ELEMENT_NODE
         i = i+1;
         config.states.allspPVs{i,1} = char(childNode.getAttribute('name'));
      end  % End IF
      childNode = childNode.getNextSibling;
   end  % End WHILE
   % get the proportional gain value
   nodeList = xDoc.getElementsByTagName('proportional_gain');
   child = nodeList.item(0);
   config.states.pGain = str2num(child.getAttribute('value'));

   % get the integral gain value
   nodeList = xDoc.getElementsByTagName('integral_gain');
   child = nodeList.item(0);
   config.states.iGain = str2num(child.getAttribute('value'));

   % get the size of the intregral gain err summation matrix
   nodeList = xDoc.getElementsByTagName('err_data_buffer');
   child = nodeList.item(0);
   config.states.maxerrs = str2num(child.getAttribute('size'));
end % states

% get the state PV (on off for this feedback)
nodeList = xDoc.getElementsByTagName('fbck_state_PV');
child = nodeList.item(0);
config.states.statePV = char(child.getAttribute('name'));


% get all actPV elements.
nodes = xDoc.getElementsByTagName('allactPVs');
if (nodes.getLength()>0)
   % there is only one node, get it's children and store PV info
   node = nodes.item(0);
   childNode = node.getFirstChild;
   i=0;
   while ~isempty(childNode)
      %Filter out text, comments, and processing instructions.
      if childNode.getNodeType == childNode.ELEMENT_NODE
         i = i+1;
         config.act.allactPVs{i,1} = char(childNode.getAttribute('name'));
%        config.act.energy(i,1) = str2num(childNode.getAttribute('energy'));
      end  % End IF
      childNode = childNode.getNextSibling;
   end  % End WHILE

   % get all rbPV elements.
   nodes = xDoc.getElementsByTagName('allrbPVs');
   % there is only one node, get it's children and store PV info
   node = nodes.item(0);
   childNode = node.getFirstChild;
   i=0;
   while ~isempty(childNode)
      %Filter out text, comments, and processing instructions.
      if childNode.getNodeType == childNode.ELEMENT_NODE
         i = i+1;
         config.act.allrbPVs{i,1} = char(childNode.getAttribute('name'));
      end  % End IF
      childNode = childNode.getNextSibling;
   end  % End WHILE

   % get all actuator Storage PV elements.
   nodes = xDoc.getElementsByTagName('allactStorePVs');
   % there is only one node, get it's children and store PV info
   node = nodes.item(0);
   childNode = node.getFirstChild;
   i=0;
   while ~isempty(childNode)
      %Filter out text, comments, and processing instructions.
      if childNode.getNodeType == childNode.ELEMENT_NODE
         i = i+1;
         config.act.allstorePVs{i,1} = char(childNode.getAttribute('name'));
      end  % End IF
      childNode = childNode.getNextSibling;
   end  % End WHILE

   % get all ctrlPV elements.
   nodes = xDoc.getElementsByTagName('allctrlPVs');
   if (nodes.getLength()>0)
      % there is only one node, get it's children and store PV info
      node = nodes.item(0);
      childNode = node.getFirstChild;
      i=0;
      while ~isempty(childNode)
         %Filter out text, comments, and processing instructions.
         if childNode.getNodeType == childNode.ELEMENT_NODE
            i = i+1;
            config.ctrl.allctrlPVs{i,1} = char(childNode.getAttribute('name'));
         end  % End IF
         childNode = childNode.getNextSibling;
      end  % End WHILE
   end % end ctrlPV list
end % all actuator info

% get all meas related PVs.
nodes = xDoc.getElementsByTagName('allmeasPVs');
if (nodes.getLength()>0)
   % there is only one node, get it's children and store PV info
   node = nodes.item(0);
   childNode = node.getFirstChild;
   i=0;
   while ~isempty(childNode)
      %Filter out text, comments, and processing instructions.
      if childNode.getNodeType == childNode.ELEMENT_NODE
         i = i+1;
         config.meas.allmeasPVs{i,1} = char(childNode.getAttribute('name'));
         config.meas.dispersion(i,1) = 1;
      end  % End IF
      childNode = childNode.getNextSibling;
   end  % End WHILE

   % get all resPV elements.
   nodes = xDoc.getElementsByTagName('allresPVs');
   % there is only one node, get it's children and store PV info
   node = nodes.item(0);
   childNode = node.getFirstChild;
   i=0;
   while ~isempty(childNode)
      %Filter out text, comments, and processing instructions.
      if childNode.getNodeType == childNode.ELEMENT_NODE
         i = i+1;
         config.meas.allresPVs{i,1} = char(childNode.getAttribute('name'));
      end  % End IF
      childNode = childNode.getNextSibling;
   end  % End WHILE

   % get all meas storage PV elements.
   nodes = xDoc.getElementsByTagName('allmeasStorePVs');
   % there is only one node, get it's children and store PV info
   node = nodes.item(0);
   childNode = node.getFirstChild;
   i=0;
   while ~isempty(childNode)
      %Filter out text, comments, and processing instructions.
      if childNode.getNodeType == childNode.ELEMENT_NODE
         i = i+1;
         config.meas.allstorePVs{i,1} = char(childNode.getAttribute('name'));
      end  % End IF
      childNode = childNode.getNextSibling;
   end  % End WHILE
end % measurment PVs

% change to the $MATLABDATAFILES path to read the file
%if usejava('desktop')
%else
%   try
%      cd (sprintf ('%s/Feedback/', getenv('MATLABDATAFILES') ) );
%   catch
%   end
%end
%if there is a reference orbit file specified, load that file
%the refData.data matrix is #data points(rows) x #all meas devices(cols)
% in this case, do not calc new act tolerances, that should have been done
% at the time the ref orbit was initially loaded
config.refInit = 0;
if strcmp(config.reforbitName, '0') ~= 1
   try
    file = sprintf ('%s/Feedback/data/%s%s/%s', ...
         getenv('MATLABDATAFILES'), config.feedbackAcro, config.feedbackNum, config.reforbitName); 
    load(file);
    if exist('refData', 'var')
      config.refData = refData;
      config.refInit = 1;
    end
   catch
   fbDispMsg('No Ref.Orbit, using zeros', config.feedbackAcro, 2);
   end
    
end
if (config.refInit==0)
    %create and store ref orbit data structure
    %count is the number of data points that were averaged
    refData.count = 0;
    refData.data = zeros(length(config.meas.allmeasPVs),1);
    if ~isempty(config.act.allactPVs)
       refData.actvals = lcaGet(config.act.allactPVs);
    else
       refData.actvals = 0;
    end
    config.refData = refData;
    config.refInit = 0;
end

% save the new configuration for the next function calls
setappdata(0, 'Config_structure', config);
newconfig = config;


