// digits for the LED display, if a common cathode display is used I suppose the code needs some changes
// use this only if you're not going to use daisy chained 74HC595's
// there's no resistors used, because I believe the leds will withstand the current because of multiplexing which also decreases the brightness for about 50%

// These pins are for an common anode 2-digit 7 segment display in multiplexing mode (9 pins, 7 cathodes and 2 common anodes)

int pin1 = 2;
int pin2 = 3;
int pin3 = 14;
int pin4 = 15;
int pin5 = 16;
int pin6 = 17;
int pin7 = 18;

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