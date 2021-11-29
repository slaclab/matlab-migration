%% Function to keep track of timing on EOS cam

%
% A.Knetsch Jan 17 2016
function[Timing] = EOSLO()


    EOSCalibrationPV='SIOC:SYS1:ML00:CALC171';
    EOSCalibration=lcaGet(EOSCalibrationPV); %fs/px
    % check EPICS PV THFarFeedback_stop (bool)

    
    
    % grab profmon image
    EOSLoPVName = 'PROF:LI20:B100';
    prof_data = profmon_grab(EOSLoPVName);
    % timing PV
    TimingPV='SIOC:SYS1:ML00:CALC170';
    % ROIX=[prof_data.roiX+1:prof_data.roiXN+prof_data.roiX-1];
    % ROIY=[prof_data.roiY+1:prof_data.roiYN+prof_data.roiY-1];
     img=prof_data.img;
    % take projections
    %px_x = [prof.roiX:prof.roiX+prof.roiXN-1];
    % px_y = [prof.roiY:prof.roiY+prof.roiYN-1];
    
    proj_x = sum(img,1);
    % proj_y = sum(prof.img,2)';

    % % find centroid
    % Cx = sum(proj_x.*px_x)/sum(proj_x) % px
    % Cy = sum(proj_y.*px_y)/sum(proj_y) % px

    % find peak (better than centroid)
    [max_x peak_x] = max(proj_x); % px




    % compare to alignment tolerance
    Timing= (peak_x+prof_data.roiX+1)*EOSCalibration/1000-22;
    
    %['Timing: 'num2str(Timing*1000) ' ps']
    pause(1);
    
    lcaPut(TimingPV,Timing);
   
    %[num2str(Timing*1000) ' ps']
end

