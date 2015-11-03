#version 300 es

precision mediump float;

in lowp vec4 colorVarying;
in mediump vec2 texcoord;

out mediump vec4 outputColor;

uniform sampler2D sourceTexture;
uniform vec2 texelSize;
uniform bool useBlur;

void main()
{
    vec4 destColor = texture(sourceTexture, texcoord);
    if (useBlur) {
        float iteration = 3.0;
        vec2 texelSizeHalf = texelSize * 0.5;
        vec2 uvOffset = texelSize.xy * iteration + texelSizeHalf;
        vec2 texcoordSample;
        vec4 blurColor;

        texcoordSample.x = texcoord.x - uvOffset.x;
        texcoordSample.y = texcoord.y + uvOffset.y;
        blurColor = texture(sourceTexture, texcoordSample);

        texcoordSample.x = texcoord.x + uvOffset.x;
        texcoordSample.y = texcoord.y + uvOffset.y;
        blurColor += texture(sourceTexture, texcoordSample);

        texcoordSample.x = texcoord.x + uvOffset.x;
        texcoordSample.y = texcoord.y - uvOffset.y;
        blurColor += texture(sourceTexture, texcoordSample);

        texcoordSample.x = texcoord.x - uvOffset.x;
        texcoordSample.y = texcoord.y - uvOffset.y;
        blurColor += texture(sourceTexture, texcoordSample);

        blurColor *= 0.2;
        destColor += blurColor;
    }
    outputColor = colorVarying * destColor;
}
