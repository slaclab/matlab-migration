function [BDES1, BDES2] = set_QS_z_ob(z_ob)

lcaPutSmart('SIOC:SYS1:ML03:AO001', z_ob);

[BDES1, BDES2] = set_QS_trim();

end