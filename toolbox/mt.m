%mt.m

xcors =  1;
ycors = 1;
quads = 1;
soln = 1;
bends = 1;
use_in20_linac = 1; %  use in20 linac magnets

in20 = 0;
in21 = 1;


ctrl.standardize = 1; % standardize all magnets
ctrl.trim = 0; % trim all magnets (doesn't work if standardize on)
ctrl.kludgestandardize = 0;
ctrl.test_magnets = 1;
ctrl.con_to_des = 1;
ctrl.run = 1;



clear m;
j = 0;
if in20
    if xcors
        j = j + 1;
        m{j} = 'XCOR:IN20:121';
        j = j + 1;
        m{j} = 'XCOR:IN20:221';
        j = j + 1;
        m{j} = 'XCOR:IN20:311';
        j = j + 1;
        m{j} = 'XCOR:IN20:341';
        j = j + 1;
        m{j} = 'XCOR:IN20:381';
        j = j + 1;
        m{j} = 'XCOR:IN20:411';
        j = j + 1;
        m{j} = 'XCOR:IN20:491';
        j = j + 1;
        m{j} = 'XCOR:IN20:521';
        j = j + 1;
        m{j} = 'XCOR:IN20:641';
        j = j + 1;
        m{j} = 'XCOR:IN20:721';
        j = j + 1;
        if use_in20_linac
            m{j} = 'XCOR:IN20:761';
            j = j + 1;
        end
        m{j} = 'XCOR:IN20:811';
        j = j + 1;
        m{j} = 'XCOR:IN20:831';
        j = j + 1;
        m{j} = 'XCOR:IN20:911';
        j = j + 1;
        m{j} = 'XCOR:IN20:951';
    end

    if ycors
        j = j + 1;
        m{j} = 'YCOR:IN20:122';
        j = j + 1;
        m{j} = 'YCOR:IN20:222';
        j = j + 1;
        m{j} = 'YCOR:IN20:312';
        j = j + 1;
        m{j} = 'YCOR:IN20:342';
        j = j + 1;
        m{j} = 'YCOR:IN20:382';
        j = j + 1;
        m{j} = 'YCOR:IN20:412';
        j = j + 1;
        m{j} = 'YCOR:IN20:492';
        j = j + 1;
        m{j} = 'YCOR:IN20:522';
        j = j + 1;
        m{j} = 'YCOR:IN20:642';
        j = j + 1;
        m{j} = 'YCOR:IN20:722';
        j = j + 1;
        if use_in20_linac
            m{j} = 'YCOR:IN20:762';
            j = j + 1;
        end
        m{j} = 'YCOR:IN20:812';
        j = j + 1;
        m{j} = 'YCOR:IN20:832';
        j = j + 1;
        m{j} = 'YCOR:IN20:912';
        j = j + 1;
        m{j} = 'YCOR:IN20:952';
    end

    if quads
        j = j + 1;
        m{j} = 'QUAD:IN20:121';
        j = j + 1;
        m{j} = 'QUAD:IN20:122';
        j = j + 1;
        m{j} = 'QUAD:IN20:361';
        j = j + 1;
        m{j} = 'QUAD:IN20:371';
        j = j + 1;
        m{j} = 'QUAD:IN20:425';
        j = j + 1;
        m{j} = 'QUAD:IN20:441';
        j = j + 1;
        m{j} = 'QUAD:IN20:511';
        j = j + 1;
        m{j} = 'QUAD:IN20:525';
        j = j + 1;
        m{j} = 'QUAD:IN20:631';
        j = j + 1;
        m{j} = 'QUAD:IN20:651';
        j = j + 1;
        m{j} = 'QUAD:IN20:731';
        j = j + 1;
        if use_in20_linac
            m{j} = 'QUAD:IN20:771';
            j = j + 1;
            m{j} = 'QUAD:IN20:781';
            j = j + 1;
        end
        m{j} = 'QUAD:IN20:811';
        j = j + 1;
        m{j} = 'QUAD:IN20:831';
        j = j + 1;
        m{j} = 'QUAD:IN20:941';
        j = j + 1;
        m{j} = 'QUAD:IN20:961';
    end

    if soln
        j = j + 1;
        m{j} = 'SOLN:IN20:111';
        j = j + 1;
        m{j} = 'SOLN:IN20:121';
        j = j + 1;
        m{j} = 'SOLN:IN20:311';
    end

    if bends
        j = j + 1;
        m{j} = 'BEND:IN20:231';
        j = j + 1;
        m{j} = 'BTRM:IN20:231';
        j = j + 1;
        m{j} = 'BEND:IN20:661';
        j = j + 1;
        m{j} = 'BTRM:IN20:661';
        j = j + 1;
        if use_in20_linac
            m{j} = 'BEND:IN20:751';
            j = j + 1;
        end
        m{j} = 'BEND:IN20:931';
    end
end

if in21
    if xcors
        j = j + 1;
        m{j} = 'XCOR:LI21:101';
        j = j + 1;
        m{j} = 'XCOR:LI21:135';
        j = j + 1;
        m{j} = 'XCOR:LI21:165';
        j = j + 1;
        m{j} = 'XCOR:LI21:191';
        j = j + 1;
        m{j} = 'XCOR:LI21:275';
        j = j + 1;
        m{j} = 'XCOR:LI21:325';
        j = j + 1;
        m{j} = 'XCOR:LI21:402';
        j = j + 1;
        m{j} = 'XCOR:LI21:802';
    end

    if ycors
        j = j + 1;
        m{j} = 'YCOR:LI21:102';
        j = j + 1;
        m{j} = 'YCOR:LI21:136';
        j = j + 1;
        m{j} = 'YCOR:LI21:166';
        j = j + 1;
        m{j} = 'YCOR:LI21:192';
        j = j + 1;
        m{j} = 'YCOR:LI21:276';
        j = j + 1;
        m{j} = 'YCOR:LI21:325';
        j = j + 1;
        m{j} = 'YCOR:LI21:503';
    end
    if quads
        j = j + 1;
        m{j} = 'QUAD:LI21:131';
        j = j + 1;
        m{j} = 'QUAD:LI21:161';
        j = j + 1;
        m{j} = 'QUAD:LI21:211';
        j = j + 1;
        m{j} = 'QUAD:LI21:221';
        j = j + 1;
        m{j} = 'QUAD:LI21:251';
        j = j + 1;
        m{j} = 'QUAD:LI21:271';
        j = j + 1;
        m{j} = 'QUAD:LI21:278';
        j = j + 1;
        m{j} = 'QUAD:LI21:315';
        j = j + 1;
        m{j} = 'QUAD:LI21:335';
    end
    if bends
        j = j + 1;
        m{j} = 'BEND:LI21:231';
         j = j + 1;
        m{j} = 'BTRM:LI21:215';
         j = j + 1;
         m{j} = 'BTRM:LI21:241';
         j = j + 1;
         m{j} = 'BTRM:LI21:261';


    end
end
if ctrl.run
    result = magtest2(m, ctrl);
end
