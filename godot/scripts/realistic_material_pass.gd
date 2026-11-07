extends Node3D
## Realism pass 01: improve PBR response of existing farm surfaces.
## Cosmetic only: no new colliders, geometry, save keys or gameplay changes.
## Shader samples world coordinates to work on primitive meshes without UVs.

const SURFACE_SHADER: Shader = preload("res://shaders/realistic_surface.gdshader")
var applied_count: int = 0


func _ready() -> void:
    call_deferred("_apply_finishes")


func _finish(color: Color, kind: int, scale: float, rough: float, metal: float = 0.0) -> ShaderMaterial:
    var finish := ShaderMaterial.new()
    finish.shader = SURFACE_SHADER
    finish.set_shader_parameter("base_color", color)
    finish.set_shader_parameter("surface_kind", kind)
    finish.set_shader_parameter("texture_scale", scale)
    finish.set_shader_parameter("base_roughness", rough)
    finish.set_shader_parameter("metalness", metal)
    return finish


func _apply_finishes() -> void:
    # The existing environment/premium passes also run deferred.
    # Apply to selected untouched meshes after those passes have assembled.
    await get_tree().process_frame
    await get_tree().process_frame
    await get_tree().process_frame

    var plaster := _finish(Color("#e8dac1"), 0, 1.7, 0.92)
    var wood := _finish(Color("#956743"), 1, 1.4, 0.81)
    var roof := _finish(Color("#ae6047"), 2, 2.5, 0.87)
    var barn_roof := _finish(Color("#62676b"), 3, 3.0, 0.60, 0.44)
    var metal := _finish(Color("#a0a7a6"), 3, 2.5, 0.48, 0.67)

    var selections: Dictionary = {
        "Casa - paredes de dois pavimentos": plaster,
        "Telhado esquerdo": roof,
        "Telhado direito": roof,
        "Cobertura da varanda": roof,
        "Faixa entre andares": wood,
        "Rodape da fachada": wood,
        "Piso da varanda": wood,
        "Pilar da varanda": wood,
        "Porta principal": wood,
        "Banco varanda": wood,
        "Mourao": wood,
        "Travessa da cerca": wood,
        "Celeiro - telhado esquerda": barn_roof,
        "Celeiro - telhado direita": barn_roof,
        "Silo pequeno": metal,
        "Silo telhado": metal,
    }
    for child in get_parent().get_children():
        if not child is MeshInstance3D:
            continue
        var mesh_instance := child as MeshInstance3D
        var tag := String(mesh_instance.get_meta("native_prop", ""))
        if not selections.has(tag):
            continue
        mesh_instance.material_override = selections[tag] as Material
        mesh_instance.set_meta("realism_surface", tag)
        applied_count += 1

    # LifeSim replaces the temporary solid house with enterable walls.
    # Finish the actual visible facade after PremiumArtPass has run.
    var life := get_parent().get_node_or_null("LifeSim")
    if life != null:
        for wall_name in ["Parede oeste", "Parede leste", "Parede fundos",
                          "Fachada terreo esquerda", "Fachada terreo direita",
                          "Fachada segundo andar"]:
            var wall := life.get_node_or_null(wall_name) as MeshInstance3D
            if wall != null:
                wall.material_override = plaster
                wall.set_meta("realism_surface", wall_name)
                applied_count += 1
