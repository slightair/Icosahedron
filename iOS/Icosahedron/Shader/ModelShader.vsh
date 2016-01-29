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
    vec3 eyeNormal = normalize(uNormalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);

    float nDotVP = max(0.6, dot(eyeNormal, normalize(lightPosition)));
    vec4 nDotVPVector = vec4(nDotVP, nDotVP, nDotVP, 1.0);

    vColor = diffuseColor * nDotVPVector * color;
    vTexCoord = texCoord;

    gl_Position = uProjectionMatrix * uWorldMatrix * position;
}
