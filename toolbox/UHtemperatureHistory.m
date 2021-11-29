function UHtemperatureHistory()
%
%   UHtemperatureHistory()
%
%plots old temperature profiles 

%open temperature profile file and read in data
path_name=([getenv('MATLABDATAFILES') '/undulator/UH']);
filename = '/UHtemperatureProfile.dat';
filename = [path_name filename];
display(['Reading temperature profiles from ' filename]);
fid = fopen(filename,'r');
[Tdata, count] = fscanf(fid,'%f');
fclose(fid);
NumberOfrows = length(Tdata)/100;
Tdata = reshape(Tdata,100,NumberOfrows);
Tdata = Tdata';
Tdata(:,1:99);
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

%superimpose the historical average values
hold on;
for iplot = 1:NumberOfrows
plot(z,Tdata(iplot,1:33),'.k','MarkerSize',5);
end

