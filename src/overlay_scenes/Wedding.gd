extends Node2D


func _ready():
	$BellAft.get_node("Sprite/AnimationPlayer").advance(0.65)
	$AnimationPlayer.play("Marry")
