function [] = linacRFenable( Enable )
% Enable or disable RF permit for the linac and TCav
% SINTAX:  linacRFenable( Enable )
% if Enable=0 the RF is disable, for any other value the RF is enabled
if Enable==0
    setpv('Lin:RF:RF_Off_Cmd',1);
    pause(.05)
    setpv('Lin:RF:RF_Off_Cmd',0);
    pause(.05)
else
    % Reset Linac RF interlocks
    ['Resetting Linac RF interlocks']
    InterlockCell= {
        'L2llrf:reset_inlk_1_bo'
        'L2llrf:reset_inlk_2_bo'
        'L2llrf:reset_inlk_3_bo'
        'L2llrf:reset_inlk_4_bo'
        'Lmon21:reset_inlk_1_bo'
        'Lmon21:reset_inlk_2_bo'
        'Lmon21:reset_inlk_3_bo'
        'Lmon21:reset_inlk_4_bo'
        'Lmon22:reset_inlk_1_bo'
        'Lmon22:reset_inlk_2_bo'
        'Lmon22:reset_inlk_3_bo'
        'Lmon22:reset_inlk_4_bo'
        'Lmon31:reset_inlk_1_bo'
        'Lmon31:reset_inlk_2_bo'
        'Lmon31:reset_inlk_3_bo'
        'Lmon31:reset_inlk_4_bo'
        'Lmon32:reset_inlk_1_bo'
        'Lmon32:reset_inlk_2_bo'
        'Lmon32:reset_inlk_3_bo'
        'Lmon32:reset_inlk_4_bo'
       };
    for i = 1:length(InterlockCell)
        setpv(InterlockCell{i},1);
        pause(0.1)
        setpv(InterlockCell{i},0);
    end
    
    
    %Reset PLC;
    ['Resetting Linac PLC'];
    setpv('Lin:RF:InterlockReset',1);
    pause(.05)
    setpv('Lin:RF:InterlockReset',0);
    pause(.05)
    
    
    %Reset RF enable
    setpv('Lin:RF:RF_On_Cmd',1);
    pause(.05)
    setpv('Lin:RF:RF_On_Cmd',0);
    pause(.05)
end

end

