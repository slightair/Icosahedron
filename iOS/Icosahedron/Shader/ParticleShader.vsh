attribute vec4 position;
attribute vec4 color;

varying vec4 vColor;

uniform mat4 uProjectionMatrix;
uniform mat4 uWorldMatrix;

void main()
{
    vColor = color;
    gl_Position = uProjectionMatrix * uWorldMatrix * position;
    gl_PointSize = 48.0;
}
