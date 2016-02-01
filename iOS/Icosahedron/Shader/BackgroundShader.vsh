attribute vec4 position;
attribute vec3 normal;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 vColor;
varying vec2 vTexCoord;

uniform mat4 uProjectionMatrix;
uniform mat4 uWorldMatrix;
uniform mat3 uNormalMatrix;

void main()
{
    vColor = color;
    vTexCoord = texCoord;

    gl_Position = uProjectionMatrix * uWorldMatrix * position;
}
