enum net {
	
	// PACKET SOURCE
	from_Client,
	from_Server,
	
	// PROTOCOL VERIFICATION
	protocol_Check,
	protocol_Match,
	protocol_Mismatch,
	
	// PLAYER ACTION
	player_Create,
	player_Disconnect,
	player_Connect,
	player_Join,
	player_GetCanvas,
	
	// CURSOR
	cursor_Move,
	cursor_Move_Sync,
	cursor_Draw,
	cursor_Draw_Sync,
	cursor_Erase,
	cursor_Erase_Sync,
	
	// LOBBY ACTIONS
	lobby_Destroy
	
}

function Network() constructor {
	
	/// NET SETUP
	network_set_config(network_config_connect_timeout, 5000);
	network_set_config(network_config_use_non_blocking_socket, 1);

	port = 7123;
	protocol = 4;
	ip = "sharkdotnet.duckdns.org";
	
}

function Server() : Network() constructor {
	
	clientCap = 4;
	
	server = network_create_server(network_socket_tcp, port, clientCap);
	socket = noone;
	
	srv_Buffer = buffer_create(1024, buffer_fixed, 1);
	srv_SocketList = ds_list_create();
	srv_SocketIDs = ds_map_create();
	
	GetPacket = function(_buffer) 
	{
		
		var _msgID = buffer_read(_buffer, buffer_u8);

		switch(_msgID) {
			case(net.protocol_Check):
				var _protocol = buffer_read(_buffer, buffer_u8);
				
				if(_protocol == protocol) {
					
					buffer_seek(srv_Buffer, buffer_seek_start, 0);
					buffer_write(srv_Buffer, buffer_u8, net.from_Server);
					buffer_write(srv_Buffer, buffer_u8, net.protocol_Match);
					network_send_packet(socket, srv_Buffer, buffer_tell(srv_Buffer));
				
					var _user = new ConnectedUser();
					ds_map_add(srv_SocketIDs, socket, _user);
					ds_list_add(srv_SocketList, socket);
					
				} else {
					
					buffer_seek(srv_Buffer, buffer_seek_start, 0);
					buffer_write(srv_Buffer, buffer_u8, net.from_Server);
					buffer_write(srv_Buffer, buffer_u8, net.protocol_Mismatch);
					network_send_packet(socket, srv_Buffer, buffer_tell(srv_Buffer));
					
				}
				
			break;
			case(net.player_Create):
				var _user = buffer_read(buffer, buffer_string);
				var _x = buffer_read(buffer, buffer_s16);
				var _y = buffer_read(buffer, buffer_s16);
				
				user = ds_map_find_value(srv_SocketIDs, socket);

				user.user = _user;
				user.pos.x = _x;
				user.pos.y = _y;
			
				// Create Player Object for Connecting Client
				buffer_seek(srv_Buffer,  buffer_seek_start, 0);
				buffer_write(srv_Buffer, buffer_u8, net.from_Server);
				buffer_write(srv_Buffer, buffer_u8, net.player_Connect);
				buffer_write(srv_Buffer, buffer_u8, socket);
				buffer_write(srv_Buffer, buffer_string, _user);
				buffer_write(srv_Buffer, buffer_s16, _x);
				buffer_write(srv_Buffer, buffer_s16, _y);
				network_send_packet(socket, srv_Buffer, buffer_tell(srv_Buffer));
				
				// Send already joined clients to connecting client
				for(var i = 0; i < ds_list_size(srv_SocketList); i ++) {
					var _socket = ds_list_find_value(srv_SocketList, i);
					
					if(_socket != socket) {
						var _existing = ds_map_find_value(srv_SocketIDs, _socket);
					
						buffer_seek(srv_Buffer, buffer_seek_start, 0);
						buffer_write(srv_Buffer, buffer_u8, net.from_Server);
						buffer_write(srv_Buffer, buffer_u8, net.player_Join);
						buffer_write(srv_Buffer, buffer_u8, _socket);
						buffer_write(srv_Buffer, buffer_string, _existing.user);
						buffer_write(srv_Buffer, buffer_s16, _existing.pos.x);
						buffer_write(srv_Buffer, buffer_s16, _existing.pos.y);
						network_send_packet(socket, srv_Buffer, buffer_tell(srv_Buffer));
					
						// show_message("Attempted to create player '" + existing.username + "' at X: " + string(existing.x) + ", Y: " + string(existing.y) + " with Facing: " + string(existing.dir))
					}

				}
		
				// Send clients already in game, the client that just joined
				for(var i = 0; i < ds_list_size(srv_SocketList); i ++) {
					var _socket = ds_list_find_value(srv_SocketList, i);
					
					if(_socket != socket) {
						buffer_seek(srv_Buffer,  buffer_seek_start, 0);
						buffer_write(srv_Buffer, buffer_u8, net.from_Server);
						buffer_write(srv_Buffer, buffer_u8, net.player_Join);
						buffer_write(srv_Buffer, buffer_u8, socket);
						buffer_write(srv_Buffer, buffer_string, _user);
						buffer_write(srv_Buffer, buffer_s16, _x);
						buffer_write(srv_Buffer, buffer_s16, _y);
						network_send_packet(_socket, srv_Buffer, buffer_tell(srv_Buffer));
					}
				}
				
				var _canvas = obj_Game.game.GetCanvas();
				var _canvasBuffer = buffer_create(1024, buffer_grow, 1);
				
				buffer_seek(_canvasBuffer,  buffer_seek_start, 0);
				buffer_write(_canvasBuffer, buffer_u8, net.from_Server);
				buffer_write(_canvasBuffer, buffer_u8, net.player_GetCanvas);
				buffer_get_surface(_canvasBuffer, _canvas, 2);
				
				network_send_packet(socket, _canvasBuffer, buffer_tell(_canvasBuffer));
				
				surface_free(_canvas);
				buffer_delete(_canvasBuffer);
				
			break;
			case(net.cursor_Move):
				var _x = buffer_read(buffer, buffer_s16);
				var _y = buffer_read(buffer, buffer_s16);
				
				var _user = ds_map_find_value(srv_SocketIDs, socket);
				
				_user.pos = new vec2(_x, _y);
				
				for(var i = 0; i < ds_list_size(srv_SocketList); i ++) {
					var _socket = ds_list_find_value(srv_SocketList, i);
					
					buffer_seek(srv_Buffer,  buffer_seek_start, 0);
					buffer_write(srv_Buffer, buffer_u8, net.from_Server);
					buffer_write(srv_Buffer, buffer_u8, net.cursor_Move_Sync);
					buffer_write(srv_Buffer, buffer_u8, socket);
					buffer_write(srv_Buffer, buffer_s16, _x);
					buffer_write(srv_Buffer, buffer_s16, _y);
					network_send_packet(_socket, srv_Buffer, buffer_tell(srv_Buffer));
				}

			break;
			case(net.cursor_Draw):
				var _x = buffer_read(buffer, buffer_s16);
				var _y = buffer_read(buffer, buffer_s16);
				var _size = buffer_read(buffer, buffer_u8);
				
				var _sock = ds_map_find_value(srv_SocketIDs, socket);
				
				for(var i = 0; i < ds_list_size(srv_SocketList); i ++) {
					var _socket = ds_list_find_value(srv_SocketList, i);
					
					if(_sock != _socket) 
					{
						buffer_seek(srv_Buffer,  buffer_seek_start, 0);
						buffer_write(srv_Buffer, buffer_u8, net.from_Server);
						buffer_write(srv_Buffer, buffer_u8, net.cursor_Draw_Sync);
						buffer_write(srv_Buffer, buffer_s16, _x);
						buffer_write(srv_Buffer, buffer_s16, _y);
						buffer_write(srv_Buffer, buffer_u8, _size);
						network_send_packet(_socket, srv_Buffer, buffer_tell(srv_Buffer));
					}
				}

			break;
			case(net.cursor_Erase):
				var _x = buffer_read(buffer, buffer_s16);
				var _y = buffer_read(buffer, buffer_s16);
				var _size = buffer_read(buffer, buffer_u8);
				
				var _sock = ds_map_find_value(srv_SocketIDs, socket);
				
				for(var i = 0; i < ds_list_size(srv_SocketList); i ++) {
					var _socket = ds_list_find_value(srv_SocketList, i);
					
					if(_sock != _socket) 
					{
						buffer_seek(srv_Buffer,  buffer_seek_start, 0);
						buffer_write(srv_Buffer, buffer_u8, net.from_Server);
						buffer_write(srv_Buffer, buffer_u8, net.cursor_Erase_Sync);
						buffer_write(srv_Buffer, buffer_s16, _x);
						buffer_write(srv_Buffer, buffer_s16, _y);
						buffer_write(srv_Buffer, buffer_u8, _size);
						network_send_packet(_socket, srv_Buffer, buffer_tell(srv_Buffer));
					}
				}

			break;
		}
	}
	
	Async = function() 
	{
		
		switch(async_load[? "type"]) {
			case(network_type_non_blocking_connect):
			
				// var succeeded = async_load[? "succeeded"];
		
			break;
			case(network_type_disconnect):
			    socket = ds_map_find_value(async_load,"socket");
				
				ds_list_delete(srv_SocketList, ds_list_find_index(srv_SocketList, socket));
				
				for(var i = 0; i < ds_list_size(srv_SocketList); i ++) {
					
					var _socket = ds_list_find_value(srv_SocketList, i);
					buffer_seek(srv_Buffer, buffer_seek_start, 0);
					buffer_write(srv_Buffer, buffer_u8, net.from_Server);
					buffer_write(srv_Buffer, buffer_u8, net.player_Disconnect);
					buffer_write(srv_Buffer, buffer_u8, socket);
					network_send_packet(_socket, srv_Buffer, buffer_tell(srv_Buffer));
					
				}
				
				var _user = ds_map_find_value(srv_SocketIDs, socket);
				
				delete _user;
		
				ds_map_delete(srv_SocketIDs, socket);
			break;
			case(network_type_data):	
			    buffer = async_load[? "buffer"];
				socket = async_load[? "id"];
				
			    buffer_seek(buffer, buffer_seek_start, 0)
				var _type = buffer_read(buffer, buffer_u8);
				
				if(_type == net.from_Client) { GetPacket(buffer); }
			break;
		}
		
	}
	
	Destroy = function()
	{

		var i = 0;
		repeat(ds_list_size(srv_SocketList)) {
			var _sock = ds_list_find_value(srv_SocketList, i);
	
			buffer_seek(srv_Buffer,  buffer_seek_start, 0);
			buffer_write(srv_Buffer, buffer_u8, net.from_Server);
			buffer_write(srv_Buffer, buffer_u8, net.lobby_Destroy);
	
			network_send_packet(_sock, srv_Buffer, buffer_tell(srv_Buffer));
			i ++;
		}

		network_destroy(server);
		buffer_delete(srv_Buffer);
		ds_list_destroy(srv_SocketList);
		ds_map_destroy(srv_SocketIDs);
	
	}
		
}

function Client() : Network() constructor {
	
	socket = network_create_socket(network_socket_tcp);
	connection = network_connect(socket, ip, port)
	
	cln_Buffer = buffer_create(1024, buffer_fixed, 1);
	cln_SocketIDs = ds_map_create();
	
	GetPacket = function(buffer) 
	{
		
		var _msgID = buffer_read(buffer, buffer_u8);

		switch(_msgID) {
			case(net.protocol_Match):
				with(obj_Network) { player = new LocalUser(mouse_x, mouse_y, obj_Game.game.username); playerExists = true; }
				
				buffer_seek(cln_Buffer, buffer_seek_start, 0);
				buffer_write(cln_Buffer, buffer_u8, net.from_Client);
				buffer_write(cln_Buffer, buffer_u8, net.player_Create);
				buffer_write(cln_Buffer, buffer_string, obj_Network.player.user);
				buffer_write(cln_Buffer, buffer_s16, obj_Network.player.pos.x);
				buffer_write(cln_Buffer, buffer_s16, obj_Network.player.pos.y);
			
				network_send_packet(socket, cln_Buffer, buffer_tell(cln_Buffer))
			break;
			case(net.protocol_Mismatch):
				
				show_message("You're playing on an outdated version!");
				instance_destroy(obj_Network);
				
			break;
			case(net.player_Connect):
				var _socket = buffer_read(buffer, buffer_u8);
				var _user = buffer_read(buffer, buffer_string);
				var x_ = buffer_read(buffer, buffer_s16);
				var y_ = buffer_read(buffer, buffer_s16);

				var _self = new PeerUser(x_, y_, _user);
				_self.visible = false;
			
				ds_map_add(cln_SocketIDs, _socket, _self);
				
				obj_Game.game.connected = true;
				obj_Game.game.pulledCanvas = 0;
			break;
			case(net.player_GetCanvas):
				var _canvas = surface_create(CANVASWID, CANVASHI);

				buffer_set_surface(buffer, _canvas, buffer_tell(buffer));

				obj_Game.game.preCanvas = sprite_create_from_surface(_canvas, 0, 0, CANVASWID, CANVASHI, false, false, 0, 0);

				surface_free(_canvas);
				
				obj_Game.game.pulledCanvas = 1;
			break;
			case(net.player_Join):
				var _socket = buffer_read(buffer, buffer_u8);
				var _user = buffer_read(buffer, buffer_string);
				var _x = buffer_read(buffer, buffer_s16);
				var _y = buffer_read(buffer, buffer_s16);
			
				var _peer = new PeerUser(_x, _y, _user);

				ds_map_add(cln_SocketIDs, _socket, _peer);
			break;
			case(net.player_Disconnect):
				var _socket = buffer_read(buffer, buffer_u8);
				var _user = ds_map_find_value(cln_SocketIDs, _socket);
		
				delete _user;
		
				ds_map_delete(cln_SocketIDs, _socket);
			break;
			case(net.cursor_Move_Sync):
				var _sock = buffer_read(buffer, buffer_u8);
				var _x = buffer_read(buffer, buffer_s16);
				var _y = buffer_read(buffer, buffer_s16);
			
				if(ds_map_exists(cln_SocketIDs, _sock)) {
					var _player = ds_map_find_value(cln_SocketIDs, _sock);
		
					_player.pos = new vec2(_x, _y);
				}

			break;
			case(net.cursor_Draw_Sync):
				var _x = buffer_read(buffer, buffer_s16);
				var _y = buffer_read(buffer, buffer_s16);
				var _size = buffer_read(buffer, buffer_u8);
				
				with(obj_Game.game) {
					var _ink = new Ink(_x, _y);
					canvasInk[array_length(canvasInk)] = _ink;
					
					_ink.r = _size;
				}

			break;
			case(net.cursor_Erase_Sync):
				var _x = buffer_read(buffer, buffer_s16);
				var _y = buffer_read(buffer, buffer_s16);
				var _size = buffer_read(buffer, buffer_u8);
				
				with(obj_Game.game) {
					var _ink = new Erase(_x, _y);
					canvasErase[array_length(canvasErase)] = _ink;
					
					_ink.r = _size;
				}

			break;
			case(net.lobby_Destroy):
				
				instance_destroy(obj_Network);

			break;
			
		}
	}
	
	Async = function()
	{

		switch(async_load[? "type"]) {
			case(network_type_non_blocking_connect):
			    if(async_load[? "succeeded"]) {

					buffer_seek(cln_Buffer, buffer_seek_start, 0);
					buffer_write(cln_Buffer, buffer_u8, net.from_Client);
					buffer_write(cln_Buffer, buffer_u8, net.protocol_Check);
					buffer_write(cln_Buffer, buffer_u8, protocol);

					network_send_packet(socket, cln_Buffer, buffer_tell(cln_Buffer));
			    } else {
					
					show_message("Connection failed!");
					instance_destroy(obj_Network);	
					
				}
		    break;
		    case(network_type_data):
		        var _buffer = async_load[? "buffer"];
				
		        buffer_seek(_buffer, buffer_seek_start, 0)
				var type = buffer_read(_buffer, buffer_u8);
				
				if(type == net.from_Server) { GetPacket(_buffer); }
			break;
		}
	
	}
	
	Destroy = function() 
	{

		network_destroy(socket);
		buffer_delete(cln_Buffer);
		ds_map_destroy(cln_SocketIDs);
		
	}
}