function dname=xalFileName(fname)

cmd=['grep " date=" ',fname];
[stat,s]=system(cmd);
ic=strfind(s,'"');
s=s(ic(1)+1:ic(2)-1);
[jDay,s]=strtok(s);
[jMonth,s]=strtok(s);
[jDate,s]=strtok(s);
[jTime,s]=strtok(s);
[jZone,s]=strtok(s,' :');
[jYear,s]=strtok(s,' :');
s=[jDate,'-',jMonth,'-',jYear,' ',jTime];
s=strrep(datestr(s,30),'T','_');
ic=strfind(fname,'.xml');
dname=strcat(fname(1:ic-1),'_',s,'.xml');

end
