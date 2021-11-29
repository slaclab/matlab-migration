function [m,q,sigm,sigq,cov_mq] = linearfit(x,y,sigma_y,PlotFlag)
%Calculate the least square min fit of the function y = mx + q
%Sintax: [m,q,sigm,sigq,cov_mq] = linearfit(x,y,sigma_y,PlotFlag)
%Where m and q are the fit parameters, sigm and sigq their standard
%deviation, and cov_mq their covariance. 
%x and y are vectors with the points coordinates, and sigma_y is the
%rms error on y. 
%Remark: a scalar value in sigma_y will generate a vector sigma_y with the
%same size of x and y with all elements equal to original scalar.
%APlotFlag different than zero will generate a plot of the results.
%(FS, April 6,2012)

sigma_y=abs(sigma_y);
sizx=size(x);
sizy=size(y);
sizsig=size(sigma_y);

ErrorFlag=0;
if sizx(2)~=sizy(2)
    ['ERROR: input vectors have different dimensions']
    ErrorFlag=1;
end

if sizx(1)>1
    ['ERROR: input variables must be 1D vectors']
    ErrorFlag=1;
end

if sizx(2)<2
    ['ERROR: insufficient number of points. At least 2 points required']
    ErrorFlag=1;
end

ploterrorflag=0;
if sizx(2)~= sizsig(2)
    if sizsig(2)==1
        sig_y(1:1:sizx(2))=sigma_y;
    else
        ['ERROR: input vectors have different dimensions']
        ErrorFlag=1;
    end
else
    sig_y=sigma_y;
end

if ErrorFlag==0
    % Calculate statistical moments
    sig2=sig_y.^2;
    Nterm=sum(1./sig2);
    xsum=sum(x./sig2);
    x2sum=sum(x.*x./sig2);
    ysum=sum(y./sig2);
    y2sum=sum(y.*y./sig2);
    xysum=sum(x.*y./sig2);
    
    A=[x2sum xsum;xsum Nterm];
    E=inv(A); %Error matrix
    
    %Calculate fit parameters
    par=E*[xysum ysum]';
    m=par(1);
    q=par(2);

    %calculate fit parameters standard deviation
    sigm=sqrt(E(1,1));
    sigq=sqrt(E(2,2));
    cov_mq=E(1,2);

    %Plot results
    
    if PlotFlag~=0
        
        yplus=y+sig_y;
        yminus=y-sig_y;
        yfit=m*x+q;
        
        ydelta=max(yplus)-min(yminus);
        xdelta=max(x)-min(x);
        ymax=max(yplus)+abs(0.1*ydelta);
        ymin=min(yminus)-abs(0.1*ydelta);
        xmax=max(x)+abs(0.1*xdelta);
        xmin=min(x)-abs(0.1*xdelta);
        
        plot(x,yplus,'+r')
        hold;
        plot(x,yminus,'+r')
        plot(x,y,'.r')
        plot(x,yfit)
        hold;
        axis([xmin xmax ymin ymax])
    end
else
    m='NaN';
    q='NaN';
    sigm='NaN';
    sigq='NaN';
end

end

