shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
varying vec3 world_pos;

float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(17.13, 63.71))) * 43758.5453);
}

float soft_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash21(i), hash21(i + vec2(1.0, 0.0)), u.x),
        mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), u.x),
        u.y);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 p = world_pos.xz;
    float broad = soft_noise(p * 0.25);
    float dust = soft_noise(p * 2.6);
    float pebbles = hash21(floor(p * 16.0));
    vec3 earth = mix(vec3(0.39, 0.275, 0.185), vec3(0.63, 0.455, 0.295), broad);
    earth += (dust - 0.5) * 0.085;
    earth += (pebbles - 0.5) * 0.023;
    ALBEDO = clamp(earth, vec3(0.0), vec3(1.0));
    ROUGHNESS = 0.95;
}
