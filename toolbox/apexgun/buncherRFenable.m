function [] = buncherRFenable( Enable )
% Enable or disable RF permit for the buncher
% SINTAX:  buncherRFenable( Enable )
% if Enable=0 the RF is disable, for any other value the RF is enabled
if Enable==0
    setpv('Bun:RF:RF_Off_Cmd',1);
    pause(.05)
    setpv('Bun:RF:RF_Off_Cmd',0);
    pause(.05)
else
    % Reset Buncher RF interlocks
    ['Resetting Buncher RF interlocks']
    InterlockCell= {
        'L1llrf:reset_inlk_1_bo'
        'L1llrf:reset_inlk_2_bo'
        'L1llrf:reset_inlk_3_bo'
        'L1llrf:reset_inlk_4_bo'
        'Lmon11:reset_inlk_1_bo'
        'Lmon11:reset_inlk_2_bo'
        'Lmon11:reset_inlk_3_bo'
        'Lmon11:reset_inlk_4_bo'
        'Lmon12:reset_inlk_1_bo'
        'Lmon12:reset_inlk_2_bo'
        'Lmon12:reset_inlk_3_bo'
        'Lmon12:reset_inlk_4_bo'
       };
    for i = 1:length(InterlockCell)
        setpv(InterlockCell{i},1);
        pause(0.1)
        setpv(InterlockCell{i},0);
    end
    
    
    %Reset PLC;
    ['Resetting Buncher PLC'];
    setpv('Bun:RF:InterlockReset',1);
    pause(.05)
    setpv('Bun:RF:InterlockReset',0);
    pause(.05)
    
    
    %Reset RF enable
    setpv('Bun:RF:RF_On_Cmd',1);
    pause(.05)
    setpv('Bun:RF:RF_On_Cmd',0);
    pause(.05)
end

end

