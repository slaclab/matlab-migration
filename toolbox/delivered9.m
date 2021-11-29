while 1
system('TNS_ADMIN=$TOOLS/oracle/wallets/mcc_avail && python $TOOLS/matlab/toolbox/python2EPICS.py'); %sets path and runs python file which queries APEX


bpmdmp = lcaGet('BPMS:DMP1:398:TMIT'); %BPMS dump
reprate = lcaGet('SIOC:SYS0:ML00:AO467');%machine rep rate
bykik = lcaGet('IOC:BSY0:MP01:REQBYKIKBRST',0,'double');%BYKIK
bpmltu = lcaGet('BPMS:LTU0:110:TMIT1H');%BPMS LTU
amo_stop = char(lcaGet('PPS:NEH1:1:S1INSUM')); %amo stopper
sxr_stop = char(lcaGet('PPS:NEH1:1:S2INSUM')); %sxr stopper
xpp_stop = char(lcaGet('PPS:NEH1:1:S3INSUM')); %xpp stopper
xcs_stop = char(lcaGet('PPS:FEH1:4:S4STPRSUM')); %xcs stopper
cxi_stop = char(lcaGet('PPS:FEH1:5:S5STPRSUM')); %cxi stopper
mec_stop = char(lcaGet('PPS:FEH1:6:S6STPRSUM')); %mec stopper
light=1;

hutchday='';
hutch2day='';
hutch3day='';
hutch4day='';
hutchnight='';
hutch2night='';
hutch3night='';
hutch4night='';
hutchstopday='';
hutchstopnight='';
shift='';

%Calculation---> BPMS:LTU0:110:TMIT1H>100000000||(IOC:BSY0:MP01:REQBYKIKBRST=1&BPMS:LTU0:110:TMIT1H>100000000)?1:0

if (bpmdmp > 1e8) || (bykik==1 && bpmltu>1e8)
    light = 1
else
    light = 0
end
lcaPut('SIOC:SYS0:ML03:AO065',light); %electrons available to produce light pv


%*****need something here that addresses klystron cycling and MPS faults
%*****need to accomodate for case with more than one hutch on shift

time=rem(now,1); %gets current time


%startdate1=lcaGet('SIOC:SYS0:ML03:AO001'); %pv for startdate1
%startdate = datenum(datestr(startdate1/86400 + datenum(1970,1,1)))
%startdate = datenum(startdate1);
enddate1=lcaGet('SIOC:SYS0:ML03:AO002'); %pv for enddate1
enddate = datenum(datestr(enddate1/86400 + datenum(1970,1,1))); %converts UNIX timestamp from Python to Matlab timestamp
if enddate+1 >= now; %current date
   shift1 = char(lower(lcaGet ('SIOC:SYS0:ML03:AO003.DESC'))); %selects whiteboard records that are most recent
else
    shift1=0;
end
switch shift1
    case 'day'
        hutchday = upper(char(lcaGet('SIOC:SYS0:ML03:AO004.DESC')));
        %hutchday = hutchday(1:3)
        
               strxenday1 = lcaGet('SIOC:SYS0:ML03:AO005.DESC'); %requested x-ray energy
               strxenday =str2num(char(regexp(char(strxenday1),'[\d\.]+','match')));%extracts only the number from string
                if strxenday <200
                    xenday = strxenday*1000; %if number is <200, multiply by 1000
                else
                    xenday = strxenday;
                end
                xhighday = upper(char(lcaGet('SIOC:SYS0:ML03:AO006.DESC')));%x-ray energy high priority?
                blday = lower(char(lcaGet('SIOC:SYS0:ML03:AO007.DESC')));%requested bunch length
                
                if strncmp(blday, 'nom',3) % looks for 'nominal' and 'nom' in request
                    if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                       blday = 400; %if in soft x-ray regime, sets requested bunch length to 400 fs
                    end
                    if lcaGet('SIOC:SYS0:ML00:AO627')>750
                        blday = 250;%if in hard x-ray regime, sets requested bunch length to 250 fs
                    end
                else
                    strblday1 = lcaGet('SIOC:SYS0:ML03:AO007.DESC'); 
                    blday = str2num(char(regexp(char(strblday1),'[\d\.]+','match')));%if requested bunch length is in number format, extracts only the number from string
                end
               
                blhighday = upper(char(lcaGet('SIOC:SYS0:ML03:AO008.DESC')));%bunch length high priority?
                mFELday = lower(char(lcaGet('SIOC:SYS0:ML03:AO009.DESC')));%requested minimum FEL
                
                if strcmp( mFELday,'max')%looks for 'max' in request
                 if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                    mFELday = .5; %if in soft x-ray regime, sets requested minimum FEL to .5 mJ
                 end
                 if lcaGet('SIOC:SYS0:ML00:AO627')>750
                    mFELday = 3.5; %if in hard x-ray regime, sets requested minimum FEL to 3.5 mJ
                 end
                else
                    mFELday=str2num(mFELday);
                end
                 
                mFELhighday = upper(char(lcaGet('SIOC:SYS0:ML03:AO010.DESC'))); %minimum FEL high priority?
                chrgday = char(lcaGet('SIOC:SYS0:ML03:AO011.DESC')); % requested charge
                chrghighday = upper(char(lcaGet('SIOC:SYS0:ML03:AO012.DESC'))); %charge high priority?
                bwday = lower(char(lcaGet('SIOC:SYS0:ML03:AO013.DESC'))); % requested bandwidth
                
                if ismember( bwday, {'nominal' 'nom' 'sase' 'narrow' 'seed'}) %checks for strings
                  bwday = 1; %sets requested bandwidth to 1 (for now)
                end
                
                bwhighday = upper(char(lcaGet('SIOC:SYS0:ML03:AO014.DESC'))); %bandwidth high priority?
                pulseday = char(lcaGet('SIOC:SYS0:ML03:AO015.DESC')); %requested pulse rate
                pulsehighday = upper(char(lcaGet('SIOC:SYS0:ML03:AO016.DESC'))); %pulse rate high priority?
                
          switch hutchday %determines which stopper to look at
            
              case 'AMO'
                  hutchstopday = amo_stop;
              case 'SXR'
                  hutchstopday = sxr_stop;
              case 'XPP'
                  hutchstopday = xpp_stop;
              case 'XCS'
                  hutchstopday = xcs_stop;
              case 'CXI'
                  hutchstopday = cxi_stop;
              case 'MEC'
                  hutchstopday = mec_stop;
              case 'CXI XPP'
                  hutchstopday = xpp_stop;
              case 'XPP CXI'
                  hutchstopday = xpp_stop;
              case 'MEC XPP'
                  hutchstopday = xpp_stop;
              case 'XPP MEC'
                  hutchstopday = xpp_stop;
              case 'XCS XPP'
                  hutchstopday = xpp_stop;
              case 'XPP XCS'
                  hutchstopday = xpp_stop;
                  
                 
          end
        hutchday = hutchday(1:3)
                
    case 'night'
        hutchnight = upper(char(lcaGet('SIOC:SYS0:ML03:AO004.DESC')));
        %hutchnight = hutchnight(1:3);
        
               strxennight1 = lcaGet('SIOC:SYS0:ML03:AO005.DESC'); 
               strxennight =str2num(char(regexp(char(strxennight1),'[\d\.]+','match')));
                if strxennight <200
                    xennight = strxennight*1000; %if number is <200, multiply by 1000
                else
                    xennight = strxennight;
                end
       
                xhighnight = upper(char(lcaGet('SIOC:SYS0:ML03:AO006.DESC')));
                blnight = lower(char(lcaGet('SIOC:SYS0:ML03:AO007.DESC')));
                
                 if strncmp(blnight, 'nom',3)
                    if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                        blnight = 400;
                    end
                    if lcaGet('SIOC:SYS0:ML00:AO627')>750
                        blnight = 250;
                    end
                else
                    strblnight1 = lcaGet('SIOC:SYS0:ML03:AO007.DESC'); 
                    blnight = str2num(char(regexp(char(strblnight1),'[\d\.]+','match')));
                end
                
                blhighnight = upper(char(lcaGet('SIOC:SYS0:ML03:AO008.DESC')));
                mFELnight = lower(char(lcaGet('SIOC:SYS0:ML03:AO009.DESC')));
                
                if strcmp( mFELnight,'max')
                 if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                    mFELnight = .5;
                 end
                 if lcaGet('SIOC:SYS0:ML00:AO627')>750
                    mFELnight = 3.5;
                 end
                else
                    mFELnight=str2num(mFELnight);
                end
                
                mFELhighnight = upper(char(lcaGet('SIOC:SYS0:ML03:AO010.DESC')));
                chrgnight = char(lcaGet('SIOC:SYS0:ML03:AO011.DESC'));
                chrghighnight = upper(char(lcaGet('SIOC:SYS0:ML03:AO012.DESC')));
                bwnight = lower(char(lcaGet('SIOC:SYS0:ML03:AO013.DESC')));
                
                if ismember( bwnight, {'nominal' 'nom' 'sase' 'narrow' 'seed'})
                  bwnight = 1;
                end
                
                bwhighnight = upper(char(lcaGet('SIOC:SYS0:ML03:AO014.DESC')));
                pulsenight = char(lcaGet('SIOC:SYS0:ML03:AO015.DESC'));
                pulsehighnight = upper(char(lcaGet('SIOC:SYS0:ML03:AO016.DESC')));

     
        switch hutchnight
            
            case 'AMO'
                hutchstopnight = amo_stop;
            case 'SXR'
                hutchstopnight = sxr_stop;
            case 'XPP'
                hutchstopnight = xpp_stop;
            case 'XCS'
                hutchstopnight = xcs_stop;
            case 'CXI'
                hutchstopnight = cxi_stop;
            case 'MEC'
                hutchstopnight = mec_stop;
            case 'CXI XPP'
                hutchstopnight = xpp_stop;
            case 'XPP CXI'
                hutchstopnight = xpp_stop;
            case 'MEC XPP'
                hutchstopnight = xpp_stop;
            case 'XPP MEC'
                hutchstopnight = xpp_stop;
            case 'XCS XPP'
                hutchstopnight = xpp_stop;
            case 'XPP XCS'
                hutchstopnight = xpp_stop;   
        end
        hutchnight = hutchnight(1:3)
end

enddate2=lcaGet('SIOC:SYS0:ML03:AO018'); %pv for enddate2
enddate22 = datenum(datestr(enddate2/86400 + datenum(1970,1,1)));
if enddate22+1 >= now; %current date
   shift2 = char(lower(lcaGet ('SIOC:SYS0:ML03:AO019.DESC')));
else
    shift2=0;
end
switch shift2
    case 'day'
        hutch2day = upper(char(lcaGet('SIOC:SYS0:ML03:AO020.DESC')))
        %hutch2day = hutch2day(1:3)
        
                strxenday22 = lcaGet('SIOC:SYS0:ML03:AO021.DESC'); 
                strxenday2 =str2num(char(regexp(char(strxenday22),'[\d\.]+','match')));
                if strxenday2 <200
                    xenday2 = strxenday2*1000; %if number is <200, multiply by 1000
                else
                    xenday2 = strxenday2;
                end
               
                xhighday2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO022.DESC')))
                blday2 = lower(char(lcaGet('SIOC:SYS0:ML03:AO023.DESC')));
                
                 if strncmp(blday2, 'nom',3)
                    if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                        blday2 = 400;
                    end
                    if lcaGet('SIOC:SYS0:ML00:AO627')>750
                        blday2 = 250;
                    end
                else
                    strblday2 = lcaGet('SIOC:SYS0:ML03:AO023.DESC'); 
                    blday2 = str2num(char(regexp(char(strblday2),'[\d\.]+','match')));
                end
               
                blhighday2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO024.DESC')));
                mFELday2 = lower(char(lcaGet('SIOC:SYS0:ML03:AO025.DESC')));
                
                if strcmp( mFELday2,'max')
                  if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                    mFELday2 = .5;
                 
                  end
                  if lcaGet('SIOC:SYS0:ML00:AO627')>750
                    mFELday2 = 3.5;
                  end
                else
                    mFELday2=str2num(mFELday2);
                end
                
                 
                mFELhighday2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO026.DESC')));
                chrgday2 = char(lcaGet('SIOC:SYS0:ML03:AO027.DESC'));
                chrghighday2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO028.DESC')));
                bwday2 = lower(char(lcaGet('SIOC:SYS0:ML03:AO029.DESC')));
                
                if ismember( bwday2, {'nominal' 'nom' 'sase' 'narrow' 'seed'})
                  bwday2 = 1;
                end
                
                bwhighday2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO030.DESC')));
                pulseday2 = char(lcaGet('SIOC:SYS0:ML03:AO031.DESC'));
                pulsehighday2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO032.DESC')));
                
         switch hutch2day
            
            case 'AMO'
                hutchstopday = amo_stop;
            case 'SXR'
                hutchstopday = sxr_stop;
            case 'XPP'
                hutchstopday = xpp_stop;
            case 'XCS'
                hutchstopday = xcs_stop;
            case 'CXI'
                hutchstopday = cxi_stop;
            case 'MEC'
                hutchstopday = mec_stop;
            case 'CXI XPP'
                hutchstopday = xpp_stop;
            case 'XPP CXI'
                hutchstopday = xpp_stop;
            case 'MEC XPP'
                hutchstopday = xpp_stop;
            case 'XPP MEC'
                hutchstopday = xpp_stop;
            case 'XCS XPP'
                hutchstopday = xpp_stop;
            case 'XPP XCS'
                hutchstopday = xpp_stop;
         end
         hutch2day = hutch2day(1:3)
                
    case 'night'
        hutch2night = upper(char(lcaGet('SIOC:SYS0:ML03:AO020.DESC')));
        %hutch2night = hutch2night(1:3);
        
               strxennight22 = lcaGet('SIOC:SYS0:ML03:AO021.DESC'); 
               strxennight2 =str2num(char(regexp(char(strxennight22),'[\d\.]+','match')));
                if strxennight2 <200
                    xennight2 = strxennight2*1000; %if number is <200, multiply by 1000
                else
                    xennight2 = strxennight2;
                end
       
                xhighnight2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO022.DESC')));
                blnight2 = lower(char(lcaGet('SIOC:SYS0:ML03:AO023.DESC')));
                
                 if strncmp(blnight2, 'nom',3)
                    if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                        blnight2 = 400;
                    end
                    if lcaGet('SIOC:SYS0:ML00:AO627')>750
                        blnight2 = 250;
                    end
                else
                    strblnight2 = lcaGet('SIOC:SYS0:ML03:AO023.DESC'); 
                    blnight2 = str2num(char(regexp(char(strblnight2),'[\d\.]+','match')));
                end
                
                blhighnight2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO024.DESC')));
                mFELnight2 = lower(char(lcaGet('SIOC:SYS0:ML03:AO025.DESC')));
                
                if strcmp( mFELnight2,'max')
                 if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                    mFELnight2 = .5;
                 end
                 if lcaGet('SIOC:SYS0:ML00:AO627')>750
                    mFELnight2 = 3.5;
                 end
                else 
                    mFELnight2=str2num(mFELnight2);
                end
                
                mFELhighnight2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO026.DESC')));
                chrgnight2 = char(lcaGet('SIOC:SYS0:ML03:AO027.DESC'));
                chrghighnight2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO028.DESC')));
                bwnight2 = lower(char(lcaGet('SIOC:SYS0:ML03:AO029.DESC')));
                
                if ismember( bwnight2, {'nominal' 'nom' 'sase' 'narrow' 'seed'})
                  bwbight2 = 1;
                end
                
                bwhighnight2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO030.DESC')));
                pulsenight2 = char(lcaGet('SIOC:SYS0:ML03:AO031.DESC'));
                pulsehighnight2 = upper(char(lcaGet('SIOC:SYS0:ML03:AO032.DESC')));
       
        switch hutch2night
            
            case 'AMO'
                hutchstopnight = amo_stop;
            case 'SXR'
                hutchstopnight = sxr_stop; 
            case 'XPP'
                hutchstopnight = xpp_stop;
            case 'XCS'
                hutchstopnight = xcs_stop;
            case 'CXI'
                hutchstopnight = cxi_stop;
            case 'MEC'
                hutchstopnight = mec_stop;
            case 'CXI XPP'
                hutchstopnight = xpp_stop;
            case 'XPP CXI'
                hutchstopnight = xpp_stop;
            case 'MEC XPP'
                hutchstopnight = xpp_stop;
            case 'XPP MEC'
                hutchstopnight = xpp_stop;
            case 'XCS XPP'
                hutchstopnight = xpp_stop;
            case 'XPP XCS'
                hutchstopnight = xpp_stop;   

        end
        hutch2night = hutch2night(1:3);
end

enddate3=lcaGet('SIOC:SYS0:ML03:AO034'); %pv for enddate3
enddate33 = datenum(datestr(enddate3/86400 + datenum(1970,1,1)));

if enddate33+1 >= now; %current date
   shift3 = char(lower(lcaGet ('SIOC:SYS0:ML03:AO035.DESC')));
else 
    shift3 = 0;
end

switch shift3
    case 'day'
        hutch3day = upper(char(lcaGet('SIOC:SYS0:ML03:AO036.DESC')));
        %hutch3day = hutch3day(1:3);
        
               strxenday33 = lcaGet('SIOC:SYS0:ML03:AO037.DESC');
               strxenday3 =str2num(char(regexp(char(strxenday33),'[\d\.]+','match')));
                if strxenday3 <200
                    xenday3 = strxenday3*1000; %if number is <200, multiply by 1000
                else
                    xenday3 = strxenday3;
                end
        
                xhighday3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO038.DESC')));
                blday3 = lower(char(lcaGet('SIOC:SYS0:ML03:AO039.DESC')));
               
                 if strncmp(blday3, 'nom',3)
                    if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                        blday3 = 400;
                    end
                    if lcaGet('SIOC:SYS0:ML00:AO627')>750
                        blday3 = 250;
                    end
                else
                    strblday3 = lcaGet('SIOC:SYS0:ML03:AO039.DESC'); 
                    blday3 = str2num(char(regexp(char(strblday3),'[\d\.]+','match')));
                end
                
                blhighday3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO040.DESC')));
                mFELday3 = lower(char(lcaGet('SIOC:SYS0:ML03:AO041.DESC')));
                
                if strcmp( mFELday3,'max')
                 if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                    mFELday3 = .5;
                 end
                 if lcaGet('SIOC:SYS0:ML00:AO627')>750
                    mFELday3 = 3.5;
                 end
                else
                    mFELday3=str2num(mFELday3);
                end
                
                mFELhighday3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO042.DESC')));
                chrgday3 = char(lcaGet('SIOC:SYS0:ML03:AO043.DESC'));
                chrghighday3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO044.DESC')));
                bwday3 = lower(char(lcaGet('SIOC:SYS0:ML03:AO045.DESC')));
                
                if ismember( bwday3, {'nominal' 'nom' 'sase' 'narrow' 'seed'})
                  bwday3 = 1;
                end
                
                bwhighday3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO046.DESC')));
                pulseday3 = char(lcaGet('SIOC:SYS0:ML03:AO047.DESC'));
                pulsehighday3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO048.DESC')));
                
         switch hutch3day
            
            case 'AMO'
                hutchstopday = amo_stop;
            case 'SXR'
                hutchstopday = sxr_stop;
            case 'XPP'
                hutchstopday = xpp_stop;
            case 'XCS'
                hutchstopday = xcs_stop;
            case 'CXI'
                hutchstopday = cxi_stop;
            case 'MEC'
                hutchstopday = mec_stop;
            case 'CXI XPP'
                hutchstopday = xpp_stop;
            case 'XPP CXI'
                hutchstopday = xpp_stop;
            case 'MEC XPP'
                hutchstopday = xpp_stop;
            case 'XPP MEC'
                hutchstopday = xpp_stop;
            case 'XCS XPP'
                hutchstopday = xpp_stop;
            case 'XPP XCS'
                hutchstopday = xpp_stop;
         end
         hutch3day = hutch3day(1:3);
                
    case 'night'
        hutch3night = upper(char(lcaGet('SIOC:SYS0:ML03:AO036.DESC')));
        %hutch3night = hutch3night(1:3);
        
               strxennight33 = lcaGet('SIOC:SYS0:ML03:AO037.DESC'); 
               strxennight3 =str2num(char(regexp(char(strxennight33),'[\d\.]+','match')));
                if strxennight3 <200
                    xennight3 = strxennight3*1000; %if number is <200, multiply by 1000
                else
                    xennight3 = strxennight3;
                end
       
               
                xhighnight3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO038.DESC')));
                blnight3 = lower(char(lcaGet('SIOC:SYS0:ML03:AO039.DESC')));
                
                if strncmp(blnight3, 'nom',3)
                    if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                        blnight3 = 400;
                    end
                    if lcaGet('SIOC:SYS0:ML00:AO627')>750
                        blnight3 = 250;
                    end
                else
                    strblnight3 = lcaGet('SIOC:SYS0:ML03:AO039.DESC'); 
                    blnight3 = str2num(char(regexp(char(strblnight3),'[\d\.]+','match')));
                end
                
                
                blhighnight3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO040.DESC')));
                mFELnight3 = lower(char(lcaGet('SIOC:SYS0:ML03:AO041.DESC')));
                
                if strcmp( mFELnight3,'max')
                 if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                    mFELnight3 = .5;
                 end
                 if lcaGet('SIOC:SYS0:ML00:AO627')>750
                    mFELnight3 = 3.5;
                 end
                else
                    mFELnight3=str2num(mFELnight3);
                end
                
                mFELhighnight3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO042.DESC')));
                chrgnight3 = char(lcaGet('SIOC:SYS0:ML03:AO043.DESC'));
                chrghighnight3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO044.DESC')));
                bwnight3 = lower(char(lcaGet('SIOC:SYS0:ML03:AO045.DESC')));
                
                if ismember( bwnight3, {'nominal' 'nom' 'sase' 'narrow' 'seed'})
                  bwnight3 = 1;
                end
                
                bwhighnight3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO046.DESC')));
                pulsenight3 = char(lcaGet('SIOC:SYS0:ML03:AO047.DESC'));
                pulsehighnight3 = upper(char(lcaGet('SIOC:SYS0:ML03:AO048.DESC')));
        
        
        switch hutch3night
            
            case 'AMO'
                hutchstopnight = amo_stop;
            case 'SXR'
                hutchstopnight = sxr_stop;
            case 'XPP'
                hutchstopnight = xpp_stop;
            case 'XCS'
                hutchstopnight = xcs_stop;
            case 'CXI'
                hutchstopnight = cxi_stop;
            case 'MEC'
                hutchstopnight = mec_stop;
            case 'CXI XPP'
                hutchstopnight = xpp_stop;
            case 'XPP CXI'
                hutchstopnight = xpp_stop;
            case 'MEC XPP'
                hutchstopnight = xpp_stop;
            case 'XPP MEC'
                hutchstopnight = xpp_stop;
            case 'XCS XPP'
                hutchstopnight = xpp_stop;
            case 'XPP XCS'
                hutchstopnight = xpp_stop;   

        end
        hutch3night = hutch3night(1:3);
end

enddate4=lcaGet('SIOC:SYS0:ML03:AO050'); %pv for enddate4
enddate44 = datenum(datestr(enddate4/86400 + datenum(1970,1,1)));

if enddate44+1 >= now; %current date
   shift4 = char(lower(lcaGet ('SIOC:SYS0:ML03:AO051.DESC')));
else
    shift4=0;
end

switch shift4
    case 'day'
        hutch4day = upper(char(lcaGet('SIOC:SYS0:ML03:AO052.DESC')));
        %hutch4day = hutch4day(1:3);
        
               strxenday44 = lcaGet('SIOC:SYS0:ML03:AO053.DESC'); 
               strxenday4 =str2num(char(regexp(char(strxenday44),'[\d\.]+','match')));
                if strxenday4 <200
                    xenday4 = strxenday4*1000; %if number is <200, multiply by 1000
                else
                    xenday4 = strxenday4;
                end
                
                xhighday4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO054.DESC')));
                blday4 = lower(char(lcaGet('SIOC:SYS0:ML03:AO055.DESC')));
               
                 if strncmp(blday4, 'nom',3)
                    if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                        blday4 = 400;
                    end
                    if lcaGet('SIOC:SYS0:ML00:AO627')>750
                        blday4 = 250;
                    end
                else
                    strblday4 = lcaGet('SIOC:SYS0:ML03:AO055.DESC'); 
                    blday4 = str2num(char(regexp(char(strblday4),'[\d\.]+','match')));
                end
                
                blhighday4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO056.DESC')));
                mFELday4 = lower(char(lcaGet('SIOC:SYS0:ML03:AO057.DESC')));
                
                if strcmp( mFELday4,'max')
                 if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                    mFELday4 = .5;
                 end
                 if lcaGet('SIOC:SYS0:ML00:AO627')>750
                    mFELday4 = 3.5;
                 end
                else
                    mFELday4=str2num(mFELday4);
                end
                
                mFELhighday4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO058.DESC')));
                chrgday4 = char(lcaGet('SIOC:SYS0:ML03:AO059.DESC'));
                chrghighday4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO060.DESC')));
                bwday4 = lower(char(lcaGet('SIOC:SYS0:ML03:AO061.DESC')));
                
                if ismember( bwday4, {'nominal' 'nom' 'sase' 'narrow' 'seed'})
                  bwday4 = 1;
                end
                
                bwhighday4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO062.DESC')));
                pulseday4 = char(lcaGet('SIOC:SYS0:ML03:AO063.DESC'));
                pulsehighday4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO064.DESC')));
                
        switch hutch4day
            
            case 'AMO'
                hutchstopday = amo_stop;
            case 'SXR'
                hutchstopday = sxr_stop;
            case 'XPP'
                hutchstopday = xpp_stop;
            case 'XCS'
                hutchstopday = xcs_stop;
            case 'CXI'
                hutchstopday = cxi_stop;
            case 'MEC'
                hutchstopday = mec_stop;
            case 'CXI XPP'
                hutchstopday = xpp_stop;
            case 'XPP CXI'
                hutchstopday = xpp_stop;
            case 'MEC XPP'
                hutchstopday = xpp_stop;
            case 'XPP MEC'
                hutchstopday = xpp_stop;
            case 'XCS XPP'
                hutchstopday = xpp_stop;
            case 'XPP XCS'
                hutchstopday = xpp_stop;

        end
        hutch4day = hutch4day(1:3);
                
    case 'night'
        hutch4night = upper(char(lcaGet('SIOC:SYS0:ML03:AO052.DESC')));
        %hutch4night = hutch4night(1:3);
                
               strxennight44 = lcaGet('SIOC:SYS0:ML03:AO053.DESC'); 
               strxennight4 =str2num(char(regexp(char(strxennight44),'[\d\.]+','match')));
                if strxennight4 <200
                    xennight4 = strxennight4*1000; %if number is <200, multiply by 1000
                else
                    xennight4 = strxennight4;
                end
               
                xhighnight4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO054.DESC')));
                blnight4 = lower(char(lcaGet('SIOC:SYS0:ML03:AO055.DESC')));
              
                 if strncmp(blnight4, 'nom',3)
                    if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                        blnight4 = 400;
                    end
                    if lcaGet('SIOC:SYS0:ML00:AO627')>750
                        blnight4 = 250;
                    end
                else
                    strblnight4 = lcaGet('SIOC:SYS0:ML03:AO055.DESC'); 
                    blnight4 = str2num(char(regexp(char(strblnight4),'[\d\.]+','match')));
                end
                
                blhighnight4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO056.DESC')));
                mFELnight4 = lower(char(lcaGet('SIOC:SYS0:ML03:AO057.DESC')));
                
                if strcmp( mFELday2,'max')
                 if lcaGet('SIOC:SYS0:ML00:AO627')>0 && lcaGet('SIOC:SYS0:ML00:AO627')<750
                    mFELnight4 = .5;
                 end
                 if lcaGet('SIOC:SYS0:ML00:AO627')>750
                    mFELnight4 = 3.5;
                 end
                else
                    mFELnight4=str2num(mFELnight4);
                end
                
                mFELhighnight4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO058.DESC')));
                chrgnight4 = char(lcaGet('SIOC:SYS0:ML03:AO059.DESC'));
                chrghighnight4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO060.DESC')));
                bwnight4 = lower(char(lcaGet('SIOC:SYS0:ML03:AO061.DESC')));
               
                if ismember( bwnight4, {'nominal' 'nom' 'sase' 'narrow' 'seed'})
                  bwnight4 = 1;
                end
                
                bwhighnight4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO062.DESC')));
                pulsenight4 = char(lcaGet('SIOC:SYS0:ML03:AO063.DESC'));
                pulsehighnight4 = upper(char(lcaGet('SIOC:SYS0:ML03:AO064.DESC')));
      
        switch hutch4night
            
            case 'AMO'
                hutchstopnight = amo_stop;
            case 'SXR'
                hutchstopnight = sxr_stop; 
            case 'XPP'
                hutchstopnight = xpp_stop;
            case 'XCS'
                hutchstopnight = xcs_stop;
            case 'CXI'
                hutchstopnight = cxi_stop;
            case 'MEC'
                hutchstopnight = mec_stop;
            case 'CXI XPP'
                hutchstopnight = xpp_stop;
            case 'XPP CXI'
                hutchstopnight = xpp_stop;
            case 'MEC XPP'
                hutchstopnight = xpp_stop;
            case 'XPP MEC'
                hutchstopnight = xpp_stop;
            case 'XCS XPP'
                hutchstopnight = xpp_stop;
            case 'XPP XCS'
                hutchstopnight = xpp_stop; 
        end
        hutch4night = hutch4night(1:3);
end

if time > rem(datenum('8:59'),1) && time < rem(datenum('23:59'),1) && ismember(hutchstopday,{'OUT' 'NOT_IN'}) && strcmp(hutchstopnight,'IN');
    shift = 'day' %determines current shift based on stopper status and time of day
end

if time > rem(datenum('20:59'),1) && time < rem(datenum('12:00'),1) && ismember(hutchstopnight,{'OUT' 'NOT_IN'}) && strcmp(hutchstopday,'IN');
    shift = 'night' %determines current shift based on stopper status and time of day
end

switch shift
    case 'day'
        
    switch hutchday
        case 'AMO'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); % xray energy
         
             if strcmp(xhighday, 'Y')
         
                if xenergy < xenday*.85 %compares current xray energy with 85% of requested 
                    light =0;
                end
             end
           
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); % bunch length
         
            if strcmp(blhighday, 'Y')
         
                if blength*.95 > blday
                    light =0;
                end
            end
        
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday, 'Y')
         
                if minFEL < mFELday*.85
                    light =0;
                end
            
            end
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge 
         
            if strcmp(chrghighday, 'Y')
         
                if chrg < chrgday*.85
                    light =0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday, 'Y')
         
                if bndw < bwday*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday, 'Y')
         
                if pulserate < pulseday*.85
                    light = 0;
                end
            
            end
           
      
        case 'CXI'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
        
            if strcmp(xhighday, 'Y')
         
                if xenergy < xenday*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday, 'Y')
         
                if blength*.95 > blday
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday, 'Y')
         
                if minFEL < mFELday*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday, 'Y')
         
                if chrg < chrgday*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday, 'Y')
         
                if bndw < bwday*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday, 'Y')
         
                if pulserate < pulseday*.85
                    light = 0;
                end
            
            end
         
     
         case 'SXR'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday, 'Y')
         
                if xenergy < xenday*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday, 'Y')
         
                if blength*.95 > blday
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday, 'Y')
         
                if minFEL < mFELday*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday, 'Y')
         
                if chrg < chrgday*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday, 'Y')
         
                if bndw < bwday*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday, 'Y')
         
                if pulserate < pulseday*.85
                    light = 0;
                end
            
            end
         
     
        case 'XPP'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday, 'Y')
         
                if xenergy < xenday*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday, 'Y')
         
                if blength*.95 > blday
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday, 'Y')
         
                if minFEL < mFELday*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday, 'Y')
         
                if chrg < chrgday*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday, 'Y')
         
                if bndw < bwday*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
        
            if strcmp(pulsehighday, 'Y')
         
                if pulserate < pulseday*.85
                    light = 0;
                end
            
            end
         
     
         case 'XCS'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday, 'Y')
         
                if xenergy < xenday*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday, 'Y')
         
                if blength*.95 > blday
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday, 'Y')
         
                if minFEL < mFELday*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday, 'Y')
         
                if chrg < chrgday*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday, 'Y')
         
                if bndw < bwday*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday, 'Y')
         
                if pulserate < pulseday*.85
                    light = 0;
                end
            
            end
         
        case 'MEC'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday, 'Y')
         
                if xenergy < xenday*.85
                    light = 0;
                end
            
            end
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday, 'Y')
         
                if blength*.95 > blday
                    light = 0;
                end
            
            end
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
        
            if strcmp(mFELhighday, 'Y')
         
                if minFEL < mFELday*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday, 'Y')
         
                if chrg < chrgday*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
        
            if strcmp(bwhighday, 'Y')
         
                if bndw < bwday*.85
                    light = 0;
                end
            
            end
         
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday, 'Y')
         
                if pulserate < pulseday*.85
                    light = 0;
                end
            
            end
    end
     switch hutch2day
        case 'AMO'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy 
         
             if strcmp(xhighday2, 'Y')
         
                if xenergy < xenday2*.85
                    light = 0;
                end
             end
           
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday2, 'Y')
         
                if blength2*.95 > blday2
                    light = 0;
                end
            end
        
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday2, 'Y')
         
                if minFEL < mFELday2*.85
                    light = 0;
                end
            
            end
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday2, 'Y')
         
                if chrg < chrgday2*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday2, 'Y')
         
                if bndw < bwday2*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday2, 'Y')
         
                if pulserate < pulseday2*.85
                    light = 0;
                end
            
            end
           
      
        case 'CXI'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
        
            if strcmp(xhighday2, 'Y')
         
                if xenergy < xenday2*.85
                    light = 0;
                end
            
            end
         
         blength=deblank(char(lcaGet('SIOC:SYS0:ML00:AO820'))); %bunch length
         
            if strcmp(blhighday2, 'Y')
         
                if blength*.95 >blday2
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday2, 'Y')
         
                if minFEL < (mFELday2)*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
        
            if strcmp(chrghighday2, 'Y')
         
                if chrg < chrgday2*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday2, 'Y')
         
                if bndw < bwday2*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
        
            if strcmp(pulsehighday2, 'Y')
         
                if pulserate < pulseday2*.85
                    light = 0;
                end
            
            end
         
     
         case 'SXR'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday2, 'Y')
         
                if xenergy < xenday2*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday2, 'Y')
         
                if blength*.95 > blday2
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday2, 'Y')
         
                if minFEL < mFELday2*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday2, 'Y')
         
                if chrg < chrgday2*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday2, 'Y')
         
                if bndw < bwday2*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday2, 'Y')
         
                if pulserate < pulseday2*.85
                    light = 0;
                end
            
            end
         
     
        case 'XPP'
        xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
        
            if strcmp( xhighday2,  'Y')
         
                if xenergy < xenday2*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday2, 'Y')
         
                if blength*.95 > blday2 
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
        
            if strcmp(mFELhighday2, 'Y')
         
                if minFEL < mFELday2*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
        
            if strcmp(chrghighday2, 'Y')
         
                if chrg < chrgday2*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday2, 'Y')
         
                if bndw < bwday2*.85;
                    light =0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday2, 'Y')
         
                if pulserate < pulseday2*.85
                    light = 0;
                end
            
            end
           
       
         case 'XCS'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
        
            if strcmp(xhighday2, 'Y')
         
                if xenergy < xenday2*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday2, 'Y')
         
                if blength*.95 > blday2
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
        
            if strcmp(mFELhighday2, 'Y')
         
                if minFEL < mFELday2*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
        
            if strcmp(chrghighday2, 'Y')
         
                if chrg < chrgday2*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday2, 'Y')
         
                if bndw < bwday2*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday2, 'Y')
         
                if pulserate < pulseday2*.85
                    light = 0;
                end
            
            end
         
        case 'MEC'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday2, 'Y')
         
                if xenergy < xenday2*.85
                    light = 0;
                end
            
            end
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday2, 'Y')
         
                if blength*.95 > blday2
                    light = 0;
                end
            
            end
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
        
            if strcmp(mFELhighday2, 'Y')
         
                if minFEL < mFELday2*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday2, 'Y')
         
                if chrg < chrgday2*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday2, 'Y')
         
                if bndw < bwday2*.85
                    light = 0;
                end
            
            end
         
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday2, 'Y')
         
                if pulserate < pulseday2*.85
                    light = 0;
                end
            
            end
     end
    
      switch hutch3day
        case 'AMO'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
             if strcmp(xhighday3, 'Y')
         
                if xenergy < xenday3*.85
                    light = 0;
                end
             end
           
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday3, 'Y')
         
                if blength*.95 > blday3
                    light = 0;
                end
            end
        
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday3, 'Y')
         
                if minFEL < mFELday3*.85
                    light = 0;
                end
            
            end
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday3, 'Y')
         
                if chrg < chrgday3*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday3, 'Y')
         
                if bndw < bwday3*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday3, 'Y')
         
                if pulserate < pulseday3*.85
                    light = 0;
                end
            
            end
           
      
        case 'CXI'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday3, 'Y')
         
                if xenergy < xenday3*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday3, 'Y')
         
                if blength*.95 > blday3
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday3, 'Y')
         
                if minFEL < mFELday3*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday3, 'Y')
         
                if chrg < chrgday3*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday3, 'Y')
         
                if bndw < bwday3*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday3, 'Y')
         
                if pulserate < pulseday3*.85
                    light = 0;
                end
            
            end
         
     
         case 'SXR'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday3, 'Y')
         
                if xenergy < xenday3*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday3, 'Y')
         
                if blength*.95 > blday3
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
        
            if strcmp(mFELhighday3, 'Y')
         
                if minFEL < mFELday3*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday3, 'Y')
         
                if chrg < chrgday3*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday3, 'Y')
         
                if bndw < bwday3*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday3, 'Y')
         
                if pulserate < pulseday3*.85
                    light = 0;
                end
            
            end
         
     
        case 'XPP'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday3, 'Y')
         
                if xenergy < xenday3*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday3, 'Y')
         
                if blength*.95 > blday3
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
        
             if strcmp(mFELhighday3, 'Y')
         
                if minFEL < mFELday3*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday3, 'Y')
         
                if chrg < chrgday3*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday3, 'Y')
         
                if bndw < bwday3*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday3, 'Y')
         
                if pulserate < pulseday3*.85
                    light = 0;
                end
            
            end
         
     
         case 'XCS'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday3, 'Y')
         
                if xenergy < xenday3*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday3, 'Y')
         
                if blength*.95 > blday3
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday3, 'Y')
         
                if minFEL < mFELday3*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday3, 'Y')
         
                if chrg < chrgday3*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday3, 'Y')
         
                if bndw < bwday3*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday3, 'Y')
         
                if pulserate < pulseday3*.85
                    light = 0;
                end
            
            end
         
        case 'MEC'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday3, 'Y')
         
                if xenergy < xenday3*.85
                    light = 0;
                end
            
            end
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday3, 'Y')
         
                if blength*.95 > blday3
                    light = 0;
                end
            
            end
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday3, 'Y')
         
                if minFEL < mFELday3*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday3, 'Y')
         
                if chrg < chrgday3*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday3, 'Y')
         
                if bndw < bwday3*.85
                    light = 0;
                end
            
            end
         
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday3, 'Y')
         
                if pulserate < pulseday3*.85
                    light = 0;
                end
            
            end
      end
    
            
            
     switch hutch4day
        case 'AMO'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
             if strcmp(xhighday4, 'Y')
         
                if xenergy < xenday4*.85
                    light = 0;
                end
             end
           
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday4, 'Y')
         
                if blength*.95 > blday4
                    light = 0;
                end
            end
        
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
          
            if strcmp(mFELhighday4, 'Y')
         
                if minFEL < mFELday4*.85
                    light = 0;
                end
            
            end
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday4, 'Y')
         
                if chrg < chrgday4*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday4, 'Y')
         
                if bndw < bwday4*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday4, 'Y')
         
                if pulserate < pulseday4*.85
                    light = 0;
                end
            
            end
           
      
        case 'CXI'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday4, 'Y')
         
                if xenergy < xenday4*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday4, 'Y')
         
                if blength*.95 > blday4
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday4, 'Y')
         
                if minFEL < mFELday4*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday4, 'Y')
         
                if chrg < chrgday4*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday4, 'Y')
         
                if bndw < bwday4*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday4, 'Y')
         
                if pulserate < pulseday4*.85
                    light = 0;
                end
            
            end
         
     
         case 'SXR'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
        
            if strcmp(xhighday4, 'Y')
         
                if xenergy < xenday4*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday4, 'Y')
         
                if blength*.95 > blday4
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday4, 'Y')
         
                if minFEL < mFELday4*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday4, 'Y')
         
                if chrg < chrgday4*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday4, 'Y')
         
                if bndw < bwday4*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday4, 'Y')
         
                if pulserate < pulseday4*.85
                    light = 0;
                end
            
            end
         
     
        case 'XPP'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday4, 'Y')
         
                if xenergy < xenday4*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday4, 'Y')
         
                if blength*.95 > blday4
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday4, 'Y')
         
                if minFEL < mFELday4*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday4, 'Y')
         
                if chrg < chrgday4*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday4, 'Y')
         
                if bndw < bwday4*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday4, 'Y')
         
                if pulserate < pulseday4*.85
                    light = 0;
                end
            
            end
         
     
         case 'XCS'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday4, 'Y')
         
                if xenergy < xenday4*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday4, 'Y')
         
                if blength*.95 > blday4
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday4, 'Y')
         
                if minFEL < mFELday4*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday4, 'Y')
         
                if chrg < chrgday4*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday4, 'Y')
         
                if bndw < bwday4*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday4, 'Y')
         
                if pulserate < pulseday4*.85
                    light = 0;
                end
            
            end
         
        case 'MEC'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighday4, 'Y')
         
                if xenergy < xenday4*.85
                    light = 0;
                end
            
            end
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighday4, 'Y')
         
                if blength*.95 > blday4
                    light = 0;
                end
            
            end
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighday4, 'Y')
         
                if minFEL < mFELday4*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighday4, 'Y')
         
                if chrg < chrgday4*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighday4, 'Y')
         
                if bndw < bwday4*.85
                    light = 0;
                end
            
            end
         
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighday4, 'Y')
         
                if pulserate < pulseday4*.85
                    light = 0;
                end
            
            end       
            
            
    end
    case 'night'
        switch hutchnight
        case 'AMO'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
        
             if strcmp(xhighnight, 'Y')
         
                if xenergy < xennight*.85
                    light = 0;
                end
             end
           
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight, 'Y')
         
                if blength*.95 > blnight
                    light = 0;
                end
            end
        
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight, 'Y')
         
                if minFEL < mFELnight*.85
                    light = 0;
                end
            
            end
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight, 'Y')
         
                if chrg < chrgnight*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight, 'Y')
         
                if bndw < bwnight*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight, 'Y')
         
                if pulserate < pulsenight*.85
                    light = 0;
                end
            
            end
           
      
        case 'CXI'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight, 'Y')
         
                if xenergy < xennight*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight, 'Y')
         
                if blength*.95 > blnight
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight, 'Y')
         
                if minFEL < mFELnight*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight, 'Y')
         
                if chrg < chrgnight*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight, 'Y')
         
                if bndw < bwnight*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight, 'Y')
         
                if pulserate < pulsenight*.85
                    light = 0;
                end
            
            end
         
     
         case 'SXR'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
       
            if strcmp(xhighnight, 'Y')
         
                if xenergy < xennight*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight, 'Y')
         
                if blength*.95 > blnight
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight, 'Y')
         
                if minFEL < mFELnight*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight, 'Y')
         
                if chrg < chrgnight*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight, 'Y')
         
                if bndw < bwnight*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight, 'Y')
         
                if pulserate < pulsenight*.85
                    light = 0;
                end
            
            end
         
     
        case 'XPP'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight, 'Y')
         
                if xenergy < xennight*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight, 'Y')
         
                if blength*.95 > blnight
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight, 'Y')
         
                if minFEL < mFELnight*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight, 'Y')
         
                if chrg < chrgnight*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight, 'Y')
         
                if bndw < bwnight*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight, 'Y')
         
                if pulserate < pulsenight*.85
                    light = 0;
                end
            
            end
         
     
         case 'XCS'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight, 'Y')
         
                if xenergy < xennight*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight, 'Y')
         
                if blength*.95 > blnight
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight, 'Y')
         
                if minFEL < mFELnight*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight, 'Y')
         
                if chrg < chrgnight*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight, 'Y')
         
                if bndw < bwnight*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight, 'Y')
         
                if pulserate < pulsenight*.85
                    light = 0;
                end
            
            end
         
        case 'MEC'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight, 'Y')
         
                if xenergy < xennight*.85
                    light = 0;
                end
            
            end
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight, 'Y')
         
                if blength*.95 > blnight
                    light = 0;
                end
            
            end
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight, 'Y')
         
                if minFEL < mFELnight*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight, 'Y')
         
                if chrg < chrgnight*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight, 'Y')
         
                if bndw < bwnight*.85
                    light = 0;
                end
            
            end
         
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight, 'Y')
         
                if pulserate < pulsenight*.85
                    light = 0;
                end
            
            end
        end
        
        
        switch hutch2night
        case 'AMO'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
             if strcmp(xhighnight2, 'Y')
         
                if xenergy < xennight2*.85
                    light = 0;
                end
             end
           
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight2, 'Y')
         
                if blength*.95 > blnight2
                    light = 0;
                end
            end
        
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight2, 'Y')
         
                if minFEL < mFELnight2*.85
                    light = 0;
                end
            
            end
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight2, 'Y')
         
                if chrg < chrgnight2*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight2, 'Y')
         
                if bndw < bwnight2*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight2, 'Y')
         
                if pulserate < pulsenight2*.85
                    light = 0;
                end
            
            end
           
      
        case 'CXI'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight2, 'Y')
         
                if xenergy < xennight2*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight2, 'Y')
         
                if blength*.95 > blnight2
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight2, 'Y')
         
                if minFEL < mFELnight2*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight2, 'Y')
         
                if chrg < chrgnight2*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight2, 'Y')
         
                if bndw < bwnight2*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight2, 'Y')
         
                if pulserate < pulsenight2*.85
                    light = 0;
                end
            
            end
         
     
         case 'SXR'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight2, 'Y')
         
                if xenergy < xennight2*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight2, 'Y')
         
                if blength*.95 > blnight2
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
        
            if strcmp(mFELhighnight2, 'Y')
         
                if minFEL < mFELnight2*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
        
            if strcmp(chrghighnight2, 'Y')
         
                if chrg < chrgnight2*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight2, 'Y')
         
                if bndw < bwnight2*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
        
            if strcmp(pulsehighnight2, 'Y')
         
                if pulserate < pulsenight2*.85
                    light = 0;
                end
            
            end
         
     
        case 'XPP'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight2, 'Y')
         
                if xenergy < xennight2*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight2, 'Y')
         
                if blength*.95 > blnight2
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
             if strcmp(mFELhighnight2, 'Y')
         
                if minFEL < mFELnight2*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight2, 'Y')
         
                if chrg < chrgnight2*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight2, 'Y')
         
                if bndw < bwnight2*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight2, 'Y')
         
                if pulserate < pulsenight2*.85
                    light = 0;
                end
            
            end
         
     
         case 'XCS'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight2, 'Y')
         
                if xenergy < xennight2*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight2, 'Y')
         
                if blength*.95 > blnight2
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight2, 'Y')
         
                if minFEL < mFELnight2*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
        
            if strcmp(chrghighnight2, 'Y')
         
                if chrg < chrgnight2*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight2, 'Y')
         
                if bndw < bwnight2*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
        
            if strcmp(pulsehighnight2, 'Y')
         
                if pulserate < pulsenight2*.85
                    light = 0;
                end
            
            end
         
        case 'MEC'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight2, 'Y')
         
                if xenergy < xennight2*.85
                    light = 0;
                end
            
            end
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight2, 'Y')
         
                if blength*.95 > blnight2
                    light = 0;
                end
            
            end
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight2, 'Y')
         
                if minFEL < mFELnight2*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight2, 'Y')
         
                if chrg < chrgnight2*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight2, 'Y')
         
                if bndw < bwnight2*.85
                    light = 0;
                end
            
            end
         
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight2, 'Y')
         
                if pulserate < pulsenight2*.85
                    light = 0;
                end
            
            end
        end
        
 
        
        switch hutch3night
        case 'AMO'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
             if strcmp(xhighnight3, 'Y')
         
                if xenergy < xennight3*.85
                    light = 0;
                end
             end
           
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight3, 'Y')
         
                if blength*.95 > blnight3
                    light = 0;
                end
            end
        
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight3, 'Y')
         
                if minFEL < mFELnight3*.85
                    light = 0;
                end
            
            end
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight3, 'Y')
         
                if chrg < chrgnight3*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight3, 'Y')
         
                if bndw < bwnight3*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight3, 'Y')
         
                if pulserate < pulsenight3*.85
                    light = 0;
                end
            
            end
           
      
        case 'CXI'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight3, 'Y')
         
                if xenergy < xennight3*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight3, 'Y')
         
                if blength*.95 > blnight3
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight3, 'Y')
         
                if minFEL < mFELnight3*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight3, 'Y')
         
                if chrg < chrgnight3*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight3, 'Y')
         
                if bndw < bwnight3*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight3, 'Y')
         
                if pulserate < pulsenight3*.85
                    light = 0;
                end
            
            end
         
     
         case 'SXR'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight3, 'Y')
         
                if xenergy < xennight3*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight3, 'Y')
         
                if blength*.95 > blnight3
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight3, 'Y')
         
                if minFEL < mFELnight3*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight3, 'Y')
         
                if chrg < chrgnight3*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight3, 'Y')
         
                if bndw < bwnight3*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight3, 'Y')
         
                if pulserate < pulsenight3*.85
                    light = 0;
                end
            
            end
         
     
        case 'XPP'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight3, 'Y')
         
                if xenergy < xennight3*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight3, 'Y')
         
                if blength*.95 > blnight3
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight3, 'Y')
         
                if minFEL < mFELnight3*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight3, 'Y')
         
                if chrg < chrgnight3*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight3, 'Y')
         
                if bndw < bwnight3*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight3, 'Y')
         
                if pulserate < pulsenight3*.85
                    light = 0;
                end
            
            end
         
     
         case 'XCS'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight3, 'Y')
         
                if xenergy < xennight3*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight3, 'Y')
         
                if blength*.95 > blnight3
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight3, 'Y')
         
                if minFEL < mFELnight3*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight3, 'Y')
         
                if chrg < chrgnight3*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight3, 'Y')
         
                if bndw < bwnight3*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
      
            if strcmp(pulsehighnight3, 'Y')
         
                if pulserate < pulsenight3*.85
                    light = 0;
                end
            
            end
         
        case 'MEC'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight3, 'Y')
         
                if xenergy < xennight3*.85
                    light = 0;
                end
            
            end
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight3, 'Y')
         
                if blength*.95 > blnight3
                    light = 0;
                end
            
            end
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight3, 'Y')
         
                if minFEL < mFELnight3*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight3, 'Y')
         
                if chrg < chrgnight3*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight3, 'Y')
         
                if bndw < bwnight3*.85
                    light = 0;
                end
            
            end
         
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
        
            if strcmp(pulsehighnight3, 'Y')
         
                if pulserate < pulsenight3*.85
                    light = 0;
                end
            
            end
        end
        
        switch hutch4night
        case 'AMO'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
             if strcmp(xhighnight4, 'Y')
         
                if xenergy < xennight4*.85
                    light = 0;
                end
             end
           
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight4, 'Y')
         
                if blength*.95 > blnight4
                    light = 0;
                end
            end
        
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight4, 'Y')
         
                if minFEL < mFELnight4*.85
                    light = 0;
                end
            
            end
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight4, 'Y')
         
                if chrg < chrgnight4*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight4, 'Y')
         
                if bndw < bwnight4*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight4, 'Y')
         
                if pulserate < pulsenight4*.85
                    light = 0;
                end
            
            end
           
      
        case 'CXI'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight4, 'Y')
         
                if xenergy < xennight4*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight4, 'Y')
         
                if blength*.95 > blnight4
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight4, 'Y')
         
                if minFEL < mFELnight4*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight4, 'Y')
         
                if chrg < chrgnight4*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight4, 'Y')
         
                if bndw < bwnight4*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight4, 'Y')
         
                if pulserate < pulsenight4*.85
                    light = 0;
                end
            
            end
         
     
         case 'SXR'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight4, 'Y')
         
                if xenergy < xennight4*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight4, 'Y')
         
                if blength*.95 > blnight4
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight4, 'Y')
         
                if minFEL < mFELnight4*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight4, 'Y')
         
                if chrg < chrgnight4*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight4, 'Y')
         
                if bndw < bwnight4*.85
                    light = 0;
                end
            
            end
        
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
        
            if strcmp(pulsehighnight4, 'Y')
         
                if pulserate < pulsenight4*.85
                    light = 0;
                end
            
            end
         
     
        case 'XPP'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight4, 'Y')
         
                if xenergy < xennight4*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight4, 'Y')
         
                if blength*.95 > blnight4
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight4, 'Y')
         
                if minFEL < mFELnight4*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight4, 'Y')
         
                if chrg < chrgnight4*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight4, 'Y')
         
                if bndw < bwnight4*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight4, 'Y')
         
                if pulserate < pulsenight4*.85
                    light = 0;
                end
            
            end
         
     
         case 'XCS'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight4, 'Y')
         
                if xenergy < xennight4*.85
                    light = 0;
                end
            
            end
         
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight4, 'Y')
         
                if blength*.95 > blnight4
                    light = 0;
                end
            
            end
         
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight4, 'Y')
         
                if minFEL < mFELnight4*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight4, 'Y')
         
                if chrg < chrgnight4*.85
                    light = 0;
                end
            
            end
         
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight4, 'Y')
         
                if bndw < bwnight4*.85
                    light = 0;
                end
            
            end
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight4, 'Y')
         
                if pulserate < pulsenight4*.85
                    light = 0;
                end
            
            end
         
        case 'MEC'
         xenergy=lcaGet('SIOC:SYS0:ML00:AO627'); %xray energy
         
            if strcmp(xhighnight4, 'Y')
         
                if xenergy < xennight4*.85
                    light = 0;
                end
            
            end
         blength=lcaGet('SIOC:SYS0:ML00:AO820'); %bunch length
         
            if strcmp(blhighnight4, 'Y')
         
                if blength*.95 > blnight4
                    light = 0;
                end
            
            end
         minFEL=lcaGet('SIOC:SYS0:ML00:CALC138'); % minimum FEL
         
            if strcmp(mFELhighnight4, 'Y')
         
                if minFEL < mFELnight4*.85
                    light = 0;
                end
            
            end
         
         chrg=lcaGet('SIOC:SYS0:ML00:CALC038'); %charge
         
            if strcmp(chrghighnight4, 'Y')
         
                if chrg < chrgnight4*.85
                    light = 0;
                end
            
            end
         bndw=lcaGet('SIOC:SYS0:ML00:AO426'); %bandwidth
         
            if strcmp(bwhighnight4, 'Y')
         
                if bndw < bwnight4*.85
                    light = 0;
                end
            
            end
         
         pulserate=lcaGet('SIOC:SYS0:ML00:AO467'); %pulse rate
         
            if strcmp(pulsehighnight4, 'Y')
         
                if pulserate < pulsenight4*.85
                    light = 0;
                end
            
            end
        end
        
end
   lcaPut('SIOC:SYS0:ML03:AO065',light); %electrons available to produce light pv
   lightfinal = lcaGet('SIOC:SYS0:ML03:AO065') % 1 = delivered, 0 = not delivered
    
pause(1);
end