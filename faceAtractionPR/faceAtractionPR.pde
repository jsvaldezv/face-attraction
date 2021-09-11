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

//CAMERA LIBRARIES
Capture cam;
DeepVision vision;
ULFGFaceDetectionNetwork network;
ResultList<ObjectDetectionResult> detections;

//BALLS DEFINITIONS
Box2DProcessing box2d;
Mover[] movers = new Mover[25];
Attractor a;

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
    
    //a = new Attractor(50,width/2,height/2);
}

public void draw() 
{
    background(55);

    //CAMERA
    if (cam.available()) {
        cam.read();
    }

    image(cam, 0, 0);

    if (cam.width == 0) {
        return;
    }

    detections = network.run(cam);

    noFill();
    strokeWeight(2f);

    stroke(200, 80, 100);
    for (ObjectDetectionResult detection : detections)
    {
        stroke(0,0,0,0);
        rect(detection.getX(), detection.getY(), detection.getWidth(), detection.getHeight());
        a = new Attractor(detection.getWidth()/1.5,detection.getX()+detection.getWidth()/2,detection.getY()+detection.getHeight()/2);
        box2d.step();
        a.display();

        for (int i = 0; i < movers.length; i++) 
        {
            Vec2 force = a.attract(movers[i]);
            movers[i].applyForce(force);
            movers[i].display();
        }
    }

    //surface.setTitle("Face Detector Test - FPS: " + Math.round(frameRate));
}