classdef AttenuatorCascade_Class < handle
    
    properties
        AllAttenuators
        ATT
    end
    
    methods
        function SolidAttenuators=calculate_attenuation_energies(obj, Energy, RequiredTransmission)
            %ATT is an attenuators structure
            %Energy in eV
            %RequiredTransmission if specified returns attenuations to be
            %used, if not specified it returns attenuation for each
            %attenuator if inserted.
            Transmission=[];
            NofAttenuators=numel(obj.ATT.AttenuatorsList);
            AllCombinations=ones(2^NofAttenuators,NofAttenuators);
            for II=1:NofAttenuators
                switch obj.ATT.AttenuatorsList(II).material
                    case 'C'
                        AttLength=interp1(obj.ATT.Carbon(:,1),obj.ATT.Carbon(:,2),Energy,'pchip','extrap');
                        Transmission(II)=exp(-obj.ATT.AttenuatorsList(II).thickness/AttLength);
                    case 'Al2O3'
                        AttLength=interp1(obj.ATT.Sapphire(:,1),obj.ATT.Sapphire(:,2),Energy,'pchip','extrap');
                        Transmission(II)=exp(-obj.ATT.AttenuatorsList(II).thickness/AttLength);
                    case 'Si'
                        AttLength=interp1(obj.ATT.Silicon(:,1),obj.ATT.Silicon(:,2),Energy,'pchip','extrap');
                        Transmission(II)=exp(-obj.ATT.AttenuatorsList(II).thickness/AttLength);
                end
                REPMAT=[ones(2^(NofAttenuators-II),1);NaN*zeros(2^(NofAttenuators-II),1)]*Transmission(II);
                REPTIMES=2^(II-1);
                AllCombinations(:,II)=repmat(REPMAT,[REPTIMES,1]);
            end
            AllCombinations(isnan(AllCombinations))=1;
            CombinedTransmission=prod(AllCombinations,2);
            SolidAttenuators.AllCombinations=AllCombinations;
            SolidAttenuators.CombinedTransmission=CombinedTransmission;
            SolidAttenuators.Transmission=Transmission;
            SolidAttenuators.WARNING=0;
            SolidAttenuators.WARNINGstring='Attenuation can be reached';
            if(nargin>2)
                if(RequiredTransmission<1)
                    [SortValue,SortOrder]=sort(CombinedTransmission,'descend');
                    IDOK=find(SortValue<RequiredTransmission,1,'first');
                    if(~isempty(IDOK))
                        SolidAttenuators.DesiredCombination=SolidAttenuators.AllCombinations(SortOrder(IDOK),:)<1;
                        SolidAttenuators.AchievedTransmission=SortValue(IDOK);
                    else
                        SolidAttenuators.WARNING=1;
                        SolidAttenuators.WARNINGstring='Cannot reach desired attenuation';
                        SolidAttenuators.DesiredCombination=SolidAttenuators.AllCombinations(SortOrder(end),:)<1;
                        SolidAttenuators.AchievedTransmission=SortValue(end);
                    end    
                else
                    SolidAttenuators.DesiredCombination=zeros(1,NofAttenuators);
                    SolidAttenuators.AchievedTransmission=1;
                end
            else
                SolidAttenuators.WARNING=0;
                SolidAttenuators.WARNINGstring='Function called without required transmission';
            end
        end
        
        function LoadAttenuators(obj,Filename)
           if(nargin<2)
               load('AttenuatorPresetFile','ALL_ATT');
           else
               load(Filename,'ALL_ATT');
           end
           obj.AllAttenuators=ALL_ATT;
           obj.SelectAttenuator(1);
        end
        
        function SelectAttenuator(obj,ID)
           obj.ATT=obj.AllAttenuators{ID};
        end
        
    end
end