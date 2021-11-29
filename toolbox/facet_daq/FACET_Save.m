function [data,savepath] = FACET_Save(param,QC_INFO,epics_data,E200_state,cam_back)

    data     = E200_gather_data(param,QC_INFO,epics_data,param.scanbool,E200_state,cam_back);
    slashloc = regexp(param.save_path,'/');
    savepath = fullfile(param.save_path(1:slashloc(end-2)),[param.experiment '_' num2str(param.n_saves) '.mat' ]);
    save(savepath,'data');
end
