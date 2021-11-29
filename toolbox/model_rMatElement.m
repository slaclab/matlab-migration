function r = model_rMatElement(type, d, par)
% 21-May-2019, M. Woodley
%  * allow optional cross-plane coupling for solenoid ('so') elements ...
%    hardwired for now
%  * allow thin-lens dipole and quadrupole ('mu') elements

rcant=ones(1,1,2);
[kx2,ky2,h,r65,roll]=deal(0);
[dx,tx]=deal([0;0]);
r66=1;O=eye(6);
cxy=false; % return X-Y coupled matrix for 'so' elements

switch type(1:2)
    case 'qu'
        kx2=par(1); % par=k^2=K1=GL/L/Brho [1/m^2]
        ky2=-kx2;
        if numel(par) > 1, roll=par(2);end
    case 'mu'
        if (par(1)~=0)  % thin lens kick
            k0L=par(1); % par=K0L=BL/Brho [rad]
            roll=par(2);
            k1L=0;
        else            % thin lens quad
            k1L=par(3); % par=K1L=GL/Brho [1/m]
            roll=par(4);
            k0L=0;
        end
    case 'so'
        kx2=(par(1)/2).^2; % par=2k=BL/L/Brho [1/m]
        ky2=kx2;
    case 'be'
        angle=par(1);hgap=par(2);e=par(3:4);
        k1=0;h=angle/d;
        kx2= k1+h.^2;
        ky2=-k1;
        fint=par([5 min(6,end)]); %MADs FINT
        psi=2*h*fint*hgap.*(1+sin(e).^2)./cos(e);
        rcant=repmat(eye(6),[1 1 2]);
        rcant(2,1,:)= [h h].*tan(e);
        rcant(4,3,:)=-[h h].*tan(e-psi);
        if numel(par) > 6, roll=par(7);end
%{
        if numel(par) > 6
            O([1 8 15 22])=cos(-par(7));
            O([3 10 13 20])=[-1 -1 1 1]*sin(-par(7));
        end
%}
    case 'tc'
        f=par(1); % MHz
        k=2*pi*f*1e6/2.99792458e8;
        V0=par(2); % MV
        e0=par(end); % MeV
        r25=k*V0/e0*sin(par(3));
        r65=r25^2*d/6;
        tx=[r25*d/2 r25]';
        if numel(par) > 3, roll=par(4);end
    case 'lc'
        f=par(1); % MHz
        gain=par(2); % MeV
        ph=par(3); % rad
        e0=par(4); % MeV
        k=2*pi*f*1e6/2.99792458e8;
        con=gain/e0*cos(ph);
        r66=1/(1+con);
        r65=gain/e0*sin(ph)*k;
        eta=0; % use focusing with eta > 0
        kx2=eta/8*(gain/e0/d)^2;
        ky2=kx2;
        rcant=repmat(eye(6),[1 1 2]);
        rcant(2,1,:)=[-1 1]*con/d/2;
        rcant(4,3,:)=[-1 1]*con/d/2;
        if con ~= 0
            d=d*log(1+con)/con;
        end
    case 'un'
        kx2=0;
        ky2=par(1);
        if numel(par) > 2
            if par(3) == 2 % XLEAP wiggler
               kx2 = par(1);
               ky2 = -par(1);
            end
        end
    otherwise
end

if ismember(type(1:2),{'mu'})
    if k0L~=0
        mx1=[  1   0 ]';
        mx2=[  0   1 ]';
        my1=[  1   0 ]';
        my2=[  0   1 ]';
        dx =[  0  k0L]';
        r56=0;
    else
        mx1=[  1  0]';
        mx2=[-k1L 1]';
        my1=[  1  0]';
        my2=[ k1L 1]';
        dx =[  0  0]';
        r56=0;
    end
else
    kx=sqrt(kx2);ky=sqrt(ky2);
    phix=kx.*d;phiy=ky.*d;
    kx2(kx2 == 0)=1;
    r56=-d.*(1-sinc(phix)).*h.^2./kx2;
    if ~any(kx), mx1=[1 d]';mx2=[0 1]';else
        mx1=[     cos(phix) d.*sinc(phix)]';
        mx2=[-kx.*sin(phix)     cos(phix)]';
        dx =[  h.*(d.*sinc(phix/2)).^2/2 h.*d.*sinc(phix)]';
    end
    if ~any(ky), my1=[1 d]';my2=[0 1]';else
        my1=[     cos(phiy) d.*sinc(phiy)]';
        my2=[-ky.*sin(phiy)     cos(phiy)]';
    end
end

r=eye(6);
r(1,1:2)=mx1;
r(2,1:2)=mx2;
r(3,3:4)=my1;
r(4,3:4)=my2;
r(1:2,6)= dx;
r(5,1:2)=-dx([2 1]);
r(1:2,5)= tx;
r(6,1:2)= tx([2 1]);
r(5,6  )=r56;
r(6,5  )=r65;

if ismember(type(1:2),{'so'})&&cxy
  r(1:4,1:4)=kron([cos(phix) sin(phix);-sin(phix) cos(phix)],r(1:2,1:2));
end

if ismember(type(1:2),{'ro'}), roll=par(1);end
%{
if ismember(type(1:2),{'ro'})
    O([1 8 15 22])=cos(-par(1));
    O([3 10 13 20])=[-1 -1 1 1]*sin(-par(1));
    r=O;O=eye(6,6);
    % phix=phix*0;
%    r(1:4,1:4)=kron([cos(phix) sin(phix);-sin(phix) cos(phix)],r(1:2,1:2));
end
%}

% Calculate roll matrix.
if roll
    O([1 8 15 22])=cos(-roll);
    O([3 10 13 20])=[-1 -1 1 1]*sin(-roll);
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
end

if ismember(type(1:2),{'ro'}), r=O;O=eye(6,6);end

% Apply edge focusing.
r=rcant(:,:,2)*real(r)*rcant(:,:,1);

% Apply roll angle.
r=O*r*O';

% Apply relativistic rescaling.
r=diag([1 r66 1 r66 1 r66])*r;


function y = sinc(x)

zind=x ~= 0;
y=x*0+1;
y(zind)=sin(x(zind))./x(zind);
