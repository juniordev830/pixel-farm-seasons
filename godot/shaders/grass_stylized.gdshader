shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Fine mottling and broad green variation, rendered on the real farm terrain.
// This is a shader on playable geometry, not a photo/background replacement.
varying vec3 world_at;

float hash21(vec2 uv) {
    return fract(sin(dot(uv, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
    world_at = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 p = world_at.xz;
    float noise_a = hash21(floor(p * 1.65));
    float noise_b = hash21(floor(p * 9.0));
    float fields = sin(p.x * 0.12) * sin(p.y * 0.085) * 0.5 + 0.5;
    vec3 shaded = mix(vec3(0.255, 0.415, 0.208), vec3(0.345, 0.505, 0.257), fields);
    shaded += (noise_a - 0.5) * 0.075;
    shaded += (noise_b - 0.5) * 0.022;
    ALBEDO = clamp(shaded, vec3(0.0), vec3(1.0));
    ROUGHNESS = 0.98;
}
