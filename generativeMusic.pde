import de.voidplus.leapmotion.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.midi.*;

LeapMotion leap;

Minim       minim;
AudioInput in;
FFT fft;
//BeatDetect beat;

AudioPlayer playerc;
AudioPlayer playerd;
AudioPlayer playere;
AudioPlayer playerf;
AudioPlayer playerg;
AudioPlayer playera;
AudioPlayer playerb;

AudioOutput out;

Synthesizer   synth;
MidiChannel[] channels;

int scene = 0;

float x, y;
float G=0.8;
color bg= #333333;
float d;
float xv;
float yv;
float l;

float almaBX;
float almaBY;
float almaJX;
float almaJY;

PImage scene1;
PImage intro;

boolean scenecon;
boolean eses;
boolean notetrigger;
boolean bgtrigger;
boolean bg1trigger;
boolean bg2trigger;
boolean bg3trigger;
boolean bg4trigger;
boolean bg5trigger;
boolean bg6trigger;
PImage almaB;
PImage almaJ;
float vBX;
float vJX;
float vBY;
float vJY;

PVector []pos = new PVector[20];
int     id;
float grab;

int PIANO = 0;
float v = 100;

float   durationSeconds;

class MidiSynth implements ddf.minim.ugens.Instrument
{
  int         channel;
  int         noteNumber;
  int         noteVelocity;


  MidiSynth( int channelIndex, String noteName, float vel )
  {
    channel = channelIndex;
    noteNumber = (int)Frequency.ofPitch(noteName).asMidiNote();
    noteVelocity = 1 + int(126*vel);
  }

  void noteOn( float dur )
  {
    channels[channel].noteOn( noteNumber, noteVelocity );
  }

  void noteOff()
  {
    channels[channel].noteOff( noteNumber );
  }
}

void note( float time, float duration, int channelIndex, String noteName, float velocity )
{
  out.playNote( time, duration, new MidiSynth( channelIndex, noteName, velocity ) );
}

void setup() {
  fullScreen(P3D);
  smooth();
  leap = new LeapMotion(this).allowGestures();

  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 512);
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  out   = minim.getLineOut();

  l=100;
  vBX=-5;
  vJX=5;
  newCircle();
  scenecon=false;
  eses=false;
  notetrigger=false;
  bgtrigger=false;
  bg1trigger=false;

  scene1 = loadImage("scene1bg.png");
  intro = loadImage("intro.png");

  for (int i = 0; i<10; i++) {
    pos[i] = new PVector (0, 0, 0);
  }

  try
  {
    synth = MidiSystem.getSynthesizer();
    synth.open();
    channels = synth.getChannels();
    channels[PIANO].programChange( 5 );
    out.setTempo( 120 );
    out.pauseNotes();
  }
  catch( MidiUnavailableException ex )
  {
    println( "No default synthesizer, sorry bud." );
  }
  out.resumeNotes();
}

void newCircle() {
  x=width/2;
  y=height/2;
  yv=random(-20, 0);
  xv=random(-10, 10);
  d= random(50, 100);
  vBY=0;
  vJY=0;
}

void leapOnScreenTapGesture(ScreenTapGesture g) {
  durationSeconds  = g.getDurationInSeconds();
}


void draw() {
  //switch scenes
  if (!scenecon && grab == 1) {
    scene++;
    scenecon = true;
    println(scene);
    if (scene > 7) {
      scene = 1;
    }
  } else if (scenecon == true && grab<1) {
    scenecon = false;
  }
  //screenshot
  if (frameCount % 60 == 0){
  if(durationSeconds>0.1){
    noFill();
    stroke(#ffffff);
    strokeWeight(20);
    rect(0,0,width,height);
    saveFrame(); 
  }
  }
  
  if (scene == 0) {
    image(intro, 0, 0);
    for (Hand hand : leap.getHands ()) {
      grab = hand.getGrabStrength();
    }
  }

  if (scene == 1) {

    background(#FAEEEE);
    //visualization
    fft.forward( in.mix );
    for (int a = 0; a <= width/2; a+=40) {
      noStroke();
      fill(#F3B7B7);
      ellipse(width/2, a+height/2, (fft.getBand(a)+1)*100,40) ;
      ellipse(width/2, height/2-a, (fft.getBand(a)+1)*100,40);
      fill(#F54746);
      ellipse(a, 0, 20, (fft.getBand(a)+1)*100);
      ellipse(width-a+20, 0, 20, (fft.getBand(a)+1)*100);
      ellipse(a, height, 20, (fft.getBand(a)+1)*100);
      ellipse(width-a-20, height, 20, (fft.getBand(a)+1)*100);
      fill(#F47270);
      ellipse(width-a, 0, 20, (fft.getBand(a)+1)*100);
      ellipse(a+20, 0, 20, (fft.getBand(a)+1)*100);
      ellipse(a-20, height, 20, (fft.getBand(a)+1)*100);
      ellipse(width-a, height, 20, (fft.getBand(a)+1)*100);
      
    }

    if (!bgtrigger) {
      playerc = minim.loadFile("c.mp3");
      playerc.loop();
      bgtrigger = true;
    }

    for (Hand hand : leap.getHands ()) {
      grab = hand.getGrabStrength();

      for (int i = 9; i > 0; i--) {
        stroke(#F47270, 40+i*10);
        strokeWeight(20);
        line(pos[i].x, pos[i].y, pos[i-1].x, pos[i-1].y);
        pos[i]=pos[i-1];
      }

      pos[0] = hand.getPosition();

      fill(#F47270);
      noStroke();
      ellipse(pos[0].x, pos[0].y, 25, 25);

      if (eses) {
        ellipse(almaBX, almaBY, d, d);
        ellipse(almaJX, almaJY, d, d);
        almaBX+=vBX;
        almaJX+=vJX;
        almaBY+=vBY;
        almaJY+=vJY;
        vBY+=G;
        vJY+=G;
        if (!notetrigger) {
          int b = int (random(0, 3));
          if (b==0) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 0.5, PIANO, "C4", v );
              note( 0, 0.5, PIANO, "E4", v );
              note( 0, 0.5, PIANO, "G4", v );
            } else {
              note( 0, 0.5, PIANO, "C4", v );
              note( 0.5, 0.5, PIANO, "E4", v );
              note( 1, 0.5, PIANO, "G4", v );
            }
          } else if (b==1) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 0.5, PIANO, "E4", v );
              note( 0, 0.5, PIANO, "G4", v );
              note( 0, 0.5, PIANO, "B4", v );
            } else {
              note( 0, 0.5, PIANO, "E4", v );
              note( 0.5, 0.5, PIANO, "G4", v );
              note( 1, 0.5, PIANO, "B4", v );
            }
          } else if (b==2) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 0.5, PIANO, "G4", v );
              note( 0, 0.5, PIANO, "B4", v );
              note( 0, 0.5, PIANO, "D5", v );
            } else {
              note( 0, 0.5, PIANO, "G4", v );
              note( 0.5, 0.5, PIANO, "B4", v );
              note( 1, 0.5, PIANO, "D5", v );
            }
          }
          notetrigger=true;
        }
        if (almaBY>height+d) {
          eses=false;
          newCircle();
        }
      } else {
        notetrigger=false;
        ellipse(x, y, d, d);
        y=y+yv;
        x=x+xv;
        yv=yv+G;
        if (y>height+200) {
          newCircle();
        }

        if (dist(x, y, pos[0].x, pos[0].y)<d/2) {
          eses=true;
          almaBX=x-d/2;
          almaBY=y;
          almaJX=x+d/2;
          almaJY=y;
          vBY=0;
          vJY=0;
        }
      }
    }
  }



  if (scene == 2) {
    if (!bg1trigger) {
      playerc.pause();
      playerd = minim.loadFile("d.mp3");
      playerd.loop();
      bg1trigger = true;
      
    }

    //visualization
    image(scene1, 0, 0);
    fft.forward( in.mix );
    stroke(#FF9E45);
    strokeWeight(2);
    pushMatrix();
    translate(width/2, height/2);

    float albumTheta = 0.0;
    rotate(albumTheta);
    for (int i=0; i<in.mix.size(); i+=6) {
      float rTheta = map(i, 0, fft.getBand(i)-1, 0, 2*PI);
      rotate(rTheta);
      line(0, 50, 0, 50 + fft.getBand(i)*100);
    }
    albumTheta += 0.02;
    popMatrix();


    for (Hand hand : leap.getHands ()) {
      grab = hand.getGrabStrength();

      for (int i = 9; i > 0; i--) {
        stroke(#FF9E45, 40+i*10);
        strokeWeight(20);
        line(pos[i].x, pos[i].y, pos[i-1].x, pos[i-1].y);
        pos[i]=pos[i-1];
      }

      pos[0] = hand.getPosition();

      fill(#FF9E45);
      noStroke();
      ellipse(pos[0].x, pos[0].y, 25, 25);

      fill(#FF9E45);
      if (eses) {
        ellipse(almaBX, almaBY, d, d);
        ellipse(almaJX, almaJY, d, d);
        almaBX+=vBX;
        almaJX+=vJX;
        almaBY+=vBY;
        almaJY+=vJY;
        vBY+=G;
        vJY+=G;
        if (!notetrigger) {
          int b = int (random(0, 3));
          if (b==0) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 1, PIANO, "D4", v );
              note( 0, 1, PIANO, "F4", v );
              note( 0, 1, PIANO, "A4", v );
            } else {
              note( 0, 1, PIANO, "D4", v );
              note( 1, 1, PIANO, "F4", v );
              note( 2, 1, PIANO, "A4", v );
            }
          } else if (b==1) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 1, PIANO, "F4", v );
              note( 0, 1, PIANO, "A4", v );
              note( 0, 1, PIANO, "C5", v );
            } else {
              note( 0, 1, PIANO, "C5", v );
              note( 1, 1, PIANO, "A4", v );
              note( 2, 1, PIANO, "F4", v );
            }
          } else if (b==2) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 1, PIANO, "A4", v );
              note( 0, 1, PIANO, "C5", v );
              note( 0, 1, PIANO, "E5", v );
            } else {
              note( 0, 1, PIANO, "A4", v );
              note( 1, 1, PIANO, "E5", v );
              note( 2, 1, PIANO, "C5", v );
            }
          }
          notetrigger=true;
        }
        if (almaBY>height+d) {
          eses=false;
          newCircle();
        }
      } else {
        notetrigger=false;
        ellipse(x, y, d, d);
        y=y+yv;
        x=x+xv;
        yv=yv+G;
        if (y>height+200) {
          newCircle();
        }

        if (dist(x, y, pos[0].x, pos[0].y)<d/2) {
          eses=true;
          almaBX=x-d/2;
          almaBY=y;
          almaJX=x+d/2;
          almaJY=y;
          vBY=0;
          vJY=0;
        }
      }
    }
  }
  if (scene == 3) {
    if (!bg2trigger) {
      playerd.pause();
      playere = minim.loadFile("e.mp3");
      playere.loop();
      bg2trigger = true;
    }
    background(#FFFCEE);
    //visualization
    fft.forward( in.mix );
    //int d=0;
    //d++;
    for (int d = 0; d<width; d++) {
      noStroke();
      fill(#FFE55B, 80);
      ellipse(width/2, height/2, (fft.getBand(d)+2)* 5, (fft.getBand(d)+2)* 5);
      fill(#FFE55B, 60);
      ellipse(width/2, height/2, (fft.getBand(d)+2)* 10, (fft.getBand(d)+2)* 10);
      fill(#FFE55B, 40);
      ellipse(width/2, height/2, (fft.getBand(d)+2)* 20, (fft.getBand(d)+2)* 20);
    }
    for (Hand hand : leap.getHands ()) {
      grab = hand.getGrabStrength();

      for (int i = 9; i > 0; i--) {
        stroke(#FFE55B, 40+i*10);
        strokeWeight(20);
        line(pos[i].x, pos[i].y, pos[i-1].x, pos[i-1].y);
        pos[i]=pos[i-1];
      }

      pos[0] = hand.getPosition();

      fill(#FFF5C0);
      stroke(#FFE55B);
      strokeWeight(2);
      ellipse(pos[0].x, pos[0].y, 25, 25);

      fill(#FFF5C0);
      if (eses) {
        ellipse(almaBX, almaBY, d, d);
        ellipse(almaJX, almaJY, d, d);
        almaBX+=vBX;
        almaJX+=vJX;
        almaBY+=vBY;
        almaJY+=vJY;
        vBY+=G;
        vJY+=G;
        if (!notetrigger) {
          int b = int (random(0, 3));
          if (b==0) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 1, PIANO, "E4", v );
              note( 0, 1, PIANO, "G4", v );
              note( 0, 1, PIANO, "B4", v );
            } else {
              note( 0, 1, PIANO, "E4", v );
              note( 1, 1, PIANO, "G4", v );
              note( 2, 1, PIANO, "B4", v );
            }
          } else if (b==1) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 1, PIANO, "G4", v );
              note( 0, 1, PIANO, "B4", v );
              note( 0, 1, PIANO, "D5", v );
            } else {
              note( 0, 1, PIANO, "B4", v );
              note( 1, 1, PIANO, "D5", v );
              note( 2, 1, PIANO, "G4", v );
            }
          } else if (b==2) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 1, PIANO, "B4", v );
              note( 0, 1, PIANO, "D5", v );
              note( 0, 1, PIANO, "F5", v );
            } else {
              note( 0, 1, PIANO, "F5", v );
              note( 1, 1, PIANO, "B4", v );
              note( 2, 1, PIANO, "D4", v );
            }
          }
          notetrigger=true;
        }
        if (almaBY>height+d) {
          eses=false;
          newCircle();
        }
      } else {
        notetrigger=false;
        ellipse(x, y, d, d);
        y=y+yv;
        x=x+xv;
        yv=yv+G;
        if (y>height+200) {
          newCircle();
        }

        if (dist(x, y, pos[0].x, pos[0].y)<d/2) {
          eses=true;
          almaBX=x-d/2;
          almaBY=y;
          almaJX=x+d/2;
          almaJY=y;
          vBY=0;
          vJY=0;
        }
      }
    }
  }
  if (scene == 4) {
    if (!bg3trigger) {
      playere.pause();
      playerf = minim.loadFile("f.mp3");
      playerf.loop();
      bg3trigger = true;
    }
    //visualization
    fft.forward( in.mix );
    float circleRadius = 250;
    float circleCenterX;
    float circleCenterY;
    int innerCircleNums = 32;
    int circleNums = 60;
    float targetR = 250;

    background(#ECFFF5);
    circleRadius = lerp(circleRadius, targetR, 0.05);
    if (circleRadius > 0) fill(255, 255, 0, 200);
    else fill(255, 0, 255, 200);
    noStroke();
    for (int i = 0; i < innerCircleNums; i ++)
    {
      float angle = 2* PI / innerCircleNums * i;
      float sinValue = sin(fft.getBand(i));
      float rPlus = sinValue * 150 - 50;
      circleCenterX = width/2 + cos(angle) * (circleRadius + rPlus);
      circleCenterY = height/2 + sin(angle) * (circleRadius + rPlus);
      fill(255/circleNums * i, 255 - 150/innerCircleNums * i, 200, 255);
      noStroke();
      circle(circleCenterX, circleCenterY, abs(20*rPlus/130));
      fill(250, 220, 150, 255);
    }

    for (Hand hand : leap.getHands ()) {
      grab = hand.getGrabStrength();

      for (int i = 9; i > 0; i--) {
        stroke(#ffffff, 40+i*10);
        strokeWeight(20);
        line(pos[i].x, pos[i].y, pos[i-1].x, pos[i-1].y);
        pos[i]=pos[i-1];
      }

      pos[0] = hand.getPosition();

      fill(#ffffff);
      noStroke();
      ellipse(pos[0].x, pos[0].y, 25, 25);

      fill(#ffffff);
      if (eses) {
        ellipse(almaBX, almaBY, d, d);
        ellipse(almaJX, almaJY, d, d);
        almaBX+=vBX;
        almaJX+=vJX;
        almaBY+=vBY;
        almaJY+=vJY;
        vBY+=G;
        vJY+=G;
        if (!notetrigger) {
          int b = int (random(0, 3));
          if (b==0) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 0.5, PIANO, "F4", v );
              note( 0, 0.5, PIANO, "A4", v );
              note( 0, 0.5, PIANO, "C5", v );
            } else {
              note( 0, 0.5, PIANO, "A4", v );
              note( 0.5, 0.5, PIANO, "C5", v );
              note( 1, 0.5, PIANO, "F4", v );
            }
          } else if (b==1) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 0.5, PIANO, "A4", v );
              note( 0, 0.5, PIANO, "C5", v );
              note( 0, 0.5, PIANO, "E5", v );
            } else {
              note( 0, 0.5, PIANO, "C5", v );
              note( 0.5, 0.5, PIANO, "A4", v );
              note( 1, 0.5, PIANO, "E5", v );
            }
          } else if (b==2) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 0.5, PIANO, "C5", v );
              note( 0, 0.5, PIANO, "E5", v );
              note( 0, 0.5, PIANO, "G5", v );
            } else {
              note( 0, 0.5, PIANO, "E5", v );
              note( 0.5, 0.5, PIANO, "C5", v );
              note( 1, 0.5, PIANO, "G5", v );
            }
          }
          notetrigger=true;
        }
        if (almaBY>height+d) {
          eses=false;
          newCircle();
        }
      } else {
        notetrigger=false;
        ellipse(x, y, d, d);
        y=y+yv;
        x=x+xv;
        yv=yv+G;
        if (y>height+200) {
          newCircle();
        }

        if (dist(x, y, pos[0].x, pos[0].y)<d/2) {
          eses=true;
          almaBX=x-d/2;
          almaBY=y;
          almaJX=x+d/2;
          almaJY=y;
          vBY=0;
          vJY=0;
        }
      }
    }
  }
  if (scene == 5) {
    if (!bg4trigger) {
      playerf.pause();
      playerg = minim.loadFile("g.mp3");
      playerg.loop();
      bg4trigger = true;
    }
    background(#E6E5FF);
    //visualization
    fft.forward( in.mix );
    for (int i=0; i<width; i++) {
      float d = map(fft.getBand(i), 0, 255, 0, height);
      fill(#221E93, random(100));
      float x = map(i, 0, fft.getBand(i), width/2, width);
      ellipse(x, height/2, d, d);
      x = map(i, 0, fft.getBand(i), width/2, 0);
      ellipse(x, height/2, d, d);
    }


    for (Hand hand : leap.getHands ()) {
      grab = hand.getGrabStrength();

      for (int i = 9; i > 0; i--) {
        stroke(#ffffff, 40+i*10);
        strokeWeight(20);
        line(pos[i].x, pos[i].y, pos[i-1].x, pos[i-1].y);
        pos[i]=pos[i-1];
      }

      pos[0] = hand.getPosition();

      fill(#ffffff);
      noStroke();
      ellipse(pos[0].x, pos[0].y, 25, 25);

      fill(#ffffff);
      if (eses) {
        ellipse(almaBX, almaBY, d, d);
        ellipse(almaJX, almaJY, d, d);
        almaBX+=vBX;
        almaJX+=vJX;
        almaBY+=vBY;
        almaJY+=vJY;
        vBY+=G;
        vJY+=G;
        if (!notetrigger) {
          int b = int (random(0, 3));
          if (b==0) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 0.5, PIANO, "G4", v );
              note( 0, 0.5, PIANO, "B4", v );
              note( 0, 0.5, PIANO, "D5", v );
            } else {
              note( 0, 0.5, PIANO, "D5", v );
              note( 0.5, 0.5, PIANO, "B4", v );
              note( 1, 0.5, PIANO, "G4", v );
            }
          } else if (b==1) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 0.5, PIANO, "B4", v );
              note( 0, 0.5, PIANO, "D5", v );
              note( 0, 0.5, PIANO, "F5", v );
            } else {
              note( 0, 0.5, PIANO, "B4", v );
              note( 0.5, 0.5, PIANO, "F5", v );
              note( 1, 0.5, PIANO, "D5", v );
            }
          } else if (b==2) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 0.5, PIANO, "D5", v );
              note( 0, 0.5, PIANO, "F5", v );
              note( 0, 0.5, PIANO, "A5", v );
            } else {
              note( 0, 0.5, PIANO, "A5", v );
              note( 0.5, 0.5, PIANO, "D5", v );
              note( 1, 0.5, PIANO, "F5", v );
            }
          }
          notetrigger=true;
        }
        if (almaBY>height+d) {
          eses=false;
          newCircle();
        }
      } else {
        notetrigger=false;
        ellipse(x, y, d, d);
        y=y+yv;
        x=x+xv;
        yv=yv+G;
        if (y>height+200) {
          newCircle();
        }

        if (dist(x, y, pos[0].x, pos[0].y)<d/2) {
          eses=true;
          almaBX=x-d/2;
          almaBY=y;
          almaJX=x+d/2;
          almaJY=y;
          vBY=0;
          vJY=0;
        }
      }
    }
  }
  if (scene == 6) {
    if (!bg5trigger) {
      playerg.pause();
      playera = minim.loadFile("a.mp3");
      playera.loop();
      bg5trigger = true;
    }
    background(#000000);

    //visualization
    fft.forward( in.mix );
    pushMatrix();
    var barWidth = in.mix.size();
    var diam = barWidth*0.015;
    beginShape();
    for (int i = 0; i < barWidth; i++) {
      var x1 = width * i/barWidth;
      var y1 = map(fft.getBand(i), 0, 20, height, 0);
      //float rr = 255 - y/height * 255;
      //float gg = y/height * 255;
      //float bb = random(255);
      fill(random(120, 190), random(50, 170), 230);
      stroke(0, 0, 0, 0);
      float yy = y%diam;
      ellipse(x1, y1+10, yy, yy);
      ellipse(width-x, y, yy, yy);
    }
    endShape();
    popMatrix();

    for (Hand hand : leap.getHands ()) {
      grab = hand.getGrabStrength();

      for (int i = 9; i > 0; i--) {
        stroke(#ffffff, 40+i*10);
        strokeWeight(20);
        line(pos[i].x, pos[i].y, pos[i-1].x, pos[i-1].y);
        pos[i]=pos[i-1];
      }

      pos[0] = hand.getPosition();

      fill(#ffffff);
      noStroke();
      ellipse(pos[0].x, pos[0].y, 25, 25);

      fill(#ffffff);
      if (eses) {
        ellipse(almaBX, almaBY, d, d);
        ellipse(almaJX, almaJY, d, d);
        almaBX+=vBX;
        almaJX+=vJX;
        almaBY+=vBY;
        almaJY+=vJY;
        vBY+=G;
        vJY+=G;
        if (!notetrigger) {
          int b = int (random(0, 3));
          if (b==0) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 2, PIANO, "A4", v );
              note( 0, 2, PIANO, "C5", v );
              note( 0, 2, PIANO, "E5", v );
            } else {
              note( 0, 2, PIANO, "E5", v );
              note( 2, 2, PIANO, "A4", v );
              note( 4, 2, PIANO, "C5", v );
            }
          } else if (b==1) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 2, PIANO, "C5", v );
              note( 0, 2, PIANO, "E5", v );
              note( 0, 2, PIANO, "G5", v );
            } else {
              note( 0, 2, PIANO, "C5", v );
              note( 2, 2, PIANO, "G5", v );
              note( 4, 2, PIANO, "E5", v );
            }
          } else if (b==2) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 2, PIANO, "E5", v );
              note( 0, 2, PIANO, "G5", v );
              note( 0, 2, PIANO, "B5", v );
            } else {
              note( 0, 2, PIANO, "B5", v );
              note( 2, 2, PIANO, "E5", v );
              note( 4, 2, PIANO, "G5", v );
            }
          }
          notetrigger=true;
        }
        if (almaBY>height+d) {
          eses=false;
          newCircle();
        }
      } else {
        notetrigger=false;
        ellipse(x, y, d, d);
        y=y+yv;
        x=x+xv;
        yv=yv+G;
        if (y>height+200) {
          newCircle();
        }

        if (dist(x, y, pos[0].x, pos[0].y)<d/2) {
          eses=true;
          almaBX=x-d/2;
          almaBY=y;
          almaJX=x+d/2;
          almaJY=y;
          vBY=0;
          vJY=0;
        }
      }
    }
  }
  if (scene == 7) {
    if (!bg6trigger) {
      playera.pause();
      playerb = minim.loadFile("b.mp3");
      playerb.loop();
      bg6trigger = true;
    }
    
    fft.forward( in.mix );
    pushMatrix();
    background(#FFE4F3);
    translate(0, height/2);
    for (var x=80; x <= width-80; x +=15) {
      noStroke();
      strokeWeight(10);
      stroke(230, random(70, 170), random(130, 200));
      var h = (fft.getBand(x)+random(1, 1.5))*100;
      line(x, 0-h, x, 0+h); 
    }
    popMatrix();
    for (Hand hand : leap.getHands ()) {
      grab = hand.getGrabStrength();

      for (int i = 9; i > 0; i--) {
        stroke(#ffffff, 40+i*10);
        strokeWeight(20);
        line(pos[i].x, pos[i].y, pos[i-1].x, pos[i-1].y);
        pos[i]=pos[i-1];
      }

      pos[0] = hand.getPosition();

      fill(#ffffff);
      noStroke();
      ellipse(pos[0].x, pos[0].y, 25, 25);

      fill(#ffffff);
      if (eses) {
        ellipse(almaBX, almaBY, d, d);
        ellipse(almaJX, almaJY, d, d);
        almaBX+=vBX;
        almaJX+=vJX;
        almaBY+=vBY;
        almaJY+=vJY;
        vBY+=G;
        vJY+=G;
        if (!notetrigger) {
          int b = int (random(0, 3));
          if (b==0) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 1, PIANO, "B4", v );
              note( 0, 1, PIANO, "D5", v );
              note( 0, 1, PIANO, "F5", v );
            } else {
              note( 0, 1, PIANO, "B4", v );
              note( 1, 1, PIANO, "F5", v );
              note( 2, 1, PIANO, "D5", v );
            }
          } else if (b==1) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 1, PIANO, "D5", v );
              note( 0, 1, PIANO, "F5", v );
              note( 0, 1, PIANO, "A5", v );
            } else {
              note( 0, 1, PIANO, "A5", v );
              note( 1, 1, PIANO, "D5", v );
              note( 2, 1, PIANO, "F5", v );
            }
          } else if (b==2) {
            int a = int (random(0, 2));
            if (a==0) {
              note( 0, 1, PIANO, "F5", v );
              note( 0, 1, PIANO, "A5", v );
              note( 0, 1, PIANO, "C6", v );
            } else {
              note( 0, 1, PIANO, "A5", v );
              note( 1, 1, PIANO, "F5", v );
              note( 2, 1, PIANO, "C6", v );
            }
          }
          notetrigger=true;
        }
        if (almaBY>height+d) {
          eses=false;
          newCircle();
        }
      } else {
        notetrigger=false;
        ellipse(x, y, d, d);
        y=y+yv;
        x=x+xv;
        yv=yv+G;
        if (y>height+200) {
          newCircle();
        }

        if (dist(x, y, pos[0].x, pos[0].y)<d/2) {
          eses=true;
          almaBX=x-d/2;
          almaBY=y;
          almaJX=x+d/2;
          almaJY=y;
          vBY=0;
          vJY=0;
        }
      }
    }
    if (!scenecon && grab == 1) {
      playerb.pause();
      bgtrigger=false;
      bg1trigger=false;
      bg2trigger=false;
      bg3trigger=false;
      bg4trigger=false;
      bg5trigger=false;
      bg6trigger=false;
    }
  }
}
