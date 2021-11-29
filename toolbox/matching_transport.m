function [SIG, SIGMA, X, zVect, rMat] = matching_transport(optics, SIG, Xin, indexEl, one)
%
%
%
%
if nargin < 5, one=1;end
if nargin < 4
    indexEl=1:length(optics);
    if one == -1, indexEl=fliplr(indexEl);end
end

n=sum([optics(indexEl).nsegment])+1;
incr_ = 1;
if one == -1, incr_=n;end

X=zeros(size(Xin,1),n);X(:,incr_)=Xin;
SIGMA=zeros(21,n);SIGMA(:,incr_) = SIG(triu(true(6)));
zVect = zeros(1,n);rMat = zeros(6,6,n);rMat(:,:,incr_)=eye(6);

sector=optics(1).sector;
%if ismember(sector,{'LI28' 'LTU1' 'UND1'})
if isfield(optics,'z')
    zVect(incr_) = optics(indexEl(1)).z-one*optics(indexEl(1)).length/2;
end
for i = indexEl
    nseg = optics(i).nsegment;
    L = optics(i).length/nseg;
    strength = optics(i).KL/(optics(i).length+1e-99); % kG/m
    angle = optics(i).angle/nseg;
    roll = optics(i).roll;
    E1 = optics(i).factorE1*abs(optics(i).angle);
    E2 = optics(i).factorE2*abs(optics(i).angle);
    hgap = optics(i).hgap;
    FINT = optics(i).FINT;
    switch optics(i).name
        case 'linac'
            [SIG,RK] = matching_kickLinac(SIG,optics(i),X(7,incr_),(1+one)/2,one); % entrance, downstream 
            DE = optics(i).ampl*L;
            Phi = optics(i).phase;
            lambda = 3e8/2856e6;
            for jj = 1:nseg
                iLast=incr_;
                incr_ =iLast+one;
                zVect(incr_) = zVect(iLast)+one*L;
                Ein = X(7,iLast)-(1-one)/2*DE*cos(Phi/180*pi);
                R = R_linac(L,Ein,DE,Phi,lambda)^one;
                X(1:6,incr_) = R* X(1:6,iLast);
                X(7,incr_) = X(7,iLast)+one*DE*cos(Phi/180*pi);
                SIG = R*SIG*R';
                SIGMA(:,incr_) = SIG(triu(true(6)));
                rMat(:,:,incr_) = R*RK;RK=eye(6);
            end
            [SIG,RK] = matching_kickLinac(SIG,optics(i),X(7,incr_),(1-one)/2,one); %exit, downstream 
            rMat(:,:,incr_) = RK*rMat(:,:,incr_);
            SIGMA(:,incr_) = SIG(triu(true(6)));
        case {'quad' 'drift' 'bend' 'screen' 'und'}
            for jj = 1:nseg
                iLast=incr_;
                incr_ =iLast+one;
                en=X(7,iLast)*1e-3; % X(7) in MeV
                zVect(incr_) = zVect(iLast)+one*L;
                if ismember(sector,{'LI28' 'LTU1' 'UND1'})
                    en = optics(i).en; % in GeV
                    zVect(incr_) = optics(i).z-one*optics(i).length/2+one*L*jj;
                end
                BRho = en/299.792458*1e4; % kG m
                k1 = strength/BRho;
                if one == 1 && strcmp(optics(i).name,'bend')
%                    disp([angle E1 E2 hgap FINT optics(i).factorE1 optics(i).factorE2]);
                end
                R = R_gen6(L,angle,k1,roll,0,E1,E2,hgap,FINT)^one;
                if strcmp(optics(i).name,'und')
%                    disp(R);
                end
                X(1:6,incr_) = R* X(1:6,iLast);
                X(7,incr_) = en*1e3;
                SIG = R*SIG*R';
                SIGMA(:,incr_) = SIG(triu(true(6)));
                rMat(:,:,incr_) = R;
            end
        case 'matrix'
            f=@(x,k) prod(1/nseg+(0:-1:1-k))*x.^(1/nseg-k);
            R = funm(optics(i).R,f)^one;
%            R = real((optics(i).R+1e-10)^(1/nseg))^one;
            for jj = 1:nseg
                iLast=incr_;
                incr_ =iLast+one;
                zVect(incr_) = zVect(iLast)+one*L;
                X(1:6,incr_) = R* X(1:6,iLast);
%                X(7,incr_) = X(7,iLast);
                X(7,incr_) = optics(i).en*1e3;
                if ismember(sector,{'LI28' 'LTU1' 'UND1'})
                    X(7,incr_) = optics(i).en*1e3;
%                    zVect(incr_) = optics(i).z-optics(i).length/2+L*jj;
                end
                SIG = R*SIG*R';
                SIGMA(:,incr_) = SIG(triu(true(6)));
                rMat(:,:,incr_) = R;
            end
        case 'screen'
            %index_screen = index_screen + 1;
            %screen(index_screen).Sig = SIG; 
    end 
end
