#include <LED7Segment.h>

const int latchPin = 9; //Pin connected to ST_CP of 74HC595
const int clockPin = 12; //Pin connected to SH_CP of 74HC595
const int dataPin = 10; //Pin connected to DS of 74HC595

void setup() {
 pinMode(latchPin, OUTPUT);
 pinMode(clockPin, OUTPUT);
 pinMode(dataPin, OUTPUT);
}

void loop(){
 
 digitalWrite(latchPin, LOW);
 shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[3]);
 shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[4]);
 shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[1]);
 shiftOut(dataPin, clockPin, LSBFIRST, ledCharSet[2]);
 digitalWrite(latchPin, HIGH);
 
}