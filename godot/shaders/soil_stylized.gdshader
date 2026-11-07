shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
varying vec3 world_pos;

float rand2(vec2 p) {
    return fract(sin(dot(p, vec2(67.0, 141.0))) * 52764.0);
}

float value_noise(vec2 p) {
    vec2 f = fract(p);
    vec2 i = floor(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(rand2(i), rand2(i + vec2(1.0, 0.0)), u.x),
        mix(rand2(i + vec2(0.0, 1.0)), rand2(i + vec2(1.0, 1.0)), u.x),
        u.y);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 p = world_pos.xz;
    float variation = value_noise(p * 1.45);
    float grains = rand2(floor(p * 21.0));
    vec3 soil = mix(vec3(0.195, 0.125, 0.075), vec3(0.32, 0.215, 0.128), variation);
    ALBEDO = soil + (grains - 0.5) * 0.030;
    ROUGHNESS = 0.99;
}
