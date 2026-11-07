shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
varying vec3 world_pos;

float grain_hash(vec2 p) {
    return fract(sin(dot(p, vec2(16.19, 91.73))) * 43758.5453);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    float strip = world_pos.y * 2.75;
    float plank_id = floor(strip);
    float seam = 1.0 - smoothstep(0.015, 0.065, fract(strip));
    float variation = (grain_hash(vec2(plank_id, floor(world_pos.x * 0.13))) - 0.5) * 0.13;
    float grain = sin(world_pos.x * 13.0 + world_pos.y * 3.2) * 0.014;
    float shade = 0.97 + variation + grain - seam * 0.19;
    ALBEDO = vec3(0.63, 0.28, 0.215) * shade;
    ROUGHNESS = 0.93;
}
