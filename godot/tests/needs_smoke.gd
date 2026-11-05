extends SceneTree
## Run: godot --headless --path godot --script res://tests/needs_smoke.gd
func _initialize() -> void:
    var scene := load("res://main.tscn") as PackedScene
    if scene == null:
        push_error("Could not load main scene")
        quit(1)
        return
    var main := scene.instantiate()
    root.add_child(main)
    await process_frame
    var needs := main.get_node_or_null("FarmerNeeds")
    var clock := main.get_node_or_null("DayNightController")
    var player := main.get_node_or_null("Player")
    if needs == null or clock == null or player == null:
        push_error("Missing game systems")
        quit(1)
        return
    clock.paused = true
    needs.energy = 10.0
    assert(is_equal_approx(needs.movement_multiplier(), 0.62))
    needs.energy = 0.0
    assert(is_equal_approx(needs.movement_multiplier(), 0.48))
    needs.energy = 100.0
    assert(is_equal_approx(needs.movement_multiplier(), 1.0))
    needs.hunger = 90.0
    needs.eat()
    assert(needs.hunger == 35.0)
    needs.energy = 12.0
    clock.set_clock(23, 0)
    var day_before: int = needs.day_index
    needs.sleep_until_morning()
    assert(needs.day_index == day_before + 1)
    assert(needs.energy == 100.0)
    assert(clock.get_clock() == "06:00")
    clock.set_clock(23, 59)
    clock.paused = false
    clock._process(2.0)
    clock.paused = true
    assert(clock.day_index == day_before + 2)
    assert(clock.get_clock() == "00:01")
    needs._process(0.0)
    assert(needs.day_index == clock.day_index)
    print("PASS: needs, eating, fatigue, sleep and midnight rollover")
    quit(0)
