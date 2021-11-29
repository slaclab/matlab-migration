%multi_gain_taper.m

function out = multi_gain_taper(in)
persistent initial_vals
persistent first_undulator last_undulator pivot undpvs
% in.knob is the number entered into the knob
% ENTER THE PVS YOU WANT TO CONTROL. 


% out.pvs{1,1} = 'USEG:UND1:2850:TMXPOSC';
% out.pvs{2,1} = 'USEG:UND1:2950:TMXPOSC';
% out.pvs{3,1} = 'USEG:UND1:3050:TMXPOSC';
% out.pvs{4,1} = 'USEG:UND1:3150:TMXPOSC';
% out.pvs{5,1} = 'USEG:UND1:3250:TMXPOSC';
% out.pvs{6,1} = 'USEG:UND1:3350:TMXPOSC';




out.egu = 'mmy'; % engineering units for knob (display only)

% this is called when the knob is first initialized, Usually used to record
% initial values for differential knobs.
if in.initialize % First cycle
  undpvs = cell(0);
  pvfirst = setup_pv(564, 'taper - first undulator', 'n', 1, 'multi_gain_taper');
  pvlast = setup_pv(565, 'taper - last undulator', 'n', 1, 'multi_gain_taper');
  pvpivot = setup_pv(566, 'taper - pivot undulator', 'n', 1, 'multi_gain_taper');
  pvs{1,1} = pvfirst;
  pvs{2,1} = pvlast;
  pvs{3,1} = pvpivot;
  xx= lcaGet(pvs);
  first_undulator = xx(1);
  last_undulator = xx(2);
  pivot = xx(3);
  out.num_pvs = last_undulator - first_undulator +1; % ENTER NUMBER OF PVs
  for n = first_undulator:last_undulator
    k = n - first_undulator + 1;
    undpvs{k,1} = ['USEG:UND1:', num2str(n), '50:TMXPOSC'];
  end
  initial_vals = lcaGet(undpvs); %read initial pvs values directly
end


% the calculated outputs
% put any function of the in.knob and thin initial values into the outputs
% (out.val).
%ENTER THE CALCULATION YOU WANT
out.num_pvs = last_undulator - first_undulator +1; % ENTER NUMBER OF PVs
for n = 1:out.num_pvs;
  %out.val(n,1) = initial_vals(n,1) + 2*(n/out.num_pvs-.5) * in.knob;
  %out.val(n,1) = initial_vals(n,1) + n/out.num_pvs * in.knob;
  if pivot >=  0
    out.val(n,1) = initial_vals(n,1) + (n-pivot+first_undulator)/out.num_pvs ...
      * in.knob;
  else
    out.val(n,1) = initial_vals(n,1) + in.knob;
  end
end
out.pvs = undpvs;
end


function pvname = setup_pv(num, text, egu, prec, comment)
numtxt = num2str(round(num));
numlen = length(numtxt);
if numlen == 1
  numstr = ['00', numtxt];
elseif numlen == 2
  numstr = ['0', numtxt];
else
  numstr = numtxt;
end
pvname = ['SIOC:SYS0:ML00:AO', numstr];
lcaPut([pvname, '.DESC'], text);
lcaPut([pvname, '.EGU'], egu);
lcaPut([pvname, '.PREC'], prec);
lcaPut(pv_to_comment(pvname), comment);
end

function out = pv_to_comment(pv)
str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
return;
end
