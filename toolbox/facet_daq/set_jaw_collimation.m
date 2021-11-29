function set_jaw_collimation(jaw_width)

left_jaw       = 'COLL:LI20:2085:MOTR';
right_jaw      = 'COLL:LI20:2086:MOTR';

% slit_middle = 0.;
slit_middle = lcaGetSmart('SIOC:SYS1:ML01:AO076');

left_jaw_VAL = slit_middle - jaw_width/2;
right_jaw_VAL = slit_middle + jaw_width/2;

% Move jaws to the desired positions
lcaPutSmart(left_jaw, left_jaw_VAL);
lcaPutSmart(right_jaw, right_jaw_VAL);

% Wait they reach their desired positions
while abs( lcaGetSmart([left_jaw '.RBV'])-left_jaw_VAL ) > 0.05; end;
while abs( lcaGetSmart([right_jaw '.RBV'])-right_jaw_VAL ) > 0.05; end;

end