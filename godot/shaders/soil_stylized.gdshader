shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
varying vec3 world_at;

float hash21(vec2 uv) {
    return fract(sin(dot(uv, vec2(79.2, 185.7))) * 43758.5453);
}

void vertex() {
    world_at = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 p = world_at.xz;
    float irregular = hash21(floor(p * 8.0));
    float fine = hash21(floor(p * 30.0));
    vec3 soil = mix(vec3(0.19, 0.115, 0.072), vec3(0.33, 0.215, 0.135), irregular);
    ALBEDO = soil + (fine - 0.5) * 0.05;
    ROUGHNESS = 1.0;
}
