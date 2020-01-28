extends Node2D

onready var global = get_node("/root/Global");
onready var constants = get_node("/root/Constants");
onready var unit = constants.DUNGEON_UNIT;
onready var grid_pos = Vector2();

var momentum_grid = Vector2();
var tilemap;
var solid_tiles;

#Called when object ready
func _ready():
	grid_pos = position/unit;
	grid_pos.x = floor(grid_pos.x);
	grid_pos.y = floor(grid_pos.y);

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
	
	if not tilemap.get_cell(grid_pos.x + momentum_grid.x, grid_pos.y) in solid_tiles:
		grid_pos.x += momentum_grid.x;
	else:
		momentum_grid.x = -momentum_grid.x;
	
	if not tilemap.get_cell(grid_pos.x, grid_pos.y + momentum_grid.y) in solid_tiles:
		grid_pos.y += momentum_grid.y;
	else:
		momentum_grid.y = -momentum_grid.y;

#Move sprite smoothly to the new grid position
func move_sprite():
	if(position.distance_to(grid_pos * unit) > 1 ):
		position += ((grid_pos * unit) - position ) / 5;

#Called every frame
func _process(delta):
	move_sprite();
