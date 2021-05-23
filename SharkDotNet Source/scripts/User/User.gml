
function User(_x, _y, _name) constructor  {
	
	pos = new vec2(_x, _y);
	user = _name;
	
	Render = function() {
		draw_sprite(s_Cursor, 0, pos.x, pos.y);
		// show_debug_message("Drew cursor at: " + string(pos));
	}

}

function ConnectedUser(_x, _y, _name) : User(_x, _y, _name) constructor {
	
}

function LocalUser(_x, _y, _name) : User(_x, _y, _name) constructor  {
	
	Render = function() {
		// Do Nothing
	}
	
	Update = function() {
		
		// MOVE CURSOR
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
	
	SendAction = function(_x, _y, _size, _type) 
	{
		
		with(obj_Network.client) {
			buffer_seek(cln_Buffer, buffer_seek_start, 0);

			buffer_write(cln_Buffer, buffer_u8, net.from_Client);
			
			if(_type == 1) {
				buffer_write(cln_Buffer, buffer_u8, net.cursor_Draw);
			} else if(_type == 2) {
				buffer_write(cln_Buffer, buffer_u8, net.cursor_Erase);
			}
			
			buffer_write(cln_Buffer, buffer_s16, _x)
			buffer_write(cln_Buffer, buffer_s16, _y);
			buffer_write(cln_Buffer, buffer_u8, _size);
	
			network_send_packet(socket, cln_Buffer, buffer_tell(cln_Buffer));
		}
			
	}
}

function PeerUser(_x, _y, _name) : User(_x, _y, _name) constructor {
	
	
	Render = function() {
		draw_sprite(s_Cursor, 0, pos.x, pos.y);
		
		draw_set_colour(c_lime);
		
		draw_set_halign(fa_center);
		draw_text(pos.x, pos.y + 8, user);
		draw_set_halign(fa_left);
		
		draw_set_colour(c_black);
		
	}
	
}