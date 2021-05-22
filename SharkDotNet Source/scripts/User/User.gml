
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
	
	SendInk = function(_x, _y, _size) 
	{
		
		with(obj_Network.client) {
			buffer_seek(cln_Buffer, buffer_seek_start, 0);

			buffer_write(cln_Buffer, buffer_u8, net.from_Client);
			buffer_write(cln_Buffer, buffer_u8, net.cursor_Draw);
			buffer_write(cln_Buffer, buffer_s16, _x)
			buffer_write(cln_Buffer, buffer_s16, _y);
			buffer_write(cln_Buffer, buffer_u8, _size);
	
			network_send_packet(socket, cln_Buffer, buffer_tell(cln_Buffer));
		}
			
	}
	
	SendErase = function(_x, _y, _size) 
	{
		
		with(obj_Network.client) {
			buffer_seek(cln_Buffer, buffer_seek_start, 0);

			buffer_write(cln_Buffer, buffer_u8, net.from_Client);
			buffer_write(cln_Buffer, buffer_u8, net.cursor_Erase);
			buffer_write(cln_Buffer, buffer_s16, _x)
			buffer_write(cln_Buffer, buffer_s16, _y);
			buffer_write(cln_Buffer, buffer_u8, _size);
	
			network_send_packet(socket, cln_Buffer, buffer_tell(cln_Buffer));
		}
			
	}
	
}

function PeerUser(_x, _y, _name) : User(_x, _y, _name) constructor {
	
}