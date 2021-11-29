function set_QS_QuadScan_energy_setpoint(E)

lcaPutSmart('SIOC:SYS1:ML01:AO078', E);

end