function RBINNED=BSAdataLaunch_Read(BPM_id,data)
%
% jcs 
% rev. 0: October 14, 2014
% rev. 1A: february 2, 2015: modified from BSAdataGDET---called by
%JANICE_UND_Launch to get 24-binned X&Y data for six UND1 launch fdbk
% BPM_id is passed thru function call; XAVG and YAVG are returned
%
% program to look at BSA data; sort or hard coded at first; uses FJD BSA
% data in data 1x1 structure
%
% pick a bpm and read in the data
%
%
%
X=data.the_matrix(BPM_id(1),:);
Y=data.the_matrix(BPM_id(2),:);
%
mx=find(data.x_noeta_bpm_id==BPM_id(1));
my=find(data.y_noeta_bpm_id==BPM_id(2));
%

Nmax=length(X);
%
% find the zeros  (corresponds to missing pulses
%
XZF=find(X==0);% for bpm
%XZF=find(X(1:Nmax)==0);% for bpm

% concatenate data into 24 bins (corresponding to 5 Hz
%
Jmax=length(XZF);
if gt(XZF(end)+23,Nmax) Jmax=Jmax-1; end;
%
XAVG=zeros(1,24);
YAVG=zeros(1,24);
XBIN=zeros(Jmax,24);
YBIN=zeros(Jmax,24);
%
for j=1:Jmax;
    XAVG=XAVG+X(XZF(j):XZF(j)+23);
    YAVG=YAVG+Y(XZF(j):XZF(j)+23);
    XBIN(j,:)=X(XZF(j):XZF(j)+23);
    YBIN(j,:)=Y(XZF(j):XZF(j)+23);
end;
%
XAVG=XAVG/Jmax;
YAVG=YAVG/Jmax;
%
RBINNED=[XAVG' YAVG'];
%
end