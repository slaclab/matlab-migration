function SingleParameter=deltagui_KValue2SingleParameter(KValue,handles,PolType,deltaslot)
    switch(PolType)
        case 'CPLMF'
            PS=handles.DeltaUndulatorFits{deltaslot}.PureModeFits.CPLMF;
        case 'CPRMF'
            PS=handles.DeltaUndulatorFits{deltaslot}.PureModeFits.CPRMF;
        case 'LPHMF'
            PS=handles.DeltaUndulatorFits{deltaslot}.PureModeFits.LPHMF;
        case 'LPVMF'
            PS=handles.DeltaUndulatorFits{deltaslot}.PureModeFits.LPVMF;
    end

    Nodes=ppval(PS,PS.breaks);
    [~,Coeffs]=unmkpp(PS);
    if(KValue<Nodes(1)) %go to the off position and forget about it.
        SingleParameter=8;
        return
    end
    PolinomialPiece=find(KValue>=Nodes,1,'last');

    if(PolinomialPiece==length(Nodes))
        PolinomialPiece=length(Nodes)-1;
    end

    CPOL=Coeffs(PolinomialPiece,:);
    CPOL(4)=CPOL(4)-KValue;
    Solution=roots(CPOL);
    SingleParameter=acos(PS.breaks(PolinomialPiece)+Solution(3))*32/pi/2;
    if(~isreal(SingleParameter))
        SingleParameter=0;
    end