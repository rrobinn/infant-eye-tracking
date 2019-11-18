global Calib

screensize = get(0,'MonitorPositions');
Calib.mondims1.x = screensize(2, 1);
Calib.mondims1.y = screensize(2, 2);
Calib.mondims1.width = screensize(2, 3) - screensize(1, 3);
Calib.mondims1.height = screensize(2, 4); % Use alternate monitor.

Calib.MainMonid = 1; 
Calib.TestMonid = 1;

Calib.points.x = [0.285 0.285 0.5 0.715 0.715];  % X coordinates in [0,1] coordinate system 
Calib.points.y = [0.25 0.75 0.5 0.25 0.75];  % Y coordinates in [0,1] coordinate system 
Calib.points.n = size(Calib.points.x, 2); % Number of calibration points
Calib.bkcolor = [0.85 0.85 0.85]; % background color used in calibration process
Calib.fgcolor = [0 1 0]; % (Foreground) color used in calibration process
Calib.fgcolor2 = [1 0 0]; % Color used in calibratino process when a second foreground color is used (Calibration dot)
Calib.fgcolor3 = [0 0 1];
Calib.BigMark = 25; % the big marker 
Calib.TrackStat = 25; % 
Calib.SmallMark = 7; % the small marker
Calib.Mark3 = 45;
Calib.delta = 200; % Moving speed from point a to point b
Calib.resize = 0; % To show a smaller window
Calib.NewLocation = get(gcf,'position');