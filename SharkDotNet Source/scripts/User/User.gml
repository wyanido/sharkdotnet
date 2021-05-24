
function User(_x, _y, _name) constructor  {
	
	pos = new vec2(_x, _y);
	user = _name;
	visible = true;
	
	Render = function() {
		draw_sprite_ext(s_Cursor, 0, pos.x, pos.y, 2, 2, 0, c_white, 1);
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
		if(visible) {
			var _z = obj_Game.game.view.zoom;
			
			draw_sprite_ext(s_Cursor, 0, pos.x, pos.y, 2 / _z, 2 / _z, 0, c_white, 1);
			
			draw_set_colour(c_white);
		
			draw_set_valign(fa_top);
			draw_set_halign(fa_center);
			gpu_set_alphatestenable(true);
			
			gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_alpha);
			draw_set_font(fnt_Label)
			draw_text_transformed(pos.x + (15 / _z), pos.y + (38 / _z), user, 1 / _z, 1 / _z, 0);
			draw_set_font(fnt_GUI);
			gpu_set_blendmode(bm_normal);
			
			draw_set_halign(fa_left);
		
			draw_set_colour(c_black);
		}
	}
	
}