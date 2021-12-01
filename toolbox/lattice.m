% lattice.m gives the betatron lattice, dispersion function, 
% expected oscillations (R12s), beam sizes of a region
%
% type:   reg='SC_SXR'; lattice  or:  reg='CU_HXR'; lattice 
% or:  reg='F2_ELEC'; lattice ... 
% others: reg='SC_HXR'; reg='CU_SXR'; reg='SC_DIAG0';  ...
% 
names0 = model_nameRegion([], reg);
namebpm=model_nameRegion('BPMS', reg);

path(path,'/home/fphysics/decker/matlab/toolbox')
load BPM_F2inj
load BPM_F2li14
%load QUAD_F2inj
load namF2
%names = names0; 
names = [names0; namebpm]; 
if strcmp(reg, 'FACET')
    names =[BPM_F2inj; BPM_F2li14; namF2; names0];
    [Rdum, z,Ldum, twiss, ener]= model_rMatGet(names, [],{'BEAMPATH=F2_ELEC','TYPE=DESIGN'});
    [Rbpm, zb,Ldumb, twissb, enerb]= model_rMatGet([BPM_F2inj; BPM_F2li14; namebpm], [],{'BEAMPATH=F2_ELEC','TYPE=DESIGN'});  %F2_ELEC
    z(55) = 4.4124;   % hard coded quad 361
    z(56) = 4.7408;   %            quad 371
else 
   [Rdum, z,Ldum, twiss, ener]    = model_rMatGet(names, [],{'POS=MID',['BEAMPATH=' reg],'TYPE=DESIGN'});  % 'POS=MID''POSB=MID', 'SelPosUse=BBA'
   [Rbpm, zb,Ldumb, twissb, enerb]= model_rMatGet(namebpm, [],{['BEAMPATH=' reg],'TYPE=DESIGN'});  
end
[zz,ii]=sort(z);
[zzb,iib]=sort(zb);

% for plotting reasons
regp = reg;

for i = 1:length(reg)
    if strcmp(reg(i),'_')
        regp(i) = ' ';
    end
end

    
sigx = sqrt(twiss(3,:)*1./twiss(1,:)/1000*0.511);
sigy = sqrt(twiss(8,:)*1./twiss(1,:)/1000*0.511);
sigxb = sqrt(twissb(3,:)*1./twissb(1,:)/1000*0.511);
sigyb = sqrt(twissb(8,:)*1./twissb(1,:)/1000*0.511);

figure
plot(zz,sigx(ii),'b')
hold on, grid on
plot(zz,sigx(ii),'b.')
plot(zz,sigy(ii),'r')
plot(zz,sigy(ii),'r.')
plot(zzb,sigxb(iib),'bx')
plot(zzb,sigyb(iib),'r+')
%axis([0 1020 00 200])
xlabel('z [m]')
ylabel('Sig_x (b), Sig_y (r) [mm]')
title([regp ' Betatron Beam Sizes '])
plotfj18

figure
plot(zz,twiss(5,ii),'b')
hold on, grid on
plot(zz,twiss(5,ii),'b.')
plot(zz,twiss(10,ii),'r')
plot(zz,twiss(10,ii),'r.')
plot(zzb,twissb(5,iib),'bx')
plot(zzb,twissb(10,iib),'r+')
xlabel('z [m]')
ylabel('Eta_x (b), Eta_y (r) [m]')
title([regp ' Dispersion Function'])
plotfj18
%axis([0 1020 -.500 .200])

i835 = length(names);
clear char0
for i=1:i835
    char0(i) = [' '];
end
z_and_name = [num2str(zz')  char0'   char(names(ii))];
if strcmp(reg, 'FACET')
    znam = z_and_name(548:end,:)
else
    znam = z_and_name(1:end,:) 
end

R1s=permute(Rdum(1,[1 2 3 4 6],:),[3 2 1]);
R3s=permute(Rdum(3,[1 2 3 4 6],:),[3 2 1]);
R1sb=permute(Rbpm(1,[1 2 3 4 6],:),[3 2 1]);
R3sb=permute(Rbpm(3,[1 2 3 4 6],:),[3 2 1]);

figure
plot(zz,R1s(ii,1),'b')
hold on, grid on
plot(zz,R1s(ii,1),'b.')
plot(zz,R3s(ii,3),'r')
plot(zz,R3s(ii,3),'r.')
%axis([0 55 -3 2])
plot(zzb,R1sb(iib,1),'bx')
plot(zzb,R3sb(iib,3),'r+')
xlabel('z [m]')
ylabel('R12s (b), R13s (r)')
title('Expected Oscillations')
plotfj18
%axis([0 1020 -3 2])

figure
plot(zz,twiss(3,ii),'b')
hold on, grid on
plot(zz,twiss(3,ii),'b.')
plot(zz,twiss(8,ii),'r')
plot(zz,twiss(8,ii),'r.')
%axis([0 1020 00 200])
plot(zzb,twissb(3,iib),'bx')
plot(zzb,twissb(8,iib),'r+')
xlabel('z [m]')
ylabel('Beta_x (b), Beta_y (r) [m]')
title([regp ' Design Betatron Function'])
plotfj18


% Getting to a matched lattice at a certain point, e.g. z0=371.41787
z0=371.41787;
z0=1620.3677;
z0=410.05749;
%z0=1640.45;
z0=1471.42;
%z0=535;
[mi, im] = min(abs(z-z0));
names((im));
ba4 = [twiss(3,im) twiss(4,im) twiss(8,im) twiss(9,im)];

[mib, imb] = min(abs(zb-z0));
namebpm((imb));
ba4b = [twissb(3,imb) twissb(4,imb) twissb(8,imb) twissb(9,imb)];

ba0=[30.8576   -0.0017   69.1007    0.0011];

% r, zn, twi can be now from a CURRENT model, e.g.:
% load model_7625MeV_08jul2020_1050

% matched_lat(ba4, z0, r, zn, twi, regp);


