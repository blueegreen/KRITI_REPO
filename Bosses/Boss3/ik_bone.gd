extends Node2D
class_name IK_BONE

@export_category("IK_mechanics")
@export var head : Node2D
@export var tail : Node2D
@export var sprite : Node2D
@export var is_pinned : Node2D
@export var is_following : Node2D

@export_category("Constrains")
@export var is_angle_constrained := false
@export var angle_limit : float = 99
@export var constrain_with : IK_BONE = null

var length : float
var angle : float
var sprite_offset : Vector2

func _ready():
	if not head or not tail:
		queue_free()
		return
	if sprite:
		sprite_offset = sprite.position - head.position
	length = head.position.distance_to(tail.position)
	if is_angle_constrained:
		if constrain_with:
			angle = constrain_with.get_dir().angle_to(get_dir())
		else:
			angle = get_dir().angle()

func _process(_delta):
	if not head or not tail:
		queue_free()
		return
	if not get_parent() is IK_BONE:
		if is_following:
			tail.global_position = is_following.global_position
		length_constraint()
		if get_child_count() > 0:
			for child in get_children():
				if child is IK_BONE:
					child.follow_chain()
		render()

func get_dir() -> Vector2:
	return head.global_position.direction_to(tail.global_position)

func follow_chain():
	if get_parent() is IK_BONE:
		tail.global_position = get_parent().head.global_position
		if not is_pinned:
			length_constraint()
			angle_constraint()
		else:
			head.global_position = is_pinned.global_position
			angle_constraint()
			pin_constraint()
		if get_child_count() > 0:
			for child in get_children():
				if child is IK_BONE:
					child.follow_chain()
		render()

func render():
	if not sprite or not head or not tail:
		return
	var rot = head.position.angle_to_point(tail.position)
	var target_position = sprite_offset.rotated(rot) + head.position
	sprite.position = target_position
	sprite.rotation = rot

func length_constraint():
	var dir = head.position.direction_to(tail.position)
	var dist = head.position.distance_to(tail.position)
	var offset = dist - length
	head.position += dir * offset

func pin_constraint():
	var dir = tail.position.direction_to(head.position)
	var dist = tail.position.distance_to(head.position)
	var offset = dist - length
	tail.position += dir * offset
	#if is_following:
		#tail.global_position = is_following.global_position
	if get_parent() is IK_BONE:
		get_parent().head.global_position = tail.global_position
		get_parent().pin_constraint()

func angle_constraint():
	if not is_angle_constrained:
		return
	var new_angle :float
	if constrain_with:
		new_angle = constrain_with.get_dir().angle_to(get_dir())
	else:
		new_angle = get_dir().angle()
	if abs(new_angle - angle) > angle_limit:
		var offset = (-sign(new_angle - angle)) * (abs(new_angle - angle) - angle_limit)
		var new_tail_dir = (head.global_position.direction_to(tail.global_position)).rotated(offset)
		var new_tail_position = head.global_position + new_tail_dir * length
		tail.global_position = new_tail_position
		if get_parent() is IK_BONE:
			if not get_parent().is_following:
				get_parent().pin_constraint()
