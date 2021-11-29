function [ract, gatt, satt] = control_feeAttenGet()

% returns total FEE transmission ratio, and structs with info about the current gas
% attenuator and solid attenuator states.

gatt.trans = lcaGetSmart('GATT:FEE1:310:R_ACT');                % gas attenuator transmission
gatt.flow = lcaGetSmart('GFFSM:FEE1:310:ATT_FLOW_STATUS');      % gas flow status
gatt.setpoint = lcaGetSmart('VGPR:FEE1:311:PSETPOINT_DES');     % pressure setpoint
gatt.pressure = lcaGetSmart('VGPR:FEE1:311:P');                 % current pressure

satt.trans = lcaGetSmart('SATT:FEE1:320:RACT');                 % solid attenuator transmission
satt.state = lcaGetSmart(strcat({'SATT:FEE1:32'}, ...           % in/out status of each attenuator
    cellstr(num2str((1:9)')), {':STATE'}));

ract(1,:) = gatt.trans;
ract(2,:) = satt.trans;