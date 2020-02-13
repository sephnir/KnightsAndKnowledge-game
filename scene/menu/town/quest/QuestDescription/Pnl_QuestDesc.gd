extends Panel

var quest = null;
onready var global = $"/root/Global";
onready var routes = $"/root/API";
onready var load_spinner = find_parent("Quest").find_node("Cpn_Loading");

func _on_Btn_Depart_button_up():
	global.quest = quest;
	load_spinner.visible = true;
	var request_url = global.get_request_url(routes.API_TOPIC_QUESTION_LIST);
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json",
		global.get_bearer()
	];
	var query = to_json({
		"quest_id": quest.id
	});
	
	$HR_FetchTopics.request(request_url, headers, false, HTTPClient.METHOD_POST, query);
	

func _on_HR_FetchTopics_request_completed(result, response_code, headers, body):
	load_spinner.visible = false;
	var json = JSON.parse(body.get_string_from_utf8());
	if(json.result != null):
		if(json.result.has("success")):
			global.topics = json.result.success;
			get_tree().change_scene("res://scene/game/dungeon/main.tscn");
