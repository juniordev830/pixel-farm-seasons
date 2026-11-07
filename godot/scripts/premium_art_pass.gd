extends Node3D
## Passo visual premium: caminho organico e transicao de solo suave.
## Apenas geometria de cena, sem colisoes, sem alterar save ou gameplay.
## Material por vertices reduz draw calls e evita arquivos externos.
const BARN_FINISH := preload("res://shaders/barn_planks_stylized.gdshader")
const PLASTER_FINISH := preload("res://shaders/cream_plaster_stylized.gdshader")
const ROAD_STEPS := 72
const EARTH_DARK := Color("#755d49")
const EARTH_LIGHT := Color("#a28568")
const GRASS_EDGE := Color("#5b7c4b")
const CROSS_SECTIONS := [-1.0, -0.84, -0.55, -0.22, 0.22, 0.55, 0.84, 1.0]

var road_ready := false


func _ready() -> void:
    call_deferred("_install")


func _road_center(z: float) -> Vector3:
    # A estrada principal se curva para ligar a entrada a varanda.
    var bend := 1.0 - smoothstep(-8.0, 8.0, z)
    return Vector3(-4.0 - 10.7 * bend, 0.060, z)


func _side(z: float) -> Vector3:
    var direction := (_road_center(z - 0.15) - _road_center(z + 0.15)).normalized()
    return Vector3(-direction.z, 0.0, direction.x).normalized()


func _point(z: float, u: float) -> Vector3:
    var width := 2.20 + 0.17 * sin(z * 0.31) + 0.12 * sin(z * 0.87)
    var edge_wobble := 0.11 * sin(z * 1.7 + u * 4.0) * absf(u)
    return _road_center(z) + _side(z) * (width * u + edge_wobble)


func _tint(z: float, u: float) -> Color:
    var warmth := 0.50 + 0.26 * sin(z * 0.73 + u * 3.8)
    var soil := EARTH_DARK.lerp(EARTH_LIGHT, warmth)
    var grassy_margin := smoothstep(0.55, 1.0, absf(u))
    return soil.lerp(GRASS_EDGE, grassy_margin)


func _vertex(builder: SurfaceTool, at: Vector3, tint: Color) -> void:
    builder.set_normal(Vector3.UP)
    builder.set_color(tint)
    builder.add_vertex(at)


func _road_surface() -> void:
    var builder := SurfaceTool.new()
    builder.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(ROAD_STEPS):
        var z0 := lerpf(39.0, -7.4, float(i) / float(ROAD_STEPS))
        var z1 := lerpf(39.0, -7.4, float(i + 1) / float(ROAD_STEPS))
        for j in range(CROSS_SECTIONS.size() - 1):
            var u0: float = CROSS_SECTIONS[j]
            var u1: float = CROSS_SECTIONS[j + 1]
            var p00 := _point(z0, u0)
            var p01 := _point(z0, u1)
            var p10 := _point(z1, u0)
            var p11 := _point(z1, u1)
            _vertex(builder, p00, _tint(z0, u0))
            _vertex(builder, p10, _tint(z1, u0))
            _vertex(builder, p01, _tint(z0, u1))
            _vertex(builder, p01, _tint(z0, u1))
            _vertex(builder, p10, _tint(z1, u0))
            _vertex(builder, p11, _tint(z1, u1))
    var road_mesh := builder.commit()
    var mat := StandardMaterial3D.new()
    mat.vertex_color_use_as_albedo = true
    mat.roughness = 0.98
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    var road := MeshInstance3D.new()
    road.name = "Estrada organica da fazenda"
    road.mesh = road_mesh
    road.material_override = mat
    road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(road)
    road_ready = road_mesh != null


func _install() -> void:
    # A aplicacao existente de shaders termina antes de esconder as malhas antigas.
    await get_tree().process_frame
    await get_tree().process_frame
    _road_surface()
    if not road_ready:
        push_error("PremiumArtPass: falha ao construir caminho natural")
        return
    for old_name in ["Estrada da fazenda", "Caminho ate a varanda"]:
        var old_road := get_parent().get_node_or_null(old_name) as MeshInstance3D
        if old_road != null:
            old_road.visible = false
    _apply_wall_finishes()


func _apply_wall_finishes() -> void:
    # Texturas leves geradas em shader, sem novos objetos nem colisões.
    var barn := get_parent().get_node_or_null("Celeiro vermelho") as MeshInstance3D
    if barn != null:
        var wood := ShaderMaterial.new()
        wood.shader = BARN_FINISH
        barn.material_override = wood

    var life := get_parent().get_node_or_null("LifeSim")
    if life == null:
        return
    var plaster := ShaderMaterial.new()
    plaster.shader = PLASTER_FINISH
    for wall_name in ["Parede oeste", "Parede leste", "Parede fundos",
                      "Fachada terreo esquerda", "Fachada terreo direita",
                      "Fachada segundo andar"]:
        var wall := life.get_node_or_null(wall_name) as MeshInstance3D
        if wall != null:
            wall.material_override = plaster
