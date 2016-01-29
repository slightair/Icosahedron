precision mediump float;

varying vec4 vColor;
varying vec2 vTexCoord;

uniform sampler2D uTexture;

void main()
{
    vec4 textureColor = texture2D(uTexture, vTexCoord);

    gl_FragColor = vColor * textureColor;
}
