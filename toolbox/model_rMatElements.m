function r = model_rMatElements(type, d, par0)
% 05-Jun-2019, M. Woodley
%  * allow thin-lens dipole and quadrupole ('mu') elements
%  * allow undulator ('un') elements to focus vertically or horizontally
%    via newly added par(3)

type=cellstr(type);
if iscell(d), d=vertcat(d{:});end
d=reshape(d,[],1);
if isnumeric(par0), par0=num2cell(par0,2);end

nElem=numel(type);
r=repmat(eye(6),[1 1 nElem]);
rcant=cat(4,r,r);
[O,rgam]=deal(reshape(r,[],nElem));
[kx2,ky2,h,r56,r65,r25,r66,roll]=deal(zeros(nElem,1));
[k0L,t0,k1L,t1]=deal(zeros(nElem,1)); % MULTIPOLEs
r66(:)=1;

for tag={'Q'  'S'  'B'  'T'  'L'  'U'  'R'  'M' ; ...
         'qu' 'so' 'be' 'tc' 'lc' 'un' 'ro' 'mu'; ...
          2    1    7    5    4    2    1    4  }
    is.(tag{1})=strncmp(type,tag{2},2);
    par.(tag{1})=vertcat(par0{is.(tag{1})});
    if isempty(par.(tag{1})), par.(tag{1})=zeros(0,1);end
    par.(tag{1})(:,end+1:tag{3})=0;
end

% Quadrupole
kx2(is.Q)=par.Q(:,1);
ky2(is.Q)=-kx2(is.Q,1);
roll(is.Q)=par.Q(:,2);

% Multipole (thin-lens dipole OR quadrupole only)
k0L(is.M)=par.M(:,1);
t0(is.M)=par.M(:,2);
k1L(is.M)=par.M(:,3);
t1(is.M)=par.M(:,4);

% Solenoid
kx2(is.S)=(par.S(:,1)/2).^2; % par=2k=BL/L/Brho [1/m]
ky2(is.S)=kx2(is.S);

% Delta undulator
%2g^2m^2c^2/q^2/B_0^2/L = 150 m @ 5 GeV
% f = 2 L (gamma m c/(q B_0 L))^2
% Brho = E/e/c
% 1/f = K1 L
% K1 = (2 B_0/sqrt(2)/Brho/2)^2

% Bend
angle=par.B(:,1);hgap=par.B(:,2);e=par.B(:,3:4);
k1=0;h(is.B)=angle./d(is.B,1);
kx2(is.B)= k1+h(is.B,1).^2;
ky2(is.B)=-k1;
fint=par.B(:,5:6); %MADs FINT
psi=2*h(is.B,[1 1]).*fint.*[hgap hgap].*(1+sin(e).^2)./cos(e);
rcant(2,1,is.B,:)= h(is.B,[1 1]).*tan(e);
rcant(4,3,is.B,:)=-h(is.B,[1 1]).*tan(e-psi);
roll(is.B)=par.B(:,7);

% Transverse deflector
f=par.T(:,1); % MHz
k=2*pi*f*1e6/2.99792458e8;
r25(is.T)=k.*par.T(:,2)./par.T(:,5).*sin(par.T(:,3));
r65(is.T)=r25(is.T).^2.*d(is.T)/6;
roll(is.T)=par.T(:,4);

% Accelerator
f=par.L(:,1); % MHz
gain=par.L(:,2); % MeV
ph=par.L(:,3); % rad
e0=par.L(:,4); % MeV
k=2*pi*f*1e6/2.99792458e8;
con=gain./e0.*cos(ph);
r66(is.L)=1./(1+con);
r65(is.L)=gain./e0.*sin(ph).*k;
eta=0; % use focusing with eta > 0
kx2(is.L)=eta/8*(gain./e0./d(is.L,1)).^2;
ky2(is.L)=kx2(is.L,1);
rcant(2,1,is.L,:)=(con./d(is.L,1))*[-1 1]/2;
rcant(4,3,is.L,:)=(con./d(is.L,1))*[-1 1]/2;
idL=find(is.L);isCon=con ~= 0;
d(idL(isCon))=d(idL(isCon),1).*log(1+con(isCon,1))./con(isCon,1);
rgam([8 22 36],:)=[1;1;1]*r66';

% Undulator
kx2(is.U)=0;
ky2(is.U)=par.U(:,1);
if (size(par.U,2)>2)
    idU=find(is.U);
    idH=find(par.U(:,3)==0);
    ky2(idU(idH))=0;
    kx2(idU(idH))=par.U(idH,1);
    
    %XLEAP Wigglers
    idXW=find(par.U(:,3) == 2);
    kx2(idU(idXW))=par.U(idXW,1);
    ky2(idU(idXW))=-par.U(idXW,1);
end

% Calculate R-matrix elements.

% pre-allocate arrays
[mx1,mx2,dx,my1,my2,tx]=deal(zeros(2,nElem));
[kx,phix,ky,phiy]=deal(zeros(nElem,1));

% initialize MULTIPOLE matrices to unity
id=find(is.M);n=length(id);
if n>0
    mx1(:,id)=repmat([1 0]',1,n);
    mx2(:,id)=repmat([0 1]',1,n);
    my1(:,id)=repmat([1 0]',1,n);
    my2(:,id)=repmat([0 1]',1,n);
end

% handle thin-lens dipoles
id=find(is.M&k0L~=0);n=length(id);
if n>0
    dx(:,id)=[zeros(n,1) k0L(id)]';
    roll(id)=t0(id);
end

% handle thin-lens quadrupoles
id=find(is.M&k1L~=0);n=length(id);
if n>0
    mx2(2,id)=-k1L(id);
    my2(2,id)=+k1L(id);
    roll(id)=t1(id);
end

% everything else
id=find(~is.M);n=length(id);
if n>0
    kx(id)=sqrt(kx2(id));phix(id)=kx(id).*d(id);
    ky(id)=sqrt(ky2(id));phiy(id)=ky(id).*d(id);
    jd=find(kx2(id)==0);
    kx2(id(jd))=1;
    r56(id)=-d(id).*(1-sinc(phix(id))).*h(id).^2./kx2(id);

    mx1(:,id)=[     cos(phix(id)) d(id).*sinc(phix(id))]';
    mx2(:,id)=[-kx(id).*sin(phix(id))     cos(phix(id))]';
    dx(:,id) =[  h(id).*(d(id).*sinc(phix(id)/2)).^2/2 h(id).*d(id).*sinc(phix(id))]';
    my1(:,id)=[     cos(phiy(id)) d(id).*sinc(phiy(id))]';
    my2(:,id)=[-ky(id).*sin(phiy(id))     cos(phiy(id))]';
    tx(:,id) =[      r25(id).*d(id)/2           r25(id)]';
end

% Assemble R-matrix.


r(1,1:2,:)=mx1;
r(2,1:2,:)=mx2;
r(3,3:4,:)=my1;
r(4,3:4,:)=my2;
r(1:2,6,:)= dx;
r(5,1:2,:)=-dx([2 1],:);
r(1:2,5,:)= tx;
r(6,1:2,:)= tx([2 1],:);
r(5,6  ,:)=r56;
r(6,5  ,:)=r65;
r=real(r);

%{
if ismember(type(1:2),{'so'})
    % phix=phix*0;
    phi=repmat(reshape(phix,1,1,[]),2,2);
    r(1:4,1:4,:)=repmat(r(1:2,1:2,:),2,2).*cat(1,cat(2,cos(phi),sin(phi)),cat(2,-sin(phi),cos(phi)));
end
%}

% Roll
roll(is.R)=par.R(:,1);

% Calculate roll matrix.
is.O=roll ~= 0;
O([1  8 15 22],is.O)=[ 1; 1;1;1]*cos(-roll(is.O,1))';
O([3 10 13 20],is.O)=[-1;-1;1;1]*sin(-roll(is.O,1))';
%{
            c = cos(-par(7));               % -sign gives TRANSPORT convention
            s = sin(-par(7));
            O = [ c  0  s  0  0  0; ...
                  0  c  0  s  0  0; ...
                 -s  0  c  0  0  0; ...
                  0 -s  0  c  0  0; ...
                  0  0  0  0  1  0; ...
                  0  0  0  0  0  1];
%}

% Roll
r(:,:,is.R)=reshape(O(:,is.R),6,6,[]);
O(:,is.R)=0;O([1 8 15 22 29 36],is.R)=1;

% Apply edge focusing.
r(:,:,is.B | is.L)=tensorprod(rcant(:,:,is.B | is.L,2),tensorprod(r(:,:,is.B | is.L),rcant(:,:,is.B | is.L,1))); % r=rcant2*r*rcant1

% Apply roll angle.
O=reshape(O,6,6,[]);
r(:,:,is.O)=tensorprod(O(:,:,is.O),tensorprod(r(:,:,is.O),permute(O(:,:,is.O),[2 1 3]))); % r=O*r*O'

% Apply relativistic rescaling.
rgam=reshape(rgam,6,6,[]);
r(:,:,is.L)=tensorprod(rgam(:,:,is.L),r(:,:,is.L)); % r=rgam*r


function y = sinc(x)

zind=x ~= 0;
y=x*0+1;
y(zind)=sin(x(zind))./x(zind);


function c=tensorprod(a, b)

c=zeros(size(a,1),size(b,2),size(a,3));
for j=1:size(a,3)
    c(:,:,j)=a(:,:,j)*b(:,:,j);
end
    