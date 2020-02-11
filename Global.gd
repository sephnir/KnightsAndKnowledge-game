extends Node

var token = "";
var guild = "";

var character = -1;
var dungeon_rand = RandomNumberGenerator.new();
var movement_rand = RandomNumberGenerator.new();


const auth_path = "user://auth.data";

func save_auth(auth):
	var f = File.new();
	f.open(auth_path, File.WRITE);
	f.store_string(auth);
	f.close();

func load_auth():
	var f = File.new();
	if f.file_exists(auth_path):
		f.open(auth_path, File.READ);
		var auth = f.get_as_text();
		f.close();
		return auth;
	return null;
