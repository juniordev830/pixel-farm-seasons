shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
varying vec3 world_pos;

float rand2(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = rand2(i);
    float b = rand2(i + vec2(1.0, 0.0));
    float c = rand2(i + vec2(0.0, 1.0));
    float d = rand2(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 p = world_pos.xz;
    float meadow = value_noise(p * 0.14);
    float patches = value_noise(p * 0.91);
    float tiny = value_noise(p * 8.0);
    vec3 shaded = mix(vec3(0.23, 0.38, 0.18), vec3(0.36, 0.49, 0.24), meadow);
    shaded += (patches - 0.5) * 0.035;
    shaded += (tiny - 0.5) * 0.008;
    ALBEDO = clamp(shaded, vec3(0.0), vec3(1.0));
    ROUGHNESS = 0.98;
}
