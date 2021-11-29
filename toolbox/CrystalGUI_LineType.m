function [COLORE, STILE, SPESSORE]=CrystalGUI_LineType(Piano)

C1=Piano(1)^2+Piano(2)^2+Piano(3)^2;
C2=sum(abs(Piano));
C3=max(abs(Piano));

COLORE=[abs(Piano(1)/31),abs(Piano(2))/31,1-abs(Piano(3))/31];

switch(C1)
    case 3
        COLORE=[1,0,0];
    case 8
        COLORE=[0,1,0];
    case 11
        COLORE=[0,0,0];
    case 16
        COLORE=[0,0,1];
    case 19
        COLORE=[1,0,1];
    case 24
        COLORE=[1,0.6,0];
    case 27
        switch(C2)
            case 7
                COLORE=[1,1,0];
            case 9
                COLORE=[0,0.2,0.4];
        end
    case 32
        COLORE=[0,0,0.8];
    case 35
        COLORE=[0.8,0.8,0];
    case 40
        COLORE=[0.2,0,0.8];
    case 43
        COLORE=[0.7,0.7,0];
    case 48
        COLORE=[0.4,0,0.7];
    case 51
        switch(C2)
            case 9
                COLORE=[0.7,0.5,0];
            case 11
                COLORE=[0.7,0.7,0];
        end
    case 56
        COLORE=[0.3,0,0.8];
    case 59
        switch(C2)
            case 11
                COLORE=[0.5,0.3,0.0];
            case 13
                COLORE=[0.5,0.4,0];
        end
    case 64
        COLORE=[0,0.7,0];
    case 67
        COLORE=[0.4,0.4,0];
    case 72 
        switch(C3)
            case 8
                COLORE=[0.5,0,0.7];
            case 6
                COLORE=[0.5,0,0.6];
        end
    case 75
        switch(C2)
            case 13
                COLORE=[0.4,0.3,0.0];
            case 15
                COLORE=[0.4,0.4,0.0];
        end
    case 80
        COLORE=[0.5,1,0.7];
    case 83
        switch(C2)
            case 11
                COLORE=[0.3,0.3,0.0];
            case 15
                COLORE=[0.3,0.4,0.0];
        end
    case 88
        COLORE=[0.5,0.8,0.7];
    case 91
        COLORE=[0.2,0.5,0.0];
    case 96
        COLORE=[0.5,0.6,0.7];
    case 99
        switch(C2)
            case 15
                COLORE=[0.2,0.6,0.0];
            case 17
                COLORE=[0.2,0.7,0.0];
        end
    case 104
        switch(C3)
            case 10
                COLORE=[0.5,0.4,0.7];
            case 8
                COLORE=[0.5,0.2,0.7];
        end
    case 107
        switch(C2)
            case 15
                COLORE=[0.2,0.5,0.1];
            case 17
                COLORE=[0.2,0.4,0.1];
        end
    case 115
        COLORE=[0.3,0.6,0.2];
    case 120
        COLORE=[0.75,0.9,0.7];
    case 123
        switch(C2)
            case 13
                COLORE=[0.3,0.6,0.3];
            case 19
                COLORE=[0.3,0.6,0.4];
        end
    case 128
        COLORE=[0.3,0.4,1];
    otherwise
    COLORE=[abs(Piano(1)/31),abs(Piano(2))/31,1-abs(Piano(3))/31];
end

STILE = '-';
if Piano(1) == Piano(2) && sign(Piano(1)) == ~sign(Piano(3))
      STILE = '--';
   elseif Piano(1) ~= Piano(2)
      STILE = '-.';
end
if(Piano(1) == 0) &&(0==Piano(2))
    STILE='-';
end

SPESSORE=1.5;
if (sum(Piano==[0,0,4])==3)
    SPESSORE=2;
end
if (sum(Piano==[2,2,0])==3)
    SPESSORE=2;
end
if(C1>56)
    SPESSORE=1;
end

