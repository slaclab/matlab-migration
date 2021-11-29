function names = meme_names( varargin )

% meme_names retrieves the PV names, device names or element names of
% accelerator components in the LCLS-I/II complex.
%
% You can search on PV name ('name') or device name (dname) pattern.
% The default output is PV names, though you can say show device name,
% or show element name (ename).
%
% meme_names([{'name','dname','ename','lname','etype'},stringvalue]1+,...
%       ['show',{'name','dname','ename','lname','etype'}])
%
% The first arguments to meme_names is 1 or more pairs of strings that give the 
% (conjunctive) conditions for the name search. The first string in each
% pair says how the second string should be interpretted - that is, is the
% second a PV name, a device name, an element name or a modelled line name.
%
% name - PV name. May include % wildcard, eg 'name','QUAD:IN20:961:%'.
% dname - Device name. May include % wildcard, eg 'dname','QUAD:LI23:%'. 
% ename - Element name, eg 'ename','BPM23201'.
% lname - Modelled line name, eg 'lname','L2'.
% etype - Element type, eg 'etype','QUAD'.
%
% Following the condition argument pairs, give a single 'show' pair, to
% say what to return. Any one of the identifiers above may also be used
% in a show command (though only 'name' may be given as both a conditional
% and used in a show - so you can give a PV name pattern and ask for
% the resulting list of PV names). If a 'show' pair is not given, show
% 'name' is assumed. That is, show PV names that match the conditions.
% 
% 'show' also takes 'z' as a value, so you can ask to show the z of 
% given devices or elemenst.
%
% References:
% All devices, elements, their type and model lines, are given in:
% [1] http://www.slac.stanford.edu/grp/ad/model/output/lcls/latest/opt/LCLS_lines.dat
%
%
%% Simple get names of PVs matching pattern
% To simply get the names of all the PVs matching simple pattern,
% give first argument 'name', and second argument the pattern where
% the % character is a simple wildcard.
% 
% meme_names('name','QUAD:IN20:961:%')   % All PVs of QUAD:IN20:961
% meme_names('name','QUAD:IN20:%:BDES')  % All BDES Pvs of QUADs in IN20
% lcaGet(meme_names('name','BPMS:LI23:%:X')) % Get values of X BPMS values in LI23
% 
% 
%% Device names
% You can specify queries for names by giving device names, and ask for 
% device names back, as opposed to PV names. Like PV names, device 
% names can include patterns.
% 
% Given a device name, what are its PVs
% meme_names('dname','XCOR:LI21:402')
% 
% Giving device name, what is its Z position
% meme_names('dname','XCOR:LI21:402','show','z')
% 
% What are the device names matching a pattern (typically on unit list).
% This examples gets device name of XCORs and YCORS in LI21.
% meme_names('name','(X|Y)COR:LI21:%','show','dname')
% 
%
%% Element Names
% You can sepecify things by MAD modelled element name rather than PV 
% or device name. The element names are from the last released MAD decks
% of LCLS and LCLS-II [2].
%
% What's the BDES PV of element QM22
% meme_names('name','%:BDES','ename','QM22')
%
% You can also ask to 'show' ename - useful for converting device to
% element name.
%
%
%% Covert element name to device name and vice-versa
%
% Convert element name to device name; give ename, ask for dname.
% meme_names('ename','BPM23201','show','dname')
%
% Convert device name to element name
% meme_names('dname','BPMS:LI23:201','show','ename')
% 
% 
%% Element types
% The meme_names system understands all the MAD element types. You ask for 
% things by element type with specifier 'etype', and supply for instance
% 'QUAD','XCOR'. Etc. Note 'MONI' is a BPM.
% 
% What are all the BPM device names?
% meme_names('etype','MONI','show','dname')   % We want device name, not PV name
%                                        % so 'show' arg is necessary
%                                        
% What are the BACT PVs of the Horizontal Correctors 
% meme_names('name','%:BACT','etype','HKIC')
%
% Get by what element type a given device was modelled in MAD.
% meme_names('dname','HTR:IN20:467','show','etype')
% 
% 
%% Model lines
% You can specify which model line taht names must be drawn from using lname.
% The line names are formally those in the last released MAD deck of LCLS
% and LCLS-II.  
%
% Get device names of QUAD elements in line L2 (by giving element type)
% meme_names('lname','L2','etype','QUAD','show','dname')
%
% Get BDES PV names of QUAD elements in line L2 (giving type and PV name
% pattern). Note, need not use 'show', since PV name is the default output.
% meme_names('lname','L2','etype','QUAD','name','%:BDES')
% 
% Get names of all devices in modelled line 'CLTH1':
% meme_names('lname','CLTH1','show','dname')
%
% Given an element name, what modelled lines is it in?
% meme_names('ename','BPM23501','show','lname')
%

summerr='MEME:namesGet:summerr';

% Make input cell array of string input safe.

result = struct([]); %#ok<*NASGU> % Init return variable to empty struct.
pvname = 'ds';
query = [varargin];

try
    data_nttable = erpc( nturi(pvname,query{:}));
    result = nttable2struct( data_nttable );
    names=result.value.name;
catch ex
    error( summerr,'Unable to get name data for %s; %s',...
    char(query), ex.message);   
end