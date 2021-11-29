% sets all taper settings



function taper_set(in)
for n = 1:33
  statpvs{n,1} = ['USEG:UND1:',  num2str(n), '50:INSTALTNSTAT'];   
  undpvs{n,1} = ['USEG:UND1:', num2str(n), '50:TMXPOSC'];
end
taper = in;
stats = lcaGet(statpvs);
for n = 1:33
  if strcmp(stats{n,1}, 'NOT_INSTALLED');
    taper(n) = 80; % retract
  end
end
  lcaPutSmart(undpvs, taper);
end