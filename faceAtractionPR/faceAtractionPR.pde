//CAMERA LIBRARIES
import processing.javafx.*;
import ch.bildspur.vision.*;
import ch.bildspur.vision.result.*;
import processing.video.Capture;

//BALLS LIBRARIES
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

//OSC LIBRARIES
import netP5.*;
import oscP5.*;

//CAMERA LIBRARIES
Capture cam;
DeepVision vision;
ULFGFaceDetectionNetwork network;
ResultList<ObjectDetectionResult> detections;

//BALLS DEFINITIONS
Box2DProcessing box2d;
Mover[] movers = new Mover[25];
Attractor a;

//OSC DEFINITIONS
OscP5 osc;
NetAddress remote;

float amp = 0, cut = 0;
float xPos = 0, yPos = 0, circleX = 0, circleY = 0;
int cont = 0;
public void setup() 
{
    //CAMERA
    size(640, 480, FX2D);
    colorMode(HSB, 360, 100, 100);

    println("creating network...");
    vision = new DeepVision(this);
    network = vision.createULFGFaceDetectorRFB320();

    println("loading model...");
    network.setup();

    println("setup camera...");
    cam = new Capture(this, "pipeline:autovideosrc");
    cam.start();

    //BALLS
    smooth();
    box2d = new Box2DProcessing(this);
    box2d.createWorld();

    box2d.setGravity(0,0);

    for (int i = 0; i < movers.length; i++) 
        movers[i] = new Mover(random(8,16),random(width),random(height));

    //CREAR OBJETO DE OSC PARA RECIBIR
    osc = new OscP5(this, 12000);
    //CREAR OBJETO PARA MANDAR INFO
    remote = new NetAddress("127.0.0.1", 57121);
}

public void draw() 
{
    background(55);

    //CAMERA
    if (cam.available())
        cam.read();

    image(cam, 0, 0);

    if (cam.width == 0)
        return;

    detections = network.run(cam);

    noFill();
    strokeWeight(2f);

    stroke(200, 80, 100);

    for (ObjectDetectionResult detection : detections)
    {
        //stroke(0,0,0,0);

        circleX = detection.getX();
        circleY = detection.getY();

        rect(circleX, circleY, detection.getWidth(), detection.getHeight());
        a = new Attractor(detection.getWidth()/1.5, 
                          circleX + detection.getWidth()/2,
                          circleY + detection.getHeight()/2);
        box2d.step();
        a.display();

        for (int i = 0; i < movers.length; i++) 
        {
            Vec2 force = a.attract(movers[i]);
            movers[i].applyForce(force);
            movers[i].display();

            if (i == movers.length-1)
            {
                xPos = movers[i].getX();
                yPos = movers[i].getY();
            }
        }

        float dis = sqrt(pow((xPos-circleX),2) + pow((yPos-circleY),2));

        cut = map(dis, 0, 640, 0, 1);
        //println(cut);
    }

    cont++;

    if(cont >= 50)
    {
        OscMessage msg = new OscMessage("/bounce");
        msg.add(cut);
        msg.add(1);
        osc.send(msg, remote);

        cont = 0;
    }
}