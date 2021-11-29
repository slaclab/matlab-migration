%L1S_jit.m   displays the RF jitter of L1S phase and amplitude
%
pvbr={ 'ACCL:LI21:1:L1S_PHSTBR'
           'ACCL:LI21:1:L1S_AHSTBR'
           'BPMS:LI21:233:XHSTBR'
           'BPMS:LI24:801:XHSTBR'
           'BLEN:LI24:886:BIMAXHSTBR'} ;
       pvbr={ 'ACCL:LI21:1:L1S_PHSTF2'
           'ACCL:LI21:1:L1S_AHSTF2'     
           'BPMS:LI24:801:XHSTF2'
           'BPMS:LI21:233:XHSTF2'     %        'BLEN:LI24:886:BIMAXHSTF2'}
           'BLEN:LI21:265:AIMAXHSTF2'} ;
       pvbr={ 'ACCL:LI21:1:L1S_PHSTTH'
           'ACCL:LI21:1:L1S_AHSTTH'          
           'BPMS:LI21:233:XHSTTH'        %      
           'BPMS:LI24:801:XHSTTH'
           'BLEN:LI24:886:BIMAXHSTTH'    %       'BLEN:LI21:265:AIMAXHSTF2'}
           'KLYS:LI21:K1:VOLTHSTTH'
           'KLYS:LI21:K1:FWD_PHSTTH'
           'KLYS:LI21:K1:FWD_AHSTTH'}
          % 'KLYS:LI21:K3:L1S_2_SACT'
          % 'KLYS:LI21:K3:L1S_3_PA'
          % 'KLYS:LI21:K3:L1S_3_AA'}
i=200;    
if  ~exist('sl')
    sl    =zeros(1,200);  
    stdff =zeros(1,200);  
    stdff2=zeros(1,200);  
    stdff3=zeros(1,200);  
    stdff4=zeros(1,200);  
    stdff5=zeros(1,200);  
    ccf   =zeros(1,200);
    stdff6=zeros(1,200);  
    stdff7=zeros(1,200);  
    stdff8=zeros(1,200);  
end
maold =0.03*ones(1,10);

figure(1)
    subplot(3,1,1)
    ax1=gca;
    i10=1/10:1/10:i/10;
      h1m=plot(i10,stdff,'r',i10,stdff2,'b','Parent',ax1);drawnow;pause(0.1);
    plotfj
    ylabel(['L1S Ph, A RMS [deg, MeV]'])
    grid on
    legend('Phase','location','SouthWest','Amplitude')
    title('L1S Jitter and Its Effects')
   % ax1=gca;
    subplot(3,1,2)
    ax2=gca;
     h2m=plot(i10,stdff5,i10,sl,i10,ccf,'Parent',ax2);drawnow
     plotfj
xlabel(['Time [s]'])
ylabel(['cc-Ipk, slope A ph,cc A-ph'])
grid on
legend('cc Ipk-ph','location','SouthWest','Slope A-ph','cc A-ph')
  %  ax2=gca;
    subplot(3,1,3)
    ax3=gca;
    h3m=plot(i10,stdff3,'m',i10,stdff4,'r','Parent',ax3);drawnow;
      plotfj
xlabel(['Time [s]'])
ylabel(['BC2 x rms [mm], cc x_ph'])
grid on
legend('BC2 x rms','location','SouthWest','cc x-ph')
 %    ax3=gca;
 
%figure(2)
% ax2=gca;
%h1m_2=plot(i10,stdff7,'r',i10,stdff6,'b','Parent',ax1);drawnow;pause(0.0);
  plotfj
    ylabel(['FWD Ph, V RMS [deg, E-3]'])
    grid on
    legend('FWD Phase','location','SouthWest','KLYS HV')
    title('L1S Jitter and Its Voltage Effects')
    iiw=0;
while iiw<=200
    iiw=iiw+1;
    i10=1/10:1/10:i/10; %pause(.1)
    ff0=lcaGet(pvbr,200);
    ffd=lcaGet(pvbr,2800);
    ff=ffd(:,2701:2800);
    
    stdff2n=std(ff(2,:));stdffn=std(ff(1,:));      stdff=[stdff(2:200) stdffn];  stdff2=[stdff2(2:200) stdff2n];
      stdff6n=std(ff(6,:))./mean(ff(6,:))*1000; stdff7n=std(ff(7,:));      stdff6=[stdff6(2:200) stdff6n];  stdff7=[stdff7(2:200) stdff7n];
    stdff3n=std(ff(3,:));stdff3=[stdff3(2:200) stdff3n];      % 4
    dd=corrcoef(ff(1,:),ff(3,:));stdff4n=dd(1,2);stdff4=[stdff4(2:200) stdff4n];
    %stdff5(i)=std(ff(5,:));
    dd=corrcoef(ff(1,:),ff(5,:));stdff5n=dd(1,2);stdff5=[stdff5(2:200) stdff5n];
    %figure(1)
  %  subplot(3,1,1)
               %plot(i10,ff0(1,:)+21.8,i10,ff0(2,:)-145);  %stdff2);
    %h1m=plot(i10,stdff,i10,stdff2,'Parent',ax1);drawnow;pause(0.0);
  %  figure(1)
    set(h1m(1),'YData',stdff)
    set(h1m(2),'YData',stdff2)
   % figure(2)
   % set(h1m_2(1),'YData',stdff7)
   % set(h1m_2(2),'YData',stdff6)
    %plotfj
                                      %xlabel(['Time [s]'])
 %   ylabel(['L1S Ph, A RMS [deg, MeV]'])
 %   grid on


  [p0, yf, p0std] = util_polyFit(ff(6,:),ff(4,:),1);   % 1 2 now 4 6 Volt BPM
  p0=p0*1000;
  cc=corrcoef(ff(2,:),ff(1,:));
  sln=p0(1);   %/(cc(1,2)); 
  slold = sl;
  sl=[slold(2:200) sln];
  ccfold=ccf;
  ccf=[ccfold(2:200) cc(1,2)];
%subplot(3,1,2)
    % plot(i10,ff0(3,:),i10,ff0(4,:),i10,stdff4,i10,stdff5,i10,sl);
   % h2m=plot(i10,stdff3,i10,stdff4,i10,stdff5,i10,sl,'Parent',ax2);drawnow
  %  set(h2m(1),'YData',stdff3)
  %  set(h2m(2),'YData',stdff4); pause(0.1)

   set(h2m(1),'YData',stdff5);
   set(h2m(2),'YData',sl); %pause(0.1)
   set(h2m(3),'YData',ccf); 
    %plotfj
%xlabel(['Time [s]'])
%ylabel(['BC2 x, cc-x, cc-Ipk, slope A ph'])
%grid on
 
pause(0.6)



ffy=ff;
ffy(5,:)=ff(5,:)./1000;
ffy(4,:)=ff(4,:)./5;
ffg=fft(ffy'-ones(100,1)*mean(ffy'));
%subplot(3,1,3)
%figure(2)
cs=cumsum(abs(ffg(:,1:2)).^2) ;
%plot(0:60/99:60,(cs(100:-1:1,:)-ones(100,1)*max(cs)/2)*2/100/100)
%xlabel(['Frequency [Hz]']) 
%ylabel(['Integrated Power in Ph [deg^2]'])
%title(['Integrated Noise at ' char(pvbr(1)) ])
%plotfj
%grid on

subplot(3,1,3)
% h3m=plot(i10,stdff3,'Parent',ax3);drawnow;
  set(h3m(1),'YData',stdff7)     %stdff3)
  set(h3m(2),'YData',stdff6)     %stdff4)
%    plotfj
%xlabel(['Time [s]'])
%ylabel(['BC1 x rms, cc-x'])
%grid on

man=(max((cs(100:-1:1,:)-ones(100,1)*max(cs)/2)*2/100/100));
mas=[0.01 maold max(man)];
maold=mas(3:12);
ma=max(mas);
%axis([0 ceil(60/2) 0 ma]);   %*1.1]);    %f(N)
jit=sqrt(man);
aa=axis;
%text(0.2,aa(4)*0.90, ['rms = ', sprintf('%4.3f',jit(1)), ' deg '], 'FontSize',12)
%text(0.2,aa(4)*0.80, ['rms = ', sprintf('%4.3f',jit(2)), ' MeV' ], 'FontSize',12)
%if stdff4(190)>=0;return,end
end
