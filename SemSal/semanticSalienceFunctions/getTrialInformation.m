function [trialInformation, rewardingShape, stimuliList] = getTrialInformation(numBaseBlocks, numPostBlocks, numLearnTrials, rewardVideoFrameLength)

% numBaseBlocks = 1; % 8 trials per block, 6 blocks = 48 trials
% numPostBlocks = 1; % 8 trials per block, 6 blocks = 48 trials
% numLearnTrials = 12; % must be even
% rewardVideoFrameLength = 10;

pathToStimuli = 'C:/Users/Elabusers/Documents/MATLAB/SemanticSalience/Stimuli/';

addpath(pathToStimuli);

files = dir(pathToStimuli);
size(files,1);
if (size(files,1) == 0)
    ME = MException('Exception:IOException','Could not read stimulus files.');
    throw(ME);
end


% Order baseline trials
if numBaseBlocks > 0 
    baseTrialOrder = counterbalanceV8(numBaseBlocks);
    baseTrialOrder(baseTrialOrder(:,3)==1,:)=[]; % no face trials
    numBaseTrials = length(baseTrialOrder);
else
    numBaseTrials = 0;
end
% Order learning trials: 0 is reward on left, 1 is reward on right
learnTrials = [ones(numLearnTrials / 2,1); zeros(numLearnTrials / 2,1)];
learnTrialOrder = learnTrials(randperm(numLearnTrials),1);


% Order post-test trials
postTrialOrder = counterbalanceV8(numPostBlocks);
postTrialOrder(postTrialOrder(:,3)==1,:)=[]; % no face trials
numPostTrials = length(postTrialOrder);

numTrials = numBaseTrials+numLearnTrials+numPostTrials;
trialInformation = cell(numTrials, 8);% numTrial, trialType, trialNum in type, centerStim, cue, target, mask, reward
stimuliList = cell(numTrials, 8); %string name of files

% Determine this participant's reward shape
% 1 is cube, 2 is drop
rng('shuffle');
if randi(2) == 1
    rewardingShape = 'cube'
    unrewardingShape = 'drop';
    %     rewardingMask = ;
else
    rewardingShape = 'drop'
    unrewardingShape = 'cube';
    %     rewardingMask = ;
    
end

% determine order of movie presentation
nMovies = 4;
movieInfo = randi(nMovies, 1, numLearnTrials);
%% read in reward stills

% rewardStillsL_barn1 = cell(rewardVideoFrameLength,1);
% fprintf('Loading frames....rewardStillsL_barn1 \n');
% for f = 1:rewardVideoFrameLength %num frames in reward
%     [frame, ~] = imread(strcat(pathToStimuli, 'rewardFramesL_V4/frame', num2str(f-1), '.png'));
%     %     frame = ind2rgb(frame, frameMap);
%     rewardStillsL_barn1{f} = frame;
% end
% 
% rewardStillsR_barn1 = cell(rewardVideoFrameLength,1);
% fprintf('Loading frames....rewardStillsR_barn1 \n');
% for f = 1:rewardVideoFrameLength %num frames in reward
%     
%     [frame, ~] = imread(strcat(pathToStimuli, 'rewardFramesR_V4/frame', num2str(f-1), '.png'));
%     %     frame = ind2rgb(frame, frameMap);
%     rewardStillsR_barn1{f} = frame;
% end
% 
% rewardStillsL_barn2 = cell(rewardVideoFrameLength,1);
% fprintf('Loading frames....rewardFramesL_barn2 \n');
% 
% for f = 1:rewardVideoFrameLength %num frames in reward
%     [frame, ~] = imread(strcat(pathToStimuli, 'rewardFramesL_barn2/frame', num2str(f-1), '.png'));
%     %     frame = ind2rgb(frame, frameMap);
%     rewardStillsL_barn2{f} = frame;
% end
% 
% rewardStillsR_barn2 = cell(rewardVideoFrameLength,1);
% fprintf('Loading frames....rewardFramesR_barn2 \n');
% 
% for f = 1:rewardVideoFrameLength %num frames in reward
%     [frame, ~] = imread(strcat(pathToStimuli, 'rewardFramesR_barn2/frame', num2str(f-1), '.png'));
%     %     frame = ind2rgb(frame, frameMap);
%     rewardStillsR_barn2{f} = frame;
% end
% 
% rewardStillsL_hoop1 = cell(rewardVideoFrameLength,1);
% fprintf('Loading frames....rewardFramesL_hoop1 \n');
% 
% for f = 1:rewardVideoFrameLength %num frames in reward
%     [frame, ~] = imread(strcat(pathToStimuli, 'rewardFramesL_hoop1/frame', num2str(f-1), '.png'));
%     %     frame = ind2rgb(frame, frameMap);
%     rewardStillsL_hoop1{f} = frame;
% end
% 
% rewardStillsR_hoop1 = cell(rewardVideoFrameLength,1);
% fprintf('Loading frames....rewardFramesR_hoop1 \n');
% 
% for f = 1:rewardVideoFrameLength %num frames in reward
%     [frame, ~] = imread(strcat(pathToStimuli, 'rewardFramesR_hoop1/frame', num2str(f-1), '.png'));
%     %     frame = ind2rgb(frame, frameMap);
%     rewardStillsR_hoop1{f} = frame;
% end
% 
% 
 rewardStillsL_park2 = cell(rewardVideoFrameLength,1);
 fprintf('Loading frames....rewardFramesL_park2 \n');

for f = 1:rewardVideoFrameLength %num frames in reward
    [frame, ~] = imread(strcat(pathToStimuli, 'rewardFramesL_park2/frame', num2str(f-1), '.png'));
    %     frame = ind2rgb(frame, frameMap);
    rewardStillsL_park2{f} = frame;
end

rewardStillsR_park2 = cell(rewardVideoFrameLength,1);
fprintf('Loading frames....rewardFramesR_park2 \n');

for f = 1:rewardVideoFrameLength %num frames in reward
    [frame, ~] = imread(strcat(pathToStimuli, 'rewardFramesR_park2/frame', num2str(f-1), '.png'));
    %     frame = ind2rgb(frame, frameMap);
    rewardStillsR_park2{f} = frame;
end

%%
maskL = imread(strcat(pathToStimuli, 'maskL.png'));
maskR = imread(strcat(pathToStimuli, 'maskR.png'));

centerStim = imread(strcat(pathToStimuli, 'centerStim.png'));

for i = 1:numTrials
    
    if i <= numBaseTrials
        trialType = 'BASE';
        trialNum = i;
        
        cueFile = [];
        
        if baseTrialOrder(trialNum,1) == 1
            cueFile = strcat(cueFile, rewardingShape);
        elseif baseTrialOrder(trialNum,2) == 1
            cueFile = strcat(cueFile, unrewardingShape);
        end
        
        if baseTrialOrder(trialNum,4) == 1
            cueFile = strcat(cueFile, 'R.png');
        else
            cueFile = strcat(cueFile, 'L.png');
        end
        
        if baseTrialOrder(trialNum,5) == baseTrialOrder(trialNum,4)
            targetFile = 'heartR.png';
        else
            targetFile = 'heartL.png';
        end
        
        cue = imread(strcat(pathToStimuli, cueFile));
        target = imread(strcat(pathToStimuli, targetFile));
        
        trialInformation{i,1} = i;
        trialInformation{i,2} = trialType;
        trialInformation{i,3} = trialNum;
        trialInformation{i,4} = centerStim;
        trialInformation{i,5} = cue;
        trialInformation{i,6} = target;
        
        stimuliList{i,1} = i;
        stimuliList{i,2} = trialType;
        stimuliList{i,3} = trialNum;
        stimuliList{i,4} = strcat(pathToStimuli, 'centerStim.png');
        stimuliList{i,5} = strcat(pathToStimuli, cueFile);
        stimuliList{i,6} = strcat(pathToStimuli, targetFile);
        
    elseif i <= numBaseTrials + numLearnTrials
        trialType = 'LEARN';
        trialNum = i - numBaseTrials;
        
        if learnTrialOrder(trialNum) == 0 % left
            bilateralCue = imread(strcat(pathToStimuli, rewardingShape, '-', unrewardingShape, '.png'));
%             if movieInfo(trialNum) == 1
%                 rewardingStills = rewardStillsL_barn1;
%                 rewardPath = strcat(pathToStimuli, 'rewardFramesL_V4/');
%             elseif movieInfo(trialNum) == 2
%                 rewardingStills = rewardStillsL_barn2;
%                 rewardPath = strcat(pathToStimuli, 'rewardFramesL_barn2/');
%             elseif movieInfo(trialNum) == 3
%                 rewardingStills = rewardStillsL_hoop1;
%                 rewardPath = strcat(pathToStimuli, 'rewardFramesL_hoop1/');
%             elseif movieInfo(trialNum) == 4
                rewardingStills = rewardStillsL_park2;
                rewardPath = strcat(pathToStimuli, 'rewardFramesL_park2/');
            %end
            mask = 'maskL';
        else
            bilateralCue = imread(strcat(pathToStimuli, unrewardingShape, '-', rewardingShape, '.png'));
%             if movieInfo(trialNum) == 1
%                 rewardingStills = rewardStillsR_barn1;
%                 rewardPath = strcat(pathToStimuli, 'rewardFramesR_V4/');
%             elseif movieInfo(trialNum) == 2
%                 rewardingStills = rewardStillsR_barn2;
%                 rewardPath = strcat(pathToStimuli, 'rewardFramesR_barn2/');
%             elseif movieInfo(trialNum) == 3
%                 rewardingStills = rewardStillsR_hoop1;
%                 rewardPath = strcat(pathToStimuli, 'rewardFramesR_hoop1/');
%             elseif movieInfo(trialNum) == 4
                rewardingStills = rewardStillsR_park2;
                rewardPath = strcat(pathToStimuli, 'rewardFramesR_park2/');
            %end
            mask = 'maskR';
        end
        
        trialInformation{i,1} = i;
        trialInformation{i,2} = trialType;
        trialInformation{i,3} = trialNum;
        trialInformation{i,4} = centerStim;
        trialInformation{i,5} = bilateralCue;
        trialInformation{i,7} = mask;
        trialInformation{i,8} = rewardingStills;
        
        stimuliList{i,1} = i;
        stimuliList{i,2} = trialType;
        stimuliList{i,3} = trialNum;
        stimuliList{i,4} = strcat(pathToStimuli, 'centerStim.png');
        stimuliList{i,5} = strcat(pathToStimuli, unrewardingShape, '-', rewardingShape, '.png');
        stimuliList{i,7} = mask;
        stimuliList{i,8} = rewardPath;
        
    else
        trialType = 'POST';
        trialNum = i - numBaseTrials - numLearnTrials;
        cueFile = [];
        
        if postTrialOrder(trialNum,1) == 1
            cueFile = strcat(cueFile, rewardingShape);
        elseif postTrialOrder(trialNum,2) == 1
            cueFile = strcat(cueFile, unrewardingShape);
        end
        
        if postTrialOrder(trialNum,4) == 1
            cueFile = strcat(cueFile, 'R.png');
        else
            cueFile = strcat(cueFile, 'L.png');
        end
        
        if postTrialOrder(trialNum,5) == postTrialOrder(trialNum,4)
            targetFile = 'heartR.png';
        else
            targetFile = 'heartL.png';
        end
        
        cue = imread(strcat(pathToStimuli, cueFile));
        target = imread(strcat(pathToStimuli, targetFile));
        
        trialInformation{i,1} = i;
        trialInformation{i,2} = trialType;
        trialInformation{i,3} = trialNum;
        trialInformation{i,4} = centerStim;
        trialInformation{i,5} = cue;
        trialInformation{i,6} = target;
        
        stimuliList{i,1} = i;
        stimuliList{i,2} = trialType;
        stimuliList{i,3} = trialNum;
        stimuliList{i,4} = strcat(pathToStimuli, 'centerStim.png');
        stimuliList{i,5} = strcat(pathToStimuli, cueFile);
        stimuliList{i,6} = strcat(pathToStimuli, targetFile);
        
    end
end

end
