extends Control

onready var global = $"/root/Global";
onready var routes = $"/root/API";

onready var vsbar = $IL_Quest.get_v_scroll();

func _ready():
	$Cpn_Loading.visible = true;
	$Pnl_QuestDesc.visible = false;
	$IL_Quest/Lbl_Notice.visible = false;
	fetch_quests();

func force_scroll_style():
	vsbar.rect_min_size.x = 20;
	vsbar.rect_scale.x= 2;
	vsbar.rect_position.x = $IL_Quest.rect_size.x - vsbar.rect_min_size.x * vsbar.rect_scale.x;
	vsbar.update();
	
func fetch_quests():
	if(global.guild_token == ""):
		$IL_Quest/Lbl_Notice.visible = true;
		$IL_Quest/Lbl_Notice.text = "You have not joined any guild. Please visit the guild and try again.";
		$Cpn_Loading.visible = false;
		return;
		
	var request_url = global.get_request_url(routes.API_QUEST_LIST);
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json",
		global.get_bearer()
	];
	var query = to_json({
		"token": global.guild_token
	});
	
	$HR_FetchQuests.request(request_url, headers, false, HTTPClient.METHOD_POST, query);

func _on_HR_FetchQuests_request_completed(result, response_code, headers, body):
	$Cpn_Loading.visible = false;
	var json = JSON.parse(body.get_string_from_utf8());
	if(json.result != null):
		if(json.result.has("success")):
			setup_list(json.result.success);


func _process(delta):
	force_scroll_style();

func setup_list(list):
	$IL_Quest/Lbl_Notice.text = "No quests available in this guild.";
	$IL_Quest/Lbl_Notice.visible = true;
	$IL_Quest.clear();
	var i = 0;
	for item in list:
		$IL_Quest/Lbl_Notice.visible = false;
		$IL_Quest.add_item(item.name);
		$IL_Quest.set_item_metadata(i, 
			item
		);
		i+=1;
		
func _on_Btn_Back_button_up():
	get_tree().change_scene("res://scene/menu/town/menu.tscn");


func _on_IL_Quest_item_selected(index):
	var item = $IL_Quest.get_item_metadata(index);
	$Pnl_QuestDesc.quest = item;
	$Pnl_QuestDesc/Lbl_Title.text = item.name;
	$Pnl_QuestDesc/Lbl_Desc.text = "Levels: %s" % item.level;
	$Pnl_QuestDesc.visible = true;

