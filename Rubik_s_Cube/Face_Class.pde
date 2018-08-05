class Face {
    //Stroes a 3 x 3 2D array of colours. A total of 6 faces are needed for a rubik's cube.
    color[][] faceColours = new color[3][3];

    boolean shaded = false;

    //When initializing, set all values to defined colour. Green, Red, White, Blue, Orange, Yellow
    Face(color colour) {
        for (int i = 0; i < 3; i ++) {
            for (int j = 0; j < 3; j ++) {
                if (shaded) {
                    //This option is used so colours are shown with different shades.
                    //Useful for when you need to check if rotating sides are functional. 
                    this.faceColours[i][j] = lerpColor(colour, color(0, 0, 0), i/8.0 + j/8.0);
                } else {
                    //This option is used so colours are uniform.
                    this.faceColours[i][j] = colour;
                }
            }
        }
    }

    //Each face's given side is switched to the next face's given side, and so on, in a cycle.
    void cycleSwitchSide(Face[] switchFaces, int[] sidesNumbers) {
        //Define two colour holders
        color[] colourHolder1 = new color[3];
        color[] colourHolder2 = new color[3];
        //Set colour holders to first two sides
        colourHolder1 = switchFaces[0].getSide(sidesNumbers[0]);
        colourHolder2 = switchFaces[1].getSide(sidesNumbers[1]);
        for (int i = 0; i < switchFaces.length; i++) {
            int index = (i + 1) % switchFaces.length;
            //Let the second side be replaced with the first colour holder.
            switchFaces[index].assignSide(colourHolder1, sidesNumbers[index]);
            //Shift the second colour holder's ccolour down to the first holder
            colourHolder1 = colourHolder2;
            //Second colour holder gets next colour.
            colourHolder2 = switchFaces[(index + 1) % switchFaces.length].getSide(sidesNumbers[(index + 1) % switchFaces.length]);
        }
    }

    //Returns the 3 colours of any side of any face. 
    color[] getSide(int sideNumber) {
        color[] sideColours = new color[3];
        for (int i = 0; i < 3; i ++) {
            switch(sideNumber) {
            case 0:
                sideColours[i] = faceColours[0][2 - i]; //top
                break;
            case 1:
                sideColours[i] = faceColours[2 - i][2]; //right
                break;
            case 2:
                sideColours[i] = faceColours[2][i]; //down
                break;
            case 3:
                sideColours[i] = faceColours[i][0]; //left
                break;
            }
        }
        return sideColours;
    }

    //Set any side of any face to three specific colours. 
    void assignSide(color[] colours, int sideNumber) {
        for (int i = 0; i < 3; i ++) {
            switch(sideNumber) {
            case 0:
                faceColours[0][2 - i] = colours[i];
                break;
            case 1:
                faceColours[2 - i][2] = colours[i];
                break;
            case 2:
                faceColours[2][i] = colours[i];
                break;
            case 3:
                faceColours[i][0] = colours[i];
                break;
            }
        }
    }

    //Rotates all values on a single face.
    void rotateFace(boolean inverted) {
        //Temporary holder of new rotated face
        color[][] rotatedFace = new color[3][3];
        for (int i = 0; i < 3; i ++) {
            for (int j = 0; j < 3; j ++) {
                if (inverted == true) {
                    rotatedFace[2 - j][i] = this.faceColours[i][j];
                } else {
                    rotatedFace[j][2 - i] = this.faceColours[i][j];
                }
            }
        }
        //Set face to new values of colours. 
        for (int i = 0; i < 3; i ++) {
            for (int j = 0; j < 3; j ++) {
                this.faceColours[i][j] = rotatedFace[i][j];
            }
        }
    }
}