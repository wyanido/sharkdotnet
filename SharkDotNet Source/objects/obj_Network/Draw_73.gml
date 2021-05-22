var _map = client.cln_SocketIDs;

for(var k = ds_map_find_first(_map); !is_undefined(k); k = ds_map_find_next(_map, k)) {
	_map[? k].Render();
	
	// show_debug_message(_map[? k]);
}