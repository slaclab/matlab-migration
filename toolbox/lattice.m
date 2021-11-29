% lattice.m gives the betatron lattice, dispersion function, 
% expected oscillations (R12s), beam sizes of a region
% type:   reg='SC_SXR'; lattice  or:  reg='CU_HXR'; lattice  or:  reg='F2_ELEC'; lattice 
names0 = model_nameRegion([], reg);
namebpm=model_nameRegion('BPMS', reg);

path(path,'/home/fphysics/decker/matlab/toolbox')
load BPM_F2inj
load BPM_F2li14
%load QUAD_F2inj
load namF2
names = names0; 
if strcmp(reg, 'FACET')
    names =[BPM_F2inj; BPM_F2li14; namF2; names0];
    [Rdum, z,Ldum, twiss, ener]= model_rMatGet(names, [],{'BEAMPATH=F2_ELEC','TYPE=DESIGN'});
    [Rbpm, zb,Ldumb, twissb, enerb]= model_rMatGet([BPM_F2inj; BPM_F2li14; namebpm], [],{'BEAMPATH=F2_ELEC','TYPE=DESIGN'});  %F2_ELEC
    z(55) = 4.4124;   % hard coded quad 361
    z(56) = 4.7408;   %            quad 371
else 
   [Rdum, z,Ldum, twiss, ener]    = model_rMatGet(names, [],{['BEAMPATH=' reg],'TYPE=DESIGN'});
   [Rbpm, zb,Ldumb, twissb, enerb]= model_rMatGet(namebpm, [],{['BEAMPATH=' reg],'TYPE=DESIGN'});  
end
[zz,ii]=sort(z);
[zzb,iib]=sort(zb);

% for plotting reasons
if strcmp(reg,'SC_SXR')
    regp = 'SC SXR';
elseif strcmp(reg,'SC_HXR')
    regp = 'SC HXR';
  elseif strcmp(reg,'CU_SXR')
    regp = 'CU SXR';
  elseif strcmp(reg,'CU_HXR')
    regp = 'CU HXR';
 elseif strcmp(reg,'F2_ELEC')
    regp = 'F2 ELEC';
else 
    regp = reg;
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
title([regp ' Betatron Function'])
plotfj18


