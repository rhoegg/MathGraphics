attribute vec4 position;
attribute vec4 sourceColor;

varying vec4 destinationColor;

uniform mat4 projection;
uniform mat4 modelview;

void main(void) {
    destinationColor = sourceColor;
    gl_Position = projection * modelview * position;
}