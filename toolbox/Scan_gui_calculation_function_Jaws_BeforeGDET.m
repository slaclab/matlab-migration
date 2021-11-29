function [PVScanValues,MoreValues,PVScanNames,MoreValuesNames]=Scan_gui_calculation_function_Jaws_BeforeGDET(INPUT)

if(INPUT{2,1}(1)=='X')
   Direction='X';
   try
      Error2=lcaGetSmart('STEP:FEE1:152:ERROR'); 
   catch ME
      Error2=0;
   end
   try
      Error1=lcaGetSmart('STEP:FEE1:151:ERROR'); 
   catch ME
      Error1=0;
   end
   PVScanNames={'STEP:FEE1:152:MOTR.VAL','STEP:FEE1:151:MOTR.VAL'};
else
   Direction='Y';
   try
      Error2=lcaGetSmart('STEP:FEE1:154:ERROR'); 
   catch ME
      Error2=0;
   end
   try
      Error1=lcaGetSmart('STEP:FEE1:153:ERROR'); 
   catch ME
      Error1=0;
   end
   PVScanNames={'STEP:FEE1:154:MOTR.VAL','STEP:FEE1:153:MOTR.VAL'};
end

N_Steps = INPUT{1,2};
Center_S = INPUT{2,2};
Center_E = INPUT{3,2};
SlitOpening = INPUT{4,2};
Left_S = INPUT{5,2};
Left_E = INPUT{6,2};
Right_S = INPUT{7,2};
Right_E = INPUT{8,2};

PVScanValues=NaN;
MoreValues=NaN;
MoreValuesNames=[NaN,NaN];

if(isnan(N_Steps))
    return
end

if(any(isnan([Center_S,Center_E,SlitOpening])))
    if(any(isnan([Left_S,Left_E,Right_S,Right_E])))
        return
    else % do left & right
        LeftPath=linspace(Left_S,Left_E,N_Steps);
        RightPath=linspace(Right_S,Right_E,N_Steps);
    end
else % do center/opening
    Center=linspace(Center_S,Center_E,N_Steps);
    LeftPath=Center+SlitOpening/2;
    RightPath=Center-SlitOpening/2;
end

if(Direction=='X')
    MoreValues=transpose([LeftPath;RightPath;(LeftPath+RightPath)/2;-(RightPath-LeftPath);LeftPath+Error2;RightPath+Error1;(LeftPath+Error1+Error2+RightPath)/2;-(RightPath+Error1-LeftPath-Error2)])
    MoreValuesNames={'Left Slit','Right Slit','Slit X Center','Slit X Opening','LVDT Left Slit','LVDT Right Slit','LVDT X Center','LVDT X Opening'};
elseif(Direction=='Y')
    MoreValues=transpose([LeftPath;RightPath;(LeftPath+RightPath)/2;-(RightPath-LeftPath);LeftPath+Error2;RightPath+Error1;(LeftPath+Error1+Error2+RightPath)/2;-(RightPath+Error1-LeftPath-Error2)])
    MoreValuesNames={'Lower Slit','Right Jaw','Slit Y Center','Slit Y Opening','LVDT Lower Slit','LVDT Upper Slit','LVDT Y Center','LVDT Y Opening'};
else
   return 
end
PVScanValues=transpose([LeftPath;RightPath]);
