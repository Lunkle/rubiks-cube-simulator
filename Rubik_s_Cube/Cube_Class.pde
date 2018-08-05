class Cube {
    //Helps show orientation of face when true, but gets in the way when presenting.
    boolean showText = false;
    //Determines if draw style is transparent or solid.
    boolean solidCube = false;

    float CUBE_SIZE = 180;
    float SQUARE_PADDING = 3;
    float COLOR_SIZE = (CUBE_SIZE / 3.0) - 2 * SQUARE_PADDING;

    //6 Faces of a rbik's cube
    Face[] faces = new Face[6];

    //You can set the squares to be semi-transparent.
    int transparency = 255;
    String[] faceLetters = {"F", "R", "U", "B", "L", "D"};
    color[] colors = {color(0, 128, 0, transparency), color(255, 0, 0, transparency), color(255, 255, 255, transparency), 
        color(0, 0, 255, transparency), color(255, 145, 0, transparency), color(255, 255, 0, transparency)};
    //0          1          2          3         4           5
    //front,     right,     up,        back,     left,       down
    //green,     red,       white,     blue,     orange,     yellow

    Cube() {
        initCubeColors();
    }

    void randomizeCube() {
        int randomNumber = (int) random(10, 20);
        for (int i = 0; i < randomNumber; i++) {
            cube.rotateSide((int) random(-0.5, 4.5), true);
        }
    }

    boolean checkIfSameCube(Cube cube1, Cube cube2) {
        for (int i = 0; i < 6; i ++) {
            for (int j = 0; j < 3; j ++) {
                for (int k = 0; k < 3; k ++) {
                    if (cube1.faces[i].faceColours[j][k] != cube2.faces[i].faceColours[j][k]) {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    //Dumb solve is a dumb way to solve a cube...
    String[] dumbSolve() {
        Cube[] thisCube = {this};
        return this.dumbSolve(thisCube);
    }

    //Solved by checking every single possible move you can make on the original cube to solve it.
    String[] dumbSolve(Cube[] cubeArray) {
        //First check if any of the new ones are solved.
        for (int i = 0; i < cubeArray.length; i++) {
            if (checkIfSameCube(new Cube(), cubeArray[i])) {
                return getMoves(cubeArray.length, i + 1);
            }
        }
        if (cubeArray.length == 248832) {//12^5
            println("dumb solve method is too dumb");
            String[] warningMessage = {"too long, use another method"};
            return warningMessage;
        }
        Cube[] newCubeArray = new Cube[cubeArray.length * 12];
        for (int i = 0; i < cubeArray.length; i++) {
            for (int j = 0; j < 12; j++) {
                Cube tempNewCube = cubeArray[i].copy();
                tempNewCube.rotateSide(j % 6, j >= 6);
                newCubeArray[i * 12 + j] = tempNewCube;
            }
        }
        return dumbSolve(newCubeArray);
    }

    private String[] getMoves(int arrayLength, int cubeIndex) {
        //Basically log with base 12 (arrayLength), but that doesn't work in processing
        int numMoves = parseInt(log(arrayLength) / log(12));
        println("Number of moves to solve is", numMoves);
        String[] moves = new String[numMoves];
        //Since there are twelve possible moves you can perform on any cube, the cubeIndex variable is calculated to be
        //in specific segments with lengths that are powers of twelve. Exploiting this property of the cube index, we can
        //determine which moves were performed to result in the arrayLength and cubeIndex.
        for (int i = numMoves - 1; i > -1; i--) {
            //Get the move number by seeing which segment it is in.
            int moveNumber = cubeIndex == 0? 12:ceil(cubeIndex / pow(12, i)); //A number from 1 to 12
            //After getting move number, convert it to a string and save it.
            moves[numMoves - i - 1] = moveNumber <= 6? (numToFace(moveNumber - 1)):(numToFace(moveNumber - 7) + "'");
            //We reduce cubeIndex to facilitate further calculations. 
            cubeIndex = cubeIndex % parseInt(pow(12, i));
        }
        return moves;
    }

    //0          1          2          3         4           5
    //front,     right,     up,        back,     left,       down
    //green,     red,       white,     blue,     orange,     yellow
    String numToFace(int faceNumber) {
        return faceLetters[faceNumber];
    }

    //A testing method that prints out the colours of each face.
    private void printColours() {
        for (int i = 0; i < 6; i ++) {
            for (int j = 0; j < 3; j ++) {
                for (int k = 0; k < 3; k ++) {
                    print(this.faces[i].faceColours[j][k] + "\t");
                }
            }
            println();
        }
    }

    //Deep copy for cube object, to avoid two pointers to the same object.
    Cube copy() {
        Cube newCube = new Cube();
        for (int i = 0; i < 6; i ++) {
            for (int j = 0; j < 3; j ++) {
                for (int k = 0; k < 3; k ++) {
                    newCube.faces[i].faceColours[j][k] = this.faces[i].faceColours[j][k];
                }
            }
        }
        return newCube;
    }

    //This method rotates a side.
    void rotateSide(int faceNumber, boolean inverted) {
        faces[faceNumber].rotateFace(inverted);
        int[] sideSwitchOrder = new int[4];
        //switchFaces is the array of faces that are affected by the side that is rotated(not counting its own face of course).
        Face[] switchFaces = {};
        for (int i = 1; i < 6; i++) {
            //If i is 3, that face is the face on the opposite side, which should not be modified.
            if (i != 3) {
                //Add the current face to the switchFaces array.
                switchFaces = (Face[]) append(switchFaces, faces[(i + faceNumber) % 6]);
            }
        }
        //0          1          2          3         4           5
        //front,     right,     up,        back,     left,       down
        //green,     red,       white,     blue,     orange,     yellow
        //The following code is a fancy algorithm to find the sides of the given faces... No need to look too far into it.
        sideSwitchOrder[0] = faceNumber % 3 == 2? 2:0;
        sideSwitchOrder[2] = 2 - sideSwitchOrder[0];
        sideSwitchOrder[1] = 1 + 2 * (faceNumber / 3);
        sideSwitchOrder[3] = sideSwitchOrder[1];
        int numSpinTimes;
        //Spinning three times one way is the same as spinning once the other way.
        numSpinTimes = inverted?1:3;
        if (faceNumber % 2 == 1) {
            numSpinTimes = (numSpinTimes + 2) % 4;
        }
        for (int i = 0; i < numSpinTimes; i++) {
            faces[faceNumber].cycleSwitchSide(switchFaces, sideSwitchOrder);
        }
    }

    //Set all faces to default colours.
    void initCubeColors() {
        for (int i = 0; i < 6; i ++) {
            faces[i] = new Face(colors[i]);
        }
    }

    //This method draws the cube on screen.
    void displayCube() {
        //If it's a solid cube then fill
        if (solidCube == true) {
            fill(255);
        } else {
            noFill();
        }
        noStroke();
        box(CUBE_SIZE);
        if (solidCube == true) {
            stroke(0);
        } else {
            stroke(255);
        }
        for (int i = 0; i < 6; i ++) {
            pushMatrix();
            //  0          1         2          3         4           5
            //front,     right,     up,       back,      left,       down
            //green,      red,     white,     blue,     orange,     yellow
            if (i == 1) {
                rotateY(PI/2);
                rotateZ(-PI/2);
            } else if (i == 2) {
                rotateX(PI/2);
                rotateZ(PI/2);
            } else if (i == 3) {
                rotateX(PI);
            } else if (i == 4) {
                rotateY(-PI/2);
                rotateZ(-PI/2);
            } else if (i == 5) {
                rotateX(-PI/2);
                rotateZ(-PI/2);
            }

            translate(-CUBE_SIZE / 2, -CUBE_SIZE / 2, CUBE_SIZE/2 + 0.01);
            for (int j = 0; j < 3; j++) {
                for (int k = 0; k < 3; k ++) {
                    fill(faces[i].faceColours[j][k]);
                    rect(SQUARE_PADDING, SQUARE_PADDING, COLOR_SIZE, COLOR_SIZE);
                    fill(0);
                    //If show text is true, show the coordinate of the square of the face.
                    if (showText) {
                        text(j + " " + k, 10, 20, 1);
                    }
                    translate(CUBE_SIZE / 3, 0, 0);
                }
                translate(-CUBE_SIZE, CUBE_SIZE / 3, 0);
            }
            popMatrix();
        }
    }
}