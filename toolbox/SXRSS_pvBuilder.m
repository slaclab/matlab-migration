function [pvList,procList]=SXRSS_pvBuilder(tags, event)

%SXRSS_PVBUILDER
%  SXRSS_PVBUILDER(TAGS, EVENT) moves mirror positions

% Features:

% Input arguments:
%    TAGS: Tag for cell array containing prefixes associated with pvs e.g. M3P, SLIT_X, ML01,etc.
%    EVENT:     Cell array containing designation for pv suffixes e.g. ACT,
%    DES,PROC, ML - Matlab pvs

% Output arguments: 
%    pvList: List of PVs

% Compatibility: Version 2007b, 2012a
% Called functions: 

% Author: Dorian Bohler SLAC

% Example:
%   SXRSS_pvBuilder({'M3P'},{'ACT'}) => 'MIRR:UND1:966:P:ACT'

% --------------------------------------------------------------------


pvList=cell(size(tags));
procList=cell(2,length(tags));
for i =1:length(tags)
    
    switch tags{i}
        case 'SLITX'
            prefix='SLIT:UND1:962:X:';
            
        case 'SLITY'
            prefix='SLIT:UND1:962:Y:';
            
        case 'M3X'
            prefix='MIRR:UND1:966:X:';
            
        case 'M3P'
            prefix='MIRR:UND1:966:P:';
            
        case 'M3O'
            prefix='MIRR:UND1:966:O:';
            
        case 'GRATX'
            prefix='GRAT:UND1:934:X:';
            
        case 'GRATY'
            prefix='GRAT:UND1:934:Y:';
            
        case 'M1P'
            prefix='MIRR:UND1:936:P:';
            
        case 'M2X'   
            prefix='MIRR:UND1:964:X:';
            
        case 'ML01'
            prefix='SIOC:SYS0:ML01:';
            
    end
    
    switch event{i}
        case 'DES'
            suffix='DES';
            
        case 'ACT'
            suffix='ACT';
            
        case 'PROC'
            procList{1,i}=strcat(prefix,'TRIM.PROC');
            suffix='DES';
            procList{2,i}=strcat(prefix,'ACT');
            
        case event{i}
            suffix=char(event{i});

    end
    
    pv=strcat(prefix, suffix);
    pvList{i} =pv;
    
   
end
pvList=char(pvList);

procList=procList';



