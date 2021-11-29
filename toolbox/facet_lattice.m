names0 = model_nameRegion([], 'FACET');
path(path,'/home/fphysics/decker/matlab/toolbox')
load BPM_F2inj
load BPM_F2li14
%load QUAD_F2inj
load namF2
names =[BPM_F2inj; BPM_F2li14; namF2]; % names0];
[Rdum, z,Ldum, twiss, ener]= model_rMatGet(names, [],{'BEAMPATH=F2_ELEC','TYPE=DESIGN'});
[Rbpm, zb,Ldumb, twissb, enerb]= model_rMatGet(BPM_F2inj, [],{'BEAMPATH=F2_ELEC','TYPE=DESIGN'});
%z(55) = 4.4124;   % hard coded quad 361
%z(56) = 4.7408;   %            quad 371
[zz,ii]=sort(z);

figure
plot(zz,twiss(3,ii),'b')
hold on, grid on
plot(zz,twiss(3,ii),'b.')
plot(zz,twiss(8,ii),'r')
plot(zz,twiss(8,ii),'r.')
axis([0 1020 00 200])
xlabel('z [m]')
ylabel('Beta_x (b), Beta_y (r) [m]')
title('FACET Betatron Lattice')
plotfj18

figure
plot(zz,twiss(5,ii),'b')
hold on, grid on
plot(zz,twiss(5,ii),'b.')
xlabel('z [m]')
ylabel('eta_x (b), eta_y (r) [m]')
title('FACET Dispersion Lattice')
plotfj18
axis([0 1020 -.500 .200])

i835 = length(names);
for i=1:i835
    char0(i) = [' '];
end
z_and_name = [num2str(zz')  char0'   char(names(ii))];
znam =z_and_name(26:end,:)   %104

R1s=permute(Rdum(1,[1 2 3 4 6],:),[3 2 1]);
R3s=permute(Rdum(3,[1 2 3 4 6],:),[3 2 1]);

figure
plot(zz,R1s(ii,1),'b')
hold on, grid on
plot(zz,R3s(ii,3),'r')
plot(zz,R3s(ii,3),'r.')
plot(zz,R1s(ii,1),'b.')
%axis([0 55 -3 2])
xlabel('z [m]')
ylabel('R12s (b), R13s (r)')
title('Expected Oscillations')
plotfj
axis([0 1020 -3 2])


figure
plot(zz,twiss(3,ii),'b')
hold on, grid on
plot(zz,twiss(3,ii),'b.')
plot(zz,twiss(8,ii),'r')
plot(zz,twiss(8,ii),'r.')
axis([0 1020 00 200])
xlabel('z [m]')
ylabel('Beta_x (b), Beta_y (r) [m]')
title('FACET Betatron Lattice')
plotfj18


