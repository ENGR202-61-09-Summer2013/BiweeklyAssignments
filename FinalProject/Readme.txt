Lenny Knittel & Marat Purnyn
ENGR 202-061-09
Final Project
Cursor-Controlling App

Core functionality:

Setup Serial Port 
- We have a toggle button that open/closes the serial connection

Calibrate 
- we calibrate on serial port opening and have a button to recalibrate 

Start/Stop Reading Sensor Values 
- we have a button that starts/stop reading the accelerometer

Filtering noise 
- we use an SMA filter of 5 steps to filter the data

Visualization 
- we visualize the movement of the mouse with an axis.

Close serial port 
- our toggle button covers this

Threshold crossing detection 
- we check for the crossing of the threshold for the deadzone of the accelerometer

Advanced functionality:

Advanced User interface 
- We used a loading bar to tell the user how long to hold the accelerometer steady
- We also have a click sound occur when the user "clicks" with the accelerometer
Advanced alogrith 
- we used a java module to control the native OS cursor and move the mouse based on the orientation of the accelerometer.
Advanced visualization 
- we displayed the movement of the mouse on an axis 
- we also had the color of the "mouse" change when a click happened
Dealing with uncertainty
- we have the user hold the accelerometer steady for 3 seconds to generate a deadzone threshold. This accounds for hand-jitteryness.