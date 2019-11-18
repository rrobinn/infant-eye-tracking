function [pts, calibMetrics] = HandleCalibWorkflow(Calib)
%HandleCalibWorkflow Main function for handling the calibration workflow.
%   Input:
%         Calib: The calib config structure (see SetCalibParams)
%   Output:
%         pts: The list of points used for calibration. These could be
%         further used for the analysis such as the variance, mean etc.


while(1)

    try
        
        mOrder = randperm(Calib.points.n);
        calibplot = Calibrate(Calib, mOrder, 0, []);
        pts = PlotCalibrationPoints(calibplot, Calib, mOrder);% Show calibration points and compute calibration. 
        calibMetrics = zeros(4, size(pts, 2));
        while(1)
            for i = 1:size(pts, 2)
                left = []; right = [];
                for j = 1:size(pts(i).point, 2)
                    if (pts(i).point(j).validity(1) == 1)
                        left = [left; pts(i).point(j).left];
                    end
                    if (pts(i).point(j).validity(2) == 1)
                        right = [right; pts(i).point(j).right];
                    end
                end
                numValidL = size(left , 1);
                numValidR = size(right, 1);
                
                meanPosL = mean(left);
                meanPosR = mean(right);
                
                meanDistFromPtL = norm(meanPosL - pts(i).origs);
                meanDistFromPtR = norm(meanPosR - pts(i).origs);
                   
                stdDevL = 0;
                for k = 1:numValidL
                    stdDevL = (left(k, 1) - meanPosL(1))^2 + (left(k, 2) - meanPosL(2))^2;
                end
                stdDevL = sqrt(stdDevL / numValidL);
                
                stdDevR = 0;
                for k = 1:numValidR
                    stdDevR = (right(k, 1) - meanPosR(1))^2 + (right(k, 2) - meanPosR(2))^2;
                end
                stdDevR = sqrt(stdDevR / numValidR);
                
                fprintf('For point %d :\n', i);
                fprintf('\tLeft  eye had mean %d and std dev %d (%d points).\n', meanDistFromPtL, stdDevL, numValidL);
                fprintf('\tRight eye had mean %d and std dev %d (%d points).\n', meanDistFromPtR, stdDevR, numValidR);
                calibMetrics(1, i) = meanDistFromPtL;
                calibMetrics(2, i) = meanDistFromPtR;
                calibMetrics(3, i) = stdDevL;
                calibMetrics(4, i) = stdDevR;
            end
                                            
            h = input('Accept calibration? ([y]/n):','s');  
            if isempty(h) || strcmp(h(1),'y')
                tetio_stopCalib;
                close;
                return; 
            end
            
            h = input('Recalibrate all points (a) or some points (b)? ([a]/b):','s'); 
            
            if isempty(h) || (strcmp(h(1),'a'))
                close all;
                tetio_stopCalib;
                break; 
            else
                h = input('Please enter (space separated) the point numbers that you wish to recalibrate e.g. 1 3: ', 's');
                recalibpts = str2num(h);
                calibplot = Calibrate(Calib, mOrder, 1, recalibpts);
                pts = PlotCalibrationPoints(calibplot, Calib, mOrder);
            end         
            
        end
    catch ME    %  Calibration failed
        tetio_stopCalib;
        h = input('Not enough calibration data. Do you want to try again([y]/n):','s');
        if isempty(h) || strcmp(h(1),'y')
            close all;            
            continue; 
        else
            fprintf('%s', getReport(ME));
            return;    
        end
        
    end
end








