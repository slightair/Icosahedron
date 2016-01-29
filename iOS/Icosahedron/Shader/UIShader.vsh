attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 vColor;
varying vec2 vTexCoord;

uniform mat4 uProjectionMatrix;

void main()
{
    vColor = color;
    vTexCoord = texCoord;

    gl_Position = position * vec4(1, -1, 1, 1) * uProjectionMatrix;
}
