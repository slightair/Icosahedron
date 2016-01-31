precision highp float;

varying vec4 vColor;
varying vec2 vTexCoord;

uniform sampler2D uTexture;
uniform vec2 uTextureSize;
uniform vec2 uBlockSize;
uniform float uNoiseFactor;
uniform vec4 uEffectColor;
uniform float uEffectColorFactor;
uniform float uTime;

float rand(vec2 co)
{
    float a = fract(dot(co.xy, vec2(2.067390879775102, 12.451168662908249))) - 0.5;
    float s = a * (6.182785114200511 + a*a * (-38.026512460676566 + a*a * 53.392573080032137));
    float t = fract(s * 43758.5453);

    return t;
}

void main()
{
    vec2 blockCoord = floor(gl_FragCoord.xy / uBlockSize) * uBlockSize;
    vec2 blockCoordProgress = blockCoord / uTextureSize;
    vec2 blockSizeProgress = uBlockSize / uTextureSize;

    float noise = rand(blockCoordProgress + uTime);

    vec4 effectColor = vec4(0.0);
    if (uEffectColorFactor > 0.0) {
        effectColor = uEffectColor * uEffectColorFactor * 0.5;
    }

    vec2 texCoord = vTexCoord;
    if (abs(noise) < uNoiseFactor) {
        texCoord = vTexCoord + mix(blockSizeProgress, -blockSizeProgress, abs(noise) / uNoiseFactor);
    }

    gl_FragColor = vColor * texture2D(uTexture, texCoord) + effectColor;
}
