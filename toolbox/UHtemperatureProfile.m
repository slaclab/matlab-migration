function [Tave, Tmin, Tmax, z, time] = UHtemperatureProfile(RTDlist)
%For specified RTDs, return ave, min, and max temps for each segment.
%Default is all RTDs per segment
%RTDlist is numerical array e.g. [1 2 4 5]

if nargin == 0 %default if no argument is supplied
    RTDlist = [1 2 3 4 5 6 7 8 9 10 11 12];
end

%Construct pv names
SegmentNames = {'U01', 'U02','U03', 'U04','U05','U06','U07','U08','U09','U10',...
                'U11', 'U12','U13', 'U14','U15','U16','U17','U18','U19','U20',...
                'U21', 'U22','U23', 'U24','U25','U26','U27','U28','U29','U30',...
                'U31', 'U32','U33'};%use all 19-25 are installed 9/23/08
            

statusMask(1:33) = 1; %these are segment with working RTDs
z =  [...         
  518.8000
  522.7000
  526.6000
  530.8000
  534.7000
  538.6000
  542.9000
  546.8000
  550.6000
  554.9000
  558.8000
  562.7000
  567.0000
  570.8000
  574.7000
  579.0000
  582.9000
  586.7000
  591.0000
  594.9000
  598.8000
  603.1000
  606.9000
  610.8000
  615.1000
  619.0000
  622.9000
  627.2000
  631.0000
  634.9000
  639.2000
  643.1000
  646.9000];

numberOfSegments = length(SegmentNames);


numberOfRTDs = length(RTDlist); %number of RTDs per segment

for sIndex = 1:numberOfSegments
    segment(sIndex).name = SegmentNames{sIndex};
end

pvs = cell(numberOfRTDs,1);%cell array for mlcaGet
%Get the data
for sIndex=1:numberOfSegments

    for RTD=1:numberOfRTDs
        if RTDlist(RTD) < 10
            pvString = [segment(sIndex).name ':T0' num2str(RTDlist(RTD))];
        else
            pvString = [segment(sIndex).name ':T'  num2str(RTDlist(RTD))];
        end
        pvs{RTD} = pvString;
    end
  %  display(pvs)
    
  if (statusMask(sIndex)==1)
    [segment(sIndex).temperatures, ts] = mlcaGetSmart(pvs);
  else
    segment(sIndex).temperatures = NaN ;%dont waste time with mlcaGet
  end
    segment(sIndex).meanTemperature = mean(segment(sIndex).temperatures);
    segment(sIndex).maxTemperature = max(segment(sIndex).temperatures);
    segment(sIndex).minTemperature = min(segment(sIndex).temperatures);
end


%return data
Tave = [segment.meanTemperature];
Tmin = [segment.minTemperature];
Tmax = [segment.maxTemperature];
time = now;
tunnelAverage = mean(Tave);

%plot results
%cla;
hold on
plot(z,Tave,'Color',[0 .5 .5],'Linewidth',3);
plot(z,Tmin,'--k',z,Tmax,'--k');
xlabel('Position [m]');
ylabel('RTD Temperature [C]');
xlim([512,682]);
ylim([19, 23]);
legend('Average','Min/Max');
title( ['Undulator Hall '   datestr(now)] );
display(['Overall average ' num2str(tunnelAverage) ' [C]'])

%append the temperature profile data to a file if all RTDs is chosen
if length(RTDlist) == 12;%all RTDs are requested
    path_name=([getenv('MATLABDATAFILES') '/undulator/UH']);
    filename = '/UHtemperatureProfile.dat';
    filename = [path_name filename];
    display(['Temperature data appended to' filename]);
    fid = fopen(filename,'a');
    count = fprintf(fid,'% 5.3f',[Tave Tmin Tmax ]);
    count = fprintf(fid,'% 5.3f\n', time);
    fclose(fid);
end

%return profile
