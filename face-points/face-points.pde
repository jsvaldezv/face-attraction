import processing.javafx.*;
import ch.bildspur.vision.*;
import ch.bildspur.vision.result.*;
import processing.video.Capture;
import processing.video.*;

import netP5.*;
import oscP5.*;

Capture cam;

DeepVision vision = new DeepVision(this);
CascadeClassifierNetwork faceNetwork;
FacemarkLBFNetwork facemark;

OscP5 osc;
NetAddress remote;

ResultList<ObjectDetectionResult> detections;
ResultList<FacialLandmarkResult> markedFaces;

float cejaX = 0, cejaY = 0;
float bocaX = 0, bocaY = 0;
float caraX = 0, caraY = 0;


public void setup() 
{
    size(640, 480, FX2D);
    colorMode(HSB, 360, 100, 100);

    println("creating network...");
    faceNetwork = vision.createCascadeFrontalFace();
    facemark = vision.createFacemarkLBF();

    println("loading model...");
    faceNetwork.setup();
    facemark.setup();

    println("setup camera...");
    String[] cams = Capture.list();
    cam = new Capture(this, cams[0]);
    cam.start();

    osc = new OscP5(this, 12000);   
    remote = new NetAddress("127.0.0.1", 57120);
}


public void draw() 
{
    background(55);

    if (cam.available())
        cam.read();

    image(cam, 0, 0);
    detections = faceNetwork.run(cam);

    markedFaces = facemark.runByDetections(cam, detections);

    for (int i = 0; i < detections.size(); i++) 
    {
        ObjectDetectionResult face = detections.get(i);
        FacialLandmarkResult landmarks = markedFaces.get(i);

        noFill();
        strokeWeight(2f);
        stroke(200, 80, 100);
        rect(face.getX(), face.getY(), face.getWidth(), face.getHeight());
        caraX = face.getX();
        caraY = face.getY();

        noStroke();
        fill(100, 80, 200);

        for (int j = 0; j < landmarks.getKeyPoints().size(); j++) 
        {
            // 0 - 17 = Oreja izquierda a derecha
            // 17 - 27 = Cejas
            // 27 - 36 = Nariz
            // 36 - 48 = Ojos
            // 48 - 68 = Boca

            // Cejas
            if(j >= 17 && j < 27)
            {
                KeyPointResult kp = landmarks.getKeyPoints().get(j);
                ellipse(kp.getX(), kp.getY(), 5, 5);
                cejaX = kp.getX();
                cejaY = kp.getY();
            }

            // Boca
            else if(j >= 48 && j < 68)
            {
                KeyPointResult kp = landmarks.getKeyPoints().get(j);
                ellipse(kp.getX(), kp.getY(), 5, 5);
                bocaX = kp.getX();
                bocaY = kp.getY();
            }
        }
    }

    // Map one
    if (cejaX <= 0)
      cejaX = 1;
    if (cejaX >= 640)
      cejaX = 639;
    
    cejaX = map(cejaX, 0, 640, 100, 10000);
    
    // Map two
    if (cejaY <= 0)
      cejaY = 1;
    if (cejaX >= 480)
      cejaY = 479;
      
    cejaY = map(cejaY, 0, 480, 0, 1);
    
    // Map three
    if (bocaX <= 0)
      bocaX = 1;
    if (bocaX >= 640)
      bocaX = 639;
      
    bocaX = map(bocaX, 0, 640, 100, 800);
    
    // Map four
    if (bocaY <= 0)
      bocaY = 1;
    if (bocaY >= 480)
      bocaY = 479;
      
    bocaY = map(bocaY, 0, 480, 1, 300);
    
    // Map five
    if (caraX <= 0)
      caraX = 1;
    if (caraX >= 640)
      caraX = 639;
      
    caraX = map(caraX, 0, 640, 0.4, 1);

    // Map six
    if (caraY <= 0)
      caraY = 1;
    if (caraY >= 480)
      caraY = 479;
      
    caraY = map(caraY, 0, 480, 0, 1);

    OscMessage msg = new OscMessage("/points");

    msg.add(cejaX);
    msg.add(cejaY);

    msg.add(bocaX);
    msg.add(bocaY);

    msg.add(caraX);
    msg.add(caraY);
    
    osc.send(msg, remote);
}
