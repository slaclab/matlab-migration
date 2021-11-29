% This file loads a beam image and performs a 2D fit to get the rms size of
% the beam.

clear all;
close all hidden;

moment_data = zeros(17,3);












%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211203.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(1,1) = 0; % enter this in mm.
moment_data(1,2) = beamlist(1).stats(3);
moment_data(1,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-210531.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(2,1) = -1; % enter this in mm.
moment_data(2,2) = beamlist(1).stats(3);
moment_data(2,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-210714.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(3,1) = -2; % enter this in mm.
moment_data(3,2) = beamlist(1).stats(3);
moment_data(3,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-210742.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(4,1) = -3; % enter this in mm.
moment_data(4,2) = beamlist(1).stats(3);
moment_data(4,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-210946.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(5,1) = -5; % enter this in mm.
moment_data(5,2) = beamlist(1).stats(3);
moment_data(5,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211007.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(6,1) = -7; % enter this in mm.
moment_data(6,2) = beamlist(1).stats(3);
moment_data(6,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211035.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(7,1) = -10; % enter this in mm.
moment_data(7,2) = beamlist(1).stats(3);
moment_data(7,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211103.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(8,1) = -20; % enter this in mm.
moment_data(8,2) = beamlist(1).stats(3);
moment_data(8,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211115.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(9,1) = -30; % enter this in mm.
moment_data(9,2) = beamlist(1).stats(3);
moment_data(9,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211339.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(10,1) = 1; % enter this in mm.
moment_data(10,2) = beamlist(1).stats(3);
moment_data(10,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211405.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(11,1) = 2; % enter this in mm.
moment_data(11,2) = beamlist(1).stats(3);
moment_data(11,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211423.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(12,1) = 3; % enter this in mm.
moment_data(12,2) = beamlist(1).stats(3);
moment_data(12,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211457.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(13,1) = 5; % enter this in mm.
moment_data(13,2) = beamlist(1).stats(3);
moment_data(13,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211514.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(14,1) = 7; % enter this in mm.
moment_data(14,2) = beamlist(1).stats(3);
moment_data(14,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211533.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(15,1) = 10; % enter this in mm.
moment_data(15,2) = beamlist(1).stats(3);
moment_data(15,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211606.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(16,1) = 20; % enter this in mm.
moment_data(16,2) = beamlist(1).stats(3);
moment_data(16,3) = beamlist(1).stats(4);

%--------------------------------------------------------------------------

load('/u1/facet/matlab/data/2015/2015-12/2015-12-02/ProfMon-PROF_LI20_10-2015-12-02-211620.mat' );
[img,xsub,ysub,~,bgs] = beamAnalysis_imgProc(data);
beamlist = beamAnalysis_beamParams(img, xsub, ysub, bgs);

moment_data(17,1) = 30; % enter this in mm.
moment_data(17,2) = beamlist(1).stats(3);
moment_data(17,3) = beamlist(1).stats(4);


%%

% sort the data to get it in the right order.
[~,I] = sort(moment_data(:,1));

sorted_moments = zeros(size(moment_data));

for i = 1 : length(I)
   sorted_moments(i,:) = moment_data(I(i),:); 
end

% Fit the curves
i_start = 5;
i_stop = 12;
x = sorted_moments(i_start:i_stop,1);
y1 = sorted_moments(i_start:i_stop,2);
y2 = sorted_moments(i_start:i_stop,3);

% Define the equation to use
Q1 = (x.^2);
Q2 = -2*x;
Q3 = ones(length(x),1);
Q = [Q1 Q2 Q3];

[s1,~,R1] = fit(Q,y1);
[s2,~,R2] = fit(Q,y2);

% calc the waist location
w1 = R1(2)/(2*R1(1));
w2 = R2(2)/(2*R2(1));

figure(1)
plot(sorted_moments(:,1),sorted_moments(:,2),'.')
hold on;
plot(x,s1)
hold on;
plot(sorted_moments(:,1),sorted_moments(:,3),'.','Color','r')
hold on;
plot(x,s2,'Color','r')
xlabel('Z position [mm]','FontSize',16)
ylabel('RMS Size [px]','FontSize',16)

A = 600;
B = 1.6*A;

figure(2)
set(gcf,'Position',[0        0         B         A])
plot(x,y1,'.')
hold on;
plot(x,s1)
hold on;
plot(x,y2,'.','Color','r')
hold on;
plot(x,s2,'Color','r')
xlabel('Z position [mm]','FontSize',16)
ylabel('RMS Size [px]','FontSize',16)
legend('X','X fit','Y','Y fit')
title_0 = 'Laser Room Data 12/2';
title_1 = ['X Waist Location: ', num2str(w1), ' [mm]'];
title_2 = ['Y Waist Location: ', num2str(w2), ' [mm]'];
title_3 = ['Difference (X-Y): ', num2str(w1-w2), ' [mm]'];
title(char(title_0,title_1,title_2,title_3),'FontSize',16)





