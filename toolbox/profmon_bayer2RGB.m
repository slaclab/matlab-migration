function data = profmon_bayer2RGB(data, doCalc)
%PROFMON_BAYER2RGB
%  PROFMON_BAYER2RBG(DATA, DOCALC) converts Bayer color filter image data
%  to RGB image data.  DATA is structure as returned from profmon_grab().
%  DOCALC initialized the persistent filter pattern variables.

% Features:

% Input arguments:
%    DATA: Strcture as returned from profmon_grab
%    DOCALC: Initialized the filters

% Output arguments:
%    DATA: Contains modified IMG field

% Compatibility: Version 2007b, 2012a
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

persistent filtRed filtGreen filtBlue

if size(data.img,3) > 1, return, end
img=data.img;

if nargin < 2, doCalc=0;end

[rows,cols]=size(img);
n=numel(img);

if isempty(filtRed) || size(filtRed,1) ~= n || doCalc

    % Even pattern rows
    jER=repmat(2*(1:rows/2),3,1);
    iER=repmat((1:3)',1,rows/2)+jER-2;
    jER(iER > rows)=[];iER(iER > rows)=[];jER=jER(:)';iER=iER(:)';

    % Odd pattern rows
    jOR=repmat(2*(1:rows/2)-1,3,1);
    iOR=repmat((1:3)'-2,1,rows/2)+jOR;
    jOR(iOR < 1)=[];iOR(iOR < 1)=[];jOR=jOR(:)';iOR=iOR(:)';

    % Even pattern cols
    jEC=repmat(2*(1:cols/2),3,1);
    iEC=repmat((1:3)',1,cols/2)+jEC-2;
    jEC(iEC > cols)=[];iEC(iEC > cols)=[];jEC=jEC(:)';iEC=iEC(:)';

    % Odd pattern cols
    jOC=repmat(2*(1:cols/2)-1,3,1);
    iOC=repmat((1:3)'-2,1,cols/2)+jOC;
    jOC(iOC < 1)=[];iOC(iOC < 1)=[];jOC=jOC(:)';iOC=iOC(:)';

    %Red
    j=repmat(jOR,length(jOC),1)+repmat(rows*(jOC-1)',1,length(jOR));
    i=repmat(iOR,length(iOC),1)+repmat(rows*(iOC-1)',1,length(iOR));
    r=sparse(i,j,1,n,n);
    rw=spdiags(1./sum(r,2),0,n,n);
    filtRed=rw*r;

    % Green
    ja=repmat(jOR,length(jEC),1)+repmat(rows*(jEC-1)',1,length(jOR));
    ia=repmat(iOR,length(iEC),1)+repmat(rows*(iEC-1)',1,length(iOR));
                jb=repmat(jER,length(jOC),1)+repmat(rows*(jOC-1)',1,length(jER));
    ib=repmat(iER,length(iOC),1)+repmat(rows*(iOC-1)',1,length(iER));
    g=sparse([ia ib],[ja jb],1,n,n);
    gw=spdiags(1./sum(g,2),0,n,n);
    filtGreen=gw*g;

    % Blue
    j=repmat(jER,length(jEC),1)+repmat(rows*(jEC-1)',1,length(jER));
    i=repmat(iER,length(iEC),1)+repmat(rows*(iEC-1)',1,length(iER));
    b=sparse(i,j,1,n,n);
    bw=spdiags(1./sum(b,2),0,n,n);
    filtBlue=bw*b;
end

imgOut=zeros(rows,cols,3);img=double(data.img);
imgOut(:,:,1)=reshape(filtRed*img(:),rows,cols);
imgOut(:,:,2)=reshape(filtGreen*img(:),rows,cols);
imgOut(:,:,3)=reshape(filtBlue*img(:),rows,cols);

data.img=feval(class(data.img),imgOut);
