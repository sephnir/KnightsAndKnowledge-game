extends Node2D

onready var global = $"/root/Global";
onready var parent = find_parent('Dungeon');
onready var unit = global.DUNGEON_UNIT;
onready var grid_pos = Vector2();

var dist_to_player = 0;
var type = 0;

enum TYPE  {
	Potion = 0,
	Copper = 1,
	Silver = 2,
	Gold = 3
};

const PATH = [
	"res://graphics/sprite/items/potion.png",
	"res://graphics/sprite/items/copper.png",
	"res://graphics/sprite/items/silver.png",
	"res://graphics/sprite/items/gold.png"
]

#Called when object ready
func _ready():
	grid_pos = position/unit;
	grid_pos.x = floor(grid_pos.x);
	grid_pos.y = floor(grid_pos.y);
	self.type = global.dungeon_rand.randi_range(0, PATH.size()-1 );
	load_sprite();

# Call when instancing
func init(pos):
	self.position = pos;

# Call when player lands on item space	
func collect():
	match self.type:
		TYPE.Potion:
			global.current_hp = min(global.current_hp+1, global.MAX_HP);
		TYPE.Copper:
			global.score += 100;
		TYPE.Silver:
			global.score += 250;
		TYPE.Gold:
			global.score += 500;
	queue_free();

# Load texture as sprite
func load_sprite():
	$Spr_Item.texture = load(PATH[type]);
	update();

func _process(delta):
	update_lighting();

# Update shading of sprite based on distance to player
func update_lighting():
	var temp = clamp(1-dist_to_player/180+0.2,0.1,1);
	modulate = Color(temp,temp,temp);
