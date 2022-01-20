function [R1s,R3s,Zs,Zs0] = xy_traj_fit_setup(prim0,micr0,unit0,BPM_micrs,BPM_units)
% AIDA-PVA imports
aidapva;

name=[prim0 ':' micr0 ':' int2str(unit0)];
nameList=strcat('BPMS:',cellstr(char(BPM_micrs)),':',cellstr(int2str(BPM_units(:))));
[a,Zs]=model_rMatGet(nameList);
[r,Zs0]=model_rMatGet(name,nameList);
R1s=permute(r(1,[1 2 3 4 6],:),[3 2 1]);
R3s=permute(r(3,[1 2 3 4 6],:),[3 2 1]);

return

nbpms = length(BPM_units);
R1s = zeros(nbpms,5);
R3s = zeros(nbpms,5);
Zs  = zeros(nbpms,1);
try
  Zs0 = pvaGet([prim0 ':' micr0 ':' int2str(unit0) ':Z']);
catch e
  handleExceptions(e);
  errordlg('Fatal error on AIDAGET for database Z-values.','AIDAGET ERROR');
end
for j = 1:nbpms
  try
    Zs(j)    = pvaGet(['BPMS:' BPM_micrs(j,:) ':' int2str(BPM_units(j)) ':Z']);
  catch
    errordlg('Fatal error on AIDAGET for database Z-values.','AIDAGET ERROR');
  end
  try
    requestBuilder = pvaRequest({[prim0 ':' micr0 ':' int2str(unit0) ':R']});
    requestBuilder.returning(AIDA_DOUBLE_ARRAY);
    requestBuilder.with('B', ['BPMS:' BPM_micrs(j,:) ':' int2str(BPM_units(j))]);
    R        = ML(requestBuilder.get());
  catch e
    handleExceptions(e);
    errordlg('Fatal error on AIDAGET for database R-matrices.','AIDAGET ERROR');
  end
  Rm       = reshape(R,6,6);
  Rm       = Rm';
  R1s(j,:) = [Rm{1,1} Rm{1,2} Rm{1,3} Rm{1,4} Rm{1,6}];
  R3s(j,:) = [Rm{3,1} Rm{3,2} Rm{3,3} Rm{3,4} Rm{3,6}];
end
