function xalTwissFromRmat(probe)
%
% xalTwissFromRmat(probe)
%
% Replace XAL's phase advance and dispersion values with values computed
% directly from R-matrices

% ------------------------------------------------------------------------------
% 16-JAN-2008, M. Woodley
%    Switch from getTransferMatrix method to getResponseMatrix method for faster
%    execution; use JAMA method getArray to extract R-matrix from java object
% ------------------------------------------------------------------------------

Vd0=[0;0;0;0;1]; % [EtaX0,EtaPX0,EtaY0,EtaPY0,1]
Ri=eye(6);

% track the dispersion and phase advances and replace XAL values

traj=probe.getTrajectory;
for n=1:traj.numStates
  state=traj.stateWithIndex(n-1);
  psi=state.getBetatronPhase;

% if this is the first element, get initial values only

  if (n==1)
    Vd0(1)=state.getChromDispersionX;
    Vd0(2)=state.getChromDispersionSlopeX;
    Vd0(3)=state.getChromDispersionY;
    Vd0(4)=state.getChromDispersionSlopeY;
    psix=psi.getx;
    psiy=psi.gety;
    continue
  end

% get accumulated matrix to this point ... compute dispersion

  R=state.getResponseMatrix.getMatrix.getArray;
  R=R(1:6,1:6); % matrix from start of beamline
  Md=[R(1:4,1:4),R(1:4,6)]/R(6,6); % dispersion transport matrix
  Vd=Md*Vd0; % [EtaX,EtaPX,EtaY,EtaPY]

% replace the XAL dispersion values

  state.setChromDispersionX(Vd(1))
  state.setChromDispersionSlopeX(Vd(2))
  state.setChromDispersionY(Vd(3))
  state.setChromDispersionSlopeY(Vd(4))

% compute this element's matrix ... compute phase advances

  Rn=R*Ri; % this element's matrix
  twiss=state.getTwiss;
  bx=twiss(1).getBeta;
  ax=twiss(1).getAlpha;
  dpsix=atan2(Rn(1,2),Rn(2,2)*bx+Rn(1,2)*ax); % x phase advance (radians)
  by=twiss(2).getBeta;
  ay=twiss(2).getAlpha;
  dpsiy=atan2(Rn(3,4),Rn(4,4)*by+Rn(3,4)*ay); % y phase advance (radians)

% replace the XAL betatron phase values

  psix=psix+dpsix;
  psi.setx(psix)
  psiy=psiy+dpsiy;
  psi.sety(psiy)
  state.setBetatronPhase(psi)

% set up inverse accumulation matrix for next element

  Ri=inv(R);
end

end
