function filenames = E200_getFilenames(param)

for i = 1:param.num_NAS
    if param.flip_nas
        if i == 1; nCam = param.pm03_cams; end;
        if i == 2; nCam = param.pm02_cams; end;
        if i == 3; nCam = param.pm01_cams; end;
    else
        if i == 1; nCam = param.pm01_cams; end;
        if i == 2; nCam = param.pm02_cams; end;
        if i == 3; nCam = param.pm03_cams; end;
    end

    list = dir([param.save_path{i}, '/*.header']);

    [tmp, ind] = sort([list.datenum]);
    list2 = list(ind(end-nCam+1:end));

    for j=1:nCam
        fHEAD   = fopen([param.save_path{i}, '/', list2(j).name]);
        C = textscan(fHEAD,'%*s # Camera:%s %*s %*s # PULSEID: %f # Sequence #%f %f %f %*s','Delimiter','\n');
        cam_name = C{1}{1};
        filenames.(char(cam_name)) = [param.save_path{i}, '/', list2(j).name(1:end-7)];
        fclose(fHEAD);
    end
end

end



