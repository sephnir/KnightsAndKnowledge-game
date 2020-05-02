extends Panel

var quest = null;
onready var global = $"/root/Global";
onready var routes = $"/root/API";
onready var load_spinner = find_parent("Quest").find_node("Cpn_Loading");

var topic_size = 0;
var current_topic = 0;

func _on_Btn_Depart_button_up():
	init_global();
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
	
func init_global():
	global.quest = quest;
	if(global.quest.dungeon_seed):
		global.dungeon_seed = hash(quest.dungeon_seed);
	else:
		global.dungeon_seed = hash(quest.name);
	global.score = global.INITIAL_SCORE;
	global.current_floor = 1;
	global.current_hp = global.MAX_HP;

func _on_HR_FetchTopics_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8());
	if(json.result != null):
		if(json.result.has("success")):
			global.topics = json.result.success;
			_fetch_sprites();

func _on_HR_FetchSprites_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var image_error = image.load_png_from_buffer(body);
	if image_error:
		image_error = image.load_jpg_from_buffer(body);
	if image_error:
		image_error = image.load_webp_from_buffer(body);
	var texture = ImageTexture.new();
	texture.create_from_image(image, 0);
	
	global.topics[current_topic].sprite_tex = texture;
	current_topic += 1;
	_fetch_sprites();

func _fetch_sprites():
	topic_size = len(global.topics);
	if(current_topic >= topic_size):
		_change_room();
		return;
	var request_url = global.get_cdn_url(global.topics[current_topic].sprite_path);
	$HR_FetchSprites.request(request_url);	

func _change_room():
	load_spinner.visible = false;
	if(global.topics):
		get_tree().change_scene("res://scene/game/dungeon/main.tscn");


