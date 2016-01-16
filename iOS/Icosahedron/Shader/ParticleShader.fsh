#version 300 es

in lowp vec4 vColor;

out mediump vec4 outputColor;

uniform sampler2D uTexture;

void main()
{
    mediump vec4 textureColor = texture(uTexture, gl_PointCoord);
    if (textureColor.a < 0.01) {
        discard;
    }
    outputColor = vColor * textureColor;
}
