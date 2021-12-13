function [x, y, tmit, pulseId, stat] = control_bpmAidaGet(name, num, bpmd)
%CONTROL_BPMAIDAGET
% [X, Y, TMIT, PULSEID] = CONTROL_BPMAIDAGET(NAME, NUM, BPMD) gets
% NUM acquisitions of synchronous BPM data of SLC BPMs in list NAME through
% Aida for DGRP number BPMD.  Returns all 0 if unsuccessfull (like EPICS
% BSA).

% Features:

% Input arguments:
%    NAME: String or cellstrings of BPM names
%    NUM:  Number of pulses to acquire
%    BPMD: DGRP number or name as string, default '57' or 'NDRFACET'

% Output arguments:
%    X:       Array of horizontal beam positions [length(NAME) x NUM]
%    Y:       Array of vertical beam positions
%    TMIT:    Array of TMITs
%    PULSEID: Vector of pulse Ids.
%    STAT:    Status of acquisitions

% Compatibility: Version 7 and higher
% Called functions: model_nameConvert, aidainit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Check input arguments.
if nargin < 3, bpmd='57';end

name=model_nameConvert(reshape(cellstr(name),[],1),'SLC');
nBPM=numel(name);

% Setup DRGP
switch bpmd
    case '58'
        dgrp='SDRFACET';
    case '57'
        dgrp='NDRFACET';
    case '8'
        dgrp='ELECEP01';
    case '19'
        dgrp='SCAVSPPS';
    case 'SDRFACET'
        dgrp=bpmd;bpmd='58';
    case 'NDRFACET'
        dgrp=bpmd;bpmd='57';
    case 'ELECEP01'
        dgrp=bpmd;bpmd='8';
    case 'SCAVSPPS'
        dgrp=bpmd;bpmd='19';
end

% Set up Aida acquisition.
requestBuilder = pvaRequest([dgrp ':BUFFACQ']);
requestBuilder.with('BPMD', bpmd);
requestBuilder.with('NRPOS', num);
requestBuilder.with('BPMS', name);

% Read BPM data.
try
    out=requestBuilder.get();
    nameOut=reshape(cell(toArray(out.get('name'))), [], nBPM)';
    pulseId=reshape(cell2mat(toArray(cell(out.get('id')))),[],nBPM)';
    x=reshape(cell2mat(cell(toArray(out.get('x')))),[],nBPM)';
    y=reshape(cell2mat(cell(toArray(out.get('y')))),[],nBPM)';
    tmit=reshape(cell2mat(cell(toArray(out.get('tmits')))),[],nBPM)';
    stat=reshape(cell2mat(cell(toArray(out.get('stat')))),[],nBPM)';
    [isOut,idOut]=ismember(name,nameOut(:,1));
    pulseId=pulseId(idOut,:);
    x=x(idOut,:);
    y=y(idOut,:);
    tmit=tmit(idOut,:);
    stat=stat(idOut,:);
catch e
    handleExceptions(e);
    [x,y,tmit,pulseId,stat]=deal(zeros(nBPM,num));
end
