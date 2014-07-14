/*--------------------------------------------------------------------
  SS-meter, processing 1.51 sketch

  averages the volume from a microphone
  [using FFT to get more value for wide-spectrum sound (noise, claps)]
  sends GRB data to serial.
  
  arrow keys to ajust factors of sensivity & decline
  
  scetch was a purpose to just get thing working, dull & dirty,
  based on standart Minin example "Forward FFT" by Damien Di Fede.

  aleksey.grishchenko@gmail.com
  --------------------------------------------------------------------*/

import processing.serial.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioInput   in;
FFT         fft;

int N = 102;
Serial port;  // Create object from Serial class
byte[] line;

int volume = 0;

float mult = 3;
int multDown = 800000;

void setup() {
  size(512, 200);

  String portName = "COM6";//Serial.list()[0];
  port = new Serial(this, portName, 57600);
  
  line = new byte[N*3];
  
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 1024, 11025, 16);
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  
}

void draw() {
  background(0);
  stroke(255);
  
  // perform a forward FFT on the samples in jingle's mix buffer,
  // which contains the mix of both the left and right channels of the file
  fft.forward( in.left );
  
  int aver = 1;
  
  for(int i = 0; i < fft.specSize(); i++)  {
    // draw the line for frequency band i, scaling it up a bit so we can see it
    line( i, height, i, height - fft.getBand(i)*8 );
    
    aver += fft.getBand(i)*i;
  }
  
  //aver /= fft.specSize();
  //println(aver);
  volume += aver*mult;  
  
  setVol( (int)map(sqrt(volume), 0, 5000, 0, 102) );
  
  if(volume>0) volume -= abs(multDown-aver);
  
  //text( "vol: " + volume, 10, 10);
  
}

void setVol(int v) {
  port.write("FRAME");

  for(int i=0; i<N*3; i+=3) {
    if(i<v) {
      line[i] =   (byte)0x00;//G
      line[i+1] = (byte)0xFF;//R
      line[i+2] = (byte)0x00;//B
    } else {
      line[i] =   (byte)0xFF;//G
      line[i+1] = (byte)0x00;//R
      line[i+2] = (byte)0x00;//B
    }
    
  }
  
  port.write(line);
  
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      mult += 0.5;
      println("mult: " + mult);
    } else if (keyCode == DOWN && mult>=0.5) {
      mult -= 0.5;
      println("mult: " + mult);
    } else if (keyCode == LEFT) {
      multDown += 8000;
      println("multDown: " + multDown);
    } else if (keyCode == RIGHT && multDown >= 8000
    ) {
      multDown -= 8000;
      println("multDown: " + multDown);
    } 
  } else {
    if(key == ' ')
      volume = 0;
  }
}
