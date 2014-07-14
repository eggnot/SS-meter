/*--------------------------------------------------------------------
  SS-meter, arduino sketch
  
  stream data from serial to ws2812 (aka NeoPixels)
  you should care about bytes order (GRB or RGB) on the host
  
  this scketch is usinig modified version of "Adafruit NeoPixel library"
  the only modification is the scope of *pixels
  it should be in "public" scope, not in "private" ("Adafruit_NeoPixel.h")
  
  aleksey.grishchenko@gmail.com
  --------------------------------------------------------------------*/

#include <Adafruit_NeoPixel.h>

#define PIN 6
#define N 102

// Parameter 1 = number of pixels in strip
// Parameter 2 = pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(N, PIN, NEO_GRB + NEO_KHZ800);

void setup() {
  Serial.begin(57600);
  
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
}

void loop() {
  
  if(Serial.available()>0 && Serial.find("FRAME")) {
     Serial.readBytes((char*)strip.pixels, N*3);
     strip.show();
  }
  
}
