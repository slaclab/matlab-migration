function par = E200_path_diary(par)
% prepare save paths

if par.flip_nas
  t = [3 2 1];
else
  t = [1 2 3];
end


n_saves = lcaGetSmart('SIOC:SYS1:ML02:AO001');
if par.increment_save_num
    n_saves = n_saves + 1;
    lcaPut('SIOC:SYS1:ML02:AO001',n_saves);
end

par.timestamp = clock;
par.year = num2str(par.timestamp(1), '%.4d');
par.month = num2str(par.timestamp(2), '%.2d');
par.day = num2str(par.timestamp(3), '%.2d');
par.hour = num2str(par.timestamp(4), '%.2d');
par.minute = num2str(par.timestamp(5), '%.2d');
par.second = num2str(floor(par.timestamp(6)), '%.2d');


par.num_CAM = size(par.cams,1);
if par.num_CAM > 3 || par.num_CMOS > 3
    par.num_NAS = 3;
else
    par.num_NAS = max(par.num_CAM,par.num_CMOS);
end

for s=1:par.num_NAS

    par.save_path{s} = ['/nas/nas-li20-pm0' num2str(t(s)) '/' par.experiment '/' par.year '/' par.year par.month par.day];
    if(~exist(par.save_path{s}, 'dir')); mkdir(par.save_path{s}); end;

    par.save_path{s} = [par.save_path{s} '/' par.experiment '_' num2str(n_saves)];
    if(~exist(par.save_path{s}, 'dir')); mkdir(par.save_path{s}); end;
    system(['chmod a+w ' par.save_path{s}]);
    
    if s <= par.num_CMOS
        if par.cmos2nas
            par.cmos_path{s} = [par.save_path{s} '/' par.cam_CMOS{s,1}];
            if(~exist(par.cmos_path{s}, 'dir')); mkdir(par.cmos_path{s}); end;
            system(['chmod a+w ' par.cmos_path{s}]);
        else
            par.cmos_path{s} = ['/tmp/cmos_data/' par.year par.month par.day '/' par.experiment '_' num2str(n_saves)];
        end
    end
    
end

par.tail_path = [par.experiment '/' par.year '/' par.year par.month par.day '/' par.experiment '_' num2str(n_saves)];
par.save_name = [par.experiment '_' num2str(n_saves) '_' par.year '-' par.month '-' par.day '-' par.hour '-' par.minute '-' par.second];

% start diary 
diary off;
for i=1:par.num_NAS
    diary([par.save_path{i} '/' par.save_name '.txt']);
end
diary on;
 
end
