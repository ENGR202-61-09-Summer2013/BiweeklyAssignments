%Marat Purnyn and Leonard Knittle
%Section 61
%Group 9

%=========================================================================
%============== Accelerometer Vector Skeleton Code =======================
%=========================================================================
%This skeleton script does the following:
% 1. Specifies the COM port that the Arduino board is connected to
% 2. Initializes the Serial Port - setupSerial() (not to be altered)
% 3. Runs a calibration routine if needed - calibrate() (not to be altered)
% 4. Opens a new figure and customizes it by adding start/stop and close
%    serial buttons
%    - A different stop call   
% 5. Runs a loop that continually reads the accelerometer values 
%    readAcc() - (not to be altered)    
%    The accelerometer data is placed in the variables [gx gy gz].
% 6. Displays the vectors using line() command


%% 1. Specifies the COM port that the Arduino board is connected to
comPort = 'COM4'  %On a mac type ls /dev/tty* in Terminal and 
                  %  identify the device that is listed as usbmodem
                  %  Example for a MAC comPort = '/dev/tty.usbmodemfa131';
%comPort = '/dev/tty.usbmodemfd121';



%% 2. Initialize the Serial Port - setupSerial() (not to be altered)

%connect MATLAB to the accelerometer
if (~exist('serialFlag','var'))
 [accelerometer.s,serialFlag] = setupSerial(comPort);
end

%% 3. Run a calibration routine if needed - calibrate() (not to be altered)
 
%if the accelerometer is not calibrated, calibrate now
if(~exist('calCo', 'var'))
    calCo = calibrate(accelerometer.s);
end

%% 4. Open a new figure - add start/stop and close serial buttons

%initalize the figure that we will plot in if it does not exist
if(~exist('h', 'var') || ~ishandle(h))
    h = figure(1);
    ax = axes('box','on');
end

%add a start/stop and close serial button inside the figure
%Keep in mind the 'stop_call_wk3' function that this button calls everytime
%it is pressed 

if(~exist('button','var'))
    button = uicontrol('Style','pushbutton','String','Stop',...
                    'pos',[0 0 50 25],'parent',h,...
                    'Callback','stop_call_vector','UserData',1);
end

%Keep in mind the 'close_call' function that this button calls everytime
%it is pressed 

if(~exist('button2','var'))
    button2 = uicontrol('Style','pushbutton','String','Close Serial Port',...
                    'pos',[250 0 150 25],'parent',h,...
                    'Callback','closeSerial','UserData',1);
end

%% 5. Runs a loop that continually reads the accelerometer values 
%     readAcc() - (not to be altered)
%     The accelerometer data is placed in the variables [gx gy gz].
 
while (get(button, 'UserData'))
   
    %read accelerometer output
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
    title(['Accelerometer tilt angle: ' num2str(theta, '%.0f')]);
    
    %force MATLAB to redraw the figure
    drawnow;
    
end
