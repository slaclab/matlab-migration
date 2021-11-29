function FromSCOREtest5()
% tester for FromSCORE. Request specific snaphot id.

regions = getSCOREregions();
arg.region = regions{18};

Snap_ids = getSCORESnap_ids(arg);
arg.Snap_id = Snap_ids(1)

[data,comment,ts,title] = FromSCORE(arg);
DumpDataFromSCORE(data,comment,ts,title);
