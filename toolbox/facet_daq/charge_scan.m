function charge_scan(param)

notch_x        = 'COLL:LI20:2069:MOTR';
notch_y        = 'COLL:LI20:2072:MOTR';
notch_rotation = 'COLL:LI20:2073:MOTR';

lcaPutSmart(notch_y,-2600);
lcaPutSmart(notch_rotation,5);
lcaPutSmart(notch_x, param);

while abs( lcaGetSmart([notch_y '.RBV'])-(-2600)) > 10; end;
while abs( lcaGetSmart([notch_rotation '.RBV'])-5) > 0.02; end;
while abs( lcaGetSmart([notch_x '.RBV'])-param) > 2; end;