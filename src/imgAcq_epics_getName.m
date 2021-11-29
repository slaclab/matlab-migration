function val = imgAcq_epics_getName()
%imgAcq_epics_getName Get the name of whom does the image acquisition.
%  val = imgAcq_epics_getName() returns the name of whom does the image
%  acquisition.
%
%  Example:
%       val = imgAcq_epics_getName()

%  S. Chevtsov (chevtsov@slac.stanford.edu)

try
    val = lcaGet('PROF:PM00:1:NAME');
    val=val{1};
catch
    val = 'N/A';
end