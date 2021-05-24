extends Area2D
## Spawn



## Refrences
const Entity := preload("res://src/entity/entity.tscn")

const CaveStoryFont := preload("res://assets/fonts/cave_story.tres")



## Signals
signal evolved(spawn)

signal selected(spawn)

signal unselected(spawn)



## Exported Variables
export var spawn_name := ""

export(float, 0.1, 1.0) var spawn_rate := 0.1

export(int, 0, 250) var spawn_radius := 50

export(int, 1, 250) var population_minimum := 64

export(float, 0.0, 1.0) var mutation_rate := 0.01

export(float, 0.0, 1.0) var evolution_rate := 0.75

export var world : NodePath setget set_world



## Private Variables
var _world

var _lineage := []

var _population := []

var _evolutions := 0

var _evolution_points := 0.0

var _evolution_level := 500.0

var _hovered := false

var _selected := false

var _draw_time := 0

var _draw_points := 0

var _draw_color := Color.white



## Built-In Virtual Methods
func _ready() -> void:
	if Engine.editor_hint:
		return
	
	self.world = world
	
	if _lineage.empty():
		_add_ancestor()
		_draw_color = _lineage[0].color
		spawn_name = char(int(65 + (25 * _draw_color.r))) \
				+ char(int(65 + (25 * _draw_color.g))) \
				+ char(int(65 + (25 * _draw_color.b))) \
				+ "-" \
				+ char(int(48 + (10 * _draw_color.v)))
	
	_draw_points = 4 + (randi() % 18)


func _exit_tree() -> void:
	for ancestor in _lineage:
		match typeof(ancestor):
			TYPE_OBJECT:
				ancestor.queue_free()
			TYPE_ARRAY:
				for parent_ancestor in ancestor:
					parent_ancestor.queue_free()


func _process(delta : float) -> void:
	if Engine.editor_hint:
		return
	
	if is_instance_valid(_world) \
			and randf() < spawn_rate \
			and _population.size() < population_minimum:
		while true:
			var spawn_point := position + Vector2(
					(randi() % (spawn_radius * 2)) - spawn_radius,
					(randi() % (spawn_radius * 2)) - spawn_radius)
			if _world.is_world_point(spawn_point):
				spawn(spawn_point)
				break
	
	update()
	_draw_time = (_draw_time + 1) % 360


func _draw() -> void:
	var identify := _hovered or _selected
	draw_arc(
		Vector2.ZERO,
		32,
		deg2rad(0 + _draw_time),
		deg2rad(360 + _draw_time),
		_draw_points,
		_draw_color,
		4 if identify else 2
	)
	
	if identify:
		var name_size := CaveStoryFont.get_string_size(spawn_name)
		draw_string(
				CaveStoryFont,
				Vector2(
						0 - (name_size.x / 2),
						0),
				spawn_name,
				_draw_color)



## Public Methods
func randomize() -> void:
	self.spawn_rate = 0.1 + clamp(randf() - 0.5, 0.0, 1.0) 
	self.spawn_radius = 64 + (randi() % 128)
	self.population_minimum = 10 + (randi() % 40)
	self.mutation_rate = 0.01 + clamp(randf() - 0.96, 0.0, 1.0) 
	self.evolution_rate = 0.4 + clamp(randf() - 0.4, 0.0, 1.0)


func set_world(node_path : NodePath) -> void:
	world = node_path
	if is_inside_tree() and not world.is_empty():
		_world = get_node_or_null(world)


func select() -> void:
	_selected = true
	emit_signal("selected", self)


func unselect() -> void:
	_selected = false
	emit_signal("unselected", self)


func get_color() -> Color:
	return _draw_color


func get_lineage() -> Array:
	return _lineage.duplicate()


func get_evolutions() -> int:
	return _evolutions


func get_evolution_progress() -> float:
	return _evolution_points / _evolution_level


func spawn(spawn_point : Vector2, parent_a = null, parent_b = null):
	if is_instance_valid(_world) \
			and not _lineage.empty():
		
		if (randf() < mutation_rate or _evolution_points >= _evolution_level) \
				and is_instance_valid(parent_a) \
				and is_instance_valid(parent_b):
			evolve(parent_a, parent_b)
		
		var entity = _lineage.back().duplicate()
		entity.position = spawn_point
		entity.world = world
		entity.connect("died", self, "_on_Entity_died")
		entity.connect("mated", self, "_on_Entity_mated")
		
		_evolution_points += entity.energy
		
		_population.append(entity)
		_world.add_child(entity)


func evolve(parent_a, parent_b) -> void:
	parent_a = _lineage.back()
	_lineage.append([
		parent_a.duplicate(),
		parent_b.duplicate()])
	_add_ancestor(parent_a, parent_b)
	_evolutions += 1
	_evolution_points = 0
	_evolution_level += _evolution_level * evolution_rate
	scale += Vector2.ONE * (_evolutions * 0.15)
	emit_signal("evolved", self)



## Private Methods
func _add_ancestor(parent_a = null, parent_b = null) -> void:
	var ancestor := Entity.instance()
	ancestor.randomize(parent_a, parent_b)
	_lineage.append(ancestor)


func _on_input_event(viewport : Node, event : InputEvent, shape_idx : int) -> void:
	if event is InputEventMouse:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		if event is InputEventMouseButton:
			match event.button_index:
				BUTTON_LEFT:
					if event.doubleclick:
						select()
			get_tree().set_input_as_handled()


func _on_Entity_died(entity) -> void:
	_population.erase(entity)


func _on_mouse_entered():
	_hovered = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_mouse_exited():
	_hovered = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_Entity_mated(location, parent_a, parent_b) -> void:
	spawn(location, parent_a, parent_b)
