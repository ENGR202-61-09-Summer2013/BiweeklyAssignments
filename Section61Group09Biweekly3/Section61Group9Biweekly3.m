%Marat Purnyn and Leonard Knittle
%Section 61
%Group 9

% This function starts up and initializes GUIDE.
function varargout = Section61Group9Biweekly3(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Section61Group9Biweekly3_OpeningFcn, ...
                   'gui_OutputFcn',  @Section61Group9Biweekly3_OutputFcn, ...
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
function Section61Group9Biweekly3_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for Section61Group9Biweekly3
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % starts the read accelerometer toggle button as not enabled.
    % this makes it unavaialble until you've set up the accelerometer 
    set(handles.togglebutton2,'Enable','off'); 
    handles.alphaFilterOn = false;
    guidata(hObject,handles);
    closeSerial();
    
function varargout = Section61Group9Biweekly3_OutputFcn(hObject, eventdata, handles) 
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
        %sets the length of the arrays
        buf_len = 200;
        
        % create a fixed length empty array for each axis
        gxdata = zeros(buf_len,1);
        gydata = zeros(buf_len,1);
        gzdata = zeros(buf_len,1);
        % create a fixed length empty array for each axis's filtere data
        gxdataFiltered = zeros(buf_len,1);
        gydataFiltered = zeros(buf_len,1);
        gzdataFiltered = zeros(buf_len,1);
        %creates an index array of the same fixed length
        index = 1:buf_len;
        % Display x and y label ad title.
        xlabel('Time');
        ylabel('Magnitude');
        title('Complete magnitude representation of the accelerometer sensor data');

        %while the button is active,
        while(get(hObject,'Value'))
            %if the alpha filter is on, set the alpha value
            if(get(handles.togglebutton3,'Value'))
                alpha = get(handles.slider2,'Value');
            else
                alpha = 0;
            end
            %if the SMA filter is on, set the alpha value
            if(get(handles.togglebutton4,'Value'))
                timePeriod = round(get(handles.slider3,'Value'));
            else
                timePeriod = 0;
            end
            %selects the figure to plot the acceleration vector data to
            axes(handles.axes3);
            grid on; %turns on the grid for the graph
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
            
            % sets the filtered data to start as the actual axis value
            gxFiltered = gx; 
            gyFiltered = gy;
            gzFiltered = gz;
            %appends the new data gained on each loop to the arrays
            gxdata = [gxdata(2:end) ; gx];
            gydata = [gydata(2:end) ; gy];
            gzdata = [gzdata(2:end) ; gz];    
            gmdata = sqrt(gxdata.^2+gydata.^2+gzdata.^2);
            % if the alpha filter is on
            if(get(handles.togglebutton3,'Value'))
                  %modifies the incoming data with the alpha filter and the
                  %last value in the respective filtered array
                  gxFiltered = gxFiltered*alpha + gxdataFiltered(200)*(1-alpha);
                  gyFiltered = gyFiltered*alpha + gydataFiltered(200)*(1-alpha);
                  gzFiltered = gzFiltered*alpha + gzdataFiltered(200)*(1-alpha);
                  %appends filtered value to filtered array
                  gxdataFiltered = [gxdataFiltered(2:end) ; gxFiltered];
                  gydataFiltered = [gydataFiltered(2:end) ; gyFiltered];
                  gzdataFiltered = [gzdataFiltered(2:end) ; gzFiltered]; 
            % if the sma filter is on
            elseif(get(handles.togglebutton4,'Value'))
                  %modifies the incoming data with the alpha filter and the
                  %last n values in the respective filtered array
                  gxFiltered = mean(gxdata(end-timePeriod:end),1);
                  gxdataFiltered = [gxdataFiltered(2:end) ; gxFiltered];
                  gyFiltered = mean(gydata(end-timePeriod:end),1);
                  gydataFiltered = [gydataFiltered(2:end) ; gyFiltered];
                  gzFiltered = mean(gzdata(end-timePeriod:end),1);
                  gzdataFiltered = [gzdataFiltered(2:end) ; gzFiltered];
            else
                  %if no filter is on, append the raw value to the filtered
                  %array
                  gxdataFiltered = [gxdataFiltered(2:end) ; gx];
                  gydataFiltered = [gydataFiltered(2:end) ; gy];
                  gzdataFiltered = [gzdataFiltered(2:end) ; gz]; 
            end
            
            % plot for resultant maginitude
            axes(handles.axes1); %selects the axes in GUIDE to plot to
            plot(index,gxdata,'r', index,gydata,'g', index,gzdata,'b');
            axis([1 buf_len -3.5 3.5]);  
            xlabel('time');
            ylabel('Magnitude of the resultant acceleration');
            grid on;
            % plot for x y z magnitude
            axes(handles.axes2); %selects the axes in GUIDE to plot to
            
           
            plot(index,gxdataFiltered,'r', index,gydataFiltered,'g', index,gzdataFiltered,'b');
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


% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton3
    if(get(hObject,'Value'))
        % if the button is being pressed, start reading from the acc.
        guidata(hObject,handles);
        set(hObject,'String','Alpha Filter Off');
        set(handles.togglebutton4,'String','SMA Filter On');
        set(handles.togglebutton4,'Value',0);
        set(handles.text34,'String','Time Period:')
    else
        guidata(hObject,handles);
        set(hObject,'String','Alpha Filter On');
        set(handles.text30,'String','Alpha Value:')
    end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text30,'String',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in togglebutton4.
function togglebutton4_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton4
    if(get(hObject,'Value'))
        % if the button is being pressed, start reading from the acc.
        guidata(hObject,handles);
        set(hObject,'String','SMA Filter Off');
        set(handles.togglebutton3,'String','Alpha Filter On');
        set(handles.togglebutton3,'Value',0);
        set(handles.text30,'String','Alpha Value:')
    else
        guidata(hObject,handles);
        set(hObject,'String','SMA Filter On');
        set(handles.text34,'String','Time Period:')
    end

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.text34,'String',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
