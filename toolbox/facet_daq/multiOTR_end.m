

par.cams = {'YAG',     'YAGS:LI20:2432';
            'USOTR',    'OTRS:LI20:3158';
            'IPOTR',    'OTRS:LI20:3180';
            'DSOTR',    'OTRS:LI20:3206';
            'IP2A',    'MIRR:LI20:3202';
            'IP2B',    'MIRR:LI20:3230';
            'BETAL',    'PROF:LI20:3486'};

for i=1:size(par.cams,1)
    lcaPut(strcat(par.cams(i,2),':SAVE_IMG_DIR'),'FTP1:/PM/');
    lcaPut(strcat(par.cams(i,2),':IMAGE_NAME'), par.cams(i,1));    
end
