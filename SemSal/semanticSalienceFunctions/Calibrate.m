function calibPlotData = Calibrate(Calib,morder,iter,donts)
%CALIBRATE calibrate the eye tracker
%   This function is used to set and view the calibration results for the tobii eye tracker. 
%
%   Input: 
%         Calib: The calib structure (see CalibParams)
%         morder: Order of the calibration point 
%         iter: 0/1 (0 = A new calibation call, esnure that calibration is not already started)
%                   (1 = just fixing a few Calibration points)
%         donts: Points (with one in the index) that are to be
%         recalibrated, 0 else where
%   Output: 
%         calibPlotData: The calibration plot data, specifying the input and output calibration data

    global SPACE_KEY_IS_PRESSED;
    global UP_ARROW_PRESSED;


    clc
    assert(Calib.points.n >= 2 && length(Calib.points.x)==Calib.points.n, ...
      'Err: Invalid Calibration params, Verify...');

    readerobj = VideoReader('Duck.mp4');
    vidFrames = read(readerobj);
    numFrames = get(readerobj, 'NumberOfFrames')/2; %Only use first part of frames
    for k = 1 : numFrames
        mov(k).cdata = vidFrames(:,:,:,k);
        mov(k).colormap = [];
        mov(k).cdata = imresize(mov(k).cdata, 0.25);
    end
    %Duck audio, because these are just images above and do not include audio
    [y, Fs] = audioread('Duck_audio.mp3');
    duckAudioPlayer = audioplayer(y,Fs);
    
    figH = figure('menuBar','none','name','Calibrate','Color', Calib.bkcolor,'Renderer', 'Painters','keypressfcn','close;');
    axes('Visible', 'off', 'Units', 'normalize','Position', [0 0 1 1],'DrawMode','fast','NextPlot','replacechildren');
    Calib.mondims = Calib.mondims1;
    set(figH,'position',[Calib.mondims.x Calib.mondims.y Calib.mondims.width Calib.mondims.height]);
    xlim([1,Calib.mondims.width]); 
    ylim([1,Calib.mondims.height]);
    axis ij;
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    if (iter==0)
        tetio_startCalib;    
    end
    idx = 0;
    validmat = ones(1,Calib.points.n);
    %generate validity matrix 
    if ~isempty(donts)
        validmat = zeros(1,Calib.points.n);
        for i = 1:length(donts)
           validmat(morder==donts(i))=1;
        end
    end
    %disp(num2str(validmat)):
    pause(1);
    step= 10; %shrinking steps (increase for powerful pcs)
    
    [y, Fs] = audioread('bell2.mp3');
    player = audioplayer(y,Fs);
    
    for  i = 1:Calib.points.n;
        %show the big marker
        if (validmat(i)==0)
            continue;
        end
        ms = Calib.BigMark;  
        ms2 = Calib.Mark3;
        idx = idx+1;
        if (idx ~= 1)
            linecord = Drawline([Calib.mondims.width*Calib.points.x(morder(idx-1)) Calib.mondims.height*Calib.points.y(morder(idx-1))],...
                [Calib.mondims.width*Calib.points.x(morder(i)) Calib.mondims.height*Calib.points.y(morder(i))]);
            for k = 1:Calib.delta:length(linecord)
                h1 = plot(linecord(k,2),linecord(k,1),...
                    'o','MarkerEdgeColor',Calib.fgcolor, 'MarkerFaceColor',Calib.fgcolor,'MarkerSize',ms);
                h3 = plot(Calib.mondims.width*Calib.points.x(morder(i)),...
                     Calib.mondims.height*Calib.points.y(morder(i)),...
                     'o','MarkerEdgeColor',Calib.fgcolor3,'MarkerFaceColor',Calib.fgcolor3,'MarkerSize',ms2);

                drawnow;
                delete(h1);
                delete(h3);
            end
        end
        
        
        set(gcf, 'KeyPressFcn', @myKeyPressFcn);
        SPACE_KEY_IS_PRESSED = 0;
        UP_ARROW_PRESSED = 0;
        while (~SPACE_KEY_IS_PRESSED)
            
            % shrink
            for j = 1:step
                if (~isplaying(player))
                    play(player);
                end
                if (UP_ARROW_PRESSED)
                    stop(player);
                    play(duckAudioPlayer);
                    movie(figH, mov, 1, readerobj.FrameRate, [1920/2-240, 1280/2-250, 0, 0]);
                    stop(duckAudioPlayer);
                    play(player);
                    UP_ARROW_PRESSED = 0;
                end
                if (SPACE_KEY_IS_PRESSED)
                    break;
                end
                h3 = plot(Calib.mondims.width*Calib.points.x(morder(i)),...
                     Calib.mondims.height*Calib.points.y(morder(i)),...
                     'o','MarkerEdgeColor',Calib.fgcolor3,'MarkerFaceColor',Calib.fgcolor3,'MarkerSize',ms2);
                 hold on 
                h1 = plot(Calib.mondims.width*Calib.points.x(morder(i)),...
                    Calib.mondims.height*Calib.points.y(morder(i)),...
                    'o','MarkerEdgeColor',Calib.fgcolor,'MarkerFaceColor',Calib.fgcolor ,'MarkerSize',ms);

                        
                h2 = plot(Calib.mondims.width*Calib.points.x(morder(i)),...
                     Calib.mondims.height*Calib.points.y(morder(i)),...
                     'o','MarkerEdgeColor',Calib.fgcolor2,'MarkerFaceColor',Calib.fgcolor2,'MarkerSize',Calib.SmallMark);

                drawnow;
                if (j==1)
                    pause(0.5);
                end
                if (j==step) 
                    if ~isempty(donts)
                        tetio_removeCalibPoint(Calib.points.x(morder(i)), Calib.points.y(morder(i)));
                        disp(['deleted point ' num2str(morder(i)) ' and now adding it, where i = ' num2str(i)])
                    end
                    tetio_addCalibPoint(Calib.points.x(morder(i)),Calib.points.y(morder(i)));
                    pause(0.2);
                end
                ms = ms-ceil((Calib.BigMark - Calib.SmallMark)/step);
                ms2 = ms2-ceil((Calib.Mark3 - Calib.SmallMark)/step);
                pause(0.1)
                delete(h1);
                delete(h2);
                delete(h3);
            end
            
            % then grow
            for j = 1:step
                
                if (SPACE_KEY_IS_PRESSED)
                    break;
                end
                if (UP_ARROW_PRESSED)
                    stop(player);
                    play(duckAudioPlayer);
                    movie(figH, mov, 1, readerobj.FrameRate, [1920/2-240, 1280/2-250, 0, 0]);
                    stop(duckAudioPlayer);
                    play(player);
                    UP_ARROW_PRESSED = 0;
                end
                if (~isplaying(player))
                    play(player);
                end
                h3 = plot(Calib.mondims.width*Calib.points.x(morder(i)),...
                     Calib.mondims.height*Calib.points.y(morder(i)),...
                     'o','MarkerEdgeColor',Calib.fgcolor3,'MarkerFaceColor',Calib.fgcolor3,'MarkerSize',ms2);
                 hold on
                h1 = plot(Calib.mondims.width*Calib.points.x(morder(i)),...
                    Calib.mondims.height*Calib.points.y(morder(i)),...
                    'o','MarkerEdgeColor',Calib.fgcolor,'MarkerFaceColor',Calib.fgcolor ,'MarkerSize',ms);

                         
                h2 = plot(Calib.mondims.width*Calib.points.x(morder(i)),...
                     Calib.mondims.height*Calib.points.y(morder(i)),...
                     'o','MarkerEdgeColor',Calib.fgcolor2,'MarkerFaceColor',Calib.fgcolor2,'MarkerSize',Calib.SmallMark);
                
                drawnow;
                if (j==1)
                    pause(0.5);
                end
                if (j==step) 
                    if ~isempty(donts)
                        tetio_removeCalibPoint(Calib.points.x(morder(i)), Calib.points.y(morder(i)));
                        disp(['deleted point ' num2str(morder(i)) ' and now adding it, where i = ' num2str(i)])
                    end
                    tetio_addCalibPoint(Calib.points.x(morder(i)),Calib.points.y(morder(i)));
                    pause(0.2);
                end
                ms = ms+ceil((Calib.BigMark - Calib.SmallMark)/step);
                ms2 = ms2+ceil((Calib.Mark3 - Calib.SmallMark)/step);
                pause(0.1)
                delete(h1);
                delete(h2);
                delete(h3);
            end

        end
        
        stop(player);   
        
    end
    pause(0.5);
    close 
    tetio_computeCalib;  
    
    calibPlotData = tetio_getCalibPlotData;
    
    
    
    
    
    function myKeyPressFcn(hObject, event)
        if (strcmp(event.Key, 'space'))
            SPACE_KEY_IS_PRESSED  = 1;
        elseif (strcmp(event.Key, 'uparrow'))
            UP_ARROW_PRESSED = 1;
        end
    end
end



