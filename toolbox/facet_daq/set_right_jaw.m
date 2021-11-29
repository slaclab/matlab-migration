function set_right_jaw(x)

lcaPutSmart('COLL:LI20:2086:MOTR', x);

while abs( lcaGetSmart('COLL:LI20:2086:MOTR.RBV')-x ) > 0.05; end;

display(['Set right jaw to ' num2str(lcaGetSmart('COLL:LI20:2086:MOTR.RBV'))]);
