extends Node2D
class_name PowerupCard

signal selected(card)
var _already_selected := false

@export var text : String = "DUMMY POWERUP"
@export var powerup : GlobalPowerupManager.Powerup
var player : Player
@onready var label = $Label
@onready var rounded_rectangle = $RoundedRectangle

func _ready():
	label.text = text
	player = get_tree().get_first_node_in_group("player")
	rounded_rectangle.modulate = Color("d7e9ca")

func _on_area_2d_mouse_entered():
	scale = Vector2(1.05, 1.05)
	rounded_rectangle.modulate = Color("f1f8ed")

func _on_area_2d_mouse_exited():
	if _already_selected:
		return
	scale = Vector2(1, 1)
	rounded_rectangle.modulate = Color("d7e9ca")

func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("shoot") and not _already_selected:
		selected.emit(self)
		_already_selected = true
		if powerup and player:
			GlobalPowerupManager.apply_powerup(player, powerup)
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector2.UP * 1000, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

#func is_on_top() -> bool:
	#var space_state = get_world_2d().direct_space_state
	#var query = PhysicsPointQueryParameters2D.new()
	#query.collide_with_areas = true
	#query.collide_with_bodies = false
	#query.position = get_global_mouse_position()
	#query.collision_mask = 128
	#var result = space_state.intersect_point(query)
	#for n in result:
		#if n["collider"].get_parent() == self:
			#continue
		#if n["collider"].get_parent().get_index() > get_index():
			#return false
	#return true
		#
