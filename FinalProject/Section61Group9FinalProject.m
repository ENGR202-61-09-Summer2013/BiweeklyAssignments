% Lenny Knittel & Marat Purnyn
% ENGR 202-061-09
% Final Project
% Cursor-Controlling App

function varargout = Section61Group9FinalProject(varargin)
% SECTION61GROUP9FINALPROJECT MATLAB code for Section61Group9FinalProject.fig
%      SECTION61GROUP9FINALPROJECT, by itself, creates a new SECTION61GROUP9FINALPROJECT or raises the existing
%      singleton*.
%
%      H = SECTION61GROUP9FINALPROJECT returns the handle to a new SECTION61GROUP9FINALPROJECT or the handle to
%      the existing singleton*.
%
%      SECTION61GROUP9FINALPROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SECTION61GROUP9FINALPROJECT.M with the given input arguments.
%
%      SECTION61GROUP9FINALPROJECT('Property','Value',...) creates a new SECTION61GROUP9FINALPROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Section61Group9FinalProject_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Section61Group9FinalProject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help Section61Group9FinalProject
% Last Modified by GUIDE v2.5 28-Aug-2013 11:22:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Section61Group9FinalProject_OpeningFcn, ...
                   'gui_OutputFcn',  @Section61Group9FinalProject_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function Section61Group9FinalProject_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% Set toggle buttons as innabled so user cannot click them before setting
% up the serial connection
set(handles.tbReadAcc,'Enable','off');
set(handles.tbMouse,'Enable','off');

import java.awt.Robot; %Imports java file so that the app can control the mouse cursor.
mouse = Robot; %Creates a Robot object that can control the mouse cursor.
set(0,'units','pixels'); %Sets the units used to calculate screen size
screenSize = get(0, 'ScreenSize'); %gets the screen size

%edits textboxes to display screensize on the app for the user
set(handles.textX,'String',screenSize(3));
set(handles.textY,'String',screenSize(4));

%Sets the length of the data arrays
buf_len = 200;     
%creates arrays to store Acc. data with null data.
gxdata = zeros(buf_len,1);
gydata = zeros(buf_len,1);
gzdata = zeros(buf_len,1);
%creates arrays to store filtered Acc. data with null data.
gxdataFiltered = zeros(buf_len,1);
gydataFiltered = zeros(buf_len,1);
gzdataFiltered = zeros(buf_len,1);
%creates a default threshold values for the deadzone
thresholdX = [-0.5,0.5];
thresholdY = [-0.5,0.5];
thresholdZ = [-0.5,0.5];
%sets up variables to store the current acc. values
gx=0;
gy=0;
gz=0;
%creates variables to store the filtered acc. values.
gxFiltered=0;
gyFiltered=0;
gzFiltered=0;
%creates a time period for SMA filtering
timePeriod = 5;

%adds the variables to the handle to use as a global varriable.
handles.mouse = mouse;
handles.screenSize = screenSize;
handles.gxdata = gxdata;
handles.gydata = gydata;
handles.gzdata = gzdata;
handles.thresholdX = thresholdX;
handles.thresholdY = thresholdY;
handles.thresholdZ = thresholdZ;
handles.gxdataFiltered = gxdataFiltered;
handles.gydataFiltered = gydataFiltered;
handles.gzdataFiltered = gzdataFiltered;
handles.gx = gx;
handles.gy = gy;
handles.gz = gz;
handles.gxFiltered = gxFiltered;
handles.gyFiltered = gyFiltered;
handles.gzFiltered = gzFiltered;
handles.timePeriod = timePeriod;

% Adds the handles object to GUIDE's data space so that it can
% be accessed by the rest of our program.
guidata(hObject,handles);

function varargout = Section61Group9FinalProject_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function tbReadAcc_Callback(hObject, eventdata, handles)
    if(get(hObject,'Value'))
        % if the button is toggled on, start reading from the acc.
                
        % change the button text to reflect what unpressing it will do
        set(hObject,'String','Stop Reading Accelerometer');
        
        %start by grabbing the accelerometer from the handle since they
        %were added in another callback function.
        accelerometer = handles.accelerometer;
        calCo = handles.calCo;
        
        % now we grab the "global" variables we created in the opening function
        gxdata = handles.gxdata;
        gydata = handles.gydata;
        gzdata = handles.gzdata;        
        gxdataFiltered = handles.gxdataFiltered;
        gydataFiltered = handles.gydataFiltered;
        gzdataFiltered = handles.gzdataFiltered;
        timePeriod = handles.timePeriod;
        gx = handles.gx;
        gy = handles.gy;
        gz = handles.gz;
        gxFiltered = handles.gxFiltered;
        gyFiltered = handles.gyFiltered;
        gzFiltered = handles.gzFiltered;
        thresholdX = handles.thresholdX;
        thresholdY = handles.thresholdY;
        thresholdZ = handles.thresholdZ;
        screenSize = handles.screenSize;
        mouse = handles.mouse;

        % creates 2 variables to store the size of the screen in pixels
        screenX = screenSize(3);
        screenY = screenSize(4);
        % creates variables to store the mouse x and y coordinates
        mouseY = 0;
        mouseX = 0;   
        % creates variables to store change in the mouse and y coordinates
        mouseDX = 0;
        mouseDY = 0;
        %creates variables to store cursor x and y coordinates. 
        %it starts the cursor in the middle of the screen.
        cursorX = screenX/2;
        cursorY = screenY/2;
        %loads the windows mouse click sound to give feedback to the user
        sound = audioread('Windows Navigation Start.wav');
        %coverts the sound into something matlab can play
        player = audioplayer(sound, 30000);
        
        while(get(hObject,'Value'))
            %gets the current acc. values from the acc. 
            [gx gy gz] = readAcc(accelerometer, calCo);
            % sets the filtered data to start as the actual axis value
            gxFiltered = gx; 
            gyFiltered = gy;
            gzFiltered = gz;
            
            %appends the new data gained on each loop to the arrays
            gxdata = [gxdata(2:end) ; gx];
            gydata = [gydata(2:end) ; gy];
            gzdata = [gzdata(2:end) ; gz];   
            
            %appends SMA filtered data to the filtered arrays
            gxFiltered = mean(gxdata(end-timePeriod:end),1);
            gxdataFiltered = [gxdataFiltered(2:end) ; gxFiltered];
            gyFiltered = mean(gydata(end-timePeriod:end),1);
            gydataFiltered = [gydataFiltered(2:end) ; gyFiltered];
            gzFiltered = mean(gzdata(end-timePeriod:end),1);
            gzdataFiltered = [gzdataFiltered(2:end) ; gzFiltered];

            if(gyFiltered > thresholdY(2))
                %if the y axis filtered data is greater than the deadzone
                %threshold, then move Y mouse value "up" 
                mouseY = mouseY-(10*abs(gyFiltered)-(10*thresholdY(2)-1));
                %record the displacement of the mouse
                mouseDY = -(10*abs(gyFiltered)-(10*thresholdY(2)-1));
            elseif(gyFiltered < thresholdY(1))
                %if the y axis filtered data is less than the deadzone
                %threshold, then move Y mouse value "down" 
                mouseY = mouseY+(10*abs(gyFiltered)-(10*thresholdY(1)+1));
                %record the displacement of the mouse
                mouseDY = (10*abs(gyFiltered)-(10*thresholdY(1)+1));
            else(abs(gyFiltered)<thresholdY(2))
                %if it is in between, set the change to zero.
                mouseDY = 0;
            end
            
            if(gxFiltered > thresholdX(2))
                %if the y axis filtered data is greater than the deadzone
                %threshold, then move Y mouse value "right" 
                mouseX = mouseX-(10*abs(gxFiltered)-(10*thresholdX(2)-1));
                 %record the displacement of the mouse
                mouseDX = -(10*abs(gxFiltered)-(10*thresholdX(2)-1));
            elseif(gxFiltered < thresholdX(1))
                %if the x axis filtered data is less than the deadzone
                %threshold, then move X mouse value "left" 
                mouseX = mouseX+(10*abs(gxFiltered)-(10*thresholdX(1)+1));
                 %record the displacement of the mouse
                mouseDX = (10*abs(gxFiltered)-(10*thresholdX(1)+1));
            else(abs(gxFiltered)<thresholdX(2))
                %if it is in between, set the change to zero.
                mouseDX = 0;
            end
            
            if(get(handles.tbMouse,'Value'))
                %if the mouse toggle button is on, start moving the native
                %cursor of the Operating System.
                if(mouseDX~=0)
                    %moves the cursor based on a scaled value
                    cursorX = cursorX + mouseDX/abs(mouseDX)*abs(mouseDX)^1.5;
                end
                if(mouseDY~=0)
                    %moves the cursor based on a scaled value
                    cursorY = cursorY - mouseDY/abs(mouseDY)*abs(mouseDY)^1.5;
                end
                
                %makes sure the cursor cannot travel beyond the limits of
                %the screen's X axis
                if(cursorX<0)
                    cursorX = 0;
                elseif(cursorX>screenX)
                    cursorX = screenX;
                end
                
                %makes sure the cursor cannot travel beyond the limits of
                %the screen's Y Axis
                if(cursorY<0)
                    cursorY = 0;
                elseif(cursorY>screenY)
                    cursorY = screenY;
                end
                
                %uses the robot class to move the native cursor.
                mouse.mouseMove(cursorX,cursorY);
                
                if(gz > 1.5)
                    %clicks left mouse button
                    % 16 is the value for the left mouse button
                    % found here: http://docs.oracle.com/javase/7/docs/api/java/awt/event/InputEvent.html
                    mouse.mousePress(16); 
                elseif(gz<1.5)
                    %releases the left mouse button
                    mouse.mouseRelease(16);
                end
            end
            
            %sets the axis to plot the "mouse"
            axes(handles.MousePlot);
            cla; %clears the axis
            grid on; %puts a grid on the axis
            
            %changes color of the "mouse" based on if a click would have
            %occured
            if(gz > 1.5) %red for jerking up
                line([0 mouseX/100], [0 mouseY/100],'LineStyle', 'none', 'Color', 'red', 'LineWidth', 1, 'Marker', 'o');
                play(player);
            elseif(abs(gz)<1.5) %black for no click
                line([0 mouseX/100], [0 mouseY/100],'LineStyle', 'none', 'Color', 'black', 'LineWidth', 1, 'Marker', 'o');
            elseif(gz<-1.5) %green for jerking down 
                line([0 mouseX/100], [0 mouseY/100],'LineStyle', 'none', 'Color', 'green', 'LineWidth', 1, 'Marker', 'o');
            end
            title('Virtual Mouse position');
            xlabel('X Coordinate','FontSize',12);
            ylabel('Y Coordinate','FontSize',12);

            limits = 2; %sets the limit of the axis
            axis([-limits limits -limits limits]);
            axis square;
        end
    elseif(~get(hObject,'Value'))
        %if the button is unpressed, reset the text.
        set(hObject,'String','Start Reading Accelerometer');
    end

function editPort_Callback(hObject, eventdata, handles)


function editPort_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tbSerial_Callback(hObject, eventdata, handles)
    if(get(hObject,'Value'))
        
        % if the toggle button is being pressed
        % start opening the serial connection
        
        % enable the second toggle button to start reading
        % from the accelerometer
        set(handles.tbReadAcc,'Enable','on');
        set(handles.tbMouse,'Enable','on');
        % edit the text so we know what unpressing the button will do.
        set(hObject,'String','Close Serial Connection');
        % connect MATLAB to the accelerometer
        
        % Specifies the COM port that the Arduino board is connected to
        % by grabbing it from the textbox
        comPort = get(handles.editPort,'String');  
        % this code sets up the serial communication
        % taken from the example code
        
        if (~exist('serialFlag','var'))
         [accelerometer.s,serialFlag] = setupSerial(comPort);
        end
        % this code runs the calibration routine if the serial
        % communication is setup. modified from the example code.
        if(~exist('calCo', 'var'))
            calCo = calibrate(accelerometer.s);
            % Puts the accelerometer and calCo variables in the handle 
            % so that it can be used between callback functions 
            handles.accelerometer = accelerometer;
            handles.calCo = calCo;
            guidata(hObject,handles);
            
            %creates an array to store the acc values over the 3 second
            %period
            gxdata = zeros(50,1);
            gydata = zeros(50,1);
            gzdata = zeros(50,1);
            
            mbox = msgbox('After you click ok, please attempt to hold the Accelerometer steady so that the X and Y axis are perpendicular to the floor for 3 seconds.', 'Deadzone Calibration'); uiwait(mbox);
            %creates a loading bar to give the user feedback on how long to
            %hold steady
            h = waitbar(0,'Calculating Deadzone...');
            
            tic; %starts a timer
            while(toc<3)
                %while the timer hasn't reached 3 seconds,
                %record thte acc values
                [gx gy gz] = readAcc(accelerometer, calCo);
                gxdata = [gxdata(2:end) ; gx];
                gydata = [gydata(2:end) ; gy];
                gzdata = [gzdata(2:end) ; gz];
                %and move the loading bar for the percentage of 3 seconds 
                %that has elapsed.
                waitbar(toc/3);
            end
            %close the loading bar when it finishes
            close(h);
            mbox = msgbox('Deadzone Calibration Complete.', 'Deadzone Calibration'); uiwait(mbox);
            %set the threshold to the maximum displacement
            handles.thresholdX=[-1*max(gxdata),max(gxdata)];
            handles.thresholdY=[-1*max(gydata),max(gydata)];
            handles.thresholdZ=[-1*max(gzdata),max(gzdata)]; 
            
            %adds the threshold values to the global variable space
            guidata(hObject,handles);
        end
        
    else
        % if the button is being unpressed, change the text to indicate what
        % pressing it will do.
        set(handles.tbReadAcc,'String','Start Reading Accelerometer');
        % reset the status of the read accelerometer button
        set(handles.tbReadAcc,'Value',0);
        set(handles.tbReadAcc,'Enable','off');
        set(handles.tbMouse,'Value',0);
        set(handles.tbMouse,'Enable','off');
        set(hObject,'String','Open Serial Connection');
        % finally close the serial connection using modified close serial
        % code that will not close all figures.
        closeSerial();
    end

function tbMouse_Callback(hObject, eventdata, handles)
    if(get(hObject,'Value'))
        set(hObject,'String','Stop Controling Windows Pointer');
    elseif(~get(hObject,'Value'))
        set(hObject,'String','Start Controling Windows Pointer');
    end

function bCalibrateAcc_Callback(hObject, eventdata, handles)
if (get(handles.tbSerial,'Value'))
    %if the serial connection is open
    % Puts the accelerometer and calCo variables in the handle 
    % so that it can be used between callback functions 
    accelerometer = handles.accelerometer;
    calCo = calibrate(accelerometer.s);

    %creates an array to store the acc values over the 3 second
    %period
    gxdata = zeros(50,1);
    gydata = zeros(50,1);
    gzdata = zeros(50,1);

    mbox = msgbox('After you click ok, please attempt to hold the Accelerometer steady so that the X and Y axis are perpendicular to the floor for 3 seconds.', 'Deadzone Calibration'); uiwait(mbox);
    %creates a loading bar to give the user feedback on how long to
    %hold steady
    h = waitbar(0,'Calculating Deadzone...');

    tic; %starts a timer
    while(toc<3)
        %while the timer hasn't reached 3 seconds,
        %record thte acc values
        [gx gy gz] = readAcc(accelerometer, calCo);
        gxdata = [gxdata(2:end) ; gx];
        gydata = [gydata(2:end) ; gy];
        gzdata = [gzdata(2:end) ; gz];
        %and move the loading bar for the percentage of 3 seconds 
        %that has elapsed.
        waitbar(toc/3);
    end
    %close the loading bar when it finishes
    close(h);
    mbox = msgbox('Deadzone Calibration Complete.', 'Deadzone Calibration'); uiwait(mbox);
    %set the threshold to the maximum displacement
    handles.thresholdX=[-1*max(gxdata),max(gxdata)];
    handles.thresholdY=[-1*max(gydata),max(gydata)];
    handles.thresholdZ=[-1*max(gzdata),max(gzdata)]; 

    %adds the threshold values to the global variable space
    guidata(hObject,handles);
else
    %if the serial connection isn't open, produce and error message
    mbox = msgbox('Please open a serial connection first.', 'Error'); uiwait(mbox);
end



function tbInstructions_Callback(hObject, eventdata, handles)
    if(get(hObject,'Value'))
        %if the button is toggled on, change the buton text and make the 
        %instruction text visible
        set(hObject,'String','Instructions Off');
        set(handles.uipanelInstructions,'Visible','On');
    elseif(~get(hObject,'Value'))
        %if the button is toggled off, change the button text and make the 
        %instruction text invisible
        set(hObject,'String','Instructions On');
        set(handles.uipanelInstructions,'Visible','Off');
    end
