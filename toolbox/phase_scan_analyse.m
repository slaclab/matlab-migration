function [setok, dPhi, Xoff] = phase_scan_analyse(data, setok, refPhase, ...
    handles, order, tag, fignum, fitMode)

% Data analysis and plotting.

maximum_change = 10;
%erlim = 0.5;
erlim = Inf;

if order == 1 || ismember('BPMS:CLTS:570', data.bpmList)
  bpmX_pv = [data.bpmList{end} ':Y'];    % use Y BPM reading for TCAV or CLTS scan 
else
  bpmX_pv = [data.bpmList{end} ':X'];
end

etaX=data.etaX;E0=data.E0;initial_phase=data.phaseInit;name=data.name;
sgn = sign(etaX); % Sign of dispersion, positive sgn means upside down parabola

if ~setok, setok_msg='Scan aborted';end

dPhi = 0; % Default to no phase change

i = find(data.status);ph=data.phase(i);
bpm_xi=data.bpmX(i,:);dbpm_xi=data.bpmXStd(i,:);
%bpm_xi=bpm_xi-repmat(mean(bpm_xi),numel(i),1);

if numel(data.bpmList) > 1 && fitMode
    [orbit,orbitCov,orbitStd]=beamAnalysis_orbitFit([],data.r(1:2,[1:2 6],:),bpm_xi'*1e-3,dbpm_xi'*1e-3);
    eta=data.r(1,6,end)*1e3;
    bpm_xi=(orbit(end,:)-mean(orbit(end,:)))'*eta+mean(bpm_xi(:,end));dbpm_xi=orbitStd(end,:)'*abs(eta);
    figure(2);
    plot(ph,diag([1e6 1e6 1e4])*orbit);
    xlabel('\phi  (deg)');
    ylabel('x,x'',\delta  (\mum, \murad, 10^{-4})');
else
    bpm_xi=bpm_xi(:,end);dbpm_xi=dbpm_xi(:,end);
end

[Pp,d,dPp,ph1,ft1,yf,chisq] = beamAnalysis_phaseFit(ph,sgn*bpm_xi, ...
    dbpm_xi,'offset',order == 2,'n',1000);
Pp(end+1:3)=0;
ft  = sgn*(Pp(1)*cosd(ph - Pp(2)) + Pp(3));ft1=sgn*ft1;
amp=Pp(1);
Xoff = sgn*(Pp(3)+cosd(refPhase)*amp); % baseline offset (at dy/dx = 0)
z=util_phaseBranch(Pp(2)+refPhase,mean(ph));   % x at dy/dx = 0

if data.scanMode
    use=ft1 < min([ft;bpm_xi]) | ft1 > max([ft;bpm_xi]);
    ph1(use)=NaN;ft1(use)=NaN;
end

dphiset = sqrt(chisq)*dPp(2);                 % estimated error on optimum phase point (deg)
deltaPhi=util_phaseBranch(z-initial_phase,0); % Change in reference phase

er = sqrt(sum((ft - bpm_xi).^2))/sqrt(numel(ph));
disp(['fit error = ', num2str(er)]);
badFit=(er > erlim) | amp <= 0;

figure(fignum);
plot_bars(ph, bpm_xi, dbpm_xi, 'rd');
xlabel([name ' RF phase (deg)'])
ylabel([bpmX_pv ' (mm)'])
hold on
plot(ph1, ft1, 'b-');

ver_line(initial_phase,'k:')
txt = [datestr(data.ts) '; {\it\phi}(calc)=' sprintf('%5.2f',z) '+-' ...
       sprintf('%4.2f',dphiset) '\circ, {\it\phi}(set)=?'];
hold off
title(txt);
enhance_plot('times',14,2,5)

if badFit
    setok = 0;
    setok_msg = ['bad fit or upside-down: ' num2str(er) ' mm rms'];
elseif abs(deltaPhi) >= maximum_change
    disp([name ' phase change too large: ' num2str(deltaPhi)]);
    str = sprintf('Phase change is large (%5.1f deg).  Do you want to accept it?',deltaPhi);
    yn = questdlg(str,'LARGE PHASE CHANGE');
    if ~strcmp(yn,'Yes')
        setok = 0;       % no change (too big and not wanted)
        setok_msg = 'phase change too large';
    end
end

setPh=initial_phase;
if setok
    ver_line(z,'b--')
    if handles.nochanges                % if no changes allowed
        disp('"No changes" toggle is selected on GUI panel');
        text(scx(0.15),scy(0.75),'"No changes" toggle is set','Color','red');
    else
        setPh=z;
        dPhi = deltaPhi;
        disp(['changing phase to: ' num2str(setPh)]);
    end
else
    disp(setok_msg);
    text(scx(0.15),scy(0.75),['No correction applied: ' setok_msg],'Color','red');
end

txt = [txt(1:end-1) sprintf('%5.2f',setPh) '\circ'];
title(txt);
if ~isempty(tag)
    final_phase = str2double(get(handles.(['FINALPHASE_' tag]),'String'));
    text(scx(0.15),scy(0.85),sprintf('Final phase = %5.1f deg',final_phase));
end

if E0 % if not TCAV RF...
    gain=amp/abs(etaX)*E0;gainStd=dPp(1)/abs(etaX)*E0;
    str=sprintf('Energy gain: %6.2f +- %6.2f MeV',gain,sqrt(chisq)*gainStd);
    disp(str);
    text(scx(0.15),scy(0.65),str)
end
enhance_plot('times',14,2,5);
