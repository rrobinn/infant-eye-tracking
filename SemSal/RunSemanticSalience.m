clc 
clear all
close all

%% Setup Variables

version = 'original (Dec 2017)';
numBaseBlocks = 6; % 8 trials per block, 6 blocks = 72 trials (unless social cues also used)
numPostBlocks = 6; % 8 trials per block, 6 blocks u= 48 trials
numLearnTrials = 12; % must be even

rewardVideoFrameLength = 230; % length of reward video in frames on loop (230)
totalSecondsOpportunity = 5; % total seconds bilateral cue presented in learn trials
totalSecondsOfReward = 5; % total seconds reward video is shown

lookingTimeTriggerTrial = 0.75; %s, minimum looking time at star to trigger all trials
crosshairShapeTime = 0.1; %s, time for crosshair and one shape presented together in base and post trials
crosshairOnlyTime = 0.067; %s, time for crosshair only in base and post trials
targetTime = 1.5; %s, time target shape (heart) is on screen in base and post trials
lookingTimeTriggerReward = 0.075; %s, minimum time looking at rewarding shape to trigger reward video
rewardTime = 5; %s

pauseTimeInSeconds = 1/60; %between trials

[trialInformation, rewardingShape, stimuliList] = getTrialInformation(numBaseBlocks, numPostBlocks, numLearnTrials, rewardVideoFrameLength);

%%
addpath('C:/Users/Elabusers/Documents/MATLAB/scratchTask/functions/');
addpath('C:/Users/Elabusers/Documents/MATLAB/scratchTask/tetio/');  

% *************************************************************************
%
% Initialization and connection to the Tobii Eye-tracker
%
% *************************************************************************
 
userID = input('Please input unique identifier for this trial...\n', 's');


disp('Initializing tetio...');
tetio_init();

% Set to tracker ID to the product ID of the tracker you want to connect to.
trackerId = 'TX300-010106615291'; %M Tracker
%trackerId = 'TX300-010103349335'; %SP Tracker

%   FUNCTION "SEARCH FOR TRACKERS" IF NOTSET
if (strcmp(trackerId, 'NOTSET'))
	warning('tetio_matlab:EyeTracking', 'Variable trackerId has not been set.'); 
	disp('Browsing for trackers...');

	trackerinfo = tetio_getTrackers();
	for i = 1:size(trackerinfo,2)
		disp(trackerinfo(i).ProductId);
	end

	tetio_cleanUp();
	error('Error: the variable trackerId has not been set. Edit the EyeTrackingSample.m script and replace "NOTSET" with your tracker id (should be in the list above) before running this script again.');
end

fprintf('Connecting to tracker "%s"...\n', trackerId);
tetio_connectTracker(trackerId)
	
currentFrameRate = tetio_getFrameRate;
fprintf('Frame rate: %d Hz.\n', currentFrameRate);

% *************************************************************************
%
% Calibration of a participant
%
% *************************************************************************

SetCalibParams; 

disp('Starting TrackStatus');
% Display the track status window showing the participant's eyes (to position the participant).
TrackStatus; % Track status window will stay open until user key press.
disp('TrackStatus stopped');

disp('Starting Calibration workflow');

% Perform calibration
[pts, calibMetrics] = HandleCalibWorkflow(Calib);
disp('Calibration workflow stopped');


% *************************************************************************
%
% Display a stimulus 
%
% For the demo this simply reads and display an image.
% Any method for generation and display of stimuli availble to Matlab could
% be inserted here, for example using Psychtoolbox or Cogent. 
%
% *************************************************************************
close all;

numTrialsCompleted = 0;
dataFromAllTrials = cell(1, length(trialInformation));
crossHairEndTimes = zeros(1, length(trialInformation));
%stimuliFromAllTrials = cell(1, length(trialInformation));
%dataWithPresentationAllTrials = cell(1, length(trialInformation));

% try
% Start song.
[y, Fs] = audioread('s_Kanuto Oskorri.mp3');
player = audioplayer(y/3,Fs);
play(player);
svol = SoundVolume(.1);

for i = 1:length(trialInformation)
    if(~isplaying(player))
        play(player);
    end
    disp(['Trial: ',num2str(i)])
    % stimFile = trialInformation{i,4};
    img(:,:,1) = 255*ones(1080,1920);
    img(:,:,2) = img(:,:,1);
    img(:,:,3) = img(:,:,1);
    
    
    thisTrialInformation = trialInformation(i,1:8);

    %%% USE THIS TO COVER WITH BLANK WHITE SCREEN %%%
    %displayed = uint8(ones(size(img,1), size(img,2), size(img,3))*255);
    %%%

    %%% USE THIS TO COVER WITH LOW CONTRAST IMAGE %%%
    input_start = 0;
    input_end = 255;
    input_range = input_end - input_start;
    output_start = 240; % Make this closer to output_end to increase contrast and vice versa.
    output_end = 255;
    output_range = output_end - output_start;
    displayed = double(img);
    displayed = floor(((displayed - input_start)*output_range) / input_range) + output_start;
    displayed = uint8(displayed);
    %%%

    handle = figure('menuBar', 'none', 'name', 'Image Display', 'keypressfcn', 'close;');
    axis equal;

    axes('Visible', 'off', 'Units', 'normalized',...
        'DrawMode','fast',...
        'NextPlot','replacechildren');

    axes('position', [0 0 1 1]);
%     blank = ones(405, 720);
%     startImage(:,:,1) = blank;
%     startImage(:,:,2) = blank;
%     startImage(:,:,3) = blank;
    imageHandle = image(displayed);


    Calib.mondims = Calib.mondims1;

    set(gcf,'position', [Calib.mondims.x -Calib.mondims.y Calib.mondims.width Calib.mondims.height]); %Calib.mondims.y in M, -Calib.mondims.y in SP, changes dont seem to matter

    %xlim([1,Calib.mondims.width]); ylim([1,Calib.mondims.height]);axis ij;
    set(gca,'xtick',[]);set(gca,'ytick',[]);

    hold on;


    % *************************************************************************
    %
    % Start tracking and plot the gaze data read from the tracker.
    %
    % *************************************************************************

   
    leftEyeAll = [];
    rightEyeAll = [];
    timeStampAll = [];

    
%     scratchLocsFile = 'dummyStim.jpg';
%     scratchLocs = imread(scratchLocsFile);
    ccc6=clock;
    tetio_startTracking;

    [leftEyeAll, rightEyeAll, timeStampAll, onScreenAll, crossHairEndTS] = DataCollectSemSal(userID, thisTrialInformation, pauseTimeInSeconds, img, imageHandle, totalSecondsOpportunity, lookingTimeTriggerTrial, crosshairShapeTime, crosshairOnlyTime, targetTime, lookingTimeTriggerReward, totalSecondsOfReward);
    etime(clock,ccc6)
    tetio_stopTracking; 

    allData = horzcat(double(timeStampAll), leftEyeAll, rightEyeAll);
    dataWithPresentation = cell(size(allData,1), size(allData,2)+1);
    dataWithPresentation(1:size(allData,1), 1:size(allData,2)) = num2cell(allData);
    dataWithPresentation(1:size(allData,1), size(allData,2)+1) = onScreenAll;
    dataFromAllTrials{i} = dataWithPresentation;
    %stimuliFromAllTrials{i} = onScreenAll;
    %dataWithPresentationAllTrials{i} = dataWithPresentation;
    crossHairEndTimes(i) = crossHairEndTS;
    numTrialsCompleted = numTrialsCompleted + 1;
    


    
%     if(~isplaying(player))
%         play(player);
%     end
end
stop(player);

% ME = MException('Exception:expected','expected');
% throw(ME);
% 
% catch ME
%     stop(player);
%     % Display finished image
%     finImgFile = 'FinImg.png';
%     finImg = imread(finImgFile);
%     handle = figure('menuBar', 'none', 'name', 'Image Display');
%     axis equal;
% 
%     axes('Visible', 'off', 'Units', 'normalized',...
%         'DrawMode','fast',...
%         'NextPlot','replacechildren');
% 
%     axes('position', [0 0 1 1]);
%     imageHandle = image(finImg);
%     Calib.mondims = Calib.mondims1;
%     set(gcf,'position', [Calib.mondims.x Calib.mondims.y Calib.mondims.width Calib.mondims.height]);
%     set(gca,'xtick',[]);set(gca,'ytick',[]);
%     drawnow;
%     %Done displaying image
%     
%     if (~strcmp(ME.message, 'expected'))
%         fprintf('Error in execution : \n    %s\n    %s\n\n', ME.identifier, ME.message);
%     end
%     
%     if (~exist('output'))
%         mkdir('output');
%     end
%     fprintf('PLEASE WAIT! Analyzing and outputting data from completed trials...\n');
%     imageSizeX = 1080;
%     imageSizeY = 1920;
%     
%     dataOutName = strcat('output/', userID, '_data.csv');
%     datafid = fopen(dataOutName, 'wt');
%     eventOutName = strcat('output/', userID, '_events.csv');
%     eventfid = fopen(eventOutName, 'wt');
%     %fprintf(fid, '%0.3f time on BG,%0.3f time on L, %0.3f time on R\n', ptsOnBG/totalPts, ptsOnL/totalPts, ptsOnR/totalPts);
%     % PRINT HEADER
%     fprintf(datafid, 'Timestamp,LeftEyePos3DX,LeftEyePos3DY,LeftEyePos3DZ,');
%     fprintf(datafid, 'LeftEyePos3DRelativeX,LeftEyePos3DRelativeY,LeftEyePos3DRelativeZ,');
%     fprintf(datafid, 'LeftGazePoint2DX,LeftGazePoint2DY,');
%     fprintf(datafid, 'LeftGazePoint3DX,LeftGazePoint3DY,LeftGazePoint3DZ,');
%     fprintf(datafid, 'LeftPupilDiameter,LeftValid,');
%     fprintf(datafid, 'RightEyePos3DX,RightEyePos3DY,RightEyePos3DZ,');
%     fprintf(datafid, 'RightEyePos3DRelativeX,RightEyePos3DRelativeY,RightEyePos3DRelativeZ,');
%     fprintf(datafid, 'RightGazePoint2DX,RightGazePoint2DY,');
%     fprintf(datafid, 'RightGazePoint3DX,RightGazePoint3DY,RightGazePoint3DZ,');
%     fprintf(datafid, 'RightPupilDiameter,RightValid,');
%     fprintf(datafid, 'TrialID,TrialNumber\n');
%     
%     fprintf(eventfid, strcat(userID, '\n'));
%     d = date();
%     fprintf(eventfid, strcat(d, '\n'));
%     fprintf(eventfid, strcat(num2str(currentFrameRate), '\n'));
%     fprintf(eventfid, strcat(num2str(Calib.mondims.width), 'x', num2str(Calib.mondims.height), '\n'));
% 
%     %% Calib Data
%     fprintf(eventfid, ' ,');
%     for i = 1:size(calibMetrics, 2)
%         fprintf(eventfid, strcat('Point ', num2str(i)));
%         if (i == size(calibMetrics, 2))
%             fprintf(eventfid, '\n');
%         else
%             fprintf(eventfid, ',');
%         end
%     end
%     fprintf(eventfid, 'LeftEyeMean,');
%     for i = 1:size(calibMetrics, 2)
%         fprintf(eventfid, num2str(calibMetrics(1,i)));
%         if (i == size(calibMetrics, 2))
%             fprintf(eventfid, '\n');
%         else
%             fprintf(eventfid, ',');
%         end
%     end
%     fprintf(eventfid, 'RightEyeMean,');
%     for i = 1:size(calibMetrics, 2)
%         fprintf(eventfid, num2str(calibMetrics(2,i)));
%         if (i == size(calibMetrics, 2))
%             fprintf(eventfid, '\n');
%         else
%             fprintf(eventfid, ',');
%         end
%     end
%     fprintf(eventfid, 'LeftEyeStd,');
%     for i = 1:size(calibMetrics, 2)
%         fprintf(eventfid, num2str(calibMetrics(3,i)));
%         if (i == size(calibMetrics, 2))
%             fprintf(eventfid, '\n');
%         else
%             fprintf(eventfid, ',');
%         end
%     end
%     fprintf(eventfid, 'RightEyeStd,');
%     for i = 1:size(calibMetrics, 2)
%         fprintf(eventfid, num2str(calibMetrics(4,i)));
%         if (i == size(calibMetrics, 2))
%             fprintf(eventfid, '\n');
%         else
%             fprintf(eventfid, ',');
%         end
%     end
%     fprintf(eventfid, '\n');
%     % end calib data output
% 
%     %% 
%     fprintf(eventfid, strcat('TrialNum,TrialStartTS,Stimuli,Side,Test?,Before/After,',...
%                              'Perc_Total,Perc_Background,Perc_Left,Perc_Right,',...
%                              'Pixels_Total,Pixels_BG,Pixels_Left,Pixels_R,',...
%                              'PercTimeBG,PercTimeLeft,PercTimeRight,PercTimeInvalid,',...
%                              'MSBG,MSLeft,MSRight,MSInvalid\n'));
%     for trial = 1:numTrialsCompleted
%         t = trialOrder{trial};
%         trialName = str2num( t(size(t,2)-8:size(t,2)-7) );
%         sideStr = t(size(t,2)-4);
%         if (strcmp(sideStr, 'L'))
%             side = 1;
%         elseif(strcmp(sideStr, 'R'))
%             side = 2;
%         elseif(strcmp(sideStr, 'B'))
%             side = 3;
%         else
%             side = -1;
%         end
%         if (trial > 10)
%             testTrial = 1;
%         else
%             testTrial = 0;
%         end
%         trialStartTS = dataFromAllTrials{trial}(1,1);
%         trialAsStr = num2str(trial);
%         
%         % Print raw data
%         allData = dataFromAllTrials{trial};
%         for j = 1:size(allData,1)
%             for k = 1:size(allData,2)
%                 if ( (k == 8 || k == 21) && (allData(j,k) > 0) )
%                     fprintf(datafid, '%.3f', (allData(j, k)*imageSizeX));%convert to pixels
%                 elseif ( (k == 9 || k == 22) && (allData(j,k) > 0) ) 
%                     fprintf(datafid, '%.3f', (allData(j, k)*imageSizeY));%convert to pixels
%                 else
%                     fprintf(datafid, '%.3f', allData(j, k));
%                 end
% 
%                 if (k == size(allData,2))
%                     if (allData(j, 1) < crossHairEndTimes(trial)) 
%                         fprintf(datafid, ',99'); % 99 means crosshair is up.
%                     else
%                         fprintf(datafid, ',%d', trialName);
%                     end
%                     fprintf(datafid, ',%d', trial); %Trial number
%                     fprintf(datafid, '\n');
%                 else
%                     fprintf(datafid, ',');
%                 end
%             end            
%         end   
%         
%         
%         
%         %% Now %'s scratched
%         try
%             fileName = strcat('scratchImgs/', userID, '_T', trialAsStr , '_green_', trialOrder{trial});
%             scratched = uint8(imread(fileName));
%         catch ME
%             fprintf('Tried to open file %s but could not find or open it...\n', fileName);
%             continue;
%         end
%         bgColor = scratchLocs(1, 1, :);
%         bgScratched = 0;
%         leftPicScratched = 0;
%         rightPicScratched = 0;
%         for i = 1:imageSizeX
%             for j = 1:imageSizeY
%                 if (isequal(scratched(i,j,:), scratchLocs(i,j,:)))
%                     if (isequal(scratched(i, j, :), bgColor))
%                         bgScratched = bgScratched + 1;
%                     elseif (j < imageSizeY / 2)
%                         leftPicScratched = leftPicScratched + 1;
%                     else
%                         rightPicScratched = rightPicScratched + 1;
%                     end
%                 end
%             end
%         end
%         
%         totalScratched = bgScratched + leftPicScratched + rightPicScratched;
%         percentScratched = [totalScratched/(imageSizeX*imageSizeY), bgScratched/totalScratched, leftPicScratched/totalScratched, rightPicScratched/totalScratched];
%         afterScratchStops = -1;
%         if (testTrial)
%             afterScratchStops = 0;
%         end
%         
%         
%             ptsOnBG = 0;
%             ptsOnL = 0;
%             ptsOnR = 0;
%             ptsInvalid = 0;
%             
%             for i = 1:size(allData, 1) %% Find initial timestamp when crosshair goes away
%                 if (allData(i,1) > crossHairEndTimes(trial))
%                     initialTimeStamp = allData(i,1);
%                     break;
%                 end
%             end
%             
%             % This block is for train trials and for test trials before the
%             % scratching stops.
%             for i = 1:size(allData, 1)
%                 if (testTrial && (allData(i, 1) > (initialTimeStamp + 5000000))) %Five seconds, scratching stops
%                     break;
%                 end
%                 
%                 if (allData(i, 1) < crossHairEndTimes(trial))
%                     continue; % Don't count times before crosshair goes away!
%                 end
%                 
%                 avgEyeY = floor(((allData(i, 8)+allData(i, 21))*imageSizeY)/2);
%                 avgEyeX = floor(((allData(i, 9)+allData(i, 22))*imageSizeX)/2);
%                 
%                 if (allData(i, 14) ~= 0 || allData(i, 27) ~= 0 ||...
%                         avgEyeX <= 0 || avgEyeY <= 0 || ...
%                         avgEyeX > size(scratchLocs,1) || avgEyeY > size(scratchLocs,2))
%                     
%                     ptsInvalid = ptsInvalid+1;
%                     lastTimeStamp = allData(i, 1);
%                     continue;
%                 end
%                 
%                 if (isequal(scratchLocs(avgEyeX, avgEyeY, :), bgColor))
%                     ptsOnBG = ptsOnBG + 1;
%                 else
%                     if (avgEyeY < imageSizeY/2)
%                         ptsOnL = ptsOnL + 1;
%                     else
%                         ptsOnR = ptsOnR + 1;
%                     end
%                 end
%                 lastTimeStamp = allData(i, 1);
%             end
%             totalPts = ptsOnBG + ptsOnL + ptsOnR + ptsInvalid;
%             totalTime = (lastTimeStamp - initialTimeStamp)/1000;
%             fprintf(eventfid, '%d,%d,%s,%d,%d,%d,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f\n',...
%                 trial, trialStartTS, t, side, testTrial, afterScratchStops, percentScratched(1), percentScratched(2), percentScratched(3), percentScratched(4), ...
%                 totalScratched, bgScratched, leftPicScratched, rightPicScratched,...
%                 ptsOnBG/totalPts, ptsOnL/totalPts, ptsOnR/totalPts, ptsInvalid/totalPts, ...
%                 (ptsOnBG/totalPts)*totalTime, (ptsOnL/totalPts)*totalTime, (ptsOnR/totalPts)*totalTime, (ptsInvalid/totalPts)*totalTime);
% 
%             
%             
%         % This block is for test trials AFTER the scratching has stopped.
%         if (testTrial)
%             % Percent times after scratching stopped.
%             ptsOnBG = 0;
%             ptsOnL = 0;
%             ptsOnR = 0;
%             ptsInvalid = 0;
%             
%             for i = 1:size(allData, 1)
%                 if (allData(i, 1) < (initialTimeStamp + 5000000)) %Five seconds, scratching stops. Don't count points now before scratching stops.
%                     continue;
%                 end
%                 if (allData(i, 1) < crossHairEndTimes(trial))
%                     continue; % Don't count times before crosshair goes away!
%                 end
%                 
%                 avgEyeY = floor(((allData(i, 8)+allData(i, 21))*imageSizeY)/2);
%                 avgEyeX = floor(((allData(i, 9)+allData(i, 22))*imageSizeX)/2);
%                 
%                 if (allData(i, 14) ~= 0 || allData(i, 27) ~= 0 ||...
%                         avgEyeX <= 0 || avgEyeY <= 0 || ...
%                         avgEyeX > size(scratchLocs,1) || avgEyeY > size(scratchLocs,2))
%                     
%                     ptsInvalid = ptsInvalid+1;
%                     lastTimeStamp = allData(i,1);
%                     continue;
%                 end
%                 
%                 if (isequal(scratchLocs(avgEyeX, avgEyeY, :), bgColor))
%                     ptsOnBG = ptsOnBG + 1;
%                 else
%                     if (avgEyeY < imageSizeY/2)
%                         ptsOnL = ptsOnL + 1;
%                     else
%                         ptsOnR = ptsOnR + 1;
%                     end
%                 end
%                 lastTimeStamp = allData(i,1);
%             end
%             totalPts = ptsOnBG + ptsOnL + ptsOnR + ptsInvalid;
%             
%             try
%                 fileName = strcat('scratchImgs/', userID, '_T', trialAsStr , '_testGreen_', trialOrder{trial});
%                 scratched = uint8(imread(fileName));
%             catch ME
%                 fprintf('Tried to open file %s but could not find or open it...\n', fileName);
%                 continue;
%             end
%             bgColor = scratchLocs(1, 1, :);
%             bgScratched = 0;
%             leftPicScratched = 0;
%             rightPicScratched = 0;
%             for i = 1:imageSizeX
%                 for j = 1:imageSizeY
%                     if (isequal(scratched(i,j,:), scratchLocs(i,j,:)))
%                         if (isequal(scratched(i, j, :), bgColor))
%                             bgScratched = bgScratched + 1;
%                         elseif (j < imageSizeY / 2)
%                             leftPicScratched = leftPicScratched + 1;
%                         else
%                             rightPicScratched = rightPicScratched + 1;
%                         end
%                     end
%                 end
%             end
%             
%             totalScratched = bgScratched + leftPicScratched + rightPicScratched;
%             percentScratched = [totalScratched/(imageSizeX*imageSizeY), bgScratched/totalScratched, leftPicScratched/totalScratched, rightPicScratched/totalScratched];
%             afterScratchStops = 1;
%             
%             totalTime = (lastTimeStamp - (initialTimeStamp+ 5000000))/1000;
%             fprintf(eventfid, '%d,%d,%s,%d,%d,%d,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f,%0.3f\n',...
%                 trial, trialStartTS, t, side, testTrial, afterScratchStops, percentScratched(1), percentScratched(2), percentScratched(3), percentScratched(4), ...
%                 totalScratched, bgScratched, leftPicScratched, rightPicScratched,...
%                 ptsOnBG/totalPts, ptsOnL/totalPts, ptsOnR/totalPts, ptsInvalid/totalPts, ...
%                 (ptsOnBG/totalPts)*totalTime, (ptsOnL/totalPts)*totalTime, (ptsOnR/totalPts)*totalTime, (ptsInvalid/totalPts)*totalTime);
%         end
%         
%     end
%     fclose(datafid);
%     fclose(eventfid);
%     % Clean up at the end
%     try
%         tetio_stopTracking; 
%         tetio_disconnectTracker; 
%         tetio_cleanUp;
%     catch
%     end
% end

disp('Program finished!');

version = 'original (Dec 2017)';
numBaseBlocks = 1; % 12 trials per block, 6 blocks = 72 trials
numPostBlocks = 2; % 8 trials per block, 6 blocks = 48 trials
numLearnTrials = 12; % must be even

infoStruct.date = datestr(clock);

infoStruct.version = version;
infoStruct.numBaseBlocks = numBaseBlocks;
infoStruct.numPostBlocks = numPostBlocks;
infoStruct.numLearnTrials = numLearnTrials;

infoStruct.rewardingShape = rewardingShape;
infoStruct.stimuliList = stimuliList;
infoStruct.rewardVideoFrameLength = rewardVideoFrameLength;
infoStruct.totalSecondsOpportunity = totalSecondsOpportunity;
infoStruct.totalSecondsOfReward = totalSecondsOfReward;
infoStruct.lookingTimeTriggerTrial = lookingTimeTriggerTrial;
infoStruct.crosshairShapeTime = crosshairShapeTime;
infoStruct.crosshairOnlyTime = crosshairOnlyTime;
infoStruct.targetTime = targetTime;
infoStruct.lookingTimeTriggerReward = lookingTimeTriggerReward;
infoStruct.rewardTime = rewardTime;
infoStruct.pauseTimeInSeconds = pauseTimeInSeconds;

save(strcat('C:\Users\Elabusers\Documents\MATLAB\SemanticSalience\Output\', userID ,'_infoStruct.mat'), 'infoStruct');
save(strcat('C:\Users\Elabusers\Documents\MATLAB\SemanticSalience\Output\', userID ,'_rawData.mat'), 'dataFromAllTrials');






