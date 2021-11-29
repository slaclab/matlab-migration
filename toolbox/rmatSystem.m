function [S, corrsX_e, corrsY_e, bpms_e] = rmatSystem(model_s)
% rmatSystem computes the R-matrix response of all the BPMS from all correctors
% in a transport line. That is, rmatSystem computes A in 
% the accelerators steering problem posed as a linear least squares problem min
% ||Ax-b||. MODEL_S must be a structure conforming to description
% below, and contains all Rmatrices of all devices from 
% some upstream point (typically injection), as is returned by MEME model
% serices. 
%
% NOTE: For efficiency, rmatSystem assumes a transport layout, not
% circular. It computes response only for bpms ordinally greater than the 
% corrector. Do not use for circular machines without modification.
%
% OUTPUT arguments
%  S, a 4-D tensor, S(2 planes of effect, m bpms, n corrs, 2 planes of actuation). 
%     That is, S(1,5,3,1) is the effect of change in x angle at 3rd corrector on x
%     transverse offset at the 5th bpm. The matrix formed by the
%     bpm and corrector terms, eg S(1,:,:,1), will be lower trapezoidal, since 
%     (in a linac) downstream corrs can not affect upstream bpms
%  CORRSX_E an array of the indeces of the X correctors in the arrays of
%  MODEL_S
%  CORRSY_E an array of the indeces of the Y correctors in the arrays of
%  MODEL_S
%  BPMS_E  an array of the indeces of the BPMs in the arrays of MODEL_S.
% 
% EXAMPLE:
% R_ntt=rdbGet('MODEL:RMATS:EXTANT:FULLMACHINE');
% [S, corrsX_e, corrsY_e, bpms_e] = rmatSystem(R_ntt.value);

% ---------------------------------------------------------------------
% Auth: Greg White (greg@slac.stanford.edu) 8-Aug-2016
% Mod:
% ======================================================================

% Find indeces of correctors and bpms in arrays of model NTTable structure 
corrsX_e=find(strncmp(model_s.epics_channel_access_name,'XCOR:',5)); 
corrsY_e=find(strncmp(model_s.epics_channel_access_name,'YCOR:',5));
corrs_e=sort(vertcat(corrsX_e,corrsY_e));  % combine and sort x and y corr indeces
bpms_e=find(strncmp(model_s.epics_channel_access_name,'BPMS:',5)); 

Ncorrs=length(corrs_e); % Num of devices is equ to length of index arrays.
Mbpms=length(bpms_e);

% Check there are correctors and bpms in the model given, if not issue error.
if (Ncorrs < 1) 
        error('MDL:NODEVICES','No correctors in model!'), end;
if (Mbpms < 1) 
        error('MDL:NODEVICES','No BPMs in model!'), end;

% Initialize system matrix to 0s. In a linac, when complete, S matrix will be
% lower trapezoidal, since downstream corrs can not affect upstream bpms. 
% 
S=zeros(2,Mbpms,Ncorrs,2);

for cj=1:Ncorrs
    ce=corrs_e(cj);
    Ra_inv=zeros(6,6);
    % fprintf('Computing R-matrices for corrector %d %s ',cj,model_s.element_name{ce});
    % In linac, a is always a corrector, b is always a bpm
    bi=Mbpms;
    while (bi > 0 && model_s.ordinal(ce) < model_s.ordinal(bpms_e(bi)))
        be=bpms_e(bi);
        
        % If 1st time through for this corrector, compute inv of its R-mat.
        if (Ra_inv == 0)
            Ra = row2matrix(model_s,ce);
            Ra_inv=inv(Ra);
        end;

        % Rmat of a to b is inverse of rmat at a, times rmat of b.
        Rb=row2matrix(model_s,be);
        Rab=Ra_inv*Rb;
        
        S(1,bi,cj,1)=Rab(1,2);   % xcor->xbpm == Rab 1,2 term
        S(1,bi,cj,2)=Rab(1,4);   % ycor->xbpm == Rab 1,4 term
        S(2,bi,cj,1)=Rab(3,2);   % xcor->ybpm == Rab 3,2 term
        S(2,bi,cj,2)=Rab(3,4);   % ycor->ybpm == Rab 3,4 term
        
        bi=bi-1;
    end
end


function D = row2matrix(model_s,row)
    D=zeros(6,6);
    D(1,1) = model_s.r11(row);
    D(1,2) = model_s.r12(row);
    D(1,3) = model_s.r13(row);
    D(1,4) = model_s.r14(row);
    D(1,5) = model_s.r15(row);
    D(1,6) = model_s.r16(row);
    D(2,1) = model_s.r21(row);
    D(2,2) = model_s.r22(row);
    D(2,3) = model_s.r23(row);
    D(2,4) = model_s.r24(row);
    D(2,5) = model_s.r25(row);
    D(2,6) = model_s.r26(row);
    D(3,1) = model_s.r31(row);
    D(3,2) = model_s.r32(row);
    D(3,3) = model_s.r33(row);
    D(3,4) = model_s.r34(row);
    D(3,5) = model_s.r35(row);
    D(3,6) = model_s.r36(row);
    D(4,1) = model_s.r41(row);
    D(4,2) = model_s.r42(row);
    D(4,3) = model_s.r43(row);
    D(4,4) = model_s.r44(row);
    D(4,5) = model_s.r45(row);
    D(4,6) = model_s.r46(row);
    D(5,1) = model_s.r51(row);
    D(5,2) = model_s.r52(row);
    D(5,3) = model_s.r53(row);
    D(5,4) = model_s.r54(row);
    D(5,5) = model_s.r55(row);
    D(5,6) = model_s.r56(row);
    D(6,1) = model_s.r61(row);
    D(6,2) = model_s.r62(row);
    D(6,3) = model_s.r63(row);
    D(6,4) = model_s.r64(row);
    D(6,5) = model_s.r65(row);
    D(6,6) = model_s.r66(row);

    return;

