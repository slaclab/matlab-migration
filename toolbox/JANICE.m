ESArate = lcaGetSmart('EVNT:SYS0:1:LCALKIKRATE'); %PM1 Kick rate, actually
if ESArate > 0
    npts=120/ESArate;
else
    disp('ESA beam has no rate, using 5 Hz for display');
    npts = 24;
end
%MAX=2800;
MAX=npts*10;
avgdata = zeros(1,npts);
%
% JANICE currently accomodates up to 7 PVs, you will need to expand the two
% sections below if you want more. Also, as written JANICE expects the first
% PV to be the gas detector, you have to do some stuff if you change that.
%
PVS{1,1} = 'GDET:FEE1:241:ENRC';
PVS{2,1} = 'BPMS:UND1:2290:X';
PVS{3,1} = 'BPMS:UND1:2290:Y';
PVS{4,1} = 'BPMS:UND1:3290:X';
PVS{5,1} = 'BPMS:UND1:3290:Y';
%
% To get consecutive UND BPMs...
%for ii = 1:3
% PVS{ii+1,1} = ['BPMS:UND1:', num2str(ii+2), '90:X'];
%end
%for ii = 1:3
% PVS{ii+4,1} = ['BPMS:UND1:', num2str(ii+2), '90:Y'];
%end
%
npvs = length(PVS);
H = zeros(1:npvs);
%setting up the monitor PVs
for ii = 1:npvs
   mPVS{ii,1} = ['SIOC:SYS0:ML01:AO',num2str(233+ii)]; %#ok
   m2PVS{ii,1} = ['SIOC:SYS0:ML01:AO',num2str(240+ii)]; %#ok
end
%include the name of the PV being monitored and which pulse
% n+1 is the pulse right after the PM1/2 kicked pulse, n+2
% is the next pulse
for ii = 1:npvs
    descpv = [mPVS{ii} '.DESC'];
    mdesc = PVS{ii};
%    mdesc = [ PVS{ii} ', n+1 pulse'];
    lcaPutSmart(descpv, mdesc);
    m2desc = [PVS{ii} ', n+2 pulse'];
    m2descpv = [m2PVS{ii} '.DESC'];
    lcaPutSmart(m2descpv, m2desc);
end
%initialize the Figure
figure;
for nn = 1:npvs
    subplot(npvs,1,nn)
    H(nn) = gca;
end
pvs=PVS;

% Initialize the updating data and plot the first set
bpmdata=lcaGet(pvs);
for nn=1:npvs
    if nn==1
        PV=PVS{1};h=H(1);
    elseif nn==2
        PV=PVS{2};h=H(2);
    elseif nn==3
        PV=PVS{3};h=H(3);
    elseif nn==4
        PV=PVS{4};h=H(4);
    elseif nn==5
        PV=PVS{5};h=H(5);
    elseif nn==6
        PV=PVS{6};h=H(6);
    elseif nn == 7
        PV=PVS{7};h=H(7);
    else
        PV =  PVS{npvs}; h = H(npvs);
    end
    bpmdata = lcaGet(strcat(PV,'HSTBR'));
    %   offset = find(abs(bpmdata(1:npts)) <0.01);
    if nn==1
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
    elseif nn==3
        plothandle3 = plot(h,avgdata,'.-');
    elseif nn==4
        plothandle4 = plot(h,avgdata,'.-');
    elseif nn==5
        plothandle5 = plot(h,avgdata,'.-');
    elseif nn==6
        plothandle6 = plot(h,avgdata,'.-');
    elseif nn == 7
        plothandle7 = plot(h,avgdata,'.-');
    else
        plothandle3000 = plot(h,avgdata,'*-');
    end
    xlabel(h,'Pulse #');
    ylabel(h,PV);
    % ylim(h,[0 .5]);
    grid(h);
end
%Now just keep shifting the BPM data buffer and plotting the averages
while 1==1
    for nn=1:npvs
        if nn==1
            PV=PVS{1};h=H(1);monPV=mPVS{1};monPV2=m2PVS{1};
        elseif nn==2
            PV=PVS{2};h=H(2);monPV=mPVS{2};monPV2=m2PVS{2};
        elseif nn==3
            PV=PVS{3};h=H(3);monPV=mPVS{3};monPV2=m2PVS{3};
        elseif nn==4
            PV=PVS{4};h=H(4);monPV=mPVS{4};monPV2=m2PVS{4};
        elseif nn==5
            PV=PVS{5};h=H(5);monPV=mPVS{5};monPV2=m2PVS{5};
        elseif nn==6
            PV=PVS{6};h=H(6);monPV=mPVS{6};monPV2=m2PVS{6};
        elseif nn == 7
            PV=PVS{7};h=H(7);monPV=mPVS{7};monPV2=m2PVS{7};
        else
            PV = PVS{npvs};h = H(npvs);monPV=mPVS{npvs};monPV2=m2PVS{npvs};
        end
        bpmdata = lcaGet(strcat(PV,'HSTBR'));
        %     offset = find(abs(bpmdata(1:npts)) <0.05);
        if offset==1
            offset=npts+1;
        elseif offset==npts
            offset=2*npts;
        end
        if nn==1
            offset=find(bpmdata(1:42)<.1);
        else
            offset = find(abs(bpmdata(1:npts)) <0.00001);
        end
        bpmdata = circshift(bpmdata,[0 -offset]);
        for i=1:npts
            avgdata(i) = mean(bpmdata(i:npts:MAX));
        end
            VALn1 = avgdata(1) - mean(avgdata(3:23));
            VALn2 = avgdata(2) - mean(avgdata(3:23));
        if nn==1
            set(plothandle1, 'YData', avgdata);
            VALn1 = (100*avgdata(1)/mean(avgdata(3:23)));
            VALn2 = (100*avgdata(2)/mean(avgdata(3:23)));
        elseif nn==2
            set(plothandle2,'YData',avgdata);
        elseif nn==3
            set(plothandle3,'YData',avgdata);
        elseif nn==4
            set(plothandle4,'YData',avgdata);
        elseif nn==5
            set(plothandle5,'YData',avgdata);
        elseif nn==6            
            set(plothandle6,'YData',avgdata)
        elseif nn == 7
            set(plothandle7,'YData',avgdata);
        else
            set(plothandle3000,'Ydata',avgdata);
            vv=axis;
            if nn==1
                ylim(h,[0 4])
            else
                ylim(h,[0 ceil(vv(4))])
            end
        end
        lcaPutSmart(monPV,VALn1,'double');
        lcaPutSmart(monPV2,VALn2,'double');
        pcent=sum(avgdata)/max(avgdata*(npts-1));
        ylabel(h,sprintf('%s %8.1f%%',PV,pcent*100))
    end
    pause(0.25);
end
