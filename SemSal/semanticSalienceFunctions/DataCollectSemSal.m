function [leftEyeAll, rightEyeAll, timeStampAll, crossHairEndTS] = DataCollectSemSal(userID, thisTrialInformation, pauseTimeInSeconds, handle, totalSeconds)
%DATACOLLECT collects the data from the eye tracker
% This function is used to collect the incoming data from the tobii eye tracker.
%
%     Input:
%         durationInSeconds: duration of the desired acquisition.
%         pauseTimeInSeconds: time lapse between readings.
%
%     Output:
%         leftEyeAll: EyeArray corresponding to the left eye.
%         rightEyeAll:EyeArray corresponding to the right eye.
%         timeStampAll : timestamp of the readings

trialNumber = thisTrialInformation{1};
trialType = thisTrialInformation{2};
centerStim = thisTrialInformation{4};
cueImage = thisTrialInformation{5};
targetImage = thisTrialInformation{6};
mask = thisTrialInformation{7};
rewardStills = thisTrialInformation{8};

imageSizeX = 1080;
imageSizeY = 1920;
centerX = imageSizeX/2;
centerY = imageSizeY/2;
leftEyeAll = [];
rightEyeAll = [];
timeStampAll = [];
pause(pauseTimeInSeconds);
displayed = get(handle, 'CData');
xRange = [1, size(displayed, 2)];
yRange = [1, size(displayed, 1)];
stdDevCutoffX = 0.01*xRange(2);
stdDevCutoffY = 0.005*yRange(2);
set(handle, 'CData', displayed);

crossHair = plot(centerX, centerY, 'p', 'LineWidth', 5, 'MarkerEdgeColor','red', 'MarkerSize', 25);

readyToDisplay = 0;
numConsecutiveGoodPointsCrosshair = 0;
numConsecutiveGoodPoints = 0;

%% This segment is for when the star is up.
crossHairSizeX = 200;
crossHairSizeY = 150;
xCrosshairRange = [centerX-crossHairSizeX, centerX+crossHairSizeX];
yCrosshairRange = [centerY-crossHairSizeY, centerY+crossHairSizeY];
ct = 0;
% [y, Fs] = audioread('s_Kanuto Oskorri.mp3');
% playera = audioplayer(y/3,Fs);
% [y, Fs] = audioread('shortBell.mp3');
% playerb = audioplayer(y,Fs);
tstart = tic; times = 0;
growing = 1;
chsize = 25;
colors = cell(1,3);
colors{1} = 'red';
colors{2} = 'green';
colors{3} = 'blue';
while (~readyToDisplay)
    pause(pauseTimeInSeconds);
    set(crossHair, 'MarkerSize', chsize);
    if (growing)
        chsize = chsize + 1;
    else
        chsize = chsize - 1;
    end
    if (chsize == 40)
        growing = 0;
    elseif (chsize == 25)
        growing = 1;
    end
    set(crossHair, 'XData', centerY, 'YData', centerX);
    if (mod(ct, 4) < 3)
        set(crossHair, 'Visible', 'on');
    else
        set(crossHair, 'Visible', 'off');
    end
    ct = mod(ct+1, 4);
    
    [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
    numGazeData = size(lefteye, 2);
    leftEyeAll = vertcat(leftEyeAll, lefteye(:, 1:numGazeData));
    rightEyeAll = vertcat(rightEyeAll, righteye(:, 1:numGazeData));
    timeStampAll = vertcat(timeStampAll, timestamp(:,1));
    
    numPts = size(lefteye,1);
    for j = 1:numPts
        if (lefteye(j,7)==-1 || righteye(j,7)==-1 || lefteye(j,8)==-1 || righteye(j,8)==-1)
            continue;
        end
        %ADD FLOOR LATER
        avgEyeYs(j) = ((lefteye(j, 7)+righteye(j, 7))*xRange(2))/2;
        avgEyeXs(j) = ((lefteye(j, 8)+righteye(j, 8))*yRange(2))/2;
        
        if (avgEyeXs(j) < xCrosshairRange(1) || avgEyeXs(j) > xCrosshairRange(2) || ...
                avgEyeYs(j) < yCrosshairRange(1) || avgEyeYs(j) > yCrosshairRange(2))
            numConsecutiveGoodPointsCrosshair = 0;
            continue;
        end
        numConsecutiveGoodPointsCrosshair = numConsecutiveGoodPointsCrosshair+1;
        
        % Gaze must remain in central zone for n number
        % of points before continuing. Modify number below to change necessary duration.
        if (numConsecutiveGoodPointsCrosshair > 250) %Was 500
            readyToDisplay = 1;
            break;
        end
    end
    
    % Change color of star every 5 seconds.
    if (toc(tstart) > 5)
        times = times + 1;
        set(crossHair, 'MarkerEdgeColor',colors{mod(times,size(colors,2)) + 1});
        if (times >= 9)
            ME = MException('Did not record enough time fixated on crosshair to continue.');
            throw(ME);
        end
%         play(playerb);
        tstart = tic;
    end
end
crossHairEndTS = timeStampAll(size(timeStampAll, 1));
% Remove crosshair
set(crossHair, 'Visible', 'off');
% set(handle, 'CData', img);

%% This segment is for SemSal trials

if strcmp(trialType, 'BASE') || strcmp(trialType, 'POST')
    handle = image(cueImage);
    pause(.1);
    handle = image(centerStim);
    pause(0.067);
    handle = image(targetImage);
    pause(1.5);
elseif strcmp(trialType, 'LEARN')
    
    handle = image(centerStim);
    pause(1.5);
    
    frameOfReward = 1;
    fixOnRewardingShape = 0;
    fixOnReward = tic;
    timeForNextFrame = true;
    while(toc(fixOnReward) < totalSeconds)
        if(~fixOnRewardingShape)
            image(cueImage);
            drawnow;
            %check if fixOnRewardingShape
            for j = 1:numPts
                if (lefteye(j,7)==-1 || righteye(j,7)==-1 || lefteye(j,8)==-1 || righteye(j,8)==-1)
                    continue;
                end
                %ADD FLOOR LATER
                avgEyeYs(j) = ((lefteye(j, 7)+righteye(j, 7))*xRange(2))/2;
                avgEyeXs(j) = ((lefteye(j, 8)+righteye(j, 8))*yRange(2))/2;
                
                if mask(avgEyeXs(j), avgEyeYs(j))~=0
                    numConsecutiveGoodPoints = 0;
                    continue;
                end
                numConsecutiveGoodPoints = numConsecutiveGoodPoints+1;
                
                % Gaze must remain in central zone for n number
                % of points before continuing. Modify number below to change necessary duration.
                if (numConsecutiveGoodPointsr > 250) %Was 500
                    fixOnRewardingShape = 1;
                    break;
                end
            end
        else
            timeOfRewardFrame = toc;
            image(rewardStills{frameOfReward});
            drawnow;
            if frameOfReward < rewardVideoFrameLength
                if(timeForNextFrame)
                    frameOfReward = frameOfReward + 1;
                    second = tic;
                end
                timeForNextFrame = toc(second)>1/30;
            else
                frameOfReward = 1;
            end
        end
    end
    
end

% %% This segment is for after the person looks at the crosshair but before the picture fades (before the person looks away from the center.)
% fade = 0;
% while (~fade)
%     pause(pauseTimeInSeconds);
%     
%     [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
%     numGazeData = size(lefteye, 2);
%     leftEyeAll = vertcat(leftEyeAll, lefteye(:, 1:numGazeData));
%     rightEyeAll = vertcat(rightEyeAll, righteye(:, 1:numGazeData));
%     timeStampAll = vertcat(timeStampAll, timestamp(:,1));
%     
%     numPts = size(lefteye,1);
%     avgEyeXs = zeros(1, numPts);
%     avgEyeYs = zeros(1, numPts);
%     for j = 1:numPts
%         if (lefteye(j,7)==-1 || righteye(j,7)==-1 || lefteye(j,8)==-1 || righteye(j,8)==-1)
%             continue;
%         end
%         %ADD FLOOR LATER
%         avgEyeYs(j) = ((lefteye(j, 7)+righteye(j, 7))*xRange(2))/2;
%         avgEyeXs(j) = ((lefteye(j, 8)+righteye(j, 8))*yRange(2))/2;
%         
%         if (avgEyeXs(j) < xCrosshairRange(1) || avgEyeXs(j) > xCrosshairRange(2) || ...
%                 avgEyeYs(j) < yCrosshairRange(1) || avgEyeYs(j) > yCrosshairRange(2))
%             numConsecutiveGoodPointsCrosshair = numConsecutiveGoodPointsCrosshair + 1;
%         else
%             numConsecutiveGoodPointsCrosshair = 0;
%         end
%         
%         if (numConsecutiveGoodPointsCrosshair > 30)
%             fade = 1;
%             break;
%         end
%     end
%     
% end
% 
% % To change duration of trials, change the numbers below
% if (~testTrial)
%     % Train trials
%     durationInSeconds = 15;
% else
%     % Test trials
%     durationInSeconds = 20;
% end
% 
% %% This part actually reveals where the person is looking.
% set(handle, 'CData', displayed);
% gazePoint = plot(1,1,'o:','MarkerEdgeColor','red','LineWidth', 5, 'MarkerSize', 15);
% tstart = tic;
% scratched = uint8(zeros(size(img)));
% testScratched = uint8(zeros(size(img)));
% radius = floor(size(img,1)/60); % img/60 is 18
% testFaces = displayed;
% conversionDone = 0;
% 
% [rr,cc]=meshgrid(1:radius*2+1);
% scratch_c = uint8(sqrt((rr-radius-1).^2+(cc-radius-1).^2) <= ceil(radius)-1);
% anti_scratch_c = 1 - scratch_c; % Grid with 1s ands 0s, 0's intended to be where it was scratched
% 
% refresh_sum = [];
% tlast = tic;
% while (toc(tstart) < durationInSeconds)
%     % FLEXIBLE PAUSE
%     dt = toc(tstart) - tlast;
%     tlast = toc(tstart);
%     pause(pauseTimeInSeconds-dt);
%     
%     % READ DATA
%     [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
%     if isempty(lefteye)
%         continue;
%     end
%     
%     % TO BE PRINTED OUT
%     numGazeData = size(lefteye, 2);
%     leftEyeAll = vertcat(leftEyeAll, lefteye(:, 1:numGazeData));
%     rightEyeAll = vertcat(rightEyeAll, righteye(:, 1:numGazeData));
%     timeStampAll = vertcat(timeStampAll, timestamp(:,1));
%     
%     % INITIALIZE MOVING WINDOW
%     last3xs = zeros(1,3);
%     last3ys = zeros(1,3);
%     
%     % DELAY CHECK
%     tstartout = tic; %%TIMER
%     %disp(['!! Number of points: ', num2str(size(lefteye,1)), '!!'])
%     pocketacc = sum(lefteye(:,13)==4)/size(lefteye,1);
%     %disp(['Percent lost: ', num2str(sum(lefteye(1:5,13)==4)/numPoints)])
%     
%     %lefteye and righteye have 13 cols, xs on 7 and ys on 8
%     % FILTER OUT -1s FROM GAZE DATA
%     botheyes = [lefteye righteye];
%     botheyes = botheyes(botheyes(:,7)>=0,:);
%     botheyes = botheyes(botheyes(:,size(lefteye,2)+7)>=0,:);
%     botheyes = botheyes(botheyes(:,8)>=0,:);
%     botheyes = botheyes(botheyes(:,size(lefteye,2)+8)>=0,:);
%     %disp(['both eyes is ',num2str(size(botheyes))]);
%     
%     % TRANSLATE GAZE TO DISPLAYED IMAGE UNITS
%     avgEyeXs = ((botheyes(:,7)+botheyes(:,size(lefteye,2)+7))*xRange(2)) / 2;
%     avgEyeYs = ((botheyes(:,8)+botheyes(:,size(lefteye,2)+8))*yRange(2)) / 2;
%     %disp(['avgEyeXs is ',num2str(size(avgEyeXs))]);
%     %disp(['avgEyeYs is ',num2str(size(avgEyeYs))]);
%     %avgEyeXs is numPoints by 1
%     %avgEyeYs is numPoints by 1
%     
%     % FILTER OUT GAZE THAT EXCEEDS THE DISPLAYED IMAGE
%     bothavgs = [avgEyeXs avgEyeYs];
%     bothavgs = bothavgs(bothavgs(:,1) >= xRange(1),:);
%     bothavgs = bothavgs(bothavgs(:,1) <= xRange(2),:);
%     bothavgs = bothavgs(bothavgs(:,2) >= yRange(1),:);
%     bothavgs = bothavgs(bothavgs(:,2) <= yRange(2),:);
%     %disp(['bothavgs is ',num2str(size(bothavgs))]);
%     
%     % ROUND DOWN
%     xc = floor(bothavgs(:,1));
%     yc = floor(bothavgs(:,2));
%     
%     numPoints = size(bothavgs,1);
%     for j = 1:numPoints
%         
%         % Don't reveal picture if last 3 data points have too high of a std
%         % deviation -- noise points.
%         last3xs(2:3) = last3xs(1:2);
%         last3ys(2:3) = last3ys(1:2);
%         last3xs(1) = bothavgs(j,1);
%         last3ys(1) = bothavgs(j,2);
%         varX = var(last3xs);
%         varY = var(last3ys);
%         reveal = (varX < stdDevCutoffX^2) && (varY < stdDevCutoffY^2);
%         
%         stopForTest = 0;
%         
%         if (testTrial && toc(tstart) > 5)
%             %disp('stop employed')
%             stopForTest = 1;
%             if (~conversionDone)
%                 %disp('LOOK HERE: conversion done')
%                 testFaces = displayed;
%                 testScratched = scratched;
%                 conversionDone = 1;
%             end
%         end
%         
%         if (reveal)
%             if (scratchLocs(yc(j),xc(j),1)<160 && ~stopForTest)
%                 if ((side==1 && xc(j) < (1920/2)) || (side==2 && xc(j) > (1920/2)) || side==3)
%                     if(~isplaying(playera))
%                         svol = SoundVolume(1);
%                         %play(playera,40000);
%                     end
%                 else
%                     svol = SoundVolume(.3);
%                     %stop(playera)
%                 end
%             else
%                 svol = SoundVolume(.3);
%                 %stop(playera)
%             end
%             
%             %%
%             xlow = min(max(1, xc(j)-radius),size(img,2));
%             xhigh = min(size(img,2), max(1,xc(j)+radius));
%             ylow = min(max(1, yc(j)-radius),size(img,1));
%             yhigh = min(size(img,1), max(1,yc(j)+radius));
%             
%             % REVEAL A SQUARE FAST, NICK
%             %             if (~stopForTest)
%             %                 displayed(ylow:yhigh,xlow:xhigh,:) = img(ylow:yhigh,xlow:xhigh,:);
%             %                 scratched(ylow:yhigh,xlow:xhigh,:) = scratchLocs(ylow:yhigh,xlow:xhigh,:);
%             %             else
%             %                 testFaces(ylow:yhigh,xlow:xhigh,:) = img(ylow:yhigh,xlow:xhigh,:);
%             %                 testScratched(ylow:yhigh,xlow:xhigh,:) = scratchLocs(ylow:yhigh,xlow:xhigh,:);
%             %             end
%             %
%             % REVEAL A (FAST!!) CIRCLE, NICK
%             [X,Y] = meshgrid(xlow:xhigh,ylow:yhigh);
%             %disp('created meshgrid');
%             mask = (X-xc(j)).^2 + (Y-yc(j)).^2 - radius^2;
%             mask = cat(3,mask,mask,mask);
%             %patches for copying in
%             imgblock = img(ylow:yhigh,xlow:xhigh,:);
%             scratchLocsblock = scratchLocs(ylow:yhigh,xlow:xhigh,:);
%             
%             if (~stopForTest)
%                 %set up patches for displayed from img
%                 displayedblock = displayed(ylow:yhigh,xlow:xhigh,:);
%                 %set up patches for scratched from scratchLocs
%                 scratchedblock = scratched(ylow:yhigh,xlow:xhigh,:);
%                 %do the masking & overwriting
%                 displayedblock(mask <=0) = imgblock(mask<=0);
%                 displayed(ylow:yhigh,xlow:xhigh,:) = displayedblock;
%                 
%                 scratchedblock(mask<=0) = scratchLocsblock(mask<=0);
%                 scratched(ylow:yhigh,xlow:xhigh,:) = scratchedblock;
%             else
%                 %Do the same thing, but for hidden case
%                 testFacesblock = testFaces(ylow:yhigh,xlow:xhigh,:);
%                 %set up patches for scratched from scratchLocs
%                 testScratchedblock = testScratched(ylow:yhigh,xlow:xhigh,:);
%                 %do the masking & overwriting
%                 testFacesblock(mask <=0) = imgblock(mask<=0);
%                 testFaces(ylow:yhigh,xlow:xhigh,:) = testFacesblock;
%                 
%                 testScratchedblock(mask<=0) = scratchLocsblock(mask<=0);
%                 testScratched(ylow:yhigh,xlow:xhigh,:) = testScratchedblock;
%             end
%             
%             % DISPLAY RANDOM POINTS TO TEST IF REFRESH RATE CAUSES LAG
%             %random_points = rand(10,2);
%             %random_points(:,1) = random_points(:,1)*(xRange(2)-1)+1;
%             %random_points(:,2) = random_points(:,2)*(yRange(2)-1)+1;
%             %random_points = round(random_points);
%             %displayed(random_points(:,1),random_points(:,2)) = 0;
%             
%             % REVEAL A CIRCLE SLOW, OLD CODE
%             %             tstartin = tic; %% TIMER
%             % %             for x = xlow:xhigh
%             % %                 for y = ylow:yhigh
%             % %                     if ((x-xc)^2 + (y-yc)^2 < radius^2)
%             % %                         if (~stopForTest)
%             % %                             displayed(y,x,:) = img(y,x,:);
%             % %                             scratched(y,x,:) = scratchLocs(y,x,:);
%             % %                         else
%             % %                             testFaces(y,x,:) = img(y,x,:);
%             % %                             testScratched(y,x,:) = scratchLocs(y,x,:);
%             % %                         end
%             % %                     end
%             % %                 end
%             % %             end
%             %             %disp(['- Inside Loop Toc: ', num2str(toc(tstartin))]) %% This
%             %             %does vary but has a large amount of output
%             %%
%             
%             %            % REVEAL A CIRCLE FAST - HOPEFULLY, LIZ
%             %
%             %             xlow = xc-radius;
%             %             xhigh = xc+radius;
%             %             ylow = yc-radius;
%             %             yhigh = yc+radius;
%             %             % These could take on negative coordinates at the edges
%             %
%             %             % Check edges
%             %             edge_xlow = max(1, xlow);
%             %             edge_xhigh = min(size(img,2), xhigh);
%             %             edge_ylow = max(1, ylow);
%             %             edge_yhigh = min(size(img,1), yhigh);
%             %
%             %             % Required to only multiply a portion of the circle matrix
%             %             circle_ind_xlow = edge_xlow - xlow + 1;
%             %             circle_ind_xhigh = edge_xhigh - xhigh + radius*2+1;
%             %             circle_ind_ylow = edge_ylow - ylow + 1;
%             %             circle_ind_yhigh = edge_yhigh - yhigh + radius*2+1;
%             %
%             %             % Image in circle
%             %             AA = img(edge_ylow:edge_yhigh,edge_xlow:edge_xhigh,:);
%             %             BB = repmat(scratch_c(circle_ind_ylow:circle_ind_yhigh,circle_ind_xlow:circle_ind_xhigh),[1,1,3]);
%             %             img_circ = AA.*BB;
%             %
%             %             % Anticircle
%             %             displayed_holder = displayed;
%             %             CC = displayed(edge_ylow:edge_yhigh,edge_xlow:edge_xhigh,:);
%             %             DD = repmat(anti_scratch_c(circle_ind_ylow:circle_ind_yhigh,circle_ind_xlow:circle_ind_xhigh),[1,1,3]);
%             %             anti_img_circ = CC.*DD;
%             %
%             %             replacement = anti_img_circ + img_circ;
%             %             displayed_holder(edge_ylow:edge_yhigh,edge_xlow:edge_xhigh,:) = replacement;
%             %             displayed = displayed_holder;
%             %
%             %             %%%IF IMPLEMENTING WE NEED TO UPDATE THIS
%             %             scratched = scratchLocs;
%             %
%             %             if (stopForTest)
%             %                 disp('SHOULD NO LONGER SCRATCH')
%             %                 %testFaces = displayed_holder;
%             %                 testFaces = displayed_holder;
%             %                 displayed = testFaces;
%             %                 %testScratched = scratchLocs;
%             %             end
%             %             %% TO HERE
%         end %if (reveal)
%         
%         
%     end
%     %disp(['Outside Loop Toc: ', num2str(toc(tstartout))])
%     %Commented out because the red circle was distracting to babies
%     set(gazePoint, 'XData', mean(bothavgs(:,1)), 'YData', mean(bothavgs(:,2)));
%     set(handle, 'CData', displayed);
%     tloop = toc(tstartout);
%     refresh_sum = [refresh_sum; tloop, numPoints, pocketacc];
% end
% 
% trialAsStr = num2str(trialNumber);
% csvwrite(strcat('scratchImgs/', userID, '_T', trialAsStr , '_CompPerformance.csv'), refresh_sum);
% imwrite(scratched, strcat('scratchImgs/', userID, '_T', trialAsStr , '_green_', trialName));
% imwrite(displayed, strcat('scratchImgs/', userID, '_T', trialAsStr , '_faces_', trialName));
% if(testTrial)
%     imwrite(testScratched, strcat('scratchImgs/', userID, '_T', trialAsStr, '_testGreen_', trialName));
%     imwrite(testFaces,     strcat('scratchImgs/', userID, '_T', trialAsStr, '_testFaces_', trialName));
% end
% 
end

