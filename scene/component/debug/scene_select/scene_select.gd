extends OptionButton

func _ready():
	add_item("Login", 0);
	add_item("Dungeon", 1);
	add_item("Game GUI", 2);


func _on_SceneSelect_item_selected(ID):
	match ID:
		0:
			get_tree().change_scene("res://scene/login/login.tscn");
		1:
			get_tree().change_scene("res://scene/game/dungeon/main.tscn");
		1:
			get_tree().change_scene("res://scene/game/gui/main.tscn");

