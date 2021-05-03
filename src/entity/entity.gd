tool
extends Area2D
## Entity


## Enums
enum States {
	IDLE,
	SEEKING,
	MOVING,
	EATING,
	ATTACKING,
	RETREATING,
	REPRODUCING,
}



## Exported Variables
export(float, 0.0, 1000.0) var energy := 25.0 setget set_energy

export(float, 0.0, 100.0) var speed := 22.0 setget set_speed

export(float, 16.0, 100.0) var vision := 32.0 setget set_vision

export var variance := Color.white setget set_variance

export(int, 5, 64) var potential := 5 setget set_potential

export var parent_world : NodePath



## Private Variables
var _hovered := false

var _selected := false

var _image : Image = null

var _target := Vector2.INF

var _state : int = States.IDLE



## OnReady Variables
onready var collision_shape : CollisionShape2D = get_node("CollisionShape2D")

onready var view : Area2D = get_node("View")

onready var view_shape : CollisionShape2D = get_node("View/CollisionShape2D")

onready var sprite : Sprite = get_node("Sprite")



## Built-In Virtual Methods
func _ready() -> void:
	if is_instance_valid(collision_shape) \
			and is_instance_valid(collision_shape.shape):
		collision_shape.shape = collision_shape.shape.duplicate()
		(collision_shape.shape as RectangleShape2D).extents = Vector2.ONE * potential
	
	if is_instance_valid(view_shape) \
			and is_instance_valid(view_shape.shape):
		view_shape.shape = view_shape.shape.duplicate()
		(view_shape.shape as CircleShape2D).radius = vision


func _process(delta : float) -> void:
	if Engine.editor_hint:
		return
	
	var world = get_node_or_null(parent_world)
	if is_instance_valid(world) \
			and is_instance_valid(view):
		var areas := view.get_overlapping_areas()
		var best_target = [-INF, Vector2.INF]
		
		for area in areas:
			area = area as Area2D
			
			var points := -INF
			var distance := position.distance_to(area.position)
			
			if area.is_in_group("foods"):
				points = area.nutrition
				if points > best_target[0]:
					best_target[0] = points
					best_target[1] = area.position
			elif area.is_in_group("entities"):
				points = area.energy
				if points < energy:
					best_target[0] = points
					best_target[1] = area.position
		
		_target = best_target[1]
	
	if _target == Vector2.INF:
		_target = world.random_world_point()
	
	var distance := position.distance_to(_target)
	if distance > 8:
		translate(position.direction_to(_target) * speed * delta)
	else:
		_target = Vector2.INF
	update()


func _draw() -> void:
	if _hovered or _selected:
		var color : Color
		if _hovered:
			color = Color(1, 1, 1, 0.2)
		if _selected:
			color = Color.white
		
		draw_arc(
			Vector2.ZERO,
			16, 0, 360, 16, color, 2
		)
		
		if not _target == Vector2.INF:
			draw_line(
				to_local(position),
				to_local(_target),
				variance,
				2
			)
			
			var target_angle := rad2deg(_target.angle_to_point(position))
			draw_arc(
				Vector2.ZERO,
				vision,
				deg2rad(target_angle - 32),
				deg2rad(target_angle + 32),
				3,
				variance,
				6
			)
		
		draw_arc(
			Vector2.ZERO,
			vision,
			0,
			deg2rad(360),
			16,
			variance,
			2
		)



## Public Methods
func set_energy(value : float) -> void:
	energy = value if value > 0.0 else 0.0
	
	scale = Vector2.ONE * max(clamp(energy / 200.0, 1.0, 3.0), scale.x)
	if energy <= 0.0:
		print("die")


func set_speed(value : float) -> void:
	speed = value


func set_vision(value : float) -> void:
	vision = value
	
	if is_instance_valid(view_shape) \
			and is_instance_valid(view_shape.shape):
		(view_shape.shape as CircleShape2D).radius = vision


func set_variance(color : Color) -> void:
	variance = color


func set_potential(value : int) -> void:
	potential = value + ((value + 1) % 2)
	property_list_changed_notify()
	
	if is_instance_valid(collision_shape) \
			and is_instance_valid(collision_shape.shape):
		(collision_shape.shape as RectangleShape2D).extents = Vector2.ONE * potential


func randomize() -> void:
	self.variance = Color(randi())
	self.speed = 14 + (16 * variance.r)
	self.vision = 30 + (16 * variance.b)
	self.potential = 5 + int(3 * variance.g)
	birth()


func select() -> void:
	_selected = true
	
	var world := get_node_or_null(parent_world)
	if is_instance_valid(world):
		world.get_player().select(self)


func unselect() -> void:
	_selected = false
	
	var world := get_node_or_null(parent_world)
	if is_instance_valid(world):
		world.get_player().unselect(self)


func birth() -> void:
	_image = Image.new()
	_image.create(potential, potential, false, Image.FORMAT_RGB8)
	evolve()


func mutate() -> void:
	pass


func evolve() -> void:
	if not is_instance_valid(_image):
		printerr("need to call on entity's birth first!")
		return
	
	var axis = (potential - 1) / 2
	
	_image.lock()
	for x in range(axis + 1):
		for y in range(potential):
			if (randi() % 10) % 2 == 0:
				_image.set_pixel(x, y, variance)
				if not x == axis:
					_image.set_pixel(potential - x - 1, y, variance)
	_image.unlock()
	
	var texture = ImageTexture.new()
	texture.create_from_image(_image, 0)
	get_node("Sprite").texture = texture


func eat(nutrition) -> void:
	self.energy += nutrition


func eaten(eater) -> void:
	var dominant_color := 0 if eater.variance[0] > eater.variance[1] else 1
	dominant_color = dominant_color if eater.variance[dominant_color] > eater.variance[2] else 2
	eater.eat(energy * variance[dominant_color])
	queue_free()


## Private Methods
func _on_mouse_entered() -> void:
	_hovered = true


func _on_mouse_exited() -> void:
	_hovered = false


func _on_input_event(viewport : Node, event : InputEvent, shape_idx : int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			if _selected:
				unselect()
			else:
				select()
			get_tree().set_input_as_handled()


func _on_area_entered(area : Area2D) -> void:
	if area.is_in_group("foods"):
		area.eaten(self)
	elif area.is_in_group("entities"):
		if not variance.is_equal_approx(area.variance) and area.energy < energy:
			area.eaten(self)
