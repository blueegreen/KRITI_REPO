extends Marker2D
class_name IK_LegController


enum state {JUMP, MOVING, STATIC}
var _current_state := state.STATIC
var _move_tween : Tween

@export var leg_segment : IK_BONE
@export var body : Node2D
@export var max_allowed_leg_offset := 20.0
@export var max_allowed_body_offset := 80.0
@export var move_duration := 0.5
@export var height := 70.0
@export var offset : float

var _init_body_pos : Vector2
var _init_body_offset : Vector2
var _body_prev_pos : Vector2

func _ready():
	if not body or not leg_segment:
		queue_free()
		return
	_init_body_pos = body.global_position
	_init_body_offset = global_position - body.global_position
	_body_prev_pos = body.global_position

func _process(_delta):
	if not body or not leg_segment:
		queue_free()
		return
	match _current_state:
		state.STATIC:
			#var leg_offset = leg_segment.tail.global_position.distance_to(global_position)
			#var new_body_offset = global_position - body.global_position
			#var body_offset_change = new_body_offset.distance_to(_init_body_offset)
			#var dir = (new_body_offset - _init_body_offset).normalized()
			
			#var body_velocity = (body.global_position - _body_prev_pos) / delta
			#_body_prev_pos = body.global_position
			#
			#var body_translation = body.global_position.distance_to(_init_body_pos)
			#if body_translation > max_allowed_body_offset or leg_offset > max_allowed_leg_offset:
				#_init_body_pos = body.global_position
				#var target_pos = body.global_position + _init_body_offset + body_velocity * (offset * 1.5 + move_duration)
				#if target_pos.distance_to(global_position) > 10.0:
					#move_to_new_pos(body.global_position + _init_body_offset)
			var target_pos = body.global_position + _init_body_offset
			if target_pos.distance_to(global_position) > 40.0:
				move_to_new_pos(body.global_position + _init_body_offset)
				
		state.MOVING:
			return
		
		state.JUMP:
			#var dir = body.global_position.direction_to(global_position)
			#global_position = global_position.lerp(body.global_position + dir * 5000, delta * 3.)
			global_position = leg_segment.tail.global_position

func move_to_new_pos(pos:Vector2):
	var end_move = func():
		await get_tree().create_timer(offset/2.0).timeout
		_current_state = state.STATIC
	if _move_tween:
		_move_tween.kill()
	
	_current_state = state.MOVING
	await get_tree().create_timer(offset).timeout
	
	var half_pos : Vector2 = (pos + global_position) * 0.5
	var top_pos : Vector2 = half_pos + Vector2.UP * height
	
	_move_tween = create_tween()

	_move_tween.tween_property(self, "global_position", top_pos, move_duration / 2.0).set_ease(Tween.EASE_OUT)
	_move_tween.tween_property(self, "global_position", pos, move_duration / 2.0).set_ease(Tween.EASE_IN)
	_move_tween.tween_callback(end_move)

func set_state(new_state:state):
	_current_state = new_state
