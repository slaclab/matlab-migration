function [I_jit,E_jit,t_jit,tol_I,tol_E,tol_t,szn,sdn,Ipkn] = FEL_jitter_tols(N,sz0,sd0,Eg,Ev,R56v,T566v,phiv,dphiv,dV_Vv,dtg,dN_N,Lv,lamS,lamv,s0v,av,dI_tol,dE_tol,dt_tol,b,gu);

if ~exist('gu')
  gu = 'u';
end

tol_I   = zeros(12,1);
tol_E   = zeros(12,1);
tol_t   = zeros(12,1);

%	Outputs:	    sz:	    rms bunch length after i-th linac [mm]
%			        sd:	    rms rel. energy spread after i-th linac [%]
%			        k:	    <Ez> correlation const. of i-th linac [1/m]
%			        Ipk:	Peak current at end of i-th linac [A]
%			        dE_E:	Relative energy offset after i-th linac [%]
%			        dt:	    Timing error at end of i-th linac [psec]
%			        Eloss:	Energy loss per linac due to wake [GeV]
%			        sdsgn:	Signed, correlated E-sprd per linac
%                           (dE_E-z slope * sigz) [%]

[szn,sdn,kn,Ipkn,dE_En,dtn,Elossn,sdsgnn] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0],[0 0 0 0 0],lamv,s0v,av,gu);

% Do phase tests:
% ==============

% L0-linac RF phase error:
j = 1;
dphit = zeros(1,5);
dphit(j) = dphiv(j);
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0, dphit,[0 0 0 0 0],lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,-dphit,[0 0 0 0 0],lamv,s0v,av,gu);
tol_I(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

% L1-linac RF phase error:
j = 2;
dphit = zeros(1,5);
dphit(j) = dphiv(j);
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0, dphit,[0 0 0 0 0],lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,-dphit,[0 0 0 0 0],lamv,s0v,av,gu);
tol_I(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);
															
% Lx-linac RF phase error:
j = 3;
dphit = zeros(1,5);
dphit(j) = dphiv(j);
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0, dphit,[0 0 0 0 0],lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,-dphit,[0 0 0 0 0],lamv,s0v,av,gu);
tol_I(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

% L2-linac RF phase error:
j = 4;
dphit = zeros(1,5);
dphit(j) = dphiv(j);
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0, dphit,[0 0 0 0 0],lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,-dphit,[0 0 0 0 0],lamv,s0v,av,gu);
tol_I(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

% L3-linac RF phase error:
j = 5;
dphit = zeros(1,5);
dphit(j) = dphiv(j);
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0, dphit,[0 0 0 0 0],lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,-dphit,[0 0 0 0 0],lamv,s0v,av,gu);
tol_I(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(j) = jitter_tol([-dphiv(j) 0 dphiv(j)],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

% Do voltage tests:
% ================

% L0-linac RF voltage error:
j = 1;
dV_Vt = zeros(1,5);
dV_Vt(j) = dV_Vv(j);
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0], dV_Vt,lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0],-dV_Vt,lamv,s0v,av,gu);
tol_I(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

% L1-linac RF voltage error:
j = 2;
dV_Vt = zeros(1,5);
dV_Vt(j) = dV_Vv(j);
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0], dV_Vt,lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0],-dV_Vt,lamv,s0v,av,gu);
tol_I(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

% Lx-linac RF voltage error:
j = 3;
dV_Vt = zeros(1,5);
dV_Vt(j) = dV_Vv(j);
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0], dV_Vt,lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0],-dV_Vt,lamv,s0v,av,gu);
tol_I(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

% L2-linac RF voltage error:
j = 4;
dV_Vt = zeros(1,5);
dV_Vt(j) = dV_Vv(j);
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0], dV_Vt,lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0],-dV_Vt,lamv,s0v,av,gu);
tol_I(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

% L3-linac RF voltage error:
j = 5;
dV_Vt = zeros(1,5);
dV_Vt(j) = dV_Vv(j);
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0], dV_Vt,lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,0,[0 0 0 0 0],-dV_Vt,lamv,s0v,av,gu);
tol_I(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(j+5) = jitter_tol([-dV_Vv(j) 0 dV_Vv(j)],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

% gun timing error:
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0, dtg,[0 0 0 0 0],[0 0 0 0 0],lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              0,-dtg,[0 0 0 0 0],[0 0 0 0 0],lamv,s0v,av,gu);
tol_I(11) = jitter_tol([-dtg 0 dtg],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(11) = jitter_tol([-dtg 0 dtg],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(11) = jitter_tol([-dtg 0 dtg],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

% bunch charge error:
[szp,sdp,kp,Ipkp,dE_Ep,dtp,Elossp,sdsgnp] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                               dN_N,0,[0 0 0 0 0],[0 0 0 0 0],lamv,s0v,av,gu);
[szm,sdm,km,Ipkm,dE_Em,dtm,Elossm,sdsgnm] = double_compress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              -dN_N,0,[0 0 0 0 0],[0 0 0 0 0],lamv,s0v,av,gu);
tol_I(12) = jitter_tol([-dN_N 0 dN_N],[ Ipkm(5)  Ipkn(5)  Ipkp(5)],dI_tol*Ipkn(5) ,1,1);
tol_E(12) = jitter_tol([-dN_N 0 dN_N],[dE_Em(5) dE_En(5) dE_Ep(5)],dE_tol,1,1);
tol_t(12) = jitter_tol([-dN_N 0 dN_N],[  dtm(5)   dtn(5)   dtp(5)],dt_tol,1,1);

sumI = sum((b'./tol_I).^2);
sumE = sum((b'./tol_E).^2);
sumt = sum((b'./tol_t).^2);
I_jit = dI_tol*sqrt(sumI);
E_jit = dE_tol*sqrt(sumE);
t_jit = dt_tol*sqrt(sumt);
