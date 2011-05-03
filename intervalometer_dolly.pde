// Intervalometer and dolly motor controller

// pin that will trigger the camera
#define CAMERA_PIN 13
// "exposing" or not, if false, sends pulse to the optocoupler which triggers the camera
bool exposing = false;
int c,s,t,r,e,b = 0;
int interval;
unsigned long time = 0;

// These pins are for an common anode 2-digit 7 segment display in multiplexing mode (9 pins, 7 cathodes and 2 common anodes)

int pin1 = 2;
int pin2 = 3;
int pin3 = 14;
int pin4 = 15;
int pin5 = 16;
int pin6 = 17;
int pin7 = 18;

void setup()

{

pinMode(10, OUTPUT);  // common anode digit 2
pinMode(11, OUTPUT);  // common anode digit 1

// segments http://www.kingbrightusa.com/images/catalog/SPEC/DA04-11EWA.pdf

pinMode(2, OUTPUT);   // segment A
pinMode(3, OUTPUT);   // segment F
pinMode(14, OUTPUT);  // segment B
pinMode(15, OUTPUT);  // segment G
pinMode(16, OUTPUT);  // segment C
pinMode(17, OUTPUT);  // segment E
pinMode(18, OUTPUT);  // segment D

pinMode(A5, INPUT);   // pin for the buttons
pinMode(CAMERA_PIN, OUTPUT);  // to the optocoupler

}

// digits for the LED display, if a common cathode display is used I suppose the code needs some changes
// there's no resistors used, because I believe the leds will withstand the current because of multiplexing which also decreases the brightness for about 50%

void digit0 () {

digitalWrite(pin1, LOW);
digitalWrite(pin2, LOW);
digitalWrite(pin3, LOW);
digitalWrite(pin4, HIGH);
digitalWrite(pin5, LOW);
digitalWrite(pin6, LOW);
digitalWrite(pin7, LOW);

};

void digit1 () {

digitalWrite(pin1, HIGH);
digitalWrite(pin2, HIGH);
digitalWrite(pin3, LOW);
digitalWrite(pin4, HIGH);
digitalWrite(pin5, LOW);
digitalWrite(pin6, HIGH);
digitalWrite(pin7, HIGH);

};

void digit2 () {

digitalWrite(pin1, LOW);
digitalWrite(pin2, HIGH);
digitalWrite(pin3, LOW);
digitalWrite(pin4, LOW);
digitalWrite(pin5, HIGH);
digitalWrite(pin6, LOW);
digitalWrite(pin7, LOW);

};

void digit3 () {

digitalWrite(pin1, LOW);
digitalWrite(pin2, HIGH);
digitalWrite(pin3, LOW);
digitalWrite(pin4, LOW);
digitalWrite(pin5, LOW);
digitalWrite(pin6, HIGH);
digitalWrite(pin7, LOW);

};

void digit4 () {

digitalWrite(pin1, HIGH);
digitalWrite(pin2, LOW);
digitalWrite(pin3, LOW);
digitalWrite(pin4, LOW);
digitalWrite(pin5, LOW);
digitalWrite(pin6, HIGH);
digitalWrite(pin7, HIGH);

};

void digit5 () {

digitalWrite(pin1, LOW);
digitalWrite(pin2, LOW);
digitalWrite(pin3, HIGH);
digitalWrite(pin4, LOW);
digitalWrite(pin5, LOW);
digitalWrite(pin6, HIGH);
digitalWrite(pin7, LOW);

};

void digit6 () {

digitalWrite(pin1, LOW);
digitalWrite(pin2, LOW);
digitalWrite(pin3, HIGH);
digitalWrite(pin4, LOW);
digitalWrite(pin5, LOW);
digitalWrite(pin6, LOW);
digitalWrite(pin7, LOW);

};

void digit7 () {

digitalWrite(pin1, LOW);
digitalWrite(pin2, HIGH);
digitalWrite(pin3, LOW);
digitalWrite(pin4, HIGH);
digitalWrite(pin5, LOW);
digitalWrite(pin6, HIGH);
digitalWrite(pin7, HIGH);

};

void digit8 () {

digitalWrite(pin1, LOW);
digitalWrite(pin2, LOW);
digitalWrite(pin3, LOW);
digitalWrite(pin4, LOW);
digitalWrite(pin5, LOW);
digitalWrite(pin6, LOW);
digitalWrite(pin7, LOW);

};

void digit9 () {

digitalWrite(pin1, LOW);
digitalWrite(pin2, LOW);
digitalWrite(pin3, LOW);
digitalWrite(pin4, LOW);
digitalWrite(pin5, LOW);
digitalWrite(pin6, HIGH);
digitalWrite(pin7, LOW);

};

// function for showing digits

void showdigit (int digit)

{

switch (digit) {

case 0:
digit0 ();
break;

case 1:
digit1 ();
break;

case 2:
digit2 ();
break;

case 3:
digit3 ();
break;

case 4:
digit4 ();
break;

case 5:
digit5 ();
break;

case 6:
digit6 ();
break;

case 7:
digit7 ();
break;

case 8:
digit8 ();
break;

case 9:
digit9 ();
break;

default:
break;

};

}

// These functions return a value when the corresponding button is pressed
// 2,2 kohm resistors were used between 5 buttons
// More info: http://tronixstuff.wordpress.com/2011/01/11/tutorial-using-analog-input-for-multiple-buttons/

// Reset

int resetButton(int pin) {
  
c=analogRead(pin);

if (c<180 && c>100)
  {
  r = 1; // reset button
  }
return r;
}

// digit 2 value control

int dig2Button(int pin) {
  
c=analogRead(pin);

  if (c>500)
  {
  delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
  b++; // this is the second digit button
  }
  if (b < 10) { // can't show numbers bigger than 9
  return b;
  }
  else { // if value goes over 9, automatic reset will occur
  r=1;
  }
}

// digit 1 value control

int dig1Button(int pin) {
   
c=analogRead(pin);

if (c>190 && c<220)
  {
  delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
  e++; // this is the first digit button
  }
  if (e < 10) { // can't show numbers bigger than 9
  return e;
  }
  else { // if value goes over 9, automatic reset will occur
  r=1;
  }
  
}

// Start & stop

int startButton(int pin) {
  
c=analogRead(pin);

if (c>330 && c<350) {
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

if (c>240 && c<270) {
  delay(250); // if not set, value will increment as long as the button was pressed and we don't want that to happen (about 100-200 ms)
  t++;
  }
  if (t <= 1) { 
  return t;
  }
  else if (t > 1) {
  return t=0;
  }
}


// This is where the magic happens

void loop() {

// If the reset button is pressed -> pause + every variable returns to their default values
  
if (r == 1 ) {

t = 0;
s = 0;
r = 0;
b = 0;
e = 0;

}

// constantly updating the values enables the possibility to modify interval time on the fly

b = dig2Button(5); // second digit
e = dig1Button(5); // first digit
s = startButton(5);  // start
t = timingButton(5); // time range
r = resetButton(5); // reset (and stop)

// Multiplexing the led display

   showdigit(e);
   digitalWrite(11, HIGH);
   delay(0.1);
   digitalWrite(11, LOW);
   showdigit(b);
   digitalWrite(10, HIGH);
   delay(0.1);
   digitalWrite(10, LOW);
   
// if start button is set to 1 (pressed once), the intervalometer will start

if (s == 1) {

// These statements control the interval times

if (t == 0) {
interval = e*1000 + b*100;  // turning the display values into milliseconds, max value being 9900 ms (9,9 seconds)
}
else if (t == 1) {
interval = e*10000 + b*1000; // full seconds, values from 0 to 99 seconds accepted
}

  if(exposing == false) {
    // enable optocoupler
    digitalWrite(CAMERA_PIN, HIGH);
    // delay(50); for debugging purposes only
    digitalWrite(CAMERA_PIN, LOW);
    time  = millis();
    exposing = true;
  } 
  else if ( millis() - time > interval && exposing == true) 
  {
   exposing = false;
  }
}
}