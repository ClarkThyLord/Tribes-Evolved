tool
extends Area2D
## Entity



## Refrences
const CaveStoryFont := preload("res://assets/fonts/cave_story.tres")



## Signals
signal ate(energy)

signal mated(location, parent_a, parent_b)

signal died(entity)



## Enums
enum States {
	N, # NULL
	U, # UNBORN
	B, # BORN
	S, # SEEKING
	E, # EATING
	M, # MATING
	D, # DEAD
}



## Exported Variables
export var color := Color.white setget set_color

export(float, 0.0, 1000.0) var energy := 25.0 setget set_energy

export(float, 0.0, 1.0) var energy_rate := 0.07

export(float, 0.0, 100.0) var speed := 22.0 setget set_speed

export(float, 16.0, 100.0) var vision := 32.0 setget set_vision

export(int, 5, 64) var potential := 5 setget set_potential

export(int, 1, 600) var life_span := 60

export var world : NodePath setget set_world

export var debug := false



## Private Variables
var _world

var _life_span := 0.0

var _state : int = States.N

var __state : int = States.N

var _target := Vector2.INF

var _hovered := false

var _selected := false



## OnReady Variables
onready var collision_shape : CollisionShape2D = get_node("CollisionShape2D")

onready var view : Area2D = get_node("View")

onready var view_shape : CollisionShape2D = get_node("View/CollisionShape2D")

onready var sprite : Sprite = get_node("Sprite")

onready var particles : CPUParticles2D = get_node("CPUParticles2D")



## Built-In Virtual Methods
func _ready() -> void:
	if Engine.editor_hint:
		return
	
	_set_state(States.B)
	self.world = world
	particles.color = color
	particles.emitting = true


func _process(delta : float) -> void:
	if Engine.editor_hint:
		return
	
	_set_state(States.S)
	if _state != __state:
		_print_state_transition()
	
	if is_inside_tree() and is_instance_valid(_world):
		if is_instance_valid(view):
			var areas := view.get_overlapping_areas()
			var best_target = [-INF, INF, Vector2.INF]
			
			for area in areas:
				area = area as Area2D
				
				var distance := position.distance_to(area.position)
				
				if area.is_in_group("foods"):
					if area.energy > best_target[0] and distance <= best_target[1]:
						best_target[0] = area.energy
						best_target[2] = area.position
				elif area.is_in_group("entities"):
					if area.energy < energy and distance <= best_target[1] \
						and area.is_in_group("entities"):
						if fondness(area) < 0.0 \
							or (energy >= 600 and area.energy >= 600):
							best_target[0] = area.energy
							best_target[2] = area.position
			
			if not best_target[2] == Vector2.INF:
				_target = best_target[2]
		
		if _target == Vector2.INF:
			var radius = vision * 2.5
			while true:
				_target = position + Vector2(
						(randi() % int(radius * 2)) - radius,
						(randi() % int(radius * 2)) - radius)
				if _world.is_world_point(_target):
					break
		
		var distance := position.distance_to(_target)
		if distance > 4:
			translate(position.direction_to(_target) * speed * delta)
		else:
			_target = Vector2.INF
	
	update()
	self.energy -= (energy * energy_rate) * delta
	_life_span += 0.1 * delta
	if _life_span >= life_span:
		die()


func _draw() -> void:
	if _hovered or _selected:
		var color : Color
		if _hovered:
			color = Color(1, 1, 1, 0.2)
		if _selected:
			color = Color.white
		
		if not _target == Vector2.INF:
			if debug:
				draw_line(
					to_local(position),
					to_local(_target),
					color,
					2
				)
			
			var target_angle := rad2deg(_target.angle_to_point(position))
			draw_arc(
				Vector2.ZERO,
				vision,
				deg2rad(target_angle - 32),
				deg2rad(target_angle + 32),
				3,
				color,
				6
			)
		
		draw_arc(
			Vector2.ZERO,
			vision,
			0,
			deg2rad(360),
			16,
			color,
			2
		)
		
		if debug:
			draw_arc(
				Vector2.ZERO,
				16, 0, 360, 16, color, 2
			)
			
			var state = States.keys()[_state]
			var char_size = CaveStoryFont.get_string_size(state)
			draw_string(
					CaveStoryFont,
					Vector2(0, -12) - (char_size / 2),
					state, color)



## Public Methods
func randomize(parent_a = null, parent_b = null) -> void:
	_set_state(States.U)
	if is_instance_valid(parent_a) and is_instance_valid(parent_b):
		var dominant = clamp(randf() - 0.8, 0.0, 0.2)
		var color_a = parent_a.color.to_rgba32() * (0.4 + dominant)
		var color_b = parent_b.color.to_rgba32() * (0.4 - dominant)
		self.color = Color(int(color_a + color_b))
		self.color.a = 1.0
		
		self.energy = 25 + (100 * (1 - color.v))
		self.speed = 14 + (16 * color.r)
		self.vision = 30 + (16 * color.b)
		self.potential = parent_a.potential
		
		var image : Image = parent_a.get_image()
		var parent_image : Image = parent_b.get_image()
		image.lock()
		parent_image.lock()
		var axis = (potential - 1) / 2
		for x in range(axis + 1):
			for y in range(potential):
				if (randi() % 10) % 2 == 0:
					var pixel_color := parent_image.get_pixel(x, y)
					if pixel_color.a > 0.0:
						pixel_color = color
					
					image.set_pixel(x, y, pixel_color)
					if not x == axis:
						image.set_pixel(potential - x - 1, y, pixel_color)
		image.unlock()
		parent_image.unlock()
		
		var texture = ImageTexture.new()
		texture.create_from_image(image, 0)
		get_node("Sprite").texture = texture
	else:
		self.color = Color(randi())
		self.color.a = 1.0
		
		self.energy = 25 + (100 * (1 - color.v))
		self.speed = 14 + (16 * color.r)
		self.vision = 30 + (16 * color.b)
		self.potential = 5 + int(3 * color.g)
		
		var image := Image.new()
		image.create(potential, potential, false, Image.FORMAT_RGBA8)
		image.lock()
		var axis = (potential - 1) / 2
		for x in range(axis + 1):
			for y in range(potential):
				if (randi() % 10) % 2 == 0:
					image.set_pixel(x, y, color)
					if not x == axis:
						image.set_pixel(potential - x - 1, y, color)
		image.unlock()
		
		var texture = ImageTexture.new()
		texture.create_from_image(image, 0)
		get_node("Sprite").texture = texture


func set_world(node_path : NodePath) -> void:
	world = node_path
	if is_inside_tree() and not world.is_empty():
		_world = get_node_or_null(world)


func set_energy(value : float) -> void:
	energy = value if value > 0.0 else 0.0
	
	scale = Vector2.ONE * max(clamp(energy / 200.0, 1.0, 3.0), scale.x)
	property_list_changed_notify()
	
	if Engine.editor_hint:
		if energy <= 0.0:
			die()


func set_speed(value : float) -> void:
	speed = value


func set_vision(value : float) -> void:
	vision = value
	
	if is_instance_valid(view_shape) \
			and is_instance_valid(view_shape.shape):
		(view_shape.shape as CircleShape2D).radius = vision
	property_list_changed_notify()


func set_color(value : Color) -> void:
	color = value


func set_potential(value : int) -> void:
	potential = value + ((value + 1) % 2)
	
	if is_instance_valid(collision_shape) \
			and is_instance_valid(collision_shape.shape):
		(collision_shape.shape as RectangleShape2D).extents = Vector2.ONE * potential
	property_list_changed_notify()


func get_state() -> int:
	return _state


func get_image() -> Image:
	return get_node("Sprite").texture.get_data()


func get_texture() -> Texture:
	return get_node("Sprite").texture


func get_dominant_color() -> int:
	var dominant_color := 0 if color[0] > color[1] else 1
	dominant_color = dominant_color if color[dominant_color] > color[2] else 2
	return dominant_color


func select() -> void:
	_selected = true
	
	if is_instance_valid(_world):
		_world.get_player().select(self)


func unselect() -> void:
	_selected = false
	
	if is_instance_valid(_world):
		_world.get_player().unselect(self)


func fondness(entity) -> float:
	var value = 0.0
	
	value = get_dominant_color() - entity.get_dominant_color()
	
	return clamp(value, -1.0, 1.0)


func eat(consumable) -> void:
	_set_state(States.E)
	_print_state_transition()
	var consumable_energy = consumable.eaten(self)
	self.energy += consumable_energy
	emit_signal("ate", consumable_energy)


func eaten(by) -> float:
	die()
	return energy * color[by.get_dominant_color()]


func mate(partner) -> void:
	_set_state(States.M)
	_print_state_transition()
	emit_signal("mated", position, self, partner)
	self.energy -= 600
	partner.energy -= 600


func die() -> void:
	_set_state(States.D)
	_print_state_transition()
	emit_signal("died", self)
	get_parent().remove_child(self)
	queue_free()



## Private Methods
func _set_state(state : int) -> void:
	__state = _state
	_state = state


func _print_state_transition() -> void:
	if debug and _selected:
		print(States.keys()[__state] + " > " + States.keys()[_state])


func _on_mouse_entered() -> void:
	_hovered = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_mouse_exited() -> void:
	_hovered = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_input_event(viewport : Node, event : InputEvent, shape_idx : int) -> void:
	if event is InputEventMouse:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and not event.pressed:
				if _selected:
					unselect()
				else:
					select()
				get_tree().set_input_as_handled()


func _on_area_entered(area : Area2D) -> void:
	if area.is_in_group("consumables"):
		if area.is_in_group("foods"):
			eat(area)
		elif area.is_in_group("entities"):
			if fondness(area) < 0.0 and energy > area.energy:
				eat(area)
			elif energy >= 600 and area.energy >= 600:
				mate(area)
