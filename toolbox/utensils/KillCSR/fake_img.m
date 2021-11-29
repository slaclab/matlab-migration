classdef fake_img < handle
    % helper class which feeds data to KillCSR for dev.
properties
    % Modus:
    % 0 - load
    % 1 - calc
    mode = 1
    
    data
    file = 1
    pen = 1
    phase = 0
end

properties % Should be constant but its easier during dev. this way
    FILES = {...
...'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R1I1-2015-07-30-135253.mat'... the only one without BG
'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R1I1-2015-07-30-141051.mat'...
'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R1I1-2015-07-30-143802.mat'...
'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R1I1-2015-07-30-144551.mat'...
...'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R1I1-2015-07-30-150426.mat'... only has 3 phases
'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R1I3-2015-07-30-152651.mat'...
'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R1I4-2015-07-30-152651.mat'...
'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R2I1-2015-07-30-152651.mat'...
'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R2I1-2015-07-30-153917.mat'...
'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R2I2-2015-07-30-144551.mat'...
...'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R2I2-2015-07-30-150426.mat'... 3
...'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R2I3-2015-07-30-150426.mat'... 3
...'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R3I2-2015-07-30-150426.mat'... 3
...'/u1/lcls/matlab/data/2015/2015-07/2015-07-30/KillCSR-R3I3-2015-07-30-150426.mat'... 3
}
    N_PHASE = 5
    N_PEN = 3
    
    TILTNOISE = .02*0;
    IMAGENOISE = 10;
    BEAMSIZE = .1;
    SOL_ABS = [3, -0.3]';
    SOL_PHS = [0, 1]';
    OFF_X = 1;
    OFF_Y = -2;
    n = [300 400];
    N_PART = 1e5;
end

methods
    
    function set.N_PEN(o, varargin)
        error('asdf')
    end
    
    function o = fake_img
        o.data = load(o.FILES{1});
    end
    
    function img = get_img(o, n_img)
%         error('Messung')
        
        switch o.mode
            case 0
                img = o.load(n_img);
            case 1
                img = o.calc(n_img);
            otherwise
                assert(0, 'Unknown mode')
        end
    end
end

methods(Access = private)
    function img = load(o, n_img)
        if n_img
            % where are we?
            o.phase = o.phase + 1;
            
            fprintf('%i %i %i\n', o.phase, o.pen, o.file)
            
            if o.phase > o.N_PHASE
                o.phase = 1;
                o.pen = o.pen + 1;
            end
            
            if o.pen > o.N_PEN
                o.pen = 1;
                o.file = o.file + 1;
                o.data = load(o.FILES{o.file});
            end
            
            % transform everything to int16 since matlab doesn't implicitly
            % convert from uint16 to int16
            img = o.data.data(o.pen).raw(o.phase).img;
            
            for i = 1:length(img)
                img(i).img = int16(img(i).img);
            end
        else
            img = o.data.data(1).raw(1).img(1);
            img.img = zeros(size(img.img), 'int16');
        end
    end
    
    function img = calc(o, n_img)
        % Magnet value to find the phase advance
        p = [3.918852601029911e-01, 4.367196518783866e-01, 4.769462358193502e-01,...
            5.055745467175756e-01, 5.303792917446974e-01, 5.542044038703408e-01, ...
            5.709510828467874e-01, 5.882500134065580e-01, 6.042232988423615e-01, ...
            6.190909346680361e-01, 6.333765177421253e-01, 6.479085831885278e-01, ...
            6.608240879463547e-01, 6.748934585228654e-01, 6.889366579034684e-01, ...
            7.016750961439356e-01, 7.197994762338931e-01, 7.357454972429793e-01, ...
            7.591384288689584e-01];
        
        p = control_magnetGet('QUAD:LI28:201') / model_rMatGet('QUAD:LI28:201',[],[],'EN') / 3.5624 - p;
        [~, p] = min(abs(p));
        p = p * pi / 36;
        
        tilt = sum(sin(o.SOL_PHS - p) .* (o.SOL_ABS - control_magnetGet({'CQ21' 'CQ22'}))/10);
        tmp = o.SOL_ABS - control_magnetGet({'CQ21' 'CQ22'});

        xlim = linspace(-1,1,o.n(1));
        ylim = linspace(-1,1,o.n(2));
        img = repmat(struct('img',[],'roiXN', o.n(2), 'roiYN', o.n(1), 'centerX', 10,...
            'centerY', 300, 'roiX',210, 'roiY', 50, 'res', 31), max(n_img, 1),1);

        if n_img
            for i = 1:n_img
                x = randn(o.N_PART, 1) + o.OFF_X;
                y = randn(o.N_PART, 1)*o.BEAMSIZE + x * (tilt  + randn*o.TILTNOISE) + o.OFF_Y;

                img(i).img = uint16(abs(randn(o.n)) * o.IMAGENOISE + hist3(x/4, y/4, xlim, ylim)');
            end
        else
            img.img = uint16(abs(randn(o.n)) * o.IMAGENOISE);
        end
    end
end

methods (Static)
    function out = getFake(n_img)
        global fake
        
        if isempty(fake)
            fake = fake_img;
        end
        
        out = fake.get_img(n_img);
    end
    
    function reset()
        global fake
        
        if isempty(fake)
            fake = fake_img;
        end
        
        fake.pen = 1;
        fake.file = 1;
        fake.phase = 0;
        fake.data = load(fake.FILES{fake.file});
    end
end
end