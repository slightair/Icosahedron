precision mediump float;

varying vec4 vColor;
varying vec2 vTexCoord;

uniform sampler2D uTexture;
uniform float uTime;

void main()
{
    vec2 texCoord = fract(vTexCoord + vec2(uTime, 0.0));
    vec4 textureColor = texture2D(uTexture, texCoord);

    gl_FragColor = vColor * textureColor;
}
