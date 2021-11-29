function par = FACET_save_path(par)
% prepare save path

n_saves = lcaGetSmart('SIOC:SYS1:ML02:AO001');
if par.increment_save_num
    n_saves = n_saves + 1;
    lcaPut('SIOC:SYS1:ML02:AO001',n_saves);
end
par.n_saves = n_saves;

par.timestamp = clock;
par.year = num2str(par.timestamp(1), '%.4d');
par.month = num2str(par.timestamp(2), '%.2d');
par.day = num2str(par.timestamp(3), '%.2d');
par.hour = num2str(par.timestamp(4), '%.2d');
par.minute = num2str(par.timestamp(5), '%.2d');
par.second = num2str(floor(par.timestamp(6)), '%.2d');


par.num_CAM = numel(par.cams);
if par.num_CAM == 0
    error('Need at least one camera to run FACET DAQ!');
end

if sum(par.is_UNIQ > 0)
    error('FACET DAQ does not serve UNIQ cameras yet!');
end


par.save_path = ['/nas/nas-li20-pm00/' par.experiment ...
    '/' par.year '/' par.year par.month par.day '/' par.experiment '_' num2str(n_saves) '/' par.experiment '_' num2str(n_saves) '_files/raw/images'];
if(~exist(par.save_path, 'dir')); mkdir(par.save_path); end;
system(['chmod a+w ' par.save_path]);
par.cam_path = cell(size(par.cams));
for i=1:par.num_CAM
    par.cam_path{i} = [par.save_path '/' par.names{i}];
    if(~exist(par.cam_path{i}, 'dir')); mkdir(par.cam_path{i}); end;
    system(['chmod a+w ' par.cam_path{i}]);
end


par.tail_path = [par.experiment '/' par.year '/' par.year par.month par.day '/' par.experiment '_' num2str(n_saves)];
par.save_name = [par.experiment '_' num2str(n_saves) '_' par.year '-' par.month '-' par.day '-' par.hour '-' par.minute '-' par.second];

% start diary 
% diary off;
% diary([par.save_path '/' par.save_name '.txt']);
% diary on;
 
end
