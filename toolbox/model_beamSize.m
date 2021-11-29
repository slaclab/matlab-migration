function [beamSize, beamPos] = model_beamSize(name)

[twiss,sigma]=model_twissGet(name);
emit=lcaGet('EMIT');
beamSize=sqrt(sigma(1,:).*repmat(emit,1,2)./twiss(1,:));
beamPos=[0 0]';
%beamPos=[1 1.4]'*1e-3;
