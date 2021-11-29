QuickFilter.names={'Last N events','Top  x%','Bottom x%','Within Range'};
QuickFilter.number=4;
QuickFilter.ScalarAvailable=[0,1,1,1];

QuickFilter.Subtypes(1).names={'Pick Amount of Events'};
QuickFilter.Subtypes(1).number=1;
QuickFilter.Subtypes(1).Options(1).names={'N   = '};
QuickFilter.Subtypes(1).Options(1).Default={'100'};

QuickFilter.Subtypes(2).names={'Pick Top %'};
QuickFilter.Subtypes(2).number=1;
QuickFilter.Subtypes(2).Options(1).names={'x [%] = '};
QuickFilter.Subtypes(2).Options(1).Default={'20'};

QuickFilter.Subtypes(3).names={'Pick Bottom %'};
QuickFilter.Subtypes(3).number=1;
QuickFilter.Subtypes(3).Options(1).names={'x [%] = '};
QuickFilter.Subtypes(3).Options(1).Default={'20'};

QuickFilter.Subtypes(4).names={'Center= average, Width in std units','Center= average, Width in abs units','Given Center, Width in std units','Given Center, Width in abs units','Specify from / to range'};
QuickFilter.Subtypes(4).number=5;
QuickFilter.Subtypes(4).Options(1).names={'Width (std)'};
QuickFilter.Subtypes(4).Options(1).Default={'3'};
QuickFilter.Subtypes(4).Options(2).names={'Width (abs)'};
QuickFilter.Subtypes(4).Options(2).Default={'0.1'};
QuickFilter.Subtypes(4).Options(3).names={'Center','Width (std)'};
QuickFilter.Subtypes(4).Options(3).Default={'0','3'};
QuickFilter.Subtypes(4).Options(4).names={'Center','Width (abs)'};
QuickFilter.Subtypes(4).Options(4).Default={'0','1'};
QuickFilter.Subtypes(4).Options(5).names={'From','To'};
QuickFilter.Subtypes(4).Options(5).Default={'-1','1'};

QuickOutput.names={'Average','Standard Dev.','Fluctuations'};
QuickOutput.number=3;
QuickOutput.ScalarAvailable=[1,1,1];

QuickScalar.names={'Area on Vector','Area on Image','Peak/Location on Vector','Peak/Location on Image'};
QuickScalar.number=4;
QuickScalar.VectorAvailable=[1,0,1,0];
QuickScalar.ImageAvailable=[0,1,0,1];
QuickScalar.OutsNumber=[1,1,3,2];

QuickScalar.Subtypes(1).names={'Pick Area'};
QuickScalar.Subtypes(1).number=1;
QuickScalar.Subtypes(1).Options(1).names={'X start = ','X end = '};
QuickScalar.Subtypes(1).Options(1).Default={'1','100'};

QuickScalar.Subtypes(2).names={'Pick Area'};
QuickScalar.Subtypes(2).number=1;
QuickScalar.Subtypes(2).Options(1).names={'X start = ','X end = ','Y start = ','Y end = '};
QuickScalar.Subtypes(2).Options(1).Default={'1','100','1','100'};

QuickScalar.Subtypes(3).names={'n/a'};
QuickScalar.Subtypes(3).number=0;

QuickScalar.Subtypes(4).names={'n/a'};
QuickScalar.Subtypes(4).number=0;