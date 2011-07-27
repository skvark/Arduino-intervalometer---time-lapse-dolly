// Intervalometer and dolly motor controller
// Olli-Pekka Heinisuo 2011
// Licensed under MIT license, see LICENSE.txt

// AFMotor library
#include <AFMotor.h>
// library for 7 segment displays using 74HC595 shift register
// #include <LED7Segment.h>
// Function library for multiplexing one common anode 2 digit 7 segment display, uncomment if used
// #include <CAnodeMultiplexed.h>
// LCD library
#include <LiquidCrystal.h>
// These pins are not used by Adafruit motor shield if it's using only motor 1
LiquidCrystal lcd(10, 9, 5, 3, 2, 14);

// pin that will trigger the camera
#define CAMERA_PIN 13

// "exposing" or not, if false, sends pulse to the optocoupler which triggers the camera
bool exposing = false;

// motor speed, increments by 20
// no "zero" speed, because it can cause DC gearmotor to stall 
// -> max current passes trough it, if no fuse is used the motor can suffer damage
int speed[] = {75, 95, 115, 135, 155, 175, 195, 215, 235, 255};

int c,s,t,r,e,b,m,p = 0;
int n = 9;
int pause;
int counter = 0;
int interval;
int state;
int divi;
unsigned long time = 0;
int mot;

/* These are for shift registers if used
const int latchPin = 9; // connected to ST_CP of 74HC595
const int clockPin = 12; // connected to SH_CP of 74HC595
const int dataPin = 10; // connected to DS of 74HC595
*/

AF_DCMotor motor(1, MOTOR12_64KHZ);

void setup()

{

// segments http://www.kingbrightusa.com/images/catalog/SPEC/DA04-11EWA.pdf
/* Common anode 7 segment display multiplexing pins

pinMode(9, OUTPUT); // common anode digit 2
pinMode(10, OUTPUT); // common anode digit 1

pinMode(2, OUTPUT); // segment A
pinMode(3, OUTPUT); // segment F
pinMode(14, OUTPUT); // segment B
pinMode(15, OUTPUT); // segment G
pinMode(16, OUTPUT); // segment C
pinMode(17, OUTPUT); // segment E
pinMode(18, OUTPUT); // segment D

*/

pinMode(13, OUTPUT);
pinMode(A5, INPUT); // pins for the buttons
pinMode(A4, INPUT);
pinMode(A3, INPUT);
pinMode(CAMERA_PIN, OUTPUT); // to the optocoupler

/* For shift registers
pinMode(latchPin, OUTPUT);
pinMode(clockPin, OUTPUT);
pinMode(dataPin, OUTPUT);
*/

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
lcd.clear();
motor.run(RELEASE);
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
/* if 74HC595's are used, comment these lines

   showdigit(e);
   digitalWrite(11, HIGH);
   delay(1); // 1 ms delay absolute maximum without resistors
   digitalWrite(11, LOW);
   showdigit(b);
   digitalWrite(10, HIGH);
   delay(1); // 1 ms delay absolute maximum without resistors
   digitalWrite(10, LOW);
   
*/

// The shiftout for the 74HC595's and displays
/*
digitalWrite(latchPin, LOW);
shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[4]); // motor speed
shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[4]); // pause time
shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[4]); // time, first digit
shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[4]); // time, second digit
digitalWrite(latchPin, HIGH);
*/

// These are for LCD-display, type 16x2

// Interval

if (t == 0) {
lcd.setCursor(0, 0);
lcd.print("Int:");
lcd.setCursor(4, 0);
lcd.print(e);
lcd.setCursor(5, 0);
lcd.print(",");
lcd.setCursor(6, 0);
lcd.print(b);
}
else if ( t == 1) {
lcd.setCursor(0, 0);
lcd.print("Int:");
lcd.setCursor(4, 0);
lcd.print(e);
lcd.setCursor(5, 0);
lcd.print(b);
lcd.setCursor(6, 0);
lcd.print("s");
}

// Time range

lcd.setCursor(8, 0);
lcd.print("R:");
lcd.setCursor(10, 0);
if (t == 0) {
lcd.print("n");  // normal
}
else if (t == 1) {
lcd.print("e");  // extended
}

// Motor speed

lcd.setCursor(12, 0);
lcd.print("Ms:");
lcd.setCursor(15, 0);
lcd.print(n);

// Pause time if pause mode on

lcd.setCursor(0, 1);
lcd.print("Pt:");
lcd.setCursor(3, 1);
lcd.print(p);

// Mode

lcd.setCursor(5, 1);
lcd.print("M:");
lcd.setCursor(7, 1);
if (m == 0) {
lcd.print("p");  // pause
}
else if (m == 1) {
lcd.print("c");  // continuous
}

// Picture counter

lcd.setCursor(9, 1);
lcd.print("No:");
lcd.setCursor(12, 1);
lcd.print(counter);

// Set the motor speed, 0 slowest and 9 fastest
// depends on motor type and supplied voltage

motor.setSpeed(speed[n]);

if (s == 1) {

if (m == 1) {
motor.run(FORWARD); // starts the dolly movement when in continuous movement mode
}

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
    
    if (m == 0 && mot == 1) {
    motor.run(RELEASE); // stops the dolly movement
    mot = 0;
    }
    
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
        
	// pause time ends, starts the dolly movement again (if mode in use)

else if ( millis() - time >= pause && exposing == true && mot == 0)
	{
        
	motor.run(FORWARD);
	mot = 1;

	}

	// sets the exposing flag to false when interval time has passed
   
else if ( millis() - time >= interval && exposing == true)
	{
	exposing = false; 
	}
	
}

// force motor shutdown to prevent any damage

else {
	 motor.run(RELEASE);
	 }

}