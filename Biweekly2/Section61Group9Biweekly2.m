%Marat Purnyn and Leonard Knittle
%Section 61
%Group 9

% This function starts up and initializes GUIDE.
function varargout = Section61Group9Biweekly2(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Section61Group9Biweekly2_OpeningFcn, ...
                   'gui_OutputFcn',  @Section61Group9Biweekly2_OutputFcn, ...
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

% This function runs upon starting the GUIDE figure.  
function Section61Group9Biweekly2_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for Section61Group9Biweekly2
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % starts the read accelerometer toggle button as not enabled.
    % this makes it unavaialble until you've set up the accelerometer 
    set(handles.togglebutton2,'Enable','off'); 
    
function varargout = Section61Group9Biweekly2_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%this function run on clicking the open serial communication toggle button
function togglebutton1_Callback(hObject, eventdata, handles)
    if(get(hObject,'Value'))
        % if the toggle button is being pressed
        % start opening the serial connection
        
        % enable the second toggle button to start reading
        % from the accelerometer
        set(handles.togglebutton2,'Enable','on');
        % edit the text so we know what unpressing the button will do.
        set(hObject,'String','Close Serial Connection');
        % connect MATLAB to the accelerometer
        
        % Specifies the COM port that the Arduino board is connected to
        % by grabbing it from the textbox
        comPort = get(handles.edit1,'String');  
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
        set(handles.togglebutton2,'String','Start Reading Accelerometer');
        % reset the status of the read accelerometer button
        set(handles.togglebutton2,'Value',0);
        set(handles.togglebutton2,'Enable','off');
        set(hObject,'String','Open Serial Connection');
        % finally close the serial connection using modified close serial
        % code that will not close all figures.
        closeSerial();
    end
    
% this function runs when the read accelerometer button is toggled    
function togglebutton2_Callback(hObject, eventdata, handles)
    if(get(hObject,'Value'))
        % if the button is being pressed, start reading from the acc.
        
        %start by grabbing the accelerometer from the handle since they
        %were added in another callback function.
        accelerometer = handles.accelerometer;
        calCo = handles.calCo;
        % change the button text to reflect what unpressing it will do
        set(hObject,'String','Stop Reading Accelerometer');
        
        %the following code is modified from wk3_vector.m & wk3_magnitude.m
        buf_len = 200;
        
        % create variables for all the three axis and the resultant 
        gxdata = zeros(buf_len,1);
        gydata = zeros(buf_len,1);
        gzdata = zeros(buf_len,1);
        index = 1:buf_len;

        % Display x and y label ad title.
        xlabel('Time');
        ylabel('Magnitude');
        title('Complete magnitude representation of the accelerometer sensor data');

        
        
        while(get(hObject,'Value'))
            %read accelerometer output while the button is pressed down
            
            %selects the figure to plot the acceleration vector data to
            axes(handles.axes3);
            grid on;
            %outputs the acceleration data from the readAcc function
            [gx gy gz] = readAcc(accelerometer, calCo);
            cla;            %clear everything from the current axis
            %plot X and Y acceleration vectors and resultant acceleration vector
            line([0 gx], [0 0],[0 0], 'Color', 'r', 'LineWidth', 2, 'Marker', 'o');
            line([0 0], [0 gy],[0 0], 'Color', 'g', 'LineWidth', 2, 'Marker', 'o');
            line([0 0], [0 0],[0 gz], 'Color', 'b', 'LineWidth', 2, 'Marker', 'o');
            line([0 gx], [0 gy],[0 gz], 'Color', 'black', 'LineWidth', 2, 'Marker', 'o');
            %limit plot to +/- 1.25 g in all directions and make axis square
            limits = 2.5;
            axis([-limits limits -limits limits -limits limits]);
            axis square;
            %calculate the angle of the resultant acceleration vector and print
            theta = atand(gy/gx);
            %edit the text in GUIDE so that it shows the angle of the
            %resultant vector.
            set(handles.text5,'String', num2str(theta, '%.0f')); 
            

            % from wk3_magnitude
            % Append the new reading to the end of the rolling plot data. Drop the
            % first value
            gxdata = [gxdata(2:end) ; gx];
            gydata = [gydata(2:end) ; gy];
            gzdata = [gzdata(2:end) ; gz];    
            gmdata = gxdata+gydata+gzdata;
            % Update the rolling plot

            % plot for resultant maginitude
            axes(handles.axes1); %selects the axes in GUIDE to plot to
            plot(index,gmdata,'black');
            axis([1 buf_len -3.5 3.5]);  
            xlabel('time');
            ylabel('Magnitude of the resultant acceleration');
            grid on;
            % plot for x y z magnitude
            axes(handles.axes2); %selects the axes in GUIDE to plot to
            plot(index,gxdata,'r', index,gydata,'g', index,gzdata,'b');
            axis([1 buf_len -3.5 3.5]);  
            xlabel('time');
            ylabel('Magnitude of individual axes acceleration');
            grid on;
            %adds a legend, but it lags it to much, 
            %so I added it in the .fig
            %legend('X','Y','Z','Location','BestOutside'); 

            
            %force MATLAB to redraw the figure
            drawnow;
        end
    else
        %if the button is unpressed, reset the text.
        set(hObject,'String','Start Reading Accelerometer');
    end
    
%function that executes when the text is changed in the com port textbox
function edit1_Callback(hObject, eventdata, handles)

function edit1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
