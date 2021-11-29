function [background, param] = FACET_takeBackground(param)

cams  = param.cams;
names = param.names;
if param.event_code == 233 || param.event_code == 231 || param.event_code == 229
    stat_2_9 = get_2_9(6);
else
    stat_2_9 = get_2_9(10);
end

stat_shut = lcaGet('DO:LA20:10:Bo1.RBV');

% We always save image, but its only a true background if "save_back=1"
if param.save_back
    if ~stat_shut
       lcaPut('DO:LA20:10:Bo1',1);
    end
    if param.event_code == 233 || param.event_code == 231 || param.event_code == 229
        if ~stat_2_9
            set_2_9(1,6);
        end
    else
        if ~stat_2_9
            set_2_9(1,10);
        end
    end
    pause(1);
end

data = profmon_grab(cams);

for i=1:numel(data)
	background.(names{i}).img        = data(i).img;
	background.(names{i}).ROI_X      = data(i).roiX;
	background.(names{i}).ROI_Y      = data(i).roiY;
	background.(names{i}).ROI_XNP    = data(i).roiXN;
	background.(names{i}).ROI_YNP    = data(i).roiYN;
	background.(names{i}).RESOLUTION = data(i).res;
	background.(names{i}).X_ORIENT   = data(i).orientX;
	background.(names{i}).Y_ORIENT   = data(i).orientY;
end

if param.save_back;
    if ~stat_shut
       lcaPut('DO:LA20:10:Bo1',0);
    end
    if param.event_code == 233 || param.event_code == 231 || param.event_code == 229
        if ~stat_2_9
            set_2_9(0,6);
        end
    else
        if ~stat_2_9
            set_2_9(0,10);
        end
    end
    pause(1);
end
