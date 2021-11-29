
function gettwiss(DEV)

aidainit
%fprintf(strcat('\nDEV = ',DEV,'\n\n'))

characternum = numel(DEV);
numcolon = strfind(DEV,':');
c1 = numcolon(1,1);
c2 = numcolon(1,2);

primary = DEV(1:(c1-1));
ioc = DEV(c1+1:c2-1);
unit = DEV(c2+1:characternum);


n = 0;

L3Energy = lcaGetSmart('BEND:LTU0:125:BDES');


model_init('source', 'EPICS'); % sets model source to XAL



%[NAME, ID, ISSLC] = model_nameRegion(PRIM, REGION, OPTS)
%bpms = model_nameRegion('BPMS', 'LTU');
namelist = model_nameRegion(primary, ioc);

twiss = model_rMatGet(namelist(:,:), [], 'TYPE=EXTANT', 'twiss'); % gets design twiss


DEV2 = [primary,':',ioc,':',unit];

n = 1;

for n = [1:numel(namelist)];
    compare = strcmp(namelist(n,1),DEV2);
    if compare == 1;
        DEV3 = namelist(n,1);
        break
    else
        continue
        n = n+1;
    end
    
end

energy = [twiss(1,n)];
beta_x = [twiss(3,n)];
eta_x  = [twiss(5,n)];
alpha_x= [twiss(4,n)];
phi_x  = [twiss(2,n)];
eta_xp = [twiss(6,n)];
beta_y = [twiss(8,n)];
eta_y  = [twiss(10,n)];
alpha_y= [twiss(9,n)];
phi_y  = [twiss(7,n)];
eta_yp = [twiss(11,n)];

z = lcaGetSmart([DEV2,':Z']);
zpos = z-lcaGetSmart('BPMS:IN20:221:Z');

DEVICE = DEV3;

DEVICE
formatSpec = 'Energy = %4.3f GeV \n';
fprintf(formatSpec,energy)

formatSpec = 'Beta X = %4.3f m \n';
fprintf(formatSpec,beta_x)

formatSpec = 'Eta X = %4.3f m \n';
fprintf(formatSpec,eta_x)

formatSpec = 'Alpha X = %4.3f \n';
fprintf(formatSpec,alpha_x)

formatSpec = 'Phi X = %4.3f radians \n';
fprintf(formatSpec,phi_x)

formatSpec = 'Eta Xp = %4.3f radians \n \n';
fprintf(formatSpec,eta_xp)

formatSpec = 'Beta Y = %4.3f m \n';
fprintf(formatSpec,beta_y)

formatSpec = 'Eta Y = %4.3f m \n';
fprintf(formatSpec,eta_y)

formatSpec = 'Alpha Y = %4.3f \n';
fprintf(formatSpec,alpha_y)

formatSpec = 'Phi Y = %4.3f radians \n';
fprintf(formatSpec,phi_y)

formatSpec = 'Eta Yp = %4.3f radians \n';
fprintf(formatSpec,eta_yp)

formatSpec = 'z position = %4.3f m from BPM2:IN20 \n';
fprintf(formatSpec,zpos)
end
