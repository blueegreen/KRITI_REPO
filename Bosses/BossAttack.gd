extends Node2D
class_name BossAttack

signal attack_finished

func end_attack():
	attack_finished.emit()
