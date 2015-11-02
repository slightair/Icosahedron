#version 300 es

in lowp vec4 colorVarying;
in lowp vec4 vColor;

out mediump vec4 fragColor;

void main()
{
    fragColor = colorVarying * vColor;
}
