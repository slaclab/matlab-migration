function set_QS_energy_setpoint_notrim(QS)

lcaPutSmart('SIOC:SYS1:ML03:AO003', QS);

end