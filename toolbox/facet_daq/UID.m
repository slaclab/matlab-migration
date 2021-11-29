function out = UID(EPICS_PID,SCANSTEP,DATASET,pid_to_match)
% IMAGE_PID,IMAGE_SCANSTEP,AIDA_PID,AIDA_SCANSTEP)
% function [epics_UID, image_UID, aida_UID] =
%   assign_UID(EPICS_PID,EPICS_SCANSTEP,EPICS_DATASET,pid_to_match)

n_shots = numel(EPICS_PID);
% EPICS_SHOT is the index of the shot in the step in the dataset
EPICS_SHOT = (1:n_shots)';
EPICS_SCANSTEP = SCANSTEP*ones(n_shots,1);
EPICS_DATASET = DATASET*ones(n_shots,1);

% Create UID from dataset, scan step, and shot number
epics_UID = 1e8*EPICS_DATASET+1e4*EPICS_SCANSTEP+EPICS_SHOT;
out.epics_UID=epics_UID;

% Assign UID to image data
if exist('pid_to_match','var')
    ind_match = pid_to_match == EPICS_PID;
    image_UID = epics_UID(ind_match);
    out.image_UID=image_UID;
end