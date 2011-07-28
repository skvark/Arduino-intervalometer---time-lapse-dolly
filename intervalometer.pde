// Intervalometer and dolly motor controller
// Olli-Pekka Heinisuo 2011
// Licensed under MIT license, see LICENSE.txt

// Function library for multiplexing one common anode 2 digit 7 segment display, uncomment if used
#include <CAnodeMultiplexed.h>

// pin that will trigger the camera
#define CAMERA_PIN 13

// "exposing" or not, if false, sends pulse to the optocoupler which triggers the camera
bool exposing = false;


int c,s,t,r,e,b,m,p = 0;
int n = 9;
int pause;
int counter = 0;
int interval;
int state;
int divi;
unsigned long time = 0;
int mot;

void setup()

{

// segments http://www.kingbrightusa.com/images/catalog/SPEC/DA04-11EWA.pdf
// Common anode 7 segment display multiplexing pins

pinMode(9, OUTPUT); // common anode digit 2
pinMode(10, OUTPUT); // common anode digit 1

pinMode(2, OUTPUT); // segment A
pinMode(3, OUTPUT); // segment F
pinMode(14, OUTPUT); // segment B
pinMode(15, OUTPUT); // segment G
pinMode(16, OUTPUT); // segment C
pinMode(17, OUTPUT); // segment E
pinMode(18, OUTPUT); // segment D

pinMode(13, OUTPUT);
pinMode(A5, INPUT); // pins for the buttons
pinMode(CAMERA_PIN, OUTPUT); // to the optocoupler

}

// These functions return a value when the corresponding button is pressed
// 1,8 kohm resistors were used between 6 buttons (7 resistors)
// More info: http://tronixstuff.wordpress.com/2011/01/11/tutorial-using-analog-input-for-multiple-buttons/
//
// Switches:
// 1 kohm resistors were used with 2 switches, total 6 resistors

// Reset button

int resetButton(int pin) {
  
c=analogRead(pin);

if (c<160 && c>100)
  {
  r = 1; // reset button
  }
return r;
}

/* coming later, sensor buttons for dolly

int shutDown(int pin) {
  
c=analogRead(pin);

if (c< && c>)
  {
  r = 1; // stop&reset to prevent any damage
  }
return r;
}

*/

// digit 1 value control

int dig1Button(int pin) {
   
c=analogRead(pin);

if (c>160 && c<180)
  {
  delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
  e++;
  }
  if (e < 10) { // can't show numbers bigger than 9
  return e;
  }
  else { // if value goes over 9, automatic reset will occur
  return e=0;
  }
  
}

// digit 2 value control

int dig2Button(int pin) {
  
c=analogRead(pin);

  if (c>180 && c<210)
  {
  delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
  b++;
  }
  if (b < 10) { // can't show numbers bigger than 9
  return b;
  }
  else { // if value goes over 9, automatic reset will occur
  return b=0;
  }
}

// digit 3 value control = motor speed

int dig3Button(int pin) {
   
c=analogRead(pin);

if (c>330 && c<370)
  {
  delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
  n++;
  }
  if (n < 10) { // can't show numbers bigger than 9
  return n;
  }
  else { // if value goes over 9, automatic reset will occur
  return n=0;
  }
  
}

// digit 4 value control = pause time

int dig4Button(int pin) {
   
c=analogRead(pin);

if (c>240 && c<270)
  {
  delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
  p++;
  }
  if (p < 10) { // can't show numbers bigger than 9
  return p;
  }
  else { // if value goes over 9, automatic reset will occur
  return p=0;
  }
  
}

// Start & stop

int startButton(int pin) {
  
c=analogRead(pin);

if (c>500 && c<600) {
  delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
  s++;
  }
  if (s <= 1) {
  return s;
  }
  else if (s > 1) { // stop
  return s=0;
  }
}

// select time range, default (0) is 0,0 - 9,9 seconds, (1) is 0-99 seconds

int timingSwitch(int pin) {
  
c=analogRead(pin);

if (c>450 && c < 550) {
  delay(250);
  t++;
  }
  else if (t <= 1) {
  return t;
  }
  else if (t > 1){
  return t=0;
  }
}


// This is where the magic happens

void loop() {

// If the reset button is pressed -> pause + every variable returns to their default values
  
if (r == 1 ) {

digitalWrite(CAMERA_PIN, LOW);
t = 0;
s = 0;
r = 0;
b = 0;
e = 0;
p = 0;
// default speed is 9 (maximum)
n = 9;
m = 0;
counter = 0;
}

// constantly updating the values enables the possibility to modify interval time on the fly

e = dig1Button(5); // first digit
b = dig2Button(5); // second digit
n = dig3Button(5); // third digit, motor speed
p = dig4Button(5); // fourth digit, pause time
s = startButton(5); // start
r = resetButton(5); // reset (and stop)
t = timingSwitch(4); // time range
m = motorSwitch(3); // pause / continuous mode


// Multiplexing the led display

   showdigit(e);
   digitalWrite(11, HIGH);
   delay(1); // 1 ms delay absolute maximum without resistors
   digitalWrite(11, LOW);
   showdigit(b);
   digitalWrite(10, HIGH);
   delay(1); // 1 ms delay absolute maximum without resistors
   digitalWrite(10, LOW);
   
if (s == 1) {

// These statements control the interval times

if (t == 0) {
	interval = e*1000 + b*100; // turning the display values into milliseconds, max value being 9900 ms (9,9 seconds)
        pause = p*100;  // pause time, equivalent to exposure time
	divi = 10; // pulse length divider
	}
else if (t == 1) {
	interval = e*10000 + b*1000; // full seconds, values from 0 to 99 seconds accepted
        pause = p*1000;  // pause time, equivalent to exposure time
	divi = 20; // pulse length divider
	}

if (exposing == false) {
  
    // shut motor down if option chosen
    
    // enable optocoupler
    digitalWrite(CAMERA_PIN, HIGH);
    // set state 'high' for the pulse statement
    state = HIGH;
    time = millis();
    exposing = true; 
    counter++;  // counter, if LCD is in use
    }
  
  // The circuit needs to be closed for about 100 milliseconds so the camera has time to react
  // pulse length (how long the circuit is closed), example: interval 2 sec, time range 0,1-9,9s, length 2000 ms / 10 = 200 ms
  
else if ( millis() - time >= interval / divi && state == HIGH && exposing == true)
	{
  
	digitalWrite(CAMERA_PIN, LOW);
	state = LOW;

    }
        

	// sets the exposing flag to false when interval time has passed
   
else if ( millis() - time >= interval && exposing == true)
	{
	exposing = false; 
	}
	
}


}