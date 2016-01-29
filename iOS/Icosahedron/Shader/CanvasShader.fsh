precision mediump float;

varying vec4 vColor;
varying vec2 vTexCoord;

uniform sampler2D uTexture;
uniform vec2 uBlockSize;
uniform mediump float uNoiseFactor;
uniform mediump float uTime;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec2 blockCoord = floor(gl_FragCoord.xy / uBlockSize) * uBlockSize;
    float noise = rand(blockCoord + uTime);

    vec2 texCoord = vTexCoord;
    if (noise < 0.0) {
        texCoord = vTexCoord + mix(uBlockSize, -uBlockSize, noise / uNoiseFactor);
    }

    gl_FragColor = vColor * texture2D(uTexture, texCoord);
}
