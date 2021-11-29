% reads all taper settings

function out = taper_read()
for n = 1:33
  statpvs{n,1} = ['USEG:UND1:',  num2str(n), '50:INSTALTNSTAT'];
  undpvs{n,1} = ['USEG:UND1:', num2str(n), '50:TMXPOSC'];
end
stats = lcaGet(statpvs);
out = lcaGet(undpvs);
for n = 1:33
  if strcmp(stats{n,1}, 'NOT_INSTALLED');
    out(n) = 0; % set to zero even if it was originally retracted
  end
end
end