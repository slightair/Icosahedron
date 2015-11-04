#version 300 es

in lowp vec4 colorVarying;

out mediump vec4 outputColor;

uniform sampler2D vertexTexture;
uniform bool useTexture;

void main()
{
    if (!useTexture) {
        outputColor = colorVarying;
        return;
    }

    mediump vec4 textureColor = texture(vertexTexture, gl_PointCoord);
    if (textureColor.a < 0.1) {
        discard;
    }
    outputColor = colorVarying * textureColor;
}
