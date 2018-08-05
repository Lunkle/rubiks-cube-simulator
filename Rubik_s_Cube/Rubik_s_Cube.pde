/*
    This program simulates a rubik’s cube in 3D, and allows the user to manipulate it using keyboard input.
 An index of commands are listed below:
 |----------------------------------|-----------------------------------------------|
 |Key                               |Function                                       |
 |----------------------------------|-----------------------------------------------|
 |‘f’                               |Rotates the front side clockwise               |
 |‘r’                               |Rotates the right side clockwise               |
 |‘u’                               |Rotates the up side clockwise                  |
 |‘b’                               |Rotates the back side clockwise                |
 |‘l’                               |Rotates the left side clockwise                |
 |‘d’                               |Rotates the bottom side clockwise              |
 |TAB + any of the above            |Rotates that side counter-clockwise            |
 |SPACEBAR                          |Sets camera to default/front view              |
 |UP, DOWN, LEFT, RIGHT             |Rotates camera around cube                     |
 |ENTER                             |Finds solution for current cube for up 5 moves |
 |----------------------------------|-----------------------------------------------|
 After pressing enter, the optimal solution is then printed out in a format in which a capital letter represents
 the corresponding face to be turned clockwise; if a single quote (’) follows after, then the corresponding face
 should be turned counter-clockwise. Following the steps from left to right should lead to the solved cube.
 */


//These are the variables to actually put the camera
float cameraY; //Camera's Y value
float cameraX; //Camera's X value
float cameraZ; //Camera's Z value
//Horizontal Plane, 0 degrees on x axis, Increase counter-clockwise from top-down perspective.
float cameraXZAngle = 270; //Default value is 270
//Angle of cross-section of sphere from horizontal radius (<).
float cameraRiseAngle = 0; //Default value is 0
//These two variabes create the illusion of the cube actually turning as opposed
float targetXZAngle = cameraXZAngle;
float targetRiseAngle = cameraRiseAngle; //to just immediately setting the camera angles to a different value.

//How far the camera is from the cube.
float cameraDistance = 320.0;

//When tab is held down, when you want to rotate a side, it will turn counter-clockwise. If not, then clockwise.
boolean inverse = false;

//Define cube here because it's used in setup and draw
Cube cube;

//Solve sequence will be the set of moves to solve the cube.
String[] solveSequence = {};

void setup() {
    cube = new Cube();
    //cube.randomizeCube();
    size(640, 360, P3D);
    frameRate(1000);
}

//Frame f variable to keep track of the frame and do sine and cosine stuff
float f = 0;
int[] array = {1, 2, 4, 5};
void draw() {
    if (f < 2048) {
        cube.rotateSide(array[parseInt(f)%4], true);
        if (cube.checkIfSameCube(new Cube(), cube)){
            println(f + 1);
            f = 2048;
        }
    }
    f++;
    background(204);
    //targetRiseAngle = -50 * sin(f / 50);
    //targetXZAngle = 270 + 50 * cos(f / 50);
    //targetXYAngle -= 1.2;
    updateCamera();
    camera(cameraX, cameraY, cameraZ, 0.0, 0.0, 0.0, 0, 1, 0);
    drawAxis();
    cube.displayCube();
}

void keyPressed() {
    switch(key) {
    case 'f':
        cube.rotateSide(0, inverse);
        break;
    case 'r':
        cube.rotateSide(1, inverse);
        break;
    case 'u':
        cube.rotateSide(2, inverse);
        break;
    case 'b':
        cube.rotateSide(3, inverse);
        break;
    case 'l':
        cube.rotateSide(4, inverse);
        break;
    case 'd':
        cube.rotateSide(5, inverse);
        break;
    case ENTER:
        solveSequence = cube.dumbSolve();
        for (int i = 0; i < solveSequence.length; i++) {
            print(solveSequence[i] + " ");
        }
        println();
        break;
    case ' ':
        //Reset to default view point
        targetRiseAngle = 0;
        targetXZAngle = 270;
    }
    if (key == CODED) {
        switch(keyCode) {
        case UP:
            targetRiseAngle -= 15;
            break;
        case DOWN:
            targetRiseAngle += 15;
            break;
        case LEFT:
            targetXZAngle += 15;
            break;
        case RIGHT:
            targetXZAngle -= 15;
            break;
        }
    }
    if (key == TAB) { //Hold tab to turn faces counter-clockwise
        inverse = true;
    }
}

//If tab is released then turn clockwise like normal again.
void keyReleased() {
    if (key == TAB) {
        inverse = false;
    }
}

//Draws the axis lines and label them. 
void drawAxis() {
    int lineLength = 140;
    fill(0);
    line(0, 0, lineLength, 0, 0, -lineLength);
    text("z", 0, 0, lineLength);
    text("-z", 0, 0, -lineLength);
    line(0, lineLength, 0, 0, -lineLength, 0);
    text("y", 0, lineLength, 0);
    text("-y", 0, -lineLength, 0);
    line(lineLength, 0, 0, -lineLength, 0, 0);
    text("x", lineLength, 0, 0);
    text("-x", -lineLength, 0, 0);
}

//Sets camera on the sphere with center at center of rubik's cube,
//given the rise angle and angle on the XZ plane.
void updateCamera() {
    //Preventing user from "going over the top"
    if (abs(targetRiseAngle) >= 90) {
        targetRiseAngle = cameraRiseAngle<0? -89.99:89.99;
    }
    //Finding whether to rotate cube clockwise or counter-clockwise
    float clockwiseFix = targetXZAngle - cameraXZAngle; //Clockwise fix degree
    float counterFix = -(cameraXZAngle + 360 - targetXZAngle); //Counter-clockwise fix degree
    clockwiseFix -= clockwiseFix>360? 360:0;
    counterFix -= counterFix>0? 360:0;
    float idealFix = abs(clockwiseFix)<abs(counterFix)? clockwiseFix:counterFix;
    //Updating camera angle to target, animation effect
    cameraXZAngle += idealFix / 25;
    cameraRiseAngle += (targetRiseAngle - cameraRiseAngle) / 25;
    //Set camera angle and target angle as close together as possible
    if (abs(cameraXZAngle - targetXZAngle) > 180) {
        if (cameraXZAngle < targetXZAngle) {
            cameraXZAngle += 360;
        } else {
            targetXZAngle += 360;
        }
    }
    //To prevent integer overload, modulo 360 in a special way
    if (abs(targetXZAngle) >= 360 && abs(cameraXZAngle) >= 360) {
        cameraXZAngle += cameraXZAngle < 0? 360 : -360;
        targetXZAngle += targetXZAngle < 0? 360 : -360;
    }
    //Calculating Camera position
    cameraY = cameraDistance * sin(radians(cameraRiseAngle));
    float lengthToPerp = cameraDistance * cos(radians(cameraRiseAngle));
    cameraX = lengthToPerp * cos(radians(cameraXZAngle + 180));
    cameraZ = lengthToPerp * sin(radians(cameraXZAngle + 180));
}