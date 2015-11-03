#version 300 es

precision mediump float;

in lowp vec4 colorVarying;
in mediump vec2 texcoord;

out mediump vec4 outputColor;

uniform sampler2D sourceTexture;
uniform bool useBlur;

void main()
{
    vec4 color = texture(sourceTexture, texcoord);
    outputColor = colorVarying * color;
}
