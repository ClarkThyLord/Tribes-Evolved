extends ColorRect
## Spawn View


## Public Variables
var spawn setget set_spawn



## OnReady Variables
onready var spawn_name : Label = get_node("VBoxContainer/HBoxContainer/SpawnName")

onready var evolution_progress : ProgressBar = get_node("VBoxContainer/HBoxContainer2/EvolutionProgress")



## Built-In Virtual Methods
func _ready() -> void:
	close()


func _draw() -> void:
	if is_instance_valid(spawn):
		var lineage = spawn._lineage
		if lineage.empty():
			return
		
		var depth = 0
		for ancestor in lineage:
			var pos = get_rect().size
			pos.x /= 2
			pos.y = 100 * depth
			depth += 1
			match typeof(ancestor):
				TYPE_OBJECT:
					_draw_entity(pos, ancestor)
				TYPE_ARRAY:
					for index in range(ancestor.size()):
						if index == 0:
							pos.x -= 150
						else:
							pos.x += 300
						_draw_entity(pos, ancestor[index])



## Public Methods
func set_spawn(value) -> void:
	spawn = value
	
	if is_inside_tree() and is_instance_valid(spawn):
		spawn_name.text = spawn.spawn_name
		evolution_progress.value = spawn.get_evolution_progress()
	
	update()


func show_spawn(spawn) -> void:
	print("here")
	self.visible = true
	self.spawn = spawn


func close() -> void:
	self.visible = false
	
	if is_instance_valid(spawn):
		spawn.unselect()
		spawn = null



## Private Methods
func _draw_entity(position : Vector2, entity) -> void:
	if not is_instance_valid(entity):
		return
	
	var rect = entity.get_image().get_used_rect()
	rect.position = position
	rect.size *= 20
	draw_texture_rect(
			entity._texture,
			rect, false)


func _on_visibility_changed():
	get_tree().paused = visible


func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				if event.doubleclick:
					close()


func _on_Close_pressed():
	close()
