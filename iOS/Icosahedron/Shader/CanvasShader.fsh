#version 300 es

precision mediump float;

in lowp vec4 vColor;
in lowp vec2 vTexCoord;

out mediump vec4 outputColor;

uniform sampler2D uTexture;
uniform mediump float uNoiseFactor;
uniform mediump float uTime;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec2 size = vec2(textureSize(uTexture, 0));
    vec2 blockNum = vec2(32.0, 128.0);
    vec2 blockSize = 1.0 / blockNum * size;
    vec2 blockCoord = floor(gl_FragCoord.xy / blockSize) * blockSize;
    vec2 distortion = blockSize / size;

    float noise = rand(blockCoord + uTime);

    vec2 texCoord = vTexCoord;
    if (noise < uNoiseFactor) {
        texCoord = vTexCoord + mix(distortion, -distortion, noise / uNoiseFactor);
    }

    outputColor = vColor * texture(uTexture, texCoord);
}
