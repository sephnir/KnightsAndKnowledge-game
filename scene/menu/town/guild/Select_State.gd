extends Control

var guild = find_parent("Guild");
onready var global = $"/root/Global";
onready var routes = $"/root/API";

func _ready():
	guild = find_parent("Guild");
	
func fetch_guilds():
	guild.find_node('Cpn_Loading').visible = true;
	var request_url = global.get_request_url(routes.API_CHARA_JOINED_GUILD);
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json",
		global.get_bearer()
	];
	var query = to_json({
		"char_id": global.character
	});
	
	$HR_FetchGuilds.request(request_url, headers, false, HTTPClient.METHOD_POST, query);

func _on_HR_FetchGuilds_request_completed(result, response_code, headers, body):
	guild.find_node('Cpn_Loading').visible = false;
	var json = JSON.parse(body.get_string_from_utf8());
	var label = get_tree().get_current_scene().find_node('Lbl_Dialogue');
	if(json.result != null):
		if(json.result.has("success")):
			label.text = label.MSG_DICT['select'];
			
			$ItemList.clear();
			for item in json.result.success:
				$ItemList.add_item(item.name);
		else:
			label.text = label.MSG_DICT['join_fail'];

func _process(delta):
	if(guild):
		if(guild.state == guild.GUILD_STATE.SELECT):
			visible = true;
		else:
			visible = false;


func _on_Select_State_visibility_changed():
	if(visible):
		fetch_guilds();
