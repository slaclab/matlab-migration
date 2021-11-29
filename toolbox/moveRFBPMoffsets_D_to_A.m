function RFBPMoffsets = moveRFBPMoffsets_D_to_A

RFBPMoffsets = iniRFBPMoffsets;

RFBPMoffsets = getRFBPMoffsets ( RFBPMoffsets );

RFBPMoffsets = corrRFBPMoffsets ( RFBPMoffsets );

end

function RFBPMoffsets = iniRFBPMoffsets

UndConsts                  = util_UndulatorConstants;

RFBPMoffsets.verbose       = false;
RFBPMoffsets.preBPMs       =  3;
RFBPMoffsets.nGirders      = 33;
RFBPMoffsets.nBPMs         = RFBPMoffsets.preBPMs + RFBPMoffsets.nGirders;
RFBPMoffsets.nPVs          = 2 * RFBPMoffsets.nBPMs;
RFBPMoffsets.index         = zeros ( 2, RFBPMoffsets.nBPMs );
RFBPMoffsets.zpos          = zeros ( 2, RFBPMoffsets.nBPMs );

RFBPMoffsets.BPMoffsetPV   = cell ( RFBPMoffsets.nPVs, 1 );
RFBPMoffsets.CAMoffsetPV   = cell ( RFBPMoffsets.nPVs, 1 );
RFBPMoffsets.SLDoffsetPV   = cell ( RFBPMoffsets.nPVs, 1 );
RFBPMoffsets.PNToffsetPV   = cell ( RFBPMoffsets.nPVs, 1 );

nBPMs = RFBPMoffsets.nBPMs;

index = 0;

index                                  = index + 1;

RFBPMoffsets.index     ( 1, index )  = 1;
RFBPMoffsets.index     ( 2, index )  = 1 + nBPMs;

RFBPMoffsets.zpos      (        1 )  =  508.56; % m;

RFBPMoffsets.BPMoffsetPV {         1 } = sprintf ( 'BPMS:LTU1:910:XAOFF'  );
RFBPMoffsets.BPMoffsetPV { nBPMs + 1 } = sprintf ( 'BPMS:LTU1:910:YAOFF'  );
RFBPMoffsets.CAMoffsetPV {         1 } = sprintf ( 'BPMS:LTU1:910:XOFF.B' );
RFBPMoffsets.CAMoffsetPV { nBPMs + 1 } = sprintf ( 'BPMS:LTU1:910:YOFF.B' );
RFBPMoffsets.SLDoffsetPV {         1 } = sprintf ( 'BPMS:LTU1:910:XOFF.C' );
RFBPMoffsets.SLDoffsetPV { nBPMs + 1 } = sprintf ( 'BPMS:LTU1:910:YOFF.C' );
RFBPMoffsets.PNToffsetPV {         1 } = sprintf ( 'BPMS:LTU1:910:XOFF.D' );
RFBPMoffsets.PNToffsetPV { nBPMs + 1 } = sprintf ( 'BPMS:LTU1:910:YOFF.D' );

index                                  = index + 1;

RFBPMoffsets.index     ( 1, index )  = 2;
RFBPMoffsets.index     ( 2, index )  = 2 + nBPMs;

RFBPMoffsets.zpos      (        2 )  =  511.26; % m;

RFBPMoffsets.BPMoffsetPV {         2 } = sprintf ( 'BPMS:LTU1:960:XAOFF'  );
RFBPMoffsets.BPMoffsetPV { nBPMs + 2 } = sprintf ( 'BPMS:LTU1:960:YAOFF'  );
RFBPMoffsets.CAMoffsetPV {         2 } = sprintf ( 'BPMS:LTU1:960:XOFF.B' );
RFBPMoffsets.CAMoffsetPV { nBPMs + 2 } = sprintf ( 'BPMS:LTU1:960:YOFF.B' );
RFBPMoffsets.SLDoffsetPV {         2 } = sprintf ( 'BPMS:LTU1:960:XOFF.C' );
RFBPMoffsets.SLDoffsetPV { nBPMs + 2 } = sprintf ( 'BPMS:LTU1:960:YOFF.C' );
RFBPMoffsets.PNToffsetPV {         2 } = sprintf ( 'BPMS:LTU1:960:XOFF.D' );
RFBPMoffsets.PNToffsetPV { nBPMs + 2 } = sprintf ( 'BPMS:LTU1:960:YOFF.D' );

index                                  = index + 1;

RFBPMoffsets.index     ( 1, index )  = 3;
RFBPMoffsets.index     ( 2, index )  = 3 + nBPMs;

RFBPMoffsets.zpos      (        3 )  =  UndConsts.Z_BPM { 1 };

RFBPMoffsets.BPMoffsetPV {         3 } = sprintf ( 'BPMS:UND1:100:XAOFF'  );
RFBPMoffsets.BPMoffsetPV { nBPMs + 3 } = sprintf ( 'BPMS:UND1:100:YAOFF'  );
RFBPMoffsets.CAMoffsetPV {         3 } = sprintf ( 'BPMS:UND1:100:XOFF.B' );
RFBPMoffsets.CAMoffsetPV { nBPMs + 3 } = sprintf ( 'BPMS:UND1:100:YOFF.B' );
RFBPMoffsets.SLDoffsetPV {         3 } = sprintf ( 'BPMS:UND1:100:XOFF.C' );
RFBPMoffsets.SLDoffsetPV { nBPMs + 3 } = sprintf ( 'BPMS:UND1:100:YOFF.C' );
RFBPMoffsets.PNToffsetPV {         3 } = sprintf ( 'BPMS:UND1:100:XOFF.D' );
RFBPMoffsets.PNToffsetPV { nBPMs + 3 } = sprintf ( 'BPMS:UND1:100:YOFF.D' );

for SN = 1 : RFBPMoffsets.nGirders
    jX = SN +  RFBPMoffsets.preBPMs;
    jY = SN +  RFBPMoffsets.preBPMs + nBPMs;
    
    index                                  = index + 1;

    RFBPMoffsets.index     ( 1, index )  = jX;
    RFBPMoffsets.index     ( 2, index )  = jY;

    RFBPMoffsets.zpos      (       jX )  =  UndConsts.Z_BPM { 1 + SN };

    RFBPMoffsets.BPMoffsetPV { jX } = sprintf ( 'BPMS:UND1:%d90:XAOFF',  SN );
    RFBPMoffsets.BPMoffsetPV { jY } = sprintf ( 'BPMS:UND1:%d90:YAOFF',  SN );
    RFBPMoffsets.CAMoffsetPV { jX } = sprintf ( 'BPMS:UND1:%d90:XOFF.B', SN );
    RFBPMoffsets.CAMoffsetPV { jY } = sprintf ( 'BPMS:UND1:%d90:YOFF.B', SN );
    RFBPMoffsets.SLDoffsetPV { jX } = sprintf ( 'BPMS:UND1:%d90:XOFF.C', SN );
    RFBPMoffsets.SLDoffsetPV { jY } = sprintf ( 'BPMS:UND1:%d90:YOFF.C', SN );
    RFBPMoffsets.PNToffsetPV { jX } = sprintf ( 'BPMS:UND1:%d90:XOFF.D', SN );
    RFBPMoffsets.PNToffsetPV { jY } = sprintf ( 'BPMS:UND1:%d90:YOFF.D', SN );
end

if ( RFBPMoffsets.verbose )
    for j = 1 : RFBPMoffsets.nPVs
        fprintf ( '%2.2d: %s\n', j, RFBPMoffsets.BPMoffsetPV { j } );
        fprintf ( '%2.2d: %s\n', j, RFBPMoffsets.CAMoffsetPV { j } );
        fprintf ( '%2.2d: %s\n', j, RFBPMoffsets.SLDoffsetPV { j } );
        fprintf ( '%2.2d: %s\n', j, RFBPMoffsets.PNToffsetPV { j } );
    end
end

end


function offsets = getRFBPMoffsets ( RFBPMoffsets )

offsets = RFBPMoffsets;

offsets.BPM = lcaGetSmart ( RFBPMoffsets.BPMoffsetPV );
offsets.CAM = lcaGetSmart ( RFBPMoffsets.CAMoffsetPV );
offsets.SLD = lcaGetSmart ( RFBPMoffsets.SLDoffsetPV );
offsets.PNT = lcaGetSmart ( RFBPMoffsets.PNToffsetPV );

for j = 1 : RFBPMoffsets.nBPMs
    jx = RFBPMoffsets.index     ( 1, j );
    jy = RFBPMoffsets.index     ( 2, j );
    
    fprintf ( 'BPM %2.2d: (%+6.3f,%+6.3f); CAM: (%+6.3f,%+6.3f); SLD: (%+6.3f,%+6.3f); PNT: (%+6.3f,%+6.3f).\n', ...
               j - 3, ...
               offsets.BPM ( jx ), offsets.BPM ( jy ), ...
               offsets.CAM ( jx ), offsets.CAM ( jy ), ...
               offsets.SLD ( jx ), offsets.SLD ( jy ), ...
               offsets.PNT ( jx ), offsets.PNT ( jy )  ...
            );
end

end


function offsets = corrRFBPMoffsets ( RFBPMoffsets )

offsets = RFBPMoffsets;

offsets.BPM = lcaGetSmart ( RFBPMoffsets.BPMoffsetPV );
offsets.CAM = lcaGetSmart ( RFBPMoffsets.CAMoffsetPV );
offsets.SLD = lcaGetSmart ( RFBPMoffsets.SLDoffsetPV );
offsets.PNT = lcaGetSmart ( RFBPMoffsets.PNToffsetPV );

old.BPM = offsets.BPM;
old.PNT = offsets.PNT;
offsets.old = old;
for j = 1 : RFBPMoffsets.nBPMs
    jx = RFBPMoffsets.index     ( 1, j );
    jy = RFBPMoffsets.index     ( 2, j );
    
    offsets.BPM ( jx ) = offsets.BPM ( jx ) + offsets.PNT ( jx );
    offsets.BPM ( jy ) = offsets.BPM ( jy ) + offsets.PNT ( jy );
    
    offsets.PNT ( jx) = 0;
    offsets.PNT ( jy) = 0;
    
    fprintf ( 'BPM %2.2d: from (%+7.4f,%+7.4f) to (%+7.4f,%+7.4f); PNT: from (%+7.4f,%+7.4f) to (%+7.4f,%+7.4f).\n', ...
               j - 3, ...
               old.BPM     ( jx ), old.BPM     ( jy ), ...
               offsets.BPM ( jx ), offsets.BPM ( jy ), ...
               old.PNT     ( jx ), old.PNT     ( jy ), ...
               offsets.PNT ( jx ), offsets.PNT ( jy )  ...
            );
end

lcaPutSmart ( RFBPMoffsets.BPMoffsetPV, offsets.BPM );
lcaPutSmart ( RFBPMoffsets.PNToffsetPV, offsets.PNT );

end


