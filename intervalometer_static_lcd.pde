// Intervalometer and dolly motor controller
// Olli-Pekka Heinisuo 2011
// Licensed under MIT license, see LICENSE.txt
// This is experimental version, change to master branch if you want normal version

// This version does not include any motor functionality, just plain, enchanced intervalometer! (for example star timelapses)
// BULB-mode required, this version was made very long exposures in mind: max interval 999 secs, max exposure time 999 secs 

// LCD library
#include <LiquidCrystal.h>
// These pins are not used by Adafruit motor shield if it's using only motor 1
LiquidCrystal lcd(10, 9, 5, 3, 2, 14);

// pin that will trigger the camera
#define CAMERA_PIN 13

// "exposing" or not, if false, sends pulse to the optocoupler which triggers the camera
bool exposing = false;

int c,s,t,r,e,b,m,p,n = 0;
int pause;
int counter = 0;
int interval;
int exposure;
int state;
int divi;
unsigned long time = 0;

void setup()

{

pinMode(13, OUTPUT);
pinMode(A5, INPUT); // pins for the buttons
pinMode(A4, INPUT);
pinMode(A3, INPUT);
pinMode(CAMERA_PIN, OUTPUT); // to the optocoupler

// set up the LCD's number of columns and rows:
lcd.begin(16, 2);

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

// interval time

int dig1Button(int pin) {
   
c=analogRead(pin);

if (c>160 && c<180)
  {
	delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
	++e;
  }
  if (e < 999) {
	return e;
  }
  else { 
	return e=0;
  }
  
}

// interval time

int dig2Button(int pin) {
  
c=analogRead(pin);

  if (c>180 && c<210)
  {
	delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
	--e;
  }
	if (e > 0) {
	return e;
  }
  else { 
	return e=0;
  }
}

// exposure time

int dig3Button(int pin) {
   
c=analogRead(pin);

if (c>330 && c<370)
  {
  delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
  ++n;
  }
  if (n < 999) { // can't show numbers bigger than 9
  return n;
  }
  else { // if value goes over 9, automatic reset will occur
  return n=0;
  }
  
}

// exposure time

int dig4Button(int pin) {
   
c=analogRead(pin);

if (c>240 && c<270)
  {
  delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
  --n;
  }
  if (n > 0) { // can't show numbers bigger than 9
  return n;
  }
  else { // if value goes over 9, automatic reset will occur
  return n=0;
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

/* select time range, default (0) is 0,0 - 9,9 seconds, (1) is 0-99 seconds

int timingSwitch(int pin) {
  
c=analogRead(pin);

if (c>450 && c < 550) {
  return t=1;
  }
  else if (c < 450 && c>300) {
  return t=0;
  }
  else if (c == 0) {
  return t=2;
  }
  else {
  return t=0;
  }
}

// switch for choosing motor behavior: if on, motor moves without pauses, if off motor pauses when pic is taken

int motorSwitch(int pin) {

c=analogRead(pin);

if (c>450 && c < 550) {
  return m=1;
  }
  else if (c < 450 && c>300) {
  return m=0;
  }
  else if (c == 0) {
  return m=2;
  }
  else {
  return m=0;
  }
}

*/

// This is where the magic happens

void loop() {

// If the reset button is pressed -> pause + every variable returns to their default values
  
if (r == 1 ) {

digitalWrite(CAMERA_PIN, LOW);
s = 0;
r = 0;
b = 0;
e = 0;
p = 0;
n = 0;
counter = 0;
lcd.clear();
}

// constantly updating the values enables the possibility to modify interval time on the fly

e = dig1Button(5); // interval
n = dig3Button(5); // exposure
e = dig2Button(5); // interval
n = dig4Button(5); // exposure
s = startButton(5); // start
r = resetButton(5); // reset (and stop)

// These are for LCD-display, type 16x2

// Interval


lcd.setCursor(0, 0);
lcd.print("Int:");
lcd.setCursor(4, 0);
lcd.print(e);

// Exposure time

lcd.setCursor(8, 0);
lcd.print("Exp:");
lcd.setCursor(12, 0);
lcd.print(n);

// Picture counter

lcd.setCursor(9, 1);
lcd.print("No:");
lcd.setCursor(12, 1);
lcd.print(counter);

if (s == 1) {

interval = e*1000; // full seconds, values from 0 to 999 seconds accepted 
exposure = n*1000;

if (exposing == false) {
  
    // enable optocoupler
    digitalWrite(CAMERA_PIN, HIGH);
    // set state 'high' for the pulse statement
    state = HIGH;
    time = millis();
    exposing = true; 
    counter++;  // counter, if LCD is in use
    }
  
else if ( millis() - time >= exposure && state == HIGH && exposing == true)
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