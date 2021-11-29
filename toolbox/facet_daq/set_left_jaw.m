function set_left_jaw(x)

lcaPutSmart('COLL:LI20:2085:MOTR', x);

while abs( lcaGetSmart('COLL:LI20:2085:MOTR.RBV')-x ) > 0.05; end;

display(['Set left jaw to ' num2str(lcaGetSmart('COLL:LI20:2085:MOTR.RBV'))]);
