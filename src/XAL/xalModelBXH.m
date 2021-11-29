function xalModelBXH(comboSeq,scenario)
%
% xalModelBXH(comboSeq,scenario)
%
% Compute and set XAL dipoleEntrRotAngle and dipoleExitRotAngle properties for
% laser heater chicane bends

debug=0;

xalImport
pFIELD=char(ElectromagnetPropertyAccessor.PROPERTY_FIELD);

% set up list

name=[{'BXH1'};{'BXH2'};{'BXH3'};{'BXH4'}];
id=2; % use the controlling bend

% compute edge angle scaling factor

BEND=comboSeq.getNodeWithId(name(id));
B0=BEND.getDesignField; % design field
properties=scenario.propertiesForNode(BEND);
B=properties.get(pFIELD); % extant field (T)
scale=B/B0;

%  so let it be written ...

for n=1:length(name)
  BEND=comboSeq.getNodeWithId(name(n));

% get default edge angles

  e1=BEND.getEntrRotAngle;
  e2=BEND.getExitRotAngle;

% set scaled edge angles

  BEND.setEntrRotAngle(scale*e1)
  BEND.setExitRotAngle(scale*e2)
  
  if (debug)
    disp(sprintf('%s: %.6f %.6f %.6f %.6f %.6f',char(name(n)),scale,e1,e2,scale*e1,scale*e2))
  end
end

end
