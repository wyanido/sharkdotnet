/// @desc CONTROL GAME

game.Update();

if(!instance_exists(obj_Network)) {
	
	if(keyboard_check_pressed(vk_f1)) {
		var _client = instance_create_depth(0, 0, 0, obj_Network);
		_client.StartAs("client");
	}
	
	if(keyboard_check_pressed(vk_f2)) {
		var _server = instance_create_depth(0, 0, 0, obj_Network);
		_server.StartAs("server");
	}
	
}