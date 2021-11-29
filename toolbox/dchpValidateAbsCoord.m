function val = dchpValidateAbsCoord(module, neg_us_pa, neg_ds_pr, pos_us_pa, pos_ds_pr)
% function VAL = dchpValidateGapCoord(MODULE, NEG_US_PA, NEG_DS_PR, POS_US_PA, POS_DS_PR)
%
% Validate dechirper module gap coordinates.
%
% Inputs:
%  MODULE = 'V' or 'H'
%  NEG_US_PA = neg. rail (bottom/south), upstream absolute position (mm)
%  NEG_DS_PR = downstream relative position offset from upstream end (mm)
%  POS_US_PA = pos. rail (top/north), upstream absolute position (mm)
%  POS_DS_PR = downstream relative position offset from upstream end (mm)
%
% Output:
%  VAL = 1 if valid, 0 if invalid

% Note: At install, each rail is computed independently due to constraining
% to prevent overtravel. This is expected to change in the future if in
% vacuum switches are made normally closed which will make limits for each
% rail in a module dependent on the position of its opposing rail. So this
% function is cast from the start to require inputing both rail settings.

switch lower(module)
    case 'v'  
        rail = {'B','T'};
        pv = 'DCHP:LTU1:545:';
    case 'h'
        rail = {'S','N'};
        pv = 'DCHP:LTU1:555:';
    otherwise
        error('Invalid module specified.')
end
railsign = [-1,1];
us_pa = [neg_us_pa,pos_us_pa];
ds_pa = [neg_ds_pr,pos_ds_pr] + us_pa;
val = nan(1,2);
for k = 1:2
    % Back calculate the carriage/motor positions
    [pvs,~,ispv] = lcaGetSmart({... % wall of inputs:
        [pv 'US_PP_L'];...
        [pv 'PP_TRM_L'];...
        [pv 'PP_DS_L'];...
        [pv rail{k} ':F_UC'];...
        [pv rail{k} ':F_DC'];...
        [pv rail{k} ':F_UT'];...
        [pv rail{k} ':F_DT'];...
        [pv rail{k} ':CSP.LLM'];...
        [pv rail{k} ':CSP.HLM'];...
        [pv rail{k} ':TRM.LLM'];...
        [pv rail{k} ':TRM.HLM'];... % motor limits...
        [pv 'F_MIN_GAP'];... % ...may not transform to same gap limits!
        [pv 'F_MAX_GAP'];});
    if any(~ispv);error('Can''t retrieve parameter PVs.');end
    pvs(12:13) = pvs(12:13)/2;
    if (us_pa(k)*railsign(k) < pvs(12)) || (ds_pa(k)*railsign(k) < pvs(12)) || ...
            (us_pa(k)*railsign(k) > pvs(13)) || (ds_pa(k)*railsign(k) > pvs(13))
        val = 0;
        return
    end
    a = pvs(1);
    b = pvs(2);
    bPc = pvs(3);
    F(:,:) = reshape(pvs(4:7),2,2);
    M = eye(2)/(F.*[1, -a/b; 1, bPc/b]);
    CT = M*[us_pa(k); ds_pa(k)];
    val(k) = ~((CT(1) < pvs(8)) || (CT(1) > pvs(9)) || ...
            (CT(2) < pvs(10)) || (CT(2) > pvs(11)));
end
val = val(1) && val(2);