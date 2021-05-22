
function User(_x, _y, _name) constructor  {
	
	pos = new vec2(_x, _y);
	user = _name;
	visible = true;
	
	Render = function() {
		if(visible) {
			draw_sprite(s_Cursor, 0, pos.x, pos.y);
			// show_debug_message("Drew cursor at: " + string(pos));
		}
	}

}

function ConnectedUser(_x, _y, _name) : User(_x, _y, _name) constructor {
	
}

function LocalUser(_x, _y, _name) : User(_x, _y, _name) constructor  {
	
	visible = false;
	
	Update = function() {
		
		if(mouse_x != pos.x || mouse_y != pos.y) 
		{
			
			with(obj_Network.client) {
				buffer_seek(cln_Buffer, buffer_seek_start, 0);

				buffer_write(cln_Buffer, buffer_u8, net.from_Client);
				buffer_write(cln_Buffer, buffer_u8, net.cursor_Move);
				buffer_write(cln_Buffer, buffer_s16, mouse_x)
				buffer_write(cln_Buffer, buffer_s16, mouse_y);
	
				network_send_packet(socket, cln_Buffer, buffer_tell(cln_Buffer));
			}
			
			pos = new vec2(mouse_x, mouse_y);
		}
		
	}
	
}

function PeerUser(_x, _y, _name) : User(_x, _y, _name) constructor {
	
}