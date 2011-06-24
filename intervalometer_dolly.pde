// Intervalometer and dolly motor controller
// Olli-Pekka Heinisuo 2011
// Licensed under MIT license, see LICENSE.txt

// AFMotor library
#include <AFMotor.h>
// library for 7 segment displays using 74HC595 shift register
#include <LED7Segment.h>
// Function library for multiplexing one common anode 2 digit 7 segment display, uncomment if used
// #include <CAnodeMultiplexed.h>

// pin that will trigger the camera
#define CAMERA_PIN 13
// "exposing" or not, if false, sends pulse to the optocoupler which triggers the camera
bool exposing = false;
int c,s,t,r,e,b,m,n,p = 0;
int interval;
int state;
int divi;
unsigned long time = 0;

const int latchPin = 9; // connected to ST_CP of 74HC595
const int clockPin = 12; // connected to SH_CP of 74HC595
const int dataPin = 10; // connected to DS of 74HC595

AF_DCMotor motor(1, MOTOR12_64KHZ);

void setup()

{

// segments http://www.kingbrightusa.com/images/catalog/SPEC/DA04-11EWA.pdf
/* If 74HC595 is used, comment the lines

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

pinMode(A5, INPUT); // pin for the buttons
pinMode(A4, INPUT);
pinMode(A3, INPUT);
pinMode(CAMERA_PIN, OUTPUT); // to the optocoupler
pinMode(latchPin, OUTPUT);
pinMode(clockPin, OUTPUT);
pinMode(dataPin, OUTPUT);

motor.setSpeed(255); // motor speed 0-255

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
  return e=1;
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
  return b=1;
  }
}

// digit 3 value control

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
  return n=1;
  }
  
}

// digit 4 value control

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

int timingButton(int pin) {
  
c=analogRead(pin);

if (c>450 && c < 550) {
  return t=1;
  }
  else if (c < 450 && c>300) {
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
  return t=1;
  }
  else if (c < 450 && c>300) {
  return t=2;
  }
  else {
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
n = 0;

}

// constantly updating the values enables the possibility to modify interval time on the fly

e = dig1Button(5); // first digit
b = dig2Button(5); // second digit
n = dig3Button(5); // third digit
p = dig4Button(5); // fourth digit
s = startButton(5); // start
r = resetButton(5); // reset (and stop)
t = timingButton(4); // time range
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

digitalWrite(latchPin, LOW);
shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[n]); // motor speed
shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[p]); // pause time
shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[e]); // time, first digit
shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[b]); // time, second digit
digitalWrite(latchPin, HIGH);
   
// if start button is set to 1 (pressed once), the intervalometer will start

if (s == 1) {

if (m == 1) {
motor.run(FORWARD); // starts the dolly movement when in continuous movement mode
}

// These statements control the interval times

if (t == 0) {
	interval = e*1000 + b*100; // turning the display values into milliseconds, max value being 9900 ms (9,9 seconds)
	divi = 10; // pulse length divider
	}
else if (t == 1) {
	interval = e*10000 + b*1000; // full seconds, values from 0 to 99 seconds accepted
	divi = 20; // pulse length divider
	}

if (exposing == false) {
  
    // shut motor down if option chosen
    
    if (m == 0) {
    motor.run(RELEASE); // stops the dolly movement
    }
    
    // enable optocoupler
    digitalWrite(CAMERA_PIN, HIGH);
    // set state 'high' for the pulse statement
    state = HIGH;
    time = millis();
    exposing = true; 
    
    }
  
  // The circuit needs to be closed for about 100 milliseconds so the camera has time to react
  // pulse length (how long the circuit is closed), example: interval 2 sec, time range 0,1-9,9s, length 2000 ms / 10 = 200 ms
  
else if ( millis() - time >= interval / divi && state == HIGH && exposing == true)
	{
  
	digitalWrite(CAMERA_PIN, LOW);
	state = LOW;
        
	if (m == 0) {
	motor.run(FORWARD); 
	}

        }
else if ( millis() - time >= interval && exposing == true)
	{
	exposing = false; 
	}
}

}