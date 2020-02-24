extends Node2D

onready var global = get_node("/root/Global");
onready var unit = global.DUNGEON_UNIT;
onready var grid_pos = Vector2();

var momentum_grid = Vector2();
var tilemap;
var solid_tiles;
var topic = -1;
var dist_to_player = 0;

#Called when object ready
func _ready():
	grid_pos = position/unit;
	grid_pos.x = floor(grid_pos.x);
	grid_pos.y = floor(grid_pos.y);
	topic = randi() % global.topics.size();

#Contructor. Call when instancing
func init(tilemap, solid_tiles, pos):
	self.tilemap = tilemap;
	self.solid_tiles = solid_tiles;
	self.position = pos;

#Randomly moves grid-based position of self
func move_random():
	momentum_grid.x = clamp(momentum_grid.x + 
		global.movement_rand.randi_range(-1, 1), -1, 1);
	momentum_grid.y = clamp(momentum_grid.y + 
		global.movement_rand.randi_range(-1, 1), -1, 1);
	
	var vec = Vector2(grid_pos.x + momentum_grid.x, grid_pos.y);
	if not tilemap.get_cellv(vec) in solid_tiles:
		grid_pos.x += momentum_grid.x;
	else:
		momentum_grid.x = -momentum_grid.x;
	
	vec = Vector2(grid_pos.x, grid_pos.y + momentum_grid.y);
	if not tilemap.get_cellv(vec) in solid_tiles:
		grid_pos.y += momentum_grid.y;
	else:
		momentum_grid.y = -momentum_grid.y;

#Move sprite smoothly to the new grid position
func move_sprite():
	if(position.distance_to(grid_pos * unit) > 1 ):
		position += ((grid_pos * unit) - position ) / 5;

func update_lighting():
	var temp = clamp(1-dist_to_player/180+0.2,0.1,1);
	modulate = Color(temp,temp,temp);

#Called every frame
func _process(delta):
	move_sprite();
	update_lighting();
