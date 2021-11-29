%Es = lcaGet('BEND:IN20:751:BACT');  % get present energy from BX02 [GeV]
%if Es < 0.050
%  warndlg('BX01/02 is < 50 MeV - Cannot scale magnets unless these bends > 50 MeV','BX01/02 NOT SET RIGHT')
%  return
%end

E0   = lcaGet('BEND:IN20:931:BDES');  % get present energy from BXS [GeV]
Eg   = lcaGet('SIOC:SYS0:ML00:AO105');
EL0a = lcaGet('SIOC:SYS0:ML00:AO108');
Enew = (Eg + EL0a)/1E3;
E0 = nprompt('Orignal energy at BX01/02 before deactivating L0b (in GeV) [normally use defaults]',E0,0.040,0.200);
En = nprompt('New energy, after L0b deactivated, to scale magnets to (in GeV) [normally use defaults]',Enew,0.040,0.200);

mag_PVs = {'QUAD:IN20:425'
           'QUAD:IN20:441'
           'QUAD:IN20:511'
           'QUAD:IN20:525'
           'QUAD:IN20:631'
           'QUAD:IN20:651'
           'QUAD:IN20:941'
           'QUAD:IN20:961'
           'BEND:IN20:461'
           'XCOR:IN20:411'
           'XCOR:IN20:491'
           'XCOR:IN20:521'
           'XCOR:IN20:641'
           'XCOR:IN20:911'
           'XCOR:IN20:951'
           'YCOR:IN20:412'
           'YCOR:IN20:492'
           'YCOR:IN20:522'
           'YCOR:IN20:642'
           'YCOR:IN20:912'
           'YCOR:IN20:952'
           'BEND:IN20:931'
                            };
nmags = length(mag_PVs);
for j = 1:nmags
  BDES(j) = lcaGet([mag_PVs{j} ':BDES']);
  newBDES(j) = BDES(j)*En/E0;
end
trim_magnet(mag_PVs, newBDES, 'T');
disp(sprintf('All magnets from L0b-exit to SAB have been scaled from %5.3f GeV to %5.3f GeV',E0,En))
%disp('You must still TRIM the magnets.')