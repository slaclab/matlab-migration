function val = imgAcq_epics_getGo()
%imgAcq_epics_getGo Get value of the image acquisition "GO" PV. 
%  val = imgAcq_epics_getGo() returns the value of the image acquisition
% "GO" PV.
%
%  Example:
%       val = imgAcq_epics_getGo()

%  S. Chevtsov (chevtsov@slac.stanford.edu)

try
    val = lcaGet('PROF:PM00:1:GO');
    val = val{1};
catch
    val = 'N/A';
end