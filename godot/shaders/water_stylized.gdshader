shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, cull_disabled;

// Gentle color ripples; does not affect physics or gameplay.
uniform vec4 water_dark : source_color = vec4(0.07, 0.30, 0.35, 1.0);
uniform vec4 water_light : source_color = vec4(0.22, 0.57, 0.60, 1.0);
uniform float movement_speed : hint_range(0.0, 2.0) = 0.35;

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 p = world_position.xz;
    float slow = sin(p.x * 1.3 + TIME * movement_speed)
        * cos(p.y * 1.1 - TIME * movement_speed * 0.8);
    float ripples = sin(p.x * 4.1 + p.y * 2.3 - TIME * movement_speed * 2.0);
    float mix_factor = clamp(0.53 + 0.19 * slow + 0.06 * ripples, 0.0, 1.0);
    // Slightly brighter at grazing angles, without textures or extra draw calls.
    // NORMAL and VIEW are both in view space in Godot spatial fragment shaders.
    float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
    float grazing = 1.0 - facing;
    float rim = grazing * grazing * grazing;
    ALBEDO = mix(water_dark.rgb, water_light.rgb,
        clamp(mix_factor + 0.18 * rim, 0.0, 1.0));
    ROUGHNESS = 0.36;
    SPECULAR = 0.65;
}
