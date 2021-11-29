function img_roi = trex_get_ROI(img,threshold,method,two_beam_mode)
%####################################################################

img_orig = img;

M=ones(5,5); M=M/sum(sum(M));
if method == 0
    roi_tmp = zeros(size(img));
    for k=1:(1+two_beam_mode)
        
        if k==2
            roi_tmp = roi;
            img = -(roi-1).*img_orig;
        end    
        roi               = zeros(size(img));
        candidates        = img(1:numel(img))>=threshold;
        roi(candidates)   = 2;
        img_tmp           = conv2(img,M,'same');
        [dum,start_roi_x] = max(max(img_tmp));
        [dum,start_roi_y] = max(img_tmp(:,start_roi_x));

        LastFlood                      = zeros(size(roi));
        Flood                          = LastFlood;
        Flood(start_roi_y,start_roi_x) = 1;
        Mask                           = (roi == roi(start_roi_y,start_roi_x));
        FloodFilter                    = [0,1,0; 1,1,1; 0,1,0];
        while any(LastFlood(:) ~= Flood(:))
            LastFlood = Flood;
            Flood     = conv2(double(Flood),FloodFilter,'same') & Mask;
        end
        roi(Flood)    = 1;
        roi(roi==2)   = 0;
    end   
    roi = roi + roi_tmp;
else
    roi             = zeros(size(img));
    candidates      = img(1:numel(img))>=threshold;
    roi(candidates) = 1;

    roi        = conv2(roi,M,'same');
    
    roi(roi<1) = 0;
        
end

img_roi = roi.*img_orig;
