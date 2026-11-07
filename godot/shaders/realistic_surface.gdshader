shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Procedural, tiled-in-world material: no external textures or UV dependency.
// Kind: 0=lime plaster, 1=wood, 2=terracotta/ceramic, 3=galvanized metal.
uniform vec4 base_color : source_color = vec4(0.8, 0.7, 0.6, 1.0);
uniform int surface_kind = 0;
uniform float texture_scale : hint_range(0.1, 12.0) = 2.0;
uniform float base_roughness : hint_range(0.0, 1.0) = 0.84;
uniform float metalness : hint_range(0.0, 1.0) = 0.0;

varying vec3 surface_world_pos;

float cell_hash(vec3 cell) {
    return fract(sin(dot(cell, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

float value_noise_3d(vec3 point) {
    vec3 origin = floor(point);
    vec3 blend = fract(point);
    blend = blend * blend * (3.0 - 2.0 * blend);
    float a = mix(cell_hash(origin), cell_hash(origin + vec3(1.0, 0.0, 0.0)), blend.x);
    float b = mix(cell_hash(origin + vec3(0.0, 1.0, 0.0)), cell_hash(origin + vec3(1.0, 1.0, 0.0)), blend.x);
    float c = mix(cell_hash(origin + vec3(0.0, 0.0, 1.0)), cell_hash(origin + vec3(1.0, 0.0, 1.0)), blend.x);
    float d = mix(cell_hash(origin + vec3(0.0, 1.0, 1.0)), cell_hash(origin + vec3(1.0, 1.0, 1.0)), blend.x);
    return mix(mix(a, b, blend.y), mix(c, d, blend.y), blend.z);
}

void vertex() {
    surface_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec3 p = surface_world_pos * texture_scale;
    float broad = value_noise_3d(p * 0.45);
    float detail = value_noise_3d(p * 2.8);
    float variation = (broad - 0.5) * 0.18 + (detail - 0.5) * 0.055;

    if (surface_kind == 1) {
        // Elongated grain: subtle, not a repeating painted stripe.
        float grain = sin(p.y * 10.0 + broad * 4.0 + sin(p.x * 1.8) * 0.8);
        variation += grain * 0.035;
    } else if (surface_kind == 2) {
        // Fine burnt-clay mottling across roof tiles.
        variation += (value_noise_3d(p * 5.2) - 0.5) * 0.07;
    } else if (surface_kind == 3) {
        // Light surface variation on aged galvanized metal.
        variation *= 0.40;
    }

    ALBEDO = clamp(base_color.rgb * (1.0 + variation), vec3(0.0), vec3(1.0));
    ROUGHNESS = clamp(base_roughness + (0.5 - detail) * 0.10, 0.2, 1.0);
    METALLIC = metalness;
    SPECULAR = 0.36;
}
