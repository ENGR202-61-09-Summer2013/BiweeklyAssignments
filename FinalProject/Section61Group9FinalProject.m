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
% Last Modified by GUIDE v2.5 20-Aug-2013 15:40:49

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
set(handles.tbReadAcc,'Enable','off'); 
handles.alphaFilterOn = false;
guidata(hObject,handles);

import java.awt.Robot;
mouse = Robot;
set(0,'units','pixels');
screenSize = get(0, 'ScreenSize');
set(handles.textX,'String',screenSize(3));
set(handles.textY,'String',screenSize(4));
buf_len = 200;     
gxdata = zeros(buf_len,1);
gydata = zeros(buf_len,1);
gzdata = zeros(buf_len,1);
threshold = 0.8;
gxdataFiltered = zeros(buf_len,1);
gydataFiltered = zeros(buf_len,1);
gzdataFiltered = zeros(buf_len,1);
gx=0;
gy=0;
gz=0;
gxFiltered=0;
gyFiltered=0;
gzFiltered=0;
index = 1:buf_len;
timePeriod = 5;

handles.mouse = mouse;
handles.screenSize = screenSize;
handles.index = index;
handles.gxdata = gxdata;
handles.gydata = gydata;
handles.gzdata = gzdata;
handles.threshold = threshold;
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
% Now lets add the handles object to GUIDE's data space so that it can
% be accessed by the rest of our program.
guidata(hObject,handles);

function varargout = Section61Group9FinalProject_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function tbReadAcc_Callback(hObject, eventdata, handles)
    if(get(hObject,'Value'))
        % if the button is being pressed, start reading from the acc.
                
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
        threshold = handles.threshold;
        screenSize = handles.screenSize;
        mouse = handles.mouse;
        
        %creates an index array of the same fixed length
        index = handles.index;
        screenX = screenSize(3);
        screenY = screenSize(4);
        mouseY = 0;
        mouseX = 0;   
        mouseDX = 0;
        mouseDY = 0;
        cursorX = screenX/2;
        cursorY = screenY/2;
        
        while(get(hObject,'Value'))
            
            [gx gy gz] = readAcc(accelerometer, calCo);
            % sets the filtered data to start as the actual axis value
            gxFiltered = gx; 
            gyFiltered = gy;
            gzFiltered = gz;
            
            
            %appends the new data gained on each loop to the arrays
            gxdata = [gxdata(2:end) ; gx];
            gydata = [gydata(2:end) ; gy];
            gzdata = [gzdata(2:end) ; gz];   
            %gmdata = sqrt(gxdata.^2+gydata.^2+gzdata.^2);
            
            gxFiltered = mean(gxdata(end-timePeriod:end),1);
            gxdataFiltered = [gxdataFiltered(2:end) ; gxFiltered];
            gyFiltered = mean(gydata(end-timePeriod:end),1);
            gydataFiltered = [gydataFiltered(2:end) ; gyFiltered];
            gzFiltered = mean(gzdata(end-timePeriod:end),1);
            gzdataFiltered = [gzdataFiltered(2:end) ; gzFiltered];

            if(gyFiltered > 0.5)
                mouseY = mouseY-(10*abs(gyFiltered)-4);
                mouseDY = -(10*abs(gyFiltered)-4);
            elseif(gyFiltered < -0.5)
                mouseY = mouseY+(10*abs(gyFiltered)-4);
                mouseDY = (10*abs(gyFiltered)-4);
            else
                mouseDY = 0;
            end
            
            if(gxFiltered > 0.5)
                mouseX = mouseX-(10*abs(gxFiltered)-4);
                mouseDX = -(10*abs(gxFiltered)-4);
            elseif(gxFiltered < -0.5)
                mouseX = mouseX+(10*abs(gxFiltered)-4);
                mouseDX = (10*abs(gxFiltered)-4);
            else
                mouseDX = 0;
            end
            
            if(get(handles.tbMouse,'Value'))
                if(mouseDX~=0)
                    cursorX = cursorX + mouseDX/abs(mouseDX)*abs(mouseDX)^1.5;
                end
                if(mouseDY~=0)
                    cursorY = cursorY - mouseDY/abs(mouseDY)*abs(mouseDY)^1.5;
                end
                
                if(cursorX<0)
                    cursorX = 0;
                elseif(cursorX>screenX)
                    cursorX = screenX;
                end

                if(cursorY<0)
                    cursorY = 0;
                elseif(cursorY>screenY)
                    cursorY = screenY;
                end
                
                mouse.mouseMove(cursorX,cursorY);
                if(gz > 1.5)
                    %clicks left mouse button
                    mouse.mousePress(16); 
                elseif(gz<1.5)
                    mouse.mouseRelease(16);
                end
            end
            
            axes(handles.MousePlot);
            cla;
            grid on;
            if(gz > 1.5)
                line([0 mouseX/100], [0 mouseY/100],'LineStyle', 'none', 'Color', 'red', 'LineWidth', 1, 'Marker', 'o');
            elseif(abs(gz)<1.5)
                line([0 mouseX/100], [0 mouseY/100],'LineStyle', 'none', 'Color', 'black', 'LineWidth', 1, 'Marker', 'o');
            elseif(gz<-1.5)
                line([0 mouseX/100], [0 mouseY/100],'LineStyle', 'none', 'Color', 'green', 'LineWidth', 1, 'Marker', 'o');
            end

            limits = 2;
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
        end
    else
        % if the button is being unpressed, change the text to indicate what
        % pressing it will do.
        set(handles.tbReadAcc,'String','Start Reading Accelerometer');
        % reset the status of the read accelerometer button
        set(handles.tbReadAcc,'Value',0);
        set(handles.tbReadAcc,'Enable','off');
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
accelerometer = handles.accelerometer;
if(~exist('calCo', 'var'))
    calCo = calibrate(accelerometer.s);
    handles.calCo = calCo;
    guidata(hObject,handles);
end

