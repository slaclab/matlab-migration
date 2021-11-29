function val = imgAcq_epics_getImgAcqAvailability()
%imgAcq_epics_getImgAcqAvailability Get value of the image acquisition
%availability PV. 
%  val = imgAcq_epics_getImgAcqAvailability() returns the value of the
%  image acquisition
% availability PV.
%
%  Example:
%       val = imgAcq_epics_getImgAcqAvailability()

%  S. Chevtsov (chevtsov@slac.stanford.edu)

try
    val = lcaGet('PROF:PM00:1:CTRL');
    val=val{1};
catch
    val = 'N/A';
end