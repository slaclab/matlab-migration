function [names] = aidalist(instance, attribute, nameform)
%  aidalist lists the names of Control System quantities known to AIDA-PVA.
%
%  AIDA-PVA (Accelerator Independent Data Access) [1] is a software
%  system that can get (or put) the values of control system
%  quantities from a number of sources, such as EPICS PVs, XAL
%  model, Archiver and SLC History, and various specialist SLC
%  control system items such as Klystron phase/amp, Magnets,
%  triggers etc.
%
%  Since AIDA-PVA can acquire data form many kinds of data source, not
%  just EPICS, the interpretation of instance and attribute will
%  vary. The following gives some examples of AIDA-PVA names.
%
%  Example names:  instance            attribute
%                  ------------------  ----------------
%  EPICS CA:       BPMS:IN20:425:X1    VAL
%  Archiver        QUAD:LI21:271:TEMP  HIST.lcls
%  Model           XCOR:IN20:425       twiss
%  Oracle data     LCLS                BSA.elements.byZ
%
%  aidalist returns the AIDA directory service "instances" (and
%  optionally also "attributes") matching the patterns given in the
%  instance and attribute arguments. If only an instance pattern is
%  given, then only matching instances are returned; if attributes are
%  also given, then names matching both instance and attribute are
%  returned. In the case that both instance and attribute are given,
%  the default syntax of the returned names, is
%  <instance>:<attribute>, which is the form suitable to be fed
%  directly to aidaget for acquisition (see help for
%  aidaget). However, if nameform is also given, and it is
%  specifically valued '2col', then instances and attributes are
%  returned in 2 columns.
%
%  USAGES: names = aidalist(INSTANCE)
%          names = aidalist(INSTANCE, ATTRIBUTE)
%          names = aidalist(INSTANCE, ATTRIBUTE, NAMEFORM)
%
%
%  INPUTS:
%     INSTANCE (Required) An AIDA "instance" such as the name of a device,
%              PV, name of a thing, or name of a group of data of
%              interest. '%' may be used as a wild card.
%
%     ATTRIBUTE (Optional) An AIDA "attribute", such as "VAL" would
%              indicate the EPICS VALue field of an EPICS PV instance;
%              an SLC device secondary; a modelled property like "R",
%              etc. '%' may be used as a wild card.
%
%     NAMEFORM (Optional) A string indicating the required output
%              form. Nameform is only meaningful if ATTRIBUTE is
%              given. Unless nameform is given as '2col', the
%              output will strings will have the syntax
%              "<instance>:<attribute>"; if it is '2col' they will
%              have the syntax "<instance>          <attribute>".
%
%     Wild cards:
%     Both INSTANCE and ATTRIBUTE may contain any number of '%' to
%     indicate wild cards (0 or more of any character).
%
%  OUTPUTS:
%     NAMES    will be populated with a cell array of strings. Each string
%              will be valued with the name of one AIDA instance, or
%              a complete AIDA value name (an instance attribute pair),
%              depending on whether the attribute input argument was
%              given. See above. If no names matched, NAMES will be valued
%              {} on exit. This can be tested with a statement like "if
%              isempty(aidalist('BPMS:IN20:%:X1')) disp 'Darn!'"
%
%  AIDA is a data server system that can acquire and return data in
%  the SLAC accelerator complex, such as EPICS PV values,
%  history/archiver data, model data, orbit data, Oracle data
%  etc. See https://www.slac.stanford.edu/grp/cd/soft/aida/aida-pva/. To test
%  out what aidalist will return, see https://seal.slac.stanford.edu/aidaweb/.
%
%  Examples:
%    1) Confirm BPMS:IN20:425 is a known device-name.
%       names = aidalist('BPMS:IN20:425%');
%       if isempty(names)
%          disp 'BPMS:IN20:425 is not a known device'
%       end
%
%       This form is quick way to get names of all the PVs in an
%       EPICS device (but be careful because it's likely to return more
%       than only all the EPICS PV names for a given device-name. It's
%       better to use a more constrained search pattern like in example
%       3 if you want only PV names).
%
%    2) Return All "9 something" instances XCOR in LI10.
%
%       names = aidalist('XCOR:LI10:9%')
%
%    3) Return all the 'X1' PVs of all the BPMS units in IN20
%       (useful for pairing with BSA BPM acquisitions).
%
%       names = aidalist('BPMS:IN20:%:X1')
%
%    4) Get all the attributes of a device. The following gets all the AIDA
%       names for a given device. That includes all the EPICS PV
%       VAL record names (used to get the EPICS value), plus
%       the names used to get model (twiss and R), plus names to
%       get history etc.
%
%       names = aidalist('BPMS:IN20:425%','%')
%
%    5) Which BENDs in the linac have modelled twiss?
%
%       names = aidalist('BEND:LI%:%','twiss')
%
%    6) What's known about LCLS overall?
%
%       names = aidalist('LCLS','%')
%
%
%   References:
%   [1] The AIDA-PVA web page: https://www.slac.stanford.edu/grp/cd/soft/aida/aida-pva/
%   [2] The Legacy AIDA web page: http://www.slac.stanford.edu/grp/cd/soft/aida/
%
%  Auth: 17-Sep-2008, Greg White (greg)
%

if nargin < 2
    attribute = '';
end
if nargin < 1
    instance = [];
end

command = sprintf('./scripts/aida-pvalist %s %s', instance, attribute);
[status, result] = system(command);

% Remove the final trailing \n newline, then split up the resulting
% string on \n newlines, so names is of length = number of matched
% names. Each element is one AIDA instance (if only instance arg was
% given), or one instance attribute pair.
result1 = regexp(result,'.*[^\n]','match');
names = regexp(char(result1),'\n','split');

% If the nameform arg is not given, or it is given but its value is
% anything other that specifically '2col', then replace the spaces
% with :, to make an acquirable AIDA-PVA name of the syntax
% <instance>:<attribute>, suitable for aidaget.
if nargin == 2 || (nargin > 2 && (strcmp(nameform,'2col') == 0))
    pattern = '\s+';
    names = regexprep(names,pattern,':');
end

% If there was no match then names = {''}, whose length is 1, so compensate.
if (length(names) == 1 && not(isempty(strmatch(names,{''}))))
    names={};
end

return
