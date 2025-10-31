shader_type canvas_item;
render_mode unshaded;

uniform vec2 center = vec2(0.5, 0.5);
uniform int stripes : hint_range(1, 512) = 24;
uniform float speed : hint_range(0.0, 5.0, 0.1) = 0.2;
uniform int direction : hint_range(-1, 1, 2) = 1;
uniform vec4 stripe_colors[8] : source_color;
uniform int color_count : hint_range(1, 8) = 2;

void fragment() {
    // Aspect ratio robuste : texture si dispo, sinon viewport via SCREEN_PIXEL_SIZE
    float aspect = 1.0;
    if (TEXTURE_PIXEL_SIZE.x > 0.0 && TEXTURE_PIXEL_SIZE.y > 0.0) {
        aspect = TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x; // width/height
    } else {
        aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;   // (1/w)/(1/h) = w/h
    }

    vec2 uv = UV;
    vec2 c  = center;

    // Corrige l’étirement horizontal
    vec2 dirv = (uv - c) * vec2(aspect, 1.0);

    float angle = atan(dirv.y, dirv.x);
    angle -= TIME * speed * float(direction);

    float sector = TAU / float(max(stripes, 1));

    // Normalise l’angle dans [0, TAU)
    float a = mod(angle, TAU);
    if (a < 0.0) a += TAU;

    int stripe_index = int(floor(a / sector)) % stripes;
    int color_index = clamp(stripe_index % color_count, 0, color_count - 1);

    COLOR = stripe_colors[color_index];
}
