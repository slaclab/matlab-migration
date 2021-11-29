use_sort_Z=1;

fh_u=ULT_UndulatorLine_functions;
disp('Loading static for Hard X-ray undulator line with bba2_init');
staticH=bba2_init('sector','UNDH','devList',{'BEND' 'BPMS' 'QUAD' 'XCOR' 'YCOR' 'USEG' 'PHAS' 'XEFC' 'YEFC' 'BTRM','YAGS'},'beampath','CU_HXR','sortZ',use_sort_Z);
disp('... done'); disp('Loading static for Soft X-ray undulator line with bba2_init');
staticS=bba2_init('sector','UNDS','devList',{'BEND' 'BPMS' 'QUAD' 'XCOR' 'YCOR' 'USEG' 'PHAS' 'XEFC' 'YEFC' 'BTRM','YAGS'},'beampath','CU_SXR','sortZ',use_sort_Z);
disp('... done');

disp('Checking online devices on Soft X-ray line')
UL(2)=fh_u.SXU_Init(staticS,1);
disp('... done')
disp('Checking online devices on Hard X-ray line')
UL(1)=fh_u.HXU_Init(staticH,1);
disp('... done')

disp('Loading Ltu form bba2_init');
staticHL=bba2_init('sector','LTUH','devList',{'BEND' 'BPMS' 'QUAD' 'XCOR' 'YCOR' 'USEG' 'PHAS' 'XEFC' 'YEFC'},'beampath','CU_HXR','sortZ',use_sort_Z);
staticSL=bba2_init('sector','LTUS','devList',{'BEND' 'BPMS' 'QUAD' 'XCOR' 'YCOR' 'USEG' 'PHAS' 'XEFC' 'YEFC'},'beampath','CU_SXR','sortZ',use_sort_Z);
disp('... done')

static(1)=staticH;
static(2)=staticS;

static(1).bpmList=[staticHL.bpmList(end-1:end);static(1).bpmList];
static(1).bpmList_e=[staticHL.bpmList_e(end-1:end);static(1).bpmList_e];
static(1).zBPM=[staticHL.zBPM(end-1:end),static(1).zBPM];
static(1).lBPM=[staticHL.lBPM(end-1:end),static(1).lBPM];

static(2).bpmList=[static(2).bpmList];
static(2).bpmList_e=[static(2).bpmList_e];
static(2).zBPM=[static(2).zBPM];
static(2).lBPM=[static(2).lBPM];

XorY=cellfun(@(x) x(1),staticHL.corrList);
xPos=find(XorY=='X'); yPos=find(XorY=='Y');
XorY_u=cellfun(@(x) x(1),static(1).corrList);
xPos_u=find(XorY_u=='X'); yPos_u=find(XorY_u=='Y');

static(1).corrList=[staticHL.corrList(xPos(end-2):xPos(end));static(1).corrList(xPos_u);staticHL.corrList(yPos(end-2):yPos(end));static(1).corrList(yPos_u)];
static(1).corrList_e=[staticHL.corrList_e(xPos(end-2):xPos(end));static(1).corrList_e(xPos_u);staticHL.corrList_e(yPos(end-2):yPos(end));static(1).corrList_e(yPos_u)];
static(1).zCorr=[staticHL.zCorr(xPos(end-2):xPos(end)),static(1).zCorr(xPos_u),staticHL.zCorr(yPos(end-2):yPos(end)),static(1).zCorr(yPos_u)];
static(1).lCorr=[staticHL.lCorr(xPos(end-2):xPos(end)),static(1).lCorr(xPos_u),staticHL.lCorr(yPos(end-2):yPos(end)),static(1).lCorr(yPos_u)];
static(1).corrRange=[staticHL.corrRange(xPos(end-2):xPos(end),:);static(1).corrRange(xPos_u,:);staticHL.corrRange(yPos(end-2):yPos(end),:);static(1).corrRange(yPos_u,:)];

XorY=cellfun(@(x) x(1),staticSL.corrList);
xPos=find(XorY=='X'); yPos=find(XorY=='Y');
XorY_u=cellfun(@(x) x(1),static(2).corrList);
xPos_u=find(XorY_u=='X'); yPos_u=find(XorY_u=='Y');

static(2).corrList=[staticSL.corrList(xPos(end-2):xPos(end));static(2).corrList(xPos_u);staticSL.corrList(yPos(end-2):yPos(end));static(2).corrList(yPos_u)];
static(2).corrList_e=[staticSL.corrList_e(xPos(end-2):xPos(end));static(2).corrList_e(xPos_u);staticSL.corrList_e(yPos(end-2):yPos(end));static(2).corrList_e(yPos_u)];
static(2).zCorr=[staticSL.zCorr(xPos(end-2):xPos(end)),static(2).zCorr(xPos_u),staticSL.zCorr(yPos(end-2):yPos(end)),static(2).zCorr(yPos_u)];
static(2).lCorr=[staticSL.lCorr(xPos(end-2):xPos(end)),static(2).lCorr(xPos_u),staticSL.lCorr(yPos(end-2):yPos(end)),static(2).lCorr(yPos_u)];
static(2).corrRange=[staticSL.corrRange(xPos(end-2):xPos(end),:);static(2).corrRange(xPos_u,:);staticSL.corrRange(yPos(end-2):yPos(end),:);static(2).corrRange(yPos_u,:)];

for II=1:length(UL)
   ul(II).SplineData=UL(II).SplineData;
   ul(II).name=UL(II).name;
end
