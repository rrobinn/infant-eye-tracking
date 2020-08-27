% 2017/07/20: Script generates trial-order for semantic salience experiment
% counterbalanceV8

% Testing new method, randomly order trials within block, only add to trial
% list if pass tests

function allTrials = counterbalance(NBLOCKS)
%% Constants
% NBLOCKS = 6;

%% Generate 12 possible types of trials

rewarded = [0; 0; 0; 0; 0; 0; 0; 0; 1; 1; 1; 1];
unrewarded = [1; 1; 1; 1; 0; 0; 0; 0; 0; 0; 0; 0];
face = [0; 0; 0; 0; 1; 1; 1; 1; 0; 0; 0; 0];
right = [0; 0; 1; 1; 0; 0; 1; 1; 0; 0; 1; 1];
left = double(~right);
congruent = [0; 1; 0; 1; 0; 1; 0; 1; 0; 1; 0; 1];
incongruent = double(~congruent);

stims = horzcat(rewarded, unrewarded, face, right, left, congruent, incongruent);
numTypeTrials = length(stims);

%% generate trial order blocks
allTrials = [];

while size(allTrials,1) < NBLOCKS * numTypeTrials
    
    % randomly order all possible trials
    permutedOrder = randperm(numTypeTrials);
    permutedTrials = stims(permutedOrder, :);
    
    % combine with prior block for testing
    if size(allTrials,1) >= numTypeTrials
        priorBlock = allTrials(end-numTypeTrials+1:end,:);
    else
        priorBlock = [];
    end
    
    testPriorAndPermuted = [priorBlock; permutedTrials];
    
    legitimateBlock = 1; % changes to 0 if trial order issue found
    
    % test all columns for four consecutive 1s
    for currCol = 1:7 %rewarded, unrewarded, face, right, left, cong, incong
        [column,nums] = bwlabel(testPriorAndPermuted(:,currCol));
        for i = 1:nums
            if length(find(column==i)) > 3
                legitimateBlock = 0;
                break;
            end
        end
    end
    
    % if permuted block looks good with prior block, add to allTrials
    if legitimateBlock == 1
        allTrials = [allTrials; permutedTrials];
    end
    
end % while size allTrials loop

allTrials(:, [5, 7]) = []; % get rid of left and incongruent columns

end % end function
