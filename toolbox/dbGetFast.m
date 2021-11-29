function [Bps,Ips]=dbGetFast(pslist)

% pslist = cell array of strings {micr:prim:unit} (EPICS-style)

% Get present BDES and IDES valuse for a list of power supplies

Nps=length(pslist);
BDESquery=cell(Nps,1);
IVBUquery=cell(Nps,1);
for n=1:Nps
  BDESquery{n}=strcat(pslist{n},':BDES');
  IVBUquery{n}=strcat(pslist{n},':IVBU');
end
Bps=lcaGetSmart(BDESquery);
ivbu=lcaGetSmart(IVBUquery);
Ips=zeros(Nps,1);
for n=1:Nps
  id=find(~isnan(ivbu(n,:)));
  ivb=fliplr(ivbu(n,id));
  Ips(n)=polyval(ivb,Bps(n));
end

end