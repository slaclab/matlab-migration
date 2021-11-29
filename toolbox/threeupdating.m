npts=24; %for five hertz
%MAX=2800;
MAX=504;
avgdata = zeros(1,npts);
figure;
subplot(3,1,1)
h1 = gca;
subplot(3,1,2)
h2=gca;
subplot(3,1,3)
h3=gca;
PV1 = 'BPMS:BSY0:83:X';
PV2 = 'BPMS:BSY0:83:Y';
PV3 = 'GDET:FEE1:241:ENRC';
%PV4 = 'BPMS:BSY0:83:TMIT';
pvs=cell(3,1);
pvs{1}=PV1;pvs{2}=PV2;pvs{3}=PV3;%%pvs{4}=PV4;

bpmdata=lcaGet(pvs);
for nn=1:3
  if nn==1
    PV=PV1;h=h1;
  elseif nn==2
    PV=PV2;h=h2;
  else
    PV=PV3;h=h3;
  end
  bpmdata = lcaGet(strcat(PV,'HSTBR'));
  %   offset = find(abs(bpmdata(1:npts)) <0.01);
  if nn==3
    offset=find(bpmdata(1:42)<.1);
  else
    offset = find(abs(bpmdata(1:24)) <0.00001);
  end
  bpmdata = circshift(bpmdata,[0 -offset]);
  for i=1:npts
    avgdata(i) = mean(bpmdata(i:npts:MAX));
  end
  if nn==1
    plothandle1 = plot(h, avgdata, '.-');
  elseif nn==2
    plothandle2 = plot(h,avgdata,'.-');
  else
    plothandle3 = plot(h,avgdata,'.-');
  end
  xlabel(h,'Pulse #');
  ylabel(h,PV);
  % ylim(h,[0 .5]);
  grid(h);
end
while 1==1
  for nn=1:3
    if nn==1
      PV=PV1;h=h1;
    elseif nn==2
      PV=PV2;h=h2;
    else
      PV=PV3;h=h3;
    end
    bpmdata = lcaGet(strcat(PV,'HSTBR'));
    %     offset = find(abs(bpmdata(1:npts)) <0.05);
    if offset==1
      offset=25;
    elseif offset==24
      offset=48;
    end
    if nn==3
      offset=find(bpmdata(1:42)<.1);
    else
      offset = find(abs(bpmdata(1:24)) <0.00001);
    end
    bpmdata = circshift(bpmdata,[0 -offset]);
    for i=1:npts
      avgdata(i) = mean(bpmdata(i:npts:MAX));
    end
    if nn==1
      set(plothandle1, 'YData', avgdata);
    elseif nn==2
      set(plothandle2,'YData',avgdata);
    else
      set(plothandle3,'YData',avgdata);
      vv=axis;
      if nn==3
        ylim(h,[0 4])
      else
        ylim(h,[0 ceil(vv(4))])
      end
    end
    pcent=sum(avgdata)/max(avgdata*(npts-1));
    ylabel(h,sprintf('%s %8.1f%%',PV,pcent*100))
  end
  pause(0.25);
end
