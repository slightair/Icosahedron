#version 300 es

in lowp vec4 vColor;
in lowp vec2 vTexCoord;

out mediump vec4 outputColor;

uniform sampler2D uTexture;

void main()
{
    mediump vec4 textureColor = texture(uTexture, vTexCoord);
    if (textureColor.a < 0.001) {
        discard;
    }
    outputColor = vColor * textureColor;
}