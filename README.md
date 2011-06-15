Arduino intervalometer / time-lapse dolly v. 0.2
================================================

This is an Arduino based project. The goal is to create simple yet usable intervalometer and motor controlled dolly.

### Current status

- I have soldered the intervalometer parts into a pcb breadboard, works just fine
- I'm currently engineering the dolly and waiting some parts to ship from USA

### Hardware

- Arduino Uno
- Adafruit motor shield (only if dolly is used)
- some kind of prototyping circuit board or a breadboard
- 7 segment 2-digit LED display (common cathode or anode, I recommend common cathode)

### Dolly materials

- wood (any wood should work fine)
- shafts
- gears and gear racks
- 1 rpm motor
- bearings
- other small stuff...

I bought some of the stuff from http://servocity.com/

### Components

- at least 5 pushbuttons
- 1-2 switches
- 6 x 2,2 kohm resistors (for 5 buttons, system works with other resistors too but code needs to be changed)
- 1 x 500-600 ohm resistor
- 1 x 4N35 optocoupler (I suppose 4N25 etc. will work fine too)
- optionally 74HC595N shift register(s) for LED display(s) to free pins
- wire to connect in camera, most of the cameras use 2,5mm
- wire

### Tools

- soldering equipment

### Videos

- First intervalometer prototype running version 0.1 code: http://www.youtube.com/watch?v=Y-RKiF_JtFg
- Second prototype on PCB: http://www.youtube.com/watch?v=gI8r_mp4LpY

License: MIT License, see http://github.com/skvark/Arduino-intervalometer---time-lapse-dolly/blob/master/LICENSE.txt     
author: Olli-Pekka Heinisuo    
www: http://unknownpixels.com     
email: o-p@unknownpixels.com    