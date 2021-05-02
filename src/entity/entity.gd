tool
extends Area2D
## Entity



## Private Variables
var _hovered := false

var _selected := false

var _image := Image.new()



## OnReady Variables
onready var sprite : Sprite = get_node("Sprite")



## Built-In Virtual Methods
func _ready() -> void:
	
	var size = 5
	var axis = (size - 1) / 2
	var color = Color.red
	_image.create(size, size, false, Image.FORMAT_RGB8)
	
	_image.lock()
	for x in range(axis + 1):
		for y in range(size):
			if (randi() % 10) % 2 == 0:
				_image.set_pixel(x, y, color)
				if not x == axis:
					_image.set_pixel(size - x - 1, y, color)
	_image.unlock()
	
	var texture = ImageTexture.new()
	texture.create_from_image(_image, 0)
	sprite.texture = texture


func _process(delta : float) -> void:
	update()


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



## Private Methods
func _on_mouse_entered():
	_hovered = true


func _on_mouse_exited():
	_hovered = false


func _on_input_event(viewport : Node, event : InputEvent, shape_idx : int):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			_selected = not _selected