function chisq = LCLSopt_min(X0,Xmin,Xmax,Lmax,Eg,Ev,R56v,T566v,phiv,Lv,Gcos0,Gvmax,Gvmin,sz0,sd0,N,...
                             dphiv,szn0,szmin,szmax,dszf,sdn0,sdmin,sdmax,sdsgn0,dsdsgn0,dI_dN0,ddI_dN0,...
                             dE_dN0,ddE_dN0,dI_dtg0,ddI_dtg0,dE_dtg0,ddE_dtg0,...
                             lamv,s0v,av,show_p);

% fit variables ...
% =============
R56v(3:4) = X0(1:2);                        % BC1,2 R56 [m]
phiv([2 4 5]) = X0(3:5);                    % linac-1,2,3 phase [deg]

T566v(3:4) = -1.5*R56v(3:4);                % T566 of BC1,2 chicanes set by R56 (T566=-1.5*R56 for chicane) [m]

Lv(1)   = (Ev(1)  - Eg     ) /Gcos0(1);		% linac-0 length [m]
Lv(2:5) = (Ev(2:5)- Ev(1:4))./Gcos0(2:5);	% linac-1,2,3 length [m]

% required linac gradients...
% ========================
Gv(1)   = (Ev(1)  - Eg     ) /Lv(1)   /cosd(phiv(1));	% linac-0 gradient [GV/m]
Gv(2:5) = (Ev(2:5)- Ev(1:4))./Lv(2:5)./cosd(phiv(2:5));	% linac-1,2,3 gradient [GV/m]

[szn,sdn,kn,Ipkn,dE_En,dtn,Elossn,dI_dN,dE_dN,dI_dtg,dE_dtg,sdsgn] = ...
  					LCLSopt_fun(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,dphiv,lamv,s0v,av);

p = [
     constraint_func(X0(1),Xmin(1),Xmax(1))
     constraint_func(X0(2),Xmin(2),Xmax(2))
     constraint_func(X0(3),Xmin(3),Xmax(3))
     constraint_func(X0(4),Xmin(4),Xmax(4))
     constraint_func(X0(5),Xmin(5),Xmax(5))
     constraint_func(Gv(2),Gvmin(2),Gvmax(2))   % constrain L1 gradient [GV/m]
     constraint_func(Gv(4),Gvmin(4),Gvmax(4))   % constrain L2 gradient [GV/m]
     constraint_func(Gv(5),Gvmin(5),Gvmax(5))   % constrain L3 gradient [GV/m]
     constraint_func(szn(3),szmin(3),szmax(3))	% constrain post BC1 bunch length [mm]
     constraint_func(sdn(3),sdmin(3),sdmax(3))	% constrain post BC1 energy spread [%]
     (szn(5) - szn0(5))  /dszf                  % force final rms bunch length to proper value [mm]
     (sdsgn(5) - sdsgn0(5))/dsdsgn0(5)          % force final rms signed rel. E-sprd to proper value [%]
     constraint_func(dI_dN ,-dI_dN0 ,dI_dN0 )   % minimize Ipk sens. to dN/N [A/%]
     constraint_func(dE_dN ,-dE_dN0 ,dE_dN0 )   % minimize dE/E sens. to dN/N [%/%]
     constraint_func(dI_dtg,-dI_dtg0,dI_dtg0)   % minimize Ipk sens. to dtg [A/psec]
     constraint_func(dE_dtg,-dE_dtg0,dE_dtg0)   % minimize dE/E sens. to dtg [%/psec]
                                                ]';

n = length(p);
if show_p
  disp(p(9:n));                                 % echo progress to screen
end
chisq = 1E-3*p*p'/n;                            % final penalty function to be minimized
