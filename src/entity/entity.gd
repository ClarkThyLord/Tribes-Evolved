tool
extends Area2D
## Entity



## Exported Variables
export(float, 0.0, 100.0) var energy := 25.0

export(float, 16.0, 100.0) var vision := 32.0

export var variance := Color.white

export(int, 5, 64) var potential := 5 setget set_potential



## Private Variables
var _hovered := false

var _selected := false

var _image := Image.new()



## OnReady Variables
onready var collision_shape : CollisionShape2D = get_node("CollisionShape2D")

onready var view_shape : CollisionShape2D = get_node("View/CollisionShape2D")

onready var sprite : Sprite = get_node("Sprite")



## Built-In Virtual Methods
func _ready() -> void:
	evolve()
	
	if is_instance_valid(collision_shape) \
			and is_instance_valid(collision_shape.shape):
		collision_shape.shape = collision_shape.shape.duplicate()
		(collision_shape.shape as RectangleShape2D).extents = Vector2.ONE * potential
	
	if is_instance_valid(view_shape) \
			and is_instance_valid(view_shape.shape):
		view_shape.shape = view_shape.shape.duplicate()
		(view_shape.shape as CircleShape2D).radius = vision


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
func set_potential(value : int) -> void:
	potential = value
	# FORCE ODD ?
#	potential = value + ((value + 1) % 2)
#	property_list_changed_notify()


func evolve() -> void:
	var axis = (potential - 1) / 2
	var color = Color.red
	_image.create(potential, potential, false, Image.FORMAT_RGB8)
	
	_image.lock()
	for x in range(axis + 1):
		for y in range(potential):
			if (randi() % 10) % 2 == 0:
				_image.set_pixel(x, y, color)
				if not x == axis:
					_image.set_pixel(potential - x - 1, y, color)
	_image.unlock()
	
	var texture = ImageTexture.new()
	texture.create_from_image(_image, 0)
	sprite.texture = texture


func randomize() -> void:
	pass



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
