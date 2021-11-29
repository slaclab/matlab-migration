function [BDES1, BDES2] = set_QS_z_im(z_im)

lcaPutSmart('SIOC:SYS1:ML03:AO002', z_im);

[BDES1, BDES2] = set_QS_trim();

end