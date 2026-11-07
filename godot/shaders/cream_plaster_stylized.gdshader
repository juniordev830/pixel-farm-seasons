shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
varying vec3 world_pos;

float plaster_noise(vec2 p) {
    return fract(sin(dot(p, vec2(54.17, 19.93))) * 43758.5453);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 p = world_pos.xy + world_pos.z * 0.37;
    float freckles = plaster_noise(floor(p * 18.0));
    float broad = sin(world_pos.y * 2.2 + world_pos.x * 0.6) * 0.018;
    vec3 cream = vec3(0.90, 0.80, 0.65);
    ALBEDO = cream * (0.96 + freckles * 0.065 + broad);
    ROUGHNESS = 1.0;
}
