
while 1
lcaPut('KLYS:LI20:81:MKBVFTPJ1PROC',1);
pause(0.25);
s=lcaGet('KLYS:LI20:81:MKBVFTPJ1CS')
a=char(s);
[b, c, d, e, f, g] = strread(a,'%s%s%s%s%s%s');
h = str2num(char(g))
if h > 10
  exit
end
end
