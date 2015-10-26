varying lowp vec4 colorVarying;
varying lowp vec4 vColor;

void main()
{
    gl_FragColor = colorVarying * vColor;
}
