function [n, alp, eps] = n_index(k,mat,dthin,af,units)
%N_INDEX
%  [N] = N_INDEX(K,MAT,DTHIN,AF) calculates the complex refractive index of
%  material MAT at wavenumbers K given in 1/cm. Valid strings for materials
%  MAT are 'Mylar', 'PE', 'HDPE', 'QGlass' (quartz glass), 'Quartz',
%  'LiTaO3', 'H2OVap' (air with water vapor), 'Al' (aluminum), 'Au' (gold),
%  'Cr' (chrome), and 'Grid'. DTHIN is the thickness of the material (cm) in case
%  of a metal and the water density (g cm^-3) in case of water. AF is an
%  effective partial pressure used in case of water and defaults to 1.

if nargin < 3, d=0;else d=1./dthin;end
if nargin < 4, af=1.;end
if nargin < 5, units='';end

h_planck=4.13566743e-15; %eV s
c_vac=2.99792458e8; % m/s

switch units
    case 'eV'
        k=k/c_vac/h_planck/1e2; %1/cm
    case 'mm'
        k=10./k;
    case 'um'
        k=10000./k;
    case 'nm'
        k=1e7./k;
    otherwise
end

k0=1e-8;eps=1;alp=0;

switch mat
    case 'Mylar'
        k0 =[   85   87  104  138  152  182   232   280  360  500];
        s  =[.0025 .122 .005 .011 .002 .005 .0015 .0006 .006 .162];
        gam=[   18  100   20   11   20   40    30    30   20  350];
        eps=2.71240;ss=s.*k0.^2;
    case {'PE' 'HDPE'}
        k0 =[   45     72   75    115  192     275   350];
        s  =[.0001 .00020 .001 .00005 .001 .000028 .0006];
        gam=[   30      4   80     30  145      60   200];
        eps=2.02702;ss=s.*k0.^2;
    case 'QGlass'
        k0 =[  45.  89.5    95  120  200];
        s  =[.0005 .0008  .001 .055 .008];
        gam=[13.5  4.475 14.25  192  100];
        eps=3.7347;ss=s.*k0.^2;
    case 'Quartz'
        k0 =[128.4   263   394  450   697   797   1072  1163   1227]; %1/cm
        s  =[.0006   .05   .36 .852  .018   .11    .67   .01   .009];
        gam=[4.494 7.364 2.758 4.05 8.364 7.173 7.6112 6.978 134.97]; %1/cm
        eps=2.356;ss=s.*k0.^2;
    case {'Al2O3' 'Sapphire'}
        k0 =[385 442 569 635]; %1/cm
        s  =[0.3 2.7 3.0 0.3];
        gam=[0.015 0.01 0.02 0.02].*k0; %1/cm
        eps=3.2;ss=s.*k0.^2;
        s=s*0;
        parn=[2.22e-8 -6.01e-7 1.62e-4 3.07]; % for k < 210 1/cm
        para=[-7.74e-9 9.74e-7 7.28e-4 1.15e-2 0];
        eps=complex(polyval(parn,k),polyval(para,k)/4/pi./(k+1e-20)).^2;
        ss=s.*k0.^2;
    case {'Si' 'Silicon'}
        k0 =[1e10]; %1/cm
        s  =[0];
        gam=[1].*k0; %1/cm
        parn=[3.5635e-010 -2.7777e-007 7.2194e-005 3.4136]; % for k < 300 1/cm
        para=[-2.3605e-010 2.8855e-007 -8.7655e-005 0.0148 0];
        eps=complex(polyval(parn,k),polyval(para,k)/4/pi./(k+1e-20)).^2;
        ss=s.*k0.^2;
    case 'LiTaO3'
        k0 =[142. 165 175 215 238 253 316 375 405  462  594 673  750];
        s  =[24.1 0.8 .24 .36 2.0 2.4 2.5 2.0 .15 .036 2.33 .05 .002];
        gam=[ 19.  11   7  13  19   9  14  26  24    6   32  34   22];
        eps=4.497;ss=s.*k0.^2;
    case {'C' 'Diamond'}
        k0 =[57.1429  94.3396]*1e3; %1/cm
        s  =[0.3306  4.3356];
%        gam=[10 15]*1e3; %1/cm
%        gam=[5.5 15]*1e3; %1/cm
        gam=[0 0]*1e3; %1/cm
        eps=1;ss=s.*k0.^2;
    case 'H2OVap'
        k0 =[ 6.11 10.85 12.68 14.92 15.68 15.87 18.58 20.71 25.09 30.56 ...
             32.37 32.94 36.59 37.14 38.43 38.79];
        s  =[ 2.55  2.95  27.2  28.2 0.872  3.55 1730   18.4  1150  46.6 ...
              52.8   829  5460  1650   832  5960];
        gam=[0.096 0.093 0.095 0.082 0.063 0.069 0.111 0.076 0.104 0.086 ...
             0.083 0.103 0.099 0.100 0.095 0.095]*2*af;
        eps=1.0;if d ~= 0, d=1./d;ss=s/pi^2.*d;end
        alp=0;
        for j=1:length(k0)
            alp=alp+s(j)*gam(j)/2/k0(j)^2./((k-k0(j)).^2+gam(j)^2/4);
        end
        alp=d/pi*k.^2.*alp;
    case 'H2OHIT'
        [I,k0,s,gam]=readHITRAN();
        use=I>=1 & k0 < max(abs(k)) & k0 > min(abs(k)) & s > 1/100;sum(use)
        s=s(use);k0=k0(use);gam=gam(use)*2*af;
        eps=1.0;if d ~= 0, d=1./d;ss=s/pi^2.*d;end
    case 'Al'
        ss=[127412.].^2;gam=[757.882+0.686e-3*d];
    case 'Au'
        ss=[73261.9].^2;gam=[196.623+0.471e-3*d];
    case 'Cr'
%        ss=[38269.0].^2;gam=[318.931+0.667e-3*d]; % Nominal
        ss=[86308.0].^2;gam=[1556+0.667e-3*d]; % test
%        [n1,ev]=cr();
%        k1=ev/c_vac/h_planck/1e2; %1/cm
%        eps=(interp1(k1,n1,k,'linear',1)).^2;
%        k0=[];
    case 'Grid'
        ss=[1.8412/2/pi*d].^2;gam=[0];k0=i*1e-8;
%        ss=[3.8317/2/pi*d].^2;gam=[0];
%        ss=[3.0542/2/pi*d].^2;gam=[0];
end

%{
nk=numel(k);ns=numel(ss);ss=ss(:)';k0=k0(:)';gam=gam(:)';
for j=1:ceil(ns/100)
    id=1+(j-1)*100:min(j*100,ns);
    eps=eps+sum(repmat(ss(id),nk,1)./complex(repmat(k0(id).^2,nk,1)-repmat(k(:).^2,1,numel(id)),-abs(k(:))*gam(id)),2);
end
%eps=eps+sum(repmat(ss(:)',nk,1)./complex(repmat(k0(:)'.^2,nk,1)-repmat(k(:).^2,1,numel(k0)),-abs(k(:))*gam(:)'),2);
eps=reshape(eps,size(k));
%}
for j=1:length(k0)
    eps=eps+ss(j)./complex(k0(j)^2-k.^2,-k*gam(j));
end

n=sqrt(eps*1e-8)*1e4;


function [n, ev] = cr()
% from Handbook of Chemistry & Physics, 250 nm - 20.5 um
data=[ ...
    0.06   21.19   42.00; ...
    0.10   11.81   29.76; ...
    0.14   15.31   26.36; ...
    0.18    8.73   25.37; ...
    0.22    5.30   20.62; ...
    0.26    3.91   17.12; ...
    0.30    3.15   14.28; ...
    0.42    3.47    8.97; ...
    0.54    3.92    7.06; ...
    0.66    3.96    5.95; ...
    0.78    4.13    5.03; ...
    0.90    4.43    4.60; ...
    1.00    4.47    4.43; ...
    1.12    4.53    4.31; ...
    1.24    4.50    4.28; ...
    1.36    4.42    4.30; ...
    1.46    4.31    4.32; ...
    1.77    3.84    4.37; ...
    2.00    3.48    4.36; ...
    2.20    3.18    4.41; ...
    2.40    2.75    4.46; ...
    2.60    2.22    4.36; ...
    2.80    1.80    4.06; ...
    3.00    1.54    3.71; ...
    3.20    1.44    3.40; ...
    3.40    1.39    3.24; ...
    3.60    1.26    3.12; ...
    3.80    1.12    2.95; ...
    4.00    1.02    2.76; ...
    4.20    0.94    2.58; ...
    4.40    0.90    2.42; ...
    4.50    0.89    2.35; ...
    4.60    0.88    2.28; ...
    4.70    0.86    2.21; ...
    4.80    0.86    2.13; ...
    4.90    0.86    2.07; ...
    5.00    0.85    2.01; ...
];

ev=data(:,1);
n=data(:,2)+i*data(:,3);
