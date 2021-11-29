function par = FACET_cameras(par)

CAMS = par.cams;
par.num_CAM = numel(CAMS);

list_struct = cam_list();

par.is_UNIQ = zeros(size(CAMS));
par.is_CS01 = zeros(size(CAMS));
par.is_CS02 = zeros(size(CAMS));
par.is_CS03 = zeros(size(CAMS));
par.is_CS04 = zeros(size(CAMS));
par.is_CS05 = zeros(size(CAMS));
par.is_PM20 = zeros(size(CAMS));
par.is_PM21 = zeros(size(CAMS));
par.is_PM22 = zeros(size(CAMS));
par.is_PM23 = zeros(size(CAMS));
par.is_CMOS = zeros(size(CAMS));
par.is_GIGE = zeros(size(CAMS));
par.is_AD   = zeros(size(CAMS));

par.names = cell(size(CAMS));

for i=1:par.num_CAM
    %by default all are zero. this will be changed by the if statements
    par.is_CMOS(i) = 0;
    par.is_GIGE(i) = 0;

    par.is_AD(i)   = 0;

    par.is_UNIQ(i) = 0;
    par.is_CS01(i) = 0;
    par.is_CS02(i) = 0;
    par.is_CS03(i) = 0;
    par.is_CS04(i) = 0;
    par.is_CS05(i) = 0;
    
    par.is_PM20(i) = 0;
    par.is_PM21(i) = 0;
    par.is_PM22(i) = 0;
    par.is_PM23(i) = 0;
        
        
    index = strcmp(CAMS{i},list_struct.UNIQ_CAMS.PVS);
    if sum(index)
        par.names(i) = list_struct.UNIQ_CAMS.NAMES(index);
        par.is_UNIQ(i) = 1;
    end
    
    index = strcmp(CAMS{i},list_struct.SIOC_CS01.PVS);
    if sum(index)
        par.names(i) = list_struct.SIOC_CS01.NAMES(index);
        par.is_CS01(i) = 1;
        par.is_CMOS(i) = 1;
        par.is_AD(i)   = 1;
    end
    
    index = strcmp(CAMS{i},list_struct.SIOC_CS02.PVS);
    if sum(index)
        par.names(i) = list_struct.SIOC_CS02.NAMES(index);
        par.is_CS02(i) = 1;
        par.is_CMOS(i) = 1;
        par.is_AD(i)   = 1;
    end
    
    index = strcmp(CAMS{i},list_struct.SIOC_CS03.PVS);
    if sum(index)
        par.names(i) = list_struct.SIOC_CS03.NAMES(index);
        par.is_CS03(i) = 1;
        par.is_CMOS(i) = 1;
        par.is_AD(i)   = 1;
    end
    
    index = strcmp(CAMS{i},list_struct.SIOC_CS04.PVS);
    if sum(index)
        par.names(i) = list_struct.SIOC_CS04.NAMES(index);
        par.is_CS04(i) = 1;
        par.is_CMOS(i) = 1;
        par.is_AD(i)   = 1;
    end
    
    index = strcmp(CAMS{i},list_struct.SIOC_CS05.PVS);
    if sum(index)
        par.names(i) = list_struct.SIOC_CS05.NAMES(index);
        par.is_CS05(i) = 1;
        par.is_CMOS(i) = 1;
        par.is_AD(i)   = 1;
    end
    
    index = strcmp(CAMS{i},list_struct.SIOC_PM20.PVS);
    if sum(index)
        par.names(i) = list_struct.SIOC_PM20.NAMES(index);
        par.is_PM20(i) = 1;
        par.is_GIGE(i) = 1;
        par.is_AD(i)   = 1;
    end
    
    index = strcmp(CAMS{i},list_struct.SIOC_PM21.PVS);
    if sum(index)
        par.names(i) = list_struct.SIOC_PM21.NAMES(index);
        par.is_PM21(i) = 1;
        par.is_GIGE(i) = 1;
        par.is_AD(i)   = 1;
    end
    
    index = strcmp(CAMS{i},list_struct.SIOC_PM22.PVS);
    if sum(index)
        par.names(i) = list_struct.SIOC_PM22.NAMES(index);
        par.is_PM22(i) = 1;
        par.is_GIGE(i) = 1;
        par.is_AD(i)   = 1;
    end

    index = strcmp(CAMS{i},list_struct.SIOC_PM23.PVS);
    if sum(index)
        par.names(i) = list_struct.SIOC_PM23.NAMES(index);
        par.is_PM23(i) = 1;
        par.is_GIGE(i) = 1;
        par.is_AD(i)   = 1;
    end
end
