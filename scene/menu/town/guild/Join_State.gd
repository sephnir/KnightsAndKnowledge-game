extends Control

onready var global = $"/root/Global";
onready var routes = $"/root/API";
var guild = find_parent("Guild");

func _ready():
	guild = find_parent("Guild");

func _process(delta):
	if(guild):
		if(guild.state == guild.GUILD_STATE.JOIN):
			visible=true;
		else:
			visible=false;

func _on_Btn_ICDone_button_up():
	guild.find_node('Cpn_Loading').visible = true;
	var request_url = global.get_request_url(routes.API_CHARA_JOIN_GUILD);
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json",
		global.get_bearer()
	];
	var query = to_json({
		"guild_token": $Pnl_InviteCode/LE_InviteCode.text,
		"char_id": global.character
	});
	
	$HR_JoinGuild.request(request_url, headers, false, HTTPClient.METHOD_POST, query);


func _on_HR_JoinGuild_request_completed(result, response_code, headers, body):
	guild.find_node('Cpn_Loading').visible = false;
	var json = JSON.parse(body.get_string_from_utf8());
	var label = get_tree().get_current_scene().find_node('Lbl_Dialogue');
	if(json.result != null):
		if(json.result.has("success")):
			label.text = label.MSG_DICT['join_success'];
			global.guild_name = json.result.success.name;
			global.guild_token = json.result.success.guild_token;
			guild.state = guild.GUILD_STATE.START;
		else:
			label.text = label.MSG_DICT['join_fail'];
