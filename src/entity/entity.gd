tool
extends Area2D
## Entity



## Exported Variables
export(float, 0.0, 100.0) var energy := 25.0 setget set_energy

export(float, 0.0, 100.0) var speed := 1.0 setget set_speed

export(float, 16.0, 100.0) var vision := 32.0 setget set_vision

export var variance := Color.white setget set_variance

export(int, 5, 64) var potential := 5 setget set_potential

export var parent_world : NodePath



## Private Variables
var _hovered := false

var _selected := false

var _image : Image = null

var _target := Vector2.INF



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
	var world = get_node_or_null(parent_world)
	if is_instance_valid(world) \
			and is_instance_valid(view) \
			and _target == Vector2.INF:
		var areas := view.get_overlapping_areas()
		for area in areas:
			area = area as Area2D
			if area.is_in_group("foods"):
				_target = area.position
	
	if _target == Vector2.INF:
		_target = world.random_world_point()
	
	var distance := position.distance_to(_target)
	if distance > 8:
		translate(position.direction_to(_target) * speed)
	else:
		_target = Vector2.INF


func _draw() -> void:
	if _hovered or _selected:
		var color : Color
		if _hovered:
			color = Color(1, 1, 1, 0.1)
		if _selected:
			color = Color.white
		
		draw_arc(
			Vector2.ZERO,
			16, 0, 360, 16, color, 2
		)



## Public Methods
func set_energy(value : float) -> void:
	energy = value


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


func randomize() -> void:
	self.variance = Color(randi())
	self.vision = 16 + (16 * variance.b)
	self.potential = 5 + int(3 * variance.g)
	birth()



## Private Methods
func _on_mouse_entered():
	_hovered = true
	update()


func _on_mouse_exited():
	_hovered = false
	update()


func _on_input_event(viewport : Node, event : InputEvent, shape_idx : int):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			_selected = not _selected
			update()
