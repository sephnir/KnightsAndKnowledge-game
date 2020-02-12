extends Control

var guild = find_parent("Guild");
onready var global = $"/root/Global";
onready var routes = $"/root/API";

onready var ilguilds = $IL_Guilds;
onready var vsbar = ilguilds.get_v_scroll();

func _ready():
	guild = find_parent("Guild");

func force_scroll_style():
	vsbar.rect_min_size.x = 20;
	vsbar.rect_scale.x= 2;
	vsbar.rect_position.x = 600;
	vsbar.update();
	
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
			setup_list(json.result.success);
		else:
			label.text = label.MSG_DICT['join_fail'];

func _process(delta):
	force_scroll_style();
	if(guild):
		if(guild.state == guild.GUILD_STATE.SELECT):
			visible = true;
		else:
			visible = false;

func setup_list(list):
	ilguilds.clear();
	var i = 0;
	for item in list:
		ilguilds.add_item("("+item.guild_token+") " + item.name);
		ilguilds.set_item_metadata(i, 
			{"token":item.guild_token, "name":item.name}
		);
		if(item.guild_token == global.guild_token):
			ilguilds.select(i);
		i+=1;
	ilguilds.ensure_current_is_visible();


func _on_Select_State_visibility_changed():
	if(visible):
		fetch_guilds();


func _on_Btn_SSDone_button_up():
	var selected = ilguilds.get_selected_items();
	var label = get_tree().get_current_scene().find_node('Lbl_Dialogue');
	selected = selected[0];
	global.guild_name = ilguilds.get_item_metadata(selected).name;
	global.guild_token = ilguilds.get_item_metadata(selected).token;
	global.save_guild();
	label.text = label.MSG_DICT['select_success'] % global.guild_name;
