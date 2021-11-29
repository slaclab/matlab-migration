function TF=PickRange(Input, IN1, IN2, TYPE)

TF=false(size(Input));

switch(TYPE)
    case 1 %'Center= average, Width in std units'
        AVG=mean(Input);
        STD=std(Input);
        if(isnan(AVG) || isnan(STD))
            return
        else
           TF(abs(Input-AVG ) <= IN2*STD/2) = true; 
        end
    case 2 %,'Center= average, Width in abs units',
        AVG=mean(Input);
        if(isnan(AVG))
            return
        else
           TF(abs(Input-AVG ) <= IN2/2) = true; 
        end
    case 3 %'Given Center, Width in std units',
        STD=std(Input);
        if(isnan(STD))
            return
        else
           TF(abs(Input-IN1 ) <= STD*IN2/2) = true; 
        end
    case 4 %'Given Center, Width in abs units'   
        TF(abs(Input-IN1 ) <= IN2/2) = true; 
    case 5 %,'Specify from / to range'
        TF((Input>=IN1) & (Input<=IN2)) = true;
end