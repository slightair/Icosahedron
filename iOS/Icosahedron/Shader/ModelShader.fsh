#version 300 es

in lowp vec4 colorVarying;

out mediump vec4 outputColor;

void main()
{
    outputColor = colorVarying;
}
