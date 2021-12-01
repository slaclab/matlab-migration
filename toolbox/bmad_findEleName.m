function []=bmad_findEleName(Z,plane)
%example:
%findEleName('3350','X')

%Z location is where thebeam loss should occur

%currently only setup for the HXR line
%plane ='X'

%put something in to set collimators or open them when doing these studies 
colsWriteTao;
magWriteTao;

filename = '~/dbohler/bmad/all_beam_loss/testAll.tao';
latlist = '~/dbohler/bmad/all_beam_loss/latlist_all.txt';


fid = fopen(latlist);
index = textscan(fid, '%u%s%f');
fclose(fid);
Zoff = str2double(Z) - 2014;
writeTaoInit(index, Zoff, plane)

% latlist.txt and latlist_bsy.txt work differently for bsy the offset is
% 2014

[~, id2] = min(abs(index{3}-Zoff));
idx = index{1}(id2);

%id = find(contains(index{2}, string(Z))); <-- use this one if LTU only 
%idx = index{1}(id(1));

fid = fopen(filename,'w');
formatSpec ='%s\n';
formatSpec1 ='%s %.0f\n';
energy =lcaGet('SIOC:SYS0:ML00:AO471'); %MeV (Energy out of the gun)
energyStr = ['change ele beginning e_tot @' num2str(energy) 'e6'];
%fprintf(fid,formatSpec, energyStr);


if strcmp(plane, 'Y')
    veto = 'correctors.x';
    use = 'correctors.y';
elseif strcmp(plane, 'X')
    veto = 'correctors.y';
    use = 'correctors.x';
end
s1 = sprintf('%s', 'veto var ', veto);    
fprintf(fid,formatSpec, s1);
s2 = sprintf('%s','use var ' , use);  
fprintf(fid,formatSpec, s2);
s3 = sprintf('set var %s|meas =0' , use); 
fprintf(fid,formatSpec, s3);
s4 = sprintf('set var %s|weight =3e8' , use); 
fprintf(fid,formatSpec, s4);

fprintf(fid,formatSpec, 'use dat loss.rel_point');
fprintf(fid,formatSpec, 'set dat loss.rel_point|weight = 1');
fprintf(fid,formatSpec, 'sho dat');
fprintf(fid,formatSpec, 'set lattice model=design');
fprintf(fid,formatSpec, 'set dat loss.rel_point|ele_name = DTDUND2');
fprintf(fid,formatSpec1, 'set dat loss.rel_point|meas = 2532 -',idx);
%fprintf(fid,formatSpec1, 'set dat loss.rel_point|meas = 2385 -',idx);

fprintf(fid,formatSpec,  '!call /home/physics/dbohler/bmad/all_beam_loss/setMags.tao');
fprintf(fid,formatSpec,  '!call /home/physics/dbohler/bmad/all_beam_loss/setCols.tao');
fprintf(fid,formatSpec, 'scycles 5');
fprintf(fid,formatSpec, 'sde 1000');
fprintf(fid,formatSpec, 'ode');
fprintf(fid,formatSpec, 'run');
fprintf(fid,formatSpec, 'run');
fprintf(fid,formatSpec, 'show -write optOutput.txt var -good -bmad');
fid(close);
disp('done')

bmad_writeTao(str2double(Z))