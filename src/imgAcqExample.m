% Image Acquisition Example
% Mike Zelazny (zelazny@stanford.edu) & Sergei Chevtsov (chevtsov@slac.stanford.edu)

myName = [user ' Example'];
numBkgImages = 2;
numImages = 3;
timeout = 20.0; % seconds

% Reserve image Acquisition
success = imgAcqReserve(myName);

% Check to see if I got the reservation
if success
    disp (sprintf('%s %s Reservation successful', datestr(now), myName));

    % one time init of camera properties
    cameraArray = imgAcq_initCameraProperties();
    myCamera = cameraArray{1}; % 1 for OTR1 on the development network

    % Get camera properties
    myCamera = imgAcq_epics_getCameraParam(myCamera);

    % Attempt to insert a screen
    lcaPut ([myCamera.pvPrefix ':PNEUMATIC'], 'IN');

    % Wait for screen insertion to complete
    while (true)

        if isequal(lcaGet ([myCamera.pvPrefix ':POSITION']), {'IN'})
            disp (sprintf('%s %s successfully inserted', datestr(now), myCamera.pvPrefix));
            break;
        else
            pause (1.0);
        end
    end

    % Set number of foreground and background images
    disp (sprintf('%s requests %d background images', datestr(now), numBkgImages));
    imgAcqParams(numBkgImages,0);
    % imageType=0 background
    % imageType=1 foreground (aka with beam)

    if numBkgImages > 0
        % Request Image Acquisition
        disp (sprintf('%s waiting up to %.1f seconds', datestr(now), timeout));
        acqTime = imgAcq(timeout);

        if (acqTime < timeout)
            disp (sprintf ('%s Data acquisition complete, took %.1f seconds', datestr(now), acqTime));
        else
            disp (sprintf ('%s Data acquisition timed out.  Waited for %.1f seconds', datestr(now), acqTime));
        end
    end

    % Your images may be buffered in the IOC.  They need to be loaded
    % into Matlab
    disp (sprintf ('%s collecting background image data from IOC', datestr(now)));
    dataSet = 1;
    startTime = clock;
    imgAcqGet (myCamera.pvPrefix, dataSet, myName, myCamera, numBkgImages, 0);
    eTime = etime (clock, startTime);
    disp (sprintf ('%s image collection took %.1f seconds', datestr(now), eTime));

    disp (sprintf('%s requests %d foreground ground images', datestr(now), numImages));
    imgAcqParams(numImages,1);

    % Request Image Acquisition
    disp (sprintf('%s waiting up to %.1f seconds', datestr(now), timeout));
    acqTime = imgAcq(timeout);

    if (acqTime < timeout)
        disp (sprintf ('%s Data acquisition complete, took %.1f seconds', datestr(now), acqTime));
    else
        disp (sprintf ('%s Data acquisition timed out.  Waited for %.1f seconds', datestr(now), acqTime));
    end

    disp (sprintf ('%s collecting image data from IOC', datestr(now)));
    startTime = clock;
    imgAcqGet (myCamera.pvPrefix, dataSet, myName, myCamera, numImages, 1);
    eTime = etime (clock, startTime);
    disp (sprintf ('%s image collection took %.1f seconds', datestr(now), eTime));

    % Attempt to remove screen
    disp(sprintf('%s removing %s', datestr(now), myCamera.pvPrefix));
    lcaPut ([myCamera.pvPrefix ':PNEUMATIC'], 'OUT');

    % Bring up your images in Sergei's cool slick image browser
    imgBrowserData.ipParam.subtractBg.acquired = 1;
    imgBrowser_handle = imgBrowser_main(imgBrowserData);
    set (imgBrowser_handle,'Name',[myCamera.label myName]);
    % Close this window with close(imgBrowser_handle)

    % Release when done
    disp(sprintf('%s %s releasing Reservation', datestr(now), myName));
    imgAcqRelease;

else % failed to get reservation
    whoAreYou = lcaGet ('PROF:PM00:1:NAME');
    whoName = whoAreYou{1};
    disp (sprintf ('Sorry, image acquisition reserved by %s.', whoName));
end
