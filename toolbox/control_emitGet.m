function [twiss, twissStd] = control_emitGet(name)
%CONTROL_EMITGET
%  [TWISS, TWISSSTD] = CONTROL_EMITGET(NAME) gets measured emittance data
%  for device NAME.

% Features:

% Input arguments:
%    NAME: Device name

% Output arguments:
%    TWISS:    Measured Twiss parameters [4 x 1|2 x N_NAME]
%    TWISSSTD: STD of TWISS

% Compatibility: Version 2007b, 2012a
% Called functions: model_nameConvert, lcaGetSmart

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% 29-May-2013, M. Woodley
%   Update LI04 and LI18 design Twiss (76 deg linac, 10 mm R56)
% 16-Mar-2013, P. Schuh
%   Update LI18 design twiss (76 deg linac, 5 mm R56)

name=model_nameConvert(cellstr(name));
tag='xy';

twiss=zeros(4,2,length(name));
twissStd=zeros(4,2,length(name));
for j=1:length(name)
    if any(strncmp(name{j}, {'LI01' 'LI02' 'LI11'}, 4))
        % SCP multiwire emittance measurement results are stored in WIRE:XXXX:XXXX:EPAR
        % SPAR and PPAR (electron scav positron) as defined in SLCTXT:WSOPT_SIG_COV_PAR.TXT
        % everything is in meters and radians except emitn_* (1e-5 m):
        %
        %         PAR = [emit_x , emitn_x, beta_x ,
        %                alpha_x, bmag_x , bcos_x ,
        %                bsin_x , embm_x , chisq_x,
        %                emit_y , emitn_y, beta_y ,
        %                alpha_y, bmag_y , bcos_y ,
        %                bsin_y , embm_y , chisq_y,
        %                7 x-y coupling parameters,
        %                esprd,
        %                eta_x  , sig16  , eta_y  ,
        %                sig36  , xb_yb  , spare   ]
        pvList      = strcat(name{j}, {':SPAR' ':EPAR' ':PPAR'}); % get emittance meas
        tsPvList    = strcat(name{j}, {':SPTS' ':EPTS' ':PPTS'}); % ts of last meas
        errPvList   = strcat(name{j}, {':SERR' ':EERR' ':PERR'}); % std dev of last meas
        ts = datenum(lcaGetSmart(tsPvList));
        [d, newest] = max(ts);                      % decide if SCAV or FACET has latest scan
        par_map = [2 3 4 5 11 12 13 14];            % mapping of parameters in EPAR (see above)
        twiss_scale = [10 10; 1 1; 1 1; 1 1;];      % SLC emittance units are 1e-5 m, convert to micron
        pars = lcaGetSmart(pvList(newest));
        errs = lcaGetSmart(errPvList(newest));
        twiss(:,:,j) = reshape(pars(par_map), [4 2]) .* twiss_scale;
        twissStd(:,:,j) = reshape(errs(par_map), [4 2]) .* twiss_scale;
    elseif any(strncmp(name{j}, {'LI04' 'LI18'}, 4))
        design_twiss = [ 8.8369  0.7315  34.8842 -2.6482;  % 76 deg linac
                     %   8.8312  0.7308  34.8622 -2.6447;  % LI04 design twiss (pre 5.29.2013)
                        24.7341 -1.8677  87.1890  3.7922];  % 76 deg linac, 7mm R56 per MDW
                     %  26.4316 -1.9534  93.8677  4.2869]; % 76 deg linac, 10 mm R56
                     %  24.7326 -1.8678  87.1892  3.7921]; % 76 deg linac, 5 mm R56
                     %  89.4153 -3.2308  18.6946  1.8054]; % LI18 design twiss (pre 3.16.2013)
                    ix = strncmp(name{j}, {'LI04' 'LI18'}, 4);
            twiss0 = reshape(design_twiss(ix,:), 2, 2);
        % SCP quad scan emittance measurements populate sigma matrices only :(
        % which live in WIRE:XXXX:XXXX:SIGX and :SIGY.
        for iPlane = 1:length(tag)
            pvList = strcat(name{j}, ':SIG', upper(tag(iPlane)));
            sig = lcaGetSmart(pvList);
            twissm = model_sigma2Twiss([sig(1); sig(2); sig(4)], [], model_rMatGet(name{j}, [], [], 'EN'));
            twissm(1,:) = twissm(1,:) * 1e6;
            twiss(:,iPlane,j) = model_twissBmag(twissm, twiss0(:,iPlane));
            if nargout > 1
                twissStd(:,iPlane,j) = zeros([4 1]);  % errors are not stored
            end
        end        
    else
        for iPlane=1:length(tag)
            names=strcat({'EMITN' 'BETA' 'ALPHA' 'BMAG'}','_',upper(tag(iPlane)));
            pvList=strcat(name{j},':',names);
            pvStdList=strcat(name{j},':D',names);
            twiss(:,iPlane,j)=lcaGetSmart(pvList);
            if nargout > 1
                twissStd(:,iPlane,j)=lcaGetSmart(pvStdList);
            end
        end
    end
end

twiss(1,:)=twiss(1,:)*1e-6; % Normalized emittance in m
twissStd(1,:)=twissStd(1,:)*1e-6; % Normalized emittance in m


