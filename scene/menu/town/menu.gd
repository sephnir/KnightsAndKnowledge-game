extends Node2D

onready var global = $"/root/Global";

# Called when the node enters the scene tree for the first time.
func _ready():
	global.load_guild();

func _on_Btn_Guild_button_up():
	get_tree().change_scene("res://scene/menu/town/guild/guild.tscn");


func _on_Btn_Quest_button_up():
	get_tree().change_scene("res://scene/menu/town/quest/quest.tscn");
