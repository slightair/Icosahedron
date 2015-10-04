//
//  Shader.fsh
//  Mesh
//
//  Created by slightair on 2015/10/04.
//  Copyright © 2015年 slightair. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
