function [] = bmad_writeTao(z)
%bmad_writeTao.m 
%script to write Tao for beamloss based on the Z. 

%z = 2231;

zz = [z-200 z];

[madname, bmat] = bmad_CorScan(zz,0); %get madnames and max/min values

[M,I] = min(abs(bmat(:,1)-zz(2)));

disp('The last element in range show be:')
disp('check this is correct')
madname(I)

%find five x&y correctors upstream
Dy=contains(madname,'YC');
id_y = find(Dy);
idy = id_y(end-4:end);
useCory = madname(idy);

Dx=contains(madname,'XC');
id_x = find(Dx);
idx = id_x(end-4:end);  
useCorx = madname(idx);


%edit Tao.init file
stry=['var(1:)%ele_name = ' char(39) useCory{1} char(39) ',' char(39) useCory{2} char(39) ',' char(39) useCory{3} char(39) ',' ...
    char(39) useCory{4} char(39) ',' char(39) useCory{5} char(39)];
strx=['var(1:)%ele_name = ' char(39) useCorx{1} char(39) ',' char(39) useCorx{2} char(39) ',' char(39) useCorx{3} char(39) ',' ...
    char(39) useCorx{4} char(39) ',' char(39) useCorx{5} char(39)];

bminlimy = bmat(idy, 3)*10;
bmaxlimy = bmat(idy, 6)*10;
bminlimx = bmat(idx, 3)*10;
bmaxlimx = bmat(idx, 6)*10;


str_blow = 'var(1:)%low_lim =';
str_bhigh = 'var(1:)%high_lim =';

formatSpec3 = '%s\n';
formatSpec5 ='%s %3.3f,%3.3f,%3.3f,%3.3f,%3.3f';

fid = fopen('tao_orig.init','r');
f = fread(fid);
fclose(fid);
f = strrep(f, 'BEGINNING', madname{1});
f = strrep(f,'CEDL3',madname{end});

strlowx =sprintf(formatSpec5,str_blow,bminlimx);
strhighx =sprintf(formatSpec5,str_bhigh,bmaxlimx);

strlowy =sprintf(formatSpec5,str_blow,bminlimy);
strhighy =sprintf(formatSpec5,str_bhigh,bmaxlimy);


f = strrep(f,'ele_namex', strx);
f = strrep(f,'low_limx', strlowx);
f = strrep(f,'high_limx',strhighx);

f = strrep(f,'ele_namey', stry);
f = strrep(f,'low_limy', strlowy);
f = strrep(f,'high_limy',strhighy);

fid2 = fopen('/home/physics/dbohler/bmad/all_beam_loss/tao.init','w');
fprintf(fid2,'%s',f);
fclose(fid2);
