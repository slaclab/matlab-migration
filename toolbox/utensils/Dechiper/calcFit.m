function [dataset, err] =calcFit(dataset,fun,option)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
% input: 
%     instrument.methoden(i) struct from dechirper gui
%
%
%
% Author:   J. Zemella DESY/SLAC
% created:  2015-09-28
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  debugFlg = 0;
  np=length(dataset.x);
  data=zeros(np,3);
  
  data(:,1)=dataset.x;
  data(:,2)=dataset.y;
  data(:,3)=dataset.err;
  startpar = dataset.fitPar;
  
  [errtmp,finPos,model,fitPars,xFit,yFit]=calcFinalPos(data,fun,startpar,option,debugFlg);

  
  i=1;
  if isscalar(finPos)
    dataset.center = finPos;
  else
    dataset.edge1=finPos(i,1);
    dataset.edge2=finPos(i,2);
    dataset.center = mean(finPos);
  end
  dataset.fitPar=fitPars{i};
  dataset.fit=[xFit; yFit];




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



function [err,finPos,model,fitPars,xFit,yFit]=calcFinalPos(data,fun,startPar,option,debugFlg)
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
%    option:   some parameters like polynomial order
%
% output:
%    err:       flag for sucessful moving the motor (1 <=> failure)
%    finPos:    zero position of the jaw(s)
%    model:     function handle with fit parameters inserted
%    fitpar:    fitparameter of model function
%    xFit:      x vector for plot fit 
%    yFit:      y vector for plot fit
%
%  used functions: 
%               util_erfFit
%               util_gaussFit
%               util_polyFit
%
%
% Author:   J. Zemella DESY/SLAC
% created:  2015-07-07 edited 2015-09-29
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
err='';

    modelOut=@(x) []; 
    fitPar=[];
    finPos=[];
    yFit=NaN(1, 50);
    
sData=size(data);lData=(sData(2)-1)/2;
finPos=zeros(lData,2);
model=cell(lData,1);
fitPars=cell(lData,1);

% fit data to erf or logistic function or heaviside step function
x=data(:,1);
xFit=linspace(x(1),x(end),50);
for i=1:lData

  % copy scan data from matrix to array
  y=data(:,2*i); e=data(:,2*i+1);
  
  
  % implementation of different kinds of fitting routines
  
  %fit error function
  if strcmp(fun, 'Error')
    [fitPar, ~, ~, ~, ~, ~, rfe] =util_erfFit(x, y, 1, e);
    modelIn= @(x,p) p(1)/2*erf(-(x-p(2))/p(3))+p(4);
     
    % calculate edges
    if ( fitPar(3) < 0 )
      finPos(i,:)=[0 fitPar(2)];
    else
      finPos(i,:)=[fitPar(2) 0];
    end
    modelOut=@(x) modelIn(x,fitPar);
    yFit=modelOut(xFit);
  % fit super gaussian
  elseif strcmp(fun, 'Gauss')
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
    modelOut=@(x) modelIn(x,fitPar);
    yFit=modelOut(xFit);
  elseif strcmp(fun, 'None')
    disp('no fit done by user choise');
    rfe=0;
  elseif strcmp(fun, 'Poly')

    [fitPar, yFit, parstd, yFitStd, mse, pcov, rfe] = util_polyFit(x, y, option, e, xFit);
    
    diff1 = polyder(fitPar);
    diff2 = polyder(diff1);
    finPos = fminsearch(@(x) polyval(diff1,x).^2 + polyval(diff2,x).^2, 0);
    % fit user defined function
    
  elseif strcmp(fun, 'InvCubic')

%     gap=startPar(1);
%     gap=2.;    warning('gap set hard coded to 2 mm!!!')
    gap=option(1);
    
    y0 = y(floor(length(y)/2));
%     startPar=[1.03e-4 1.e-2 y0];
    startPar=option(2:end);
    
    fcn='@(x,p) p(2)*(x-p(1)-p(3)).^-3 + p(2)*(x+p(1)-p(3)).^-3 + p(4)'; 
    modelTmp=eval(fcn);
    model1=@(x,p,hgap) modelTmp(x,[hgap p]);
    modelIn=@(x,p) model1(x,p,gap/2);
    
    %modelIn=@(x,p) modelTmp(x,p);
    
    
    [err,fitPar,~]=fitFunc(modelIn,startPar,x,y,e);
    rfe=1;
    finPos(i,:)=fitPar(2);  
    modelOut=@(x) modelIn(x,fitPar);
    yFit=modelOut(xFit);    
        
  else
 
    startpar=startPar{i};
    
    fcn=fun{i};
    modelTmp=eval(fcn);
    modelIn=@(x,p)modelTmp(x,p(3:end),p(1),p(2));


    [err,fitPar,~]=fitFunc(modelIn,startpar,x,y,e);
    rfe=1;
    finPos(i,:)=[fitPar(1) fitPar(2)];  
    modelOut=@(x) modelIn(x,fitPar);  
    yFit=modelOut(xFit);
  end
    
  
  errtmp='';
  if rfe > 1e20
    errtmp='fit error large';
  end
%   err=check(err,errtmp,'calcFinalPos: fit dows not converged');
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