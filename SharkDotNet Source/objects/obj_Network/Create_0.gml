/// @desc CREATE NETWORK

playerExists = false;

type = noone;
alarm[0] = 10;

StartAs = function(_type) {
	switch(_type) {
		case("server"): server = new Server();
		case("client"): client = new Client(); break;
	}
	
	type = _type;
}