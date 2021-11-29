function [BDES1, BDES2] = set_QS_energy_setpoint(QS)

lcaPutSmart('SIOC:SYS1:ML03:AO003', QS);

[BDES1, BDES2] = set_QS_trim();

end