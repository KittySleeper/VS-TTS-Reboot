#pragma header

uniform float corner_scale;

bool isOut(float x, float y) {
    return pow(x, 2.) + pow(y, 2.) > pow(corner_scale * .5, 2.);
}

void main() {
    vec2 UV = openfl_TextureCoordv;
    
    float s = corner_scale * .5;

    if (
        (UV.x < s      && UV.y < s      && isOut(UV.x - s,      UV.y - s)) ||
        (UV.x < s      && UV.y > 1. - s && isOut(UV.x - s,      UV.y - 1. + s)) ||
        (UV.x > 1. - s && UV.y < s      && isOut(UV.x - 1. + s, UV.y - s)) ||
        (UV.x > 1. - s && UV.y > 1. - s && isOut(UV.x - 1. + s, UV.y - 1. + s))
    ) {
        discard;
    } else {
        gl_FragColor = flixel_texture2D(bitmap, UV);
    }
}