function err=alignGap(cone,numStep,numPerPoint,timeout)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% purpose: procedure for aligning both jaws of the corrugated structure 
% by scanning the gap center. 
%
% 
% cone: struckt with two jaws
%   taperMMPV:    taperMinMax Positions
%   dechirper:
%     taper:
%     center:
%     gap:
%     period:
%     readPV:
%       taper:      rbv PV for taper of dechirper
%       center:     rbv PV for center position of gap
%       gap:        rbv PV for gap size
%       status:     PV to proofs motors status
%     writePV:
%       taper:      set PV for taper of dechirper
%       scan:       scan PV for center position of gap
%       move:       move motors to set motors in action
%       gap:        set PV for gap size
%     start:
%       val:        value of start position for scan
%     stop:
%       val:        value of stop position for scan
%   instruments:  
%      methoden:  
%        PV:     PV for scan
%        x:      x data
%        y:      y data
%        err:    error of y data points
%        finPos: final alignment position of method
%        fun:    used fit function
%        edge1:  for erf x-val of LD50 of one jaw
%        edge2:  for erf x-val of LD50 of the other jaw
%        center: calculated center gap position
%        fitPar: array of fitted parameters
%
%    numStep:       number of motor positions for the alignment procedure
%    numPerPoint:   number of taken data points per step
%    status:        status flag of gui
%       status.val == status.STOP stops calculation
%    timeout:       timeout for setting actuators
%
% output:
%     err:           empty if no failture, string if failture
%
%
% used procedures:
%     corrPlot_gui
%     util_erfFit
%     util_gaussFit 
%     util_meanNan    
%     util_stdNan 
%     filterCorrPlotDataSet
%
%
% Author:   J. Zemella DESY/SLAC
% created:  2015-07-07
%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% status.val == status.STOP

debugFlg=0; % debugFlg > 0 => debugFlg outputs; >1 => test data and debugFlg outputs
if debugFlg > 0
  fprintf('\n')
  fprintf('alignGap start\n')
end

err='';  % by default error flag is set to success

if 0
    err = 'Test Fehler';
    return
end

% ------------------------- setup for scan --------------------------------
dechirper=cone.dechirper;
% write PVs
moveMotorPV=dechirper.writePV.move;
scanPSPV=dechirper.writePV.scan;
centerPSPV=dechirper.writePV.centerUS;
taperPSPV=dechirper.writePV.gapDS;
gapUSPSPV=dechirper.writePV.gapUS;
% read back PVs
centerRBPV=dechirper.readPV.centerUS;
taperRBPV=dechirper.readPV.gapDS;
statusPV=dechirper.readPV.status;
% gapPSPV=dechirper.writePV.gap;
gapRBPV={dechirper.readPV.gapUS dechirper.readPV.gapUS};
startPos=cone.start.val;
stopPos=cone.stop.val;
tolnc=1.;
instr=cone.instrument;
detPVs={instr.methoden(:).PV};
edge1={instr.methoden(:).edge1};
edge2={instr.methoden(:).edge2};
lMeth=length(instr.methoden);
% combine defined jaw edges with fitting parameters. That's like the custom
% fit formulas are defined @(x,p,e1,e2)


% get initial positione and MinMax taper position

if strcmp(cone.taperMMPV{1}, 'DCHP:LTU1:555:N:DS_PR.HOPR') || strcmp(cone.taperMMPV{1}, 'DCHP:LTU1:545:T:DS_PR.HOPR')
  posMM = 2;
else
  posMM = -2;
end
% posMM = 0;

% posMM=sum(lcaGetSmart(cone.taperMMPV));
initCenterD = lcaGetSmart(dechirper.readPV.centerDS);
initCenterPos=lcaGetSmart(centerPSPV);
initGapPos=lcaGetSmart(gapUSPSPV);
status = cone.global_status;
% set  gap scanPV to actual gap size
errtmp=setActuator(scanPSPV,moveMotorPV,initCenterPos,centerRBPV,statusPV,tolnc,timeout,status,debugFlg);
err=check(err,errtmp,'alignGap: set gap scanPV to actual motor position failed');

% check
if isempty(strfind(cone.taperMMPV{1}, '545'))
  plane = 'V';
else
  plane = 'H';
end


% if ~(dchpValidateGapCoord(plane, initGapPos, startPos, initCenterD, posMM) && ...
%      dchpValidateGapCoord(plane, initGapPos, stopPos, initCenterD, posMM))
%   err = 'Settings are rejected';
%   return
% end


initTaperPos=lcaGetSmart(taperPSPV);
% -------------------------- set taper ------------------------------------
if isempty(err) % only done if no error
  %errtmp=setActuator(taperPSPV,moveMotorPV,posMM,taperRBPV,statusPV,tolnc,timeout,status,debugFlg);
  if posMM > 0
    lcaPutSmart(taperPSPV,posMM,'float');
%     lcaPutSmart(initCenterPos,initCenterPos,'float');
    lcaPutSmart(gapUSPSPV,initGapPos,'float');
    lcaPutSmart(taperPSPV,posMM,'float');
    pause(0.5);
    lcaPutSmart(moveMotorPV, 1, 'float');
  else
    lcaPutSmart(taperPSPV,posMM,'float');
%     lcaPutSmart(initCenterPos,initCenterPos,'float');
    lcaPutSmart(gapUSPSPV,initGapPos-posMM,'float');
    lcaPutSmart(taperPSPV,posMM,'float');
    pause(0.5);
    lcaPutSmart(moveMotorPV, 1, 'float');
  end  
  %err=check(err,errtmp,'alignGap: set trim motor to max failed');
  % debug statement
  if debugFlg > 0 && isempty(err); 
    fprintf('Set trim to trim max done\n')
  elseif debugFlg > 0
    fprintf('%s\n',err)
  end
end


% -------------- perform scan of center motor position --------------------
if isempty(err) % only done if no error
  [errtmp,data]=...
       doScan(scanPSPV,centerRBPV,detPVs,statusPV,startPos,stopPos,...
              numStep,numPerPoint,tolnc,timeout,status,debugFlg);
  err=check(err,errtmp,errtmp);
  % debug statement
  if debugFlg > 0 && isempty(err); 
    fprintf('doScan: trim max done\n')
  elseif debugFlg > 0
    fprintf('%s\n',err)
  end
  
  % copy data to struct
  for i=1:lMeth
    instr.methoden(i).x=data(:,1);
    instr.methoden(i).y=data(:,2*i);
    instr.methoden(i).err=data(:,2*i+1);
    instr.methoden(i).fitpar=min(lcaGetSmart(gapRBPV));
  end
end
% % ---------- calculation zero positions out of scan data ------------------
% if isempty(err) % only done if no error 
%   [errtmp,finPos,model,fitPars]=calcFinalPos(data,fun,startpar,debugFlg);
%   err=check(err,errtmp,'alignGap: calc final pos failed');
%   % debug statement
%   if debugFlg > 0 && isempty(err); 
%     fprintf('calcFinalPos done\n')
%   elseif debugFlg > 0
%     fprintf('%s\n',err)
%   end
%   for i=1:lMeth
%     cone.instrument.methoden(i).edge1=finPos(i,1);
%     cone.instrument.methoden(i).edge2=finPos(i,2);
%     cone.instrument.methoden(i).funOut=model{i};
%     cone.instrument.methoden(i).fitPar=fitPars{i};
%   end
%   
% end

while lcaGet(dechirper.readPV.status,1,'int')
  pause(.5)
end

% set back to initial values for 
lcaPutSmart(taperPSPV,0,'float');
lcaPutSmart(centerPSPV,initCenterPos,'float');
lcaPutSmart(gapUSPSPV,initGapPos,'float');
pause(.5);
lcaPutSmart(moveMotorPV, 1, 'float');


% errtmp=setActuator(taperPSPV,moveMotorPV,initTaperPos,taperRBPV,statusPV,tolnc,timeout,status,debugFlg);
% err=check(err,errtmp,'alignGap: setting taper back to inital position failed');
% errtmp=setActuator(centerPSPV,moveMotorPV,initCenterPos,centerRBPV,statusPV,tolnc,timeout,status);

if debugFlg > 0
  fprintf('alignGap fin\n')
  fprintf('\n')
end

end
 


function err=check(err,errtmp,errstr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if both of two inputs are empty string then output set to empty
% string otherwise output set to errstr
%
% Author:   J. Zemella DESY/SLAC
% created:  2015-07-07
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ( isempty(err) && isempty(errtmp) )
     err='';
  else
     err=errstr;
  end
end

function err=setActuator(actPV,movPV,val,rbvPV,statusPV,tolerance,timeout,status,debug)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set function for motor control 
%
% input: 
%    actPV:     device path (PV) to set motor position
%    movPV:     move motor PV
%    val:       position/set point to be set
%    rbvPV:     PV for read back value (rbv)
%    tolerance: tolerance between set point and read back value
%    timeout:   timeout if tolerance is not achieved
%    status:    status flag for gui
%
% output:
%    err: flag for sucessful moving the motor (1 <=> failure)
%
%
% Author:   J. Zemella DESY/SLAC
% created:  2015-07-07
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  err='';
  timeWait=.1;        % pause for checking if set point == rbv
  dtime=0;
 
  if debug
      fprintf('SetActuator %s to %f\n', actPV, val)
  end
  
  errtmp = lcaPutSmart(actPV, val, 'float');
  if errtmp==1, errtmp=''; end
  pause(.5)
  err=check(err,errtmp,'setActuator: lcaPutSmart set actPV failed');
  errtmp = lcaPutSmart(movPV, 1, 'float');
  if errtmp==1, errtmp=''; end
  err=check(err,errtmp,'setActuator: lcaPutSmart set movPV failed');
  
  
    
  
  % check if actuator has reached the set point
  [rbv,~,errtmp]=lcaGetSmart(rbvPV,0,'float');
  if errtmp==1
    errtmp='';
  end
  err=check(err,errtmp,'setActuator: lcaGetSmart failed');
  tic;
  while lcaGetSmart(statusPV, 1, 'int') && ~debug
    pause(1)
  end
  
%   while abs(val -rbv) > tolerance || dtime > timeout
%     [rbv,~,errtmp]=lcaGetSmart(rbvPV,0,'float');
%     pause(timeWait)
%     dtime=toc;
%   end
%   err=check(err,errtmp,'setActuator: lcaGetSmart failed');
%   if (abs(val -rbv) > tolerance ) 
%      err='setActuator: abs(rbv-setpoint) > tolerance';
%   end
end

function [err,meanVal,stdVal]=getData(detPV,numPoint,debugFlg,pos)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get function for detector data 
%
% input: 
%    detPV:    device path to get data or a cell array of PVs
%    numPoint: number of data points
%    debugFlg: ==2 enables setting test data before reading out data
%    pos:      actuator set point for creating data
%  
%
% output:
%    err:      flag for sucessful moving the motor (1 <=> failure)
%    meanVal:  average value of data set 
%              (I think about median for stability reasons)
%    stdVal:   standard deviation of data set 
%
%
% Author:   J. Zemella DESY/SLAC
% created:  2015-07-07
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  err='';

  lPV=size(detPV);
  data=zeros(numPoint,lPV(2));
  %[lclsRepRate,~,~]=lcaGetSmart('EVNT:SYS0:1:LCLSBEAMRATE');
  %dtime=10/lclsRepRate;
  dtime=0.001;

  % read numPoint times the data set(s)
  for i=1:numPoint
    
    % create test data point in debugFlg mode == 2 
    % but matlab PVs has to be set by user correctly
    if debugFlg > 0
      modErfFunc = @(p,xdata) ...
      p(1)*(1+erf(-p(2)*(xdata-p(6)))/2)+p(3)*(1+erf(-p(4)*(xdata-p(7)))/2)+p(5);
      %par=[-5.  0.25 -3. -1.75 0 -4 7 ]; %  asymmetric with diff pendestal
      par=[-5.  1.25 -3. -1.75 0 -4 7 ];
      createDbgData(detPV,modErfFunc,pos,par,1);
    end
    
    [value,~,errtmp]=lcaGetSmart(detPV,0,'float');
       
    if errtmp==1
      errtmp='';
    end
    err=check(err,errtmp,'getData: reading data failed');
    data(i,:)=value';
    pause(dtime)
  end

  % get average and standard deviation
  meanVal=mean(data);
  stdVal=std(data);
end

function [err,data]=...
            doScan(actPV,rbvPV,detPV,statusPV,startPos,stopPos,numStep,numPoint,...
                   tolerance,timeout,status,debugFlg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% perform a scan of actuator versus detector while observing the bpms 
%
% input: 
%    actPV:     actuator control system path
%    detPV:     detector control system path or cell array of PVs
%    startPos:  start pnumSteposition of scan
%    stopPos:   stop position of scan
%    numStep:   number of scan steps
%    numPoint:  number of taken data points per step
%    tolerance: actuator tolerance of between set point and read back value
%    timeout:   timeout if tolerance is not achieved
%    statusPV:  proofs motor staus
%    debugFlg:  enable bedug output values
%
% output:
%    err:       flag for sucessful moving the motor (1 <=> failure)
%    data:      data array of taken data of detector
%
%
% used functions:
%    filterCorrPlotDataSet
%
%
% Author:   J. Zemella DESY/SLAC
% created:  2015-07-07
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  err='';
  numPVs=size(detPV);numPVs=numPVs(2);
  data=zeros(numStep,2*numPVs+1);
  dPos=(stopPos-startPos)/numStep;
  
  numPerRate=0.1;
  settleTime=[1, 1];
  
  
  [errtmp,initPos,~]=getData(actPV,1,0,0);
  err=check(err,errtmp,'doScan: get initial pos failed');
  
  
  flagCorrPlot=debugFlg; % switching between corPlot_gui and own scan tool
  if flagCorrPlot == 0 || 1
    config=crtCrrPltCnf(actPV,startPos,stopPos,numStep,settleTime,...
          detPV,numPoint,numPerRate,statusPV,debugFlg);
    fix_cor_plot
    dataCorPlot =corrPlot_gui('appRemote',0,config,1);
%     warning('Change back')
%     dd =load('/u1/lcls/matlab/data/2015/2015-09/2015-09-27/Dechirper-DCHP_LTU1_555_US_GC_SCN-2015-09-27-125457.mat');
%     dataCorPlot = dd.data;

    % chechDataSet of corrplot by filter function
    dataCorPlot.config=config;
    filter={{dataCorPlot.config.readPVNameList(1),6e7,'@(x,val) x > val'}};
    if isempty(strfind(dataCorPlot.config.readPVNameList(1),'TMIT'))
      warning('no timit PV for cheching input charge')
    end
    %dataCorPlot = filterCorrPlotDataSet(dataCorPlot,filter);

    data(:,1)=[dataCorPlot.ctrlPV.val];
    tmp = arrayfun(@(in) in.val, dataCorPlot.readPV);
    

    
    data(:,2:2:2*numPVs)  =transpose(util_meanNan(tmp,3));
    data(:,3:2:2*numPVs+1)=transpose(util_stdNan(tmp,0,3)./sqrt(sum(~isnan(tmp),3)));
  else
    
    % move actuator to start value 
    errtmp=setActuator(actPV,'', startPos,rbvPV,statusPV,tolerance,timeout,status,debugFlg);
    err=check(err,errtmp,'doScan: move to start pos failed');

    %loop over numStep
    for i=1:numStep
      pos=startPos+(i-1)*dPos;
      % set actuator
      errtmp=setActuator(actPV,'',pos,rbvPV,statusPV,tolerance,timeout,status,debugFlg);
      err=check(err,errtmp,'doScan: set sctuator during scan failed');
    
      % read data of detector
      [errtmp,meanVal,stdVal]=getData(detPV,numPoint,debugFlg,pos);
      err=check(err,errtmp,sprintf('doScan: %d step failed',i));
      for j=1:numPVs
        % copy data to matrix
        data(i,1)=pos; 
        data(i,2*j)=meanVal(j);
        data(i,2*j+1)=stdVal(j);
      end
    end
    % set back to initial values
    errtmp=setActuator(actPV,'',initPos,rbvPV,statusPV,tolerance,timeout,status,debugFlg);
    err=check(err,errtmp,'doScan: move to init pos failed');
  end

 
end


function  [err,estimates,modelOut]=fitFunc(model,p0,xdata,ydata,edata)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% routine for fitting the data to input data using fminsearch
%
% input:
%    model:        fit function handle
%    p0:           start parameter for fitting dat to model
%    xdata:        x data set
%    ydata:        y data set
%    edata:        error of y data set
%
% output:
%    err:          flag for sucessful moving the motor (1 <=> failure)
%    estimates:    fitted parameters
%    modelOut:     model function with final fit parameter inserted
%
% Author:   J. Zemella DESY/SLAC
% created:  2015-07-07
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
err='';

  % 1st step: Optimizing without weight by error
  e = @(p) sum( (ydata - model(xdata,p)).^2 );
  [estimates,~] = fminsearch(e, p0); % Optimize
  
  % optionally 2nd step: Optimizing with weight by error
  if nargin == 3
    e = @(p) sum( (ydata - model(xdata,p)).^2 ./ (edata.^2) );
    [estimates, ~] = fminsearch(e, estimates); % Optimize 
  end

  modelOut=@(x) model(estimates,x);
end


function [start1,stop1,start2,stop2]=checkData(ydata,limit)
% function should return a 
  debugFlg=1;
  start1=1;stop1=1;start2=1;stop2=1;

  % smooth data and calc finite differences
  smthdata=mySmooth(ydata,floor(length(ydata)/5),@mean);
  out=myDeltaDiff(1:length(smthdata),smthdata);
    
  % get min max index of finite differences
  [~,idxMin]=min(out);[~,idxMax]=max(out);
  % this checks if the middle pat is smaller than the tail parts or not
  if (idxMin>idxMax), fac=1;else fac=-1;end
  
  
  indicesMax=find( out>limit);
  indicesMin=find(-out>limit);
  
  if fac == 1
    start1=indicesMax(1)-1;
    stop1=indicesMax(end)+1;
    start2=indicesMin(1)-1;
    stop2=indicesMin(end)+1;
  else
    start1=indicesMin(1)-1;
    stop1=indicesMin(end)+1;
    start2=indicesMax(1)-1;
    stop2=indicesMax(end)+1;
    
  end
  
  if debugFlg > 0
    plot(out)
    hold on
    plot([start1 start1],[0 2],'r')
    plot([stop1 stop1],[0 2],'r')
    plot([start2 start2],[0 2],'b')
    plot([stop2 stop2],[0 2],'b')
    plot(smthdata)
    plot(ydata)
    hold off
  end
  
end


function smthdata=mySmooth(data,n,func)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% performs a moving average/ median etc depending on the input function
% over n data points
% works only for an array
%
% input:
%   data:     data to be smoothed
%   n:        smoothing of n data points
%   func:     smoothing function
%
% output:  
%   smthdata: output data set
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  smthdata=zeros(1,length(data));

  for i=1:length(data)-floor(n/2)
    
    if i+n>length(data)
      window=length(data)-i;
    else
      window=floor(n);
    end
    smthdata(i+floor(n/2))=func(data(i:i+window));
  end
  
  % this is cheating: the first n/2 data points are a repetition of the
  % second n/2
  for i=1:floor(n/2)
    smthdata(i)=func(data(i:i+floor(n)));
  end
  
end

function out=myDeltaDiff(x,y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculates a finite differential quotient 
% works only for arrays 
%
% last point of array is set to zero!
%
% input:
%   x:      x data set
%   y:      y data set
%
% output:
%   out:    output data set
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  out=zeros(1,length(y));
  
  for i=1:length(y)-1
    out(i)=(y(i+1)-y(i))/(x(i+1)-x(i));
  end
end

function [err,finPos,model,fitPars]=calcFinalPos(data,fun,startPar,debugFlg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% routine for calculation the zero positions main and trim motor position 
% for the jaw for each used detector 
% (for now only the erfunction fit is implemented not a fit 
% to BPM position data or an possible rotation scan (trim motor position) 
% at zero main motor position 
% For this the method of analysis must be an input parameter! ) 
%
% input: 
%    data:     data sets of scans
%    fun:      array of fit function (string like dechirper gui provide)
%    startpar: array of set of start parameters
%
% output:
%    err:       flag for sucessful moving the motor (1 <=> failure)
%    finPos:    zero position of the jaw(s)
%    model:     function handle with fit parameters inserted
%    fitpar:    fitparameter of model function
%
% Author:   J. Zemella DESY/SLAC
% created:  2015-07-07
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
err='';

sData=size(data);lData=(sData(2)-1)/2;
finPos=zeros(lData,2);
model=cell(lData,1);
fitPars=cell(lData,1);

% fit data to erf or logistic function or heaviside step function
x=data(:,1);
for i=1:lData

  % copy scan data from matrix to array
  y=data(:,2*i); e=data(:,2*i+1);
  
  
  % implementation of different kinds of fitting routines
  
  %fit error function
  if strfind(char(fun(i)),'errorfunction') == 1
    [fitPar, ~, ~, ~, ~, ~, rfe] =util_erfFit(x, y, 1, e);
    modelIn= @(x,p) p(1)/2*erf(-(x-p(2))/p(3))+p(4);
     
    % calculate edges
    if ( fitPar(3) < 0 )
      finPos(i,:)=[0 fitPar(2)];
    else
      finPos(i,:)=[fitPar(2) 0];
    end
    
  % fit super gaussian
  elseif strfind(char(fun(i)),'supergaussian')
    [fitPar1, ~, parstd1, ~, ~, ~,rfe1] = util_gaussFit(x, y, 1,2, e,[]);
    [fitPar2, ~, parstd2, ~, ~, ~,rfe2] = util_gaussFit(x,-y, 1,2, e,[]);
    if rfe1 < rfe2 % check which fit is better to determine the sign of super gaussian
      fitPar=fitPar1; parstd=parstd1; fac= 1; rfe=rfe1;
    else
      fitPar=fitPar2; parstd=parstd2; fac=-1; rfe=rfe2;
    end
    modelIn= @(x,p) fac*p(1)*exp(-abs(((x-p(2))/sqrt(2)/p(3))).^p(4))+p(5);
    
    % calculate edges
    n=fitPar(4);
    tmp1=fitPar(2)-sqrt(2)*(1-1/n)^(1/n)*fitPar(3);
    tmp2=fitPar(2)+sqrt(2)*(1-1/n)^(1/n)*fitPar(3);
    finPos(i,:)=[tmp1 tmp2];
    
  % fit user defined function
  else
 
    startpar=startPar{i};
    
    fcn=fun{i};
    modelTmp=eval(fcn);
    modelIn=@(x,p)modelTmp(x,p(3:end),p(1),p(2));


    [err,fitPar,~]=fitFunc(modelIn,startpar,x,y,e);
    rfe=1;
    finPos(i,:)=[fitPar(1) fitPar(2)];  
    
  end
  modelOut=@(x) modelIn(x,fitPar);
  
  errtmp='';
  if rfe > 1e20
    errtmp='fit error large';
  end
  err=check(err,errtmp,'calcFinalPos: fit dows not converged');
  %finPos(i)=fitPar(3);
  model{i}=modelOut;
  fitPars{i}=fitPar;
  if debugFlg>1
    disp(func2str(modelOut))
    disp(fitPar)
    disp(finPos(i,:))
    figure(i)
    errorbar(x,y,e)
    hold on
    
    % function for super gaussian
    %fcn=@(x,p) fac*p(1)*exp(-abs(((abs(x)-p(2))/sqrt(2)/p(3))).^p(4))+p(5);
    plot(x,modelOut(x),'r')
      
    plot([finPos(i,1) finPos(i,1)],[min(y),max(y)], 'g')
    tmp=(finPos(i,1)+finPos(i,2))/2;
    plot([tmp tmp],[min(y),max(y)], 'g')
    plot([finPos(i,2) finPos(i,2)],[min(y),max(y)], 'g')
    hold off
    
  end
 
end

end




function err=createDbgData(detPV,model,mPos,par,facErr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function create on matlab PVs a test data point for read out by doScan
% 
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  
  ydata=model(par,mPos)+facErr*rand(1);
  err=lcaPutSmart(detPV,ydata,'float');
  pause(0.001);
  
end



function config=crtCrrPltCnf(actPV,startPos,stopPos,numStep,settleTime,...
          detPV,numPoint,numRate,statusPV,debug)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creates a config file for CorrPlot-Gui ( weak :-) ) 
%
% inputs:
%    actPV:       actuator PV
%    startPos:    starting position
%    stopPos:     stoping position
%    settleTime:  array 2x1 of initial and settle time
%    detPV:       cell array of detector PVs
%    numPoint:    number of samples per points
%    numRate:     sample rate
%    statusPV:    uses motor staus for settle time
%
% output:
%   config:  
%
%
% Author:   J. Zemella DESY/SLAC
% created:  2015-07-07
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        

config.ctrlPVNum= length({actPV});   % number of actuator PVs
config.ctrlPVName={actPV;''};  % cell array of actuator PV
config.ctrlMKBName= repmat(' ', 1, 0); 
config.ctrlPVValNum= [numStep 1]; % number of steps
config.ctrlPVRange= {startPos,stopPos;0,0};
config.ctrlPVWait= settleTime; % [initial settle time settle time]
config.ctrlPVWaitInit= debug;
config.readPVNameList= detPV'; % cell array of detector PV
config.plotHeader= strcat('Dechirper');  % plot header
config.acquireSampleNum= numPoint;
config.showFit=1;  % fit for correlation plot: 4 == parabola ; 5 ==erf
config.showFitOrder= 3;
config.settlePVName=statusPV;
%config.showAverage= 1;
%config.showSmoothing= 0;
%config.showWindowSize.nVal=50;
%config.showWindowSize.jVal=5;
%config.showWindowSize.iVal=5;
%config.profmonId=8;
%config.wireId=0;
config.plotXAxisId=1;
%config.plotYAxisId=2;
config.plotUAxisId=2;
%config.acquireBSA=0;
%config.profmonNumBG=0;
%config.profmonNumAve=1;
%config.emitId=0;
%config.show2D=0;
config.acquireSampleDelay=numRate;
%config.acquireRandomOrder=0;
%config.acquireSpiralOrder=0;
%config.acquireZigzagOrder=0;
%config.calcPVNameList={'-h'}; % formula 
%config.blenId=0;
config.profmonName=''; % profile monitor name 'none'
%config.wireName='';
%config.emitName='';
%config.blenName='';

save('/u1/lcls/matlab/config/test-conf.mat','config');

end

function fix_cor_plot
  h = util_appFind('corrPlot_gui');
  set(h, 'closerequestFcn', @(fig, ~) delete(fig))
  figure(h)
end
