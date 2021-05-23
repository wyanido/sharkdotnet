/// CANVAS BOUNDS
#macro CANVASWID 1280
#macro CANVASHI 720
#macro MAXINK 400

room_set_width(rm_Game, CANVASWID);
room_set_height(rm_Game, CANVASHI);

enum cr {
	point,
	cross,
	drag,
	scale_h,
	scale_v
}

randomize();

function Game() constructor {
	
	/// INIITALISE GAME
	view = new Camera();
	panning = false;
	canvasInk = [new Ink(-32, -32, 5)];
	canvasErase = [];
	preInk = new vec3(0, 0, 0);
	preCanvas = noone;
	preErase = noone;
	username = get_string("Please enter your username.", "Shark" + string(irandom_range(100, 999)));
	connected = false;
	preMouse = new vec2(-32, -32); 
	preMouse_global = new vec2(-32, -32);
	
	pulledCanvas = -1;
	
	cursorSize = 6;
	cursor = cr.point;
	
	// WINDOW
	drag = false;
	winDrag = new vec2(0, 0);
	
	scale = false;
	scaleSide = -1;
	winSize = new vec2(0, 0);
	scaleCursor = new vec2(0, 0);
	
	edgeDistance = 0;
	
	CursorAction = function(_x, _y, _size, _type) {
		// EXIT IF OUT OF BOUNDS
		if(_x < 0 || _x > room_width || _y < 0 || _y > room_height) { exit; }
		if(connected && pulledCanvas != 1) { exit; }
		
		if(_type == 1) {
			
			var _blot = new Ink(_x, _y, cursorSize);
			canvasInk[array_length(canvasInk)] = _blot;
			
		} else {
			
			var _blot = new Erase(_x, _y, cursorSize);
			canvasErase[array_length(canvasErase)] = _blot;
			
		}

		preInk = new vec3(_x, _y, _size);
				
		// SEND ACTION
		if(instance_exists(obj_Network) && obj_Network.playerExists) {
			obj_Network.player.SendAction(_x, _y, cursorSize, _type);
		}
	}
	
	Update = function() {
		
		#region SCALE WINDOW
			
			if(!mouse_check_button(mb_left)) { scale = 0; scaleSide = -1; }
			
			if(mouse_check_button_pressed(mb_left) && !scale) {
				// LEFT
				if(device_mouse_x_to_gui(0) < 4) {
					scale = true;
					scaleSide = 0;
				}
				
				// TOP
				if(device_mouse_y_to_gui(0) < 4) {
					scale = true;
					scaleSide = 1;
				}
				
				// RIGHT
				if(device_mouse_x_to_gui(0) > window_get_width() - 10) {
					scale = true;
					scaleSide = 2;
				}
				
				// RIGHT
				if(device_mouse_y_to_gui(0) > window_get_height() - 10) {
					scale = true;
					scaleSide = 3;
				}
				
				if(scale) {
					winSize = new vec2(window_get_width(), window_get_height());
					winDrag = new vec2(window_get_x(), window_get_y());
					scaleCursor = new vec2(display_mouse_get_x(), display_mouse_get_y())
					
					if(scaleSide == 0 || scaleSide == 2) {
						edgeDistance = device_mouse_x_to_gui(0);
					} else {
						edgeDistance = device_mouse_y_to_gui(0);
					}
				}
			}
			
			if(scale) {
				switch(scaleSide) {
					case(0):
						var _x = winSize.x - (display_mouse_get_x() - scaleCursor.x);
						if(_x < 512) { display_mouse_set(preMouse_global.x, preMouse_global.y); }
						_x = winSize.x - (display_mouse_get_x() - scaleCursor.x);
						
						window_set_position(display_mouse_get_x() - edgeDistance, winDrag.y);
						window_set_size(_x, winSize.y);
					break;
					case(1):
						window_set_position(winDrag.x, display_mouse_get_y() - edgeDistance);
						window_set_size(winSize.x, winSize.y - (display_mouse_get_y() - scaleCursor.y));
					break;
					case(2):
						var _x = winSize.x + (display_mouse_get_x() - scaleCursor.x);
						if(_x < 512) { display_mouse_set(preMouse_global.x, preMouse_global.y); }
						var _x = winSize.x + (display_mouse_get_x() - scaleCursor.x);
						
						window_set_position(winDrag.x, winDrag.y);
						window_set_size(_x, winSize.y);
					break;
					case(3):
						window_set_position(winDrag.x, winDrag.y);
						window_set_size(winSize.x, winSize.y + (display_mouse_get_y() - scaleCursor.y));
					break;
				}
				
				preMouse_global = new vec2(display_mouse_get_x(), display_mouse_get_y());
			}
		#endregion
		
		view.Update();
		
		if(!keyboard_check(vk_lcontrol)) {
			if(mouse_wheel_down()) { cursorSize += 2; }
			if(mouse_wheel_up()) { cursorSize -= 2; }
		}
		
		cursorSize = clamp(cursorSize, 2, 32);
		
		// SET CURSOR
		if(keyboard_check(vk_space) || mouse_check_button(mb_middle)) 
		{
			cursor = cr.drag;
		} else {
			var _mX = device_mouse_x_to_gui(0), _mY = device_mouse_y_to_gui(0);
			var _scaling = false;
			
			if((device_mouse_x_to_gui(0) < 4 || device_mouse_x_to_gui(0) > window_get_width() - 10) || (scale && (scaleSide == 0 || scaleSide == 2))) {
				_scaling = true;
				cursor = cr.scale_h;
			}
			
			if((device_mouse_y_to_gui(0) < 4 || device_mouse_y_to_gui(0) > window_get_height() - 10) || (scale && (scaleSide == 1 || scaleSide == 3))) {
				_scaling = true;
				cursor = cr.scale_v;
			}
			
			if(!_scaling) {
				if((mouse_x > 0 && mouse_x < room_width && mouse_y > 0 && mouse_y < room_height) && _mY > 64) {
					cursor = cr.cross;
				} else if(_mX > 0 && _mX < window_get_width() - 1 && _mY > 0 && _mY < window_get_height() - 1) {
					cursor = cr.point;
				} else {
					cursor = cr.point;
				}
			}
		}
		
		/// DRAW ON CANVAS
		if(!(keyboard_check(vk_space) || mouse_check_button(mb_middle)) && !((mouse_x == preInk.x && mouse_y == preInk.y) && preInk.z == cursorSize) && device_mouse_y_to_gui(0) > 64 && !drag && !scale) {
			
			// ACTION TYPE
			var _act = 0;
			if(mouse_check_button(mb_left)) { _act = 1; } 
			else if(mouse_check_button(mb_right)) { _act = 2; }
			
			if(_act > 0) 
			{

				CursorAction(mouse_x, mouse_y, cursorSize, _act);
				
				var _dist = point_distance(preMouse.x, preMouse.y, mouse_x, mouse_y) / min(cursorSize * 0.5, 2);
				
				for(var i = 0; i < _dist; i++) {
					var _dot = new vec2(
						lerp(preMouse.x, mouse_x, (1 / (_dist)) * i), 
						lerp(preMouse.y, mouse_y, (1 / (_dist)) * i)	
					)
					
					if!(_dot.x == preInk.x && _dot.y == preInk.y) 
					{
					
						CursorAction(_dot.x, _dot.y, cursorSize, _act);

					}
				}
			}
			
			 preMouse = new vec2(mouse_x, mouse_y);
		}
		
	}
	
	GetCanvas = function() 
	{
		
		var _canvas = surface_create(CANVASWID, CANVASHI);
		surface_set_target(_canvas);
		
		// SAVE CACHE
		if(preCanvas != noone) {
			draw_sprite(preCanvas, 0, 0, 0);
		}
		
		// SAVE CURRENT INK
		for(var i = 0; i < array_length(canvasInk); i ++) 
		{
			canvasInk[i].Render();

		}
		
		surface_reset_target();
				
		var _eraseLayer = surface_create(CANVASWID, CANVASHI);
		surface_set_target(_eraseLayer);
				
		draw_clear_alpha(c_black,0)
		draw_set_alpha(1);
		draw_set_colour(c_white);
				
		for(var i = 0; i < array_length(canvasErase); i ++) 
		{
			canvasErase[i].Render();
					
		}

		surface_reset_target();
				
		surface_set_target(_canvas);
				
		gpu_set_blendmode(bm_subtract);	
		draw_surface(_eraseLayer, 0, 0);
		gpu_set_blendmode(bm_normal);
				
		surface_reset_target();
		surface_free(_eraseLayer);

		return _canvas;
		
		surface_free(_canvas);
		
	}
	
	Render = function() 
	{
		
		/// DRAW CANVAS
		// INK
		var _refresh = (array_length(canvasInk) > MAXINK);
		var _erase = array_length(canvasErase) > 0;
		
		if(_refresh || _erase) { var _canvas = surface_create(CANVASWID, CANVASHI); surface_set_target(_canvas); }
		
		if(preCanvas != noone) { draw_sprite(preCanvas, 0, 0, 0); }
		
		for(var i = 0; i < array_length(canvasInk); i ++) 
		{
			canvasInk[i].Render();

		}
		
		if(_refresh || _erase) {
			if(_erase) {
				surface_reset_target();
				
				var _eraseLayer = surface_create(CANVASWID, CANVASHI);
				surface_set_target(_eraseLayer);
				
				draw_clear_alpha(c_black,0)
				draw_set_alpha(1);
				draw_set_colour(c_white);
				
				for(var i = 0; i < array_length(canvasErase); i ++) 
				{
					canvasErase[i].Render();
					
				}
				
				if((array_length(canvasInk) > 1) || (array_length(canvasErase) > MAXINK)) {
					delete canvasErase;
					canvasErase = [];
				}
				
				surface_reset_target();
				
				surface_set_target(_canvas);
				
				gpu_set_blendmode(bm_subtract);
				sprite_delete(preErase);
				
				draw_surface(_eraseLayer, 0, 0);
				
				gpu_set_blendmode(bm_normal);
				
				surface_free(_eraseLayer);

			}
				
			surface_reset_target();
			
			sprite_delete(preCanvas);
			preCanvas = sprite_create_from_surface(_canvas, 0, 0, CANVASWID, CANVASHI, false, false, 0, 0);
			draw_sprite(preCanvas, 0, 0, 0);
			
			canvasInk = [new Ink(-32, -32, 5)];
			
			surface_free(_canvas);	
		}
		
		// OOB
		var _ww = (obj_Game.game.view.camSize.x / obj_Game.game.view.zoom) / 2;
		var _hh = (obj_Game.game.view.camSize.y / obj_Game.game.view.zoom) / 2;
		
		draw_set_colour(make_colour_rgb(25, 25, 25));
		draw_rectangle(-_ww, -_hh, room_width + _ww, 0, false); // TOP
		draw_rectangle(-_ww, 0, 0, room_height + _hh, false); // LEFT
		draw_rectangle(room_width, 0, room_width + _ww, room_height, false); // RIGHT
		draw_rectangle(-_ww, room_height, room_width + _ww, room_height + _hh, false); // BOTTOM
		
		// BORDER
		draw_set_colour(c_red);
		draw_rectangle(1, 1, room_width - 1, room_height - 1, true);
		draw_set_colour(c_white);
		
		// PEN SIZE
		draw_set_colour(c_white);
		if(!(keyboard_check(vk_space) || mouse_check_button(mb_middle)) && (mouse_x > 0 && mouse_x < room_width && mouse_y > 0 && mouse_y < room_height)) {
			gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_alpha);
			
			
			draw_circle(mouse_x, mouse_y, cursorSize, true);
			
			gpu_set_blendmode(bm_normal);
		}

	}
	
	GUI = function() 
	{
		
		draw_set_font(fnt_GUI);
		
		// WINDOW BORDER
		var _border = 4;
		
		draw_set_colour(make_colour_rgb(33, 33, 33));
		draw_rectangle(0, 0, _border, window_get_height(), false);
		draw_rectangle(0, window_get_height(), window_get_width(), window_get_height() - _border - 2, false);
		draw_rectangle(window_get_width(), 0, window_get_width() - 128 - _border - 2, window_get_height(), false);
		
		draw_set_colour(make_colour_rgb(51, 51, 51));
		draw_rectangle(_border + 1, 32, window_get_width() - _border - 2, 64, false);
		
		/// HEADER BAR
		draw_set_colour(make_colour_rgb(33, 33, 33));
		draw_rectangle(0, 0, obj_Game.game.view.camSize.x, 32, false);
		
		draw_set_colour(c_white);
		draw_set_valign(fa_middle);
		
		draw_sprite(s_Icon, 0, 5, 2);
		draw_text(40, 18, "SHARKDOTNET | Version Alpha 0.2");
		draw_text(16, 50, "Draw: LMB  |  Pen Size: Scroll  |  Erase: RMB        Pan: Space + LMB / MMB  |  Zoom: CTRL + Scroll");
		
		draw_set_colour(c_white);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
					
		var _a = (device_mouse_x_to_gui(0) > window_get_width() - 32 && device_mouse_y_to_gui(0) < 32) ? 0.5 : 1;
		
		draw_sprite_ext(s_Button, 0, window_get_width() - 32, 2, 2, 2, 0, c_white, _a);
		
		if(_a == 0.5 && mouse_check_button_pressed(mb_left)) { game_end(); }
		
		// NETWORK BAR
		draw_set_colour(make_colour_rgb(51, 51, 51));
		
		draw_rectangle(window_get_width() - 128, 72, window_get_width() - 10, 96, false);
		draw_rectangle(window_get_width() - 128, 100, window_get_width() - 10, 100 + 192, false);
		
		draw_rectangle(window_get_width() - 128, 296, window_get_width() - 10, 292 + 30, false);
		draw_rectangle(window_get_width() - 128, 326, window_get_width() - 10, 326 + 192, false);
		
		draw_set_colour(c_white);
		draw_text(window_get_width() - 128 + 8, 84 - 6, "Network Info");
		
		if(!instance_exists(obj_Network)) {
			draw_set_colour(c_red);
			
			draw_text_ext(window_get_width() - 128 + 8, 116 - 8, "You're Offline. Network Info is only accessible when connected to a server.\n\nPress F1 to locate a Server.", 20, 100);
		} else {
			if(!connected) {
				draw_set_colour(c_yellow);
				
				draw_text_ext(window_get_width() - 128 + 8, 116 - 8, "Attempting to establish a connection...", 20, 100);

			} else {
				draw_set_colour(c_lime);
				draw_text_ext(window_get_width() - 128 + 8, 116 - 8, "Connected!", 20, 100);
				
				draw_set_colour(c_white);
				draw_text_ext(window_get_width() - 128 + 9, 302, "Online Users:", 20, 100);
				
				var _name = ds_map_find_first(obj_Network.client.cln_SocketIDs);
				for(var i = 0; i < ds_map_size(obj_Network.client.cln_SocketIDs); i ++) {
					
					draw_text_ext(window_get_width() - 128 + 9, 332 + (16 * i), ds_map_find_value(obj_Network.client.cln_SocketIDs, _name).user, 20, 100);
					
					var _name = ds_map_find_next(obj_Network.client.cln_SocketIDs, _name);
				}
				
				if(pulledCanvas != 1) {
					draw_set_colour(c_black);
					draw_set_alpha(0.75);
					draw_rectangle(4, 64, window_get_width() - 128 - 4, window_get_height() - 6, false);
					draw_set_alpha(1);
					
					draw_set_colour(c_white);
					draw_set_halign(fa_center);
					draw_set_valign(fa_middle);
					draw_text((window_get_width() - 128 - 4) / 2, (window_get_height() + 64) / 2, "Downloading Canvas from Host...\nPlease wait a moment before drawing.");
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
				}
			}
		}
		
		
		// FOOTER
		draw_set_colour(make_colour_rgb(51, 51, 51));
		draw_rectangle(5, window_get_height() - 6 - 20, window_get_width() - 6, window_get_height() - 6, false);
		
		draw_set_colour(c_white);
		draw_set_valign(fa_middle);
		draw_text(8, window_get_height() - 15, "Zoom Scale: " + string(view.zoom * 100) + "%  |  Pen Size: " + string(cursorSize) + "  |  " + string(array_length(canvasInk)) + " Active Ink Instance(s)");
		draw_set_valign(fa_top);
		
		#region DRAG WINDOW
		
			if(device_mouse_y_to_gui(0) < 32 && mouse_check_button_pressed(mb_left) && !drag && !scale) {
				drag = true;
				winDrag = new vec2(display_mouse_get_x() - window_get_x(), display_mouse_get_y() - window_get_y());
			}
			
			if(!mouse_check_button(mb_left)) { drag = 0; }
			
			if(drag) {
				window_set_position(display_mouse_get_x() - winDrag.x, display_mouse_get_y() - winDrag.y);
			}
			
		#endregion
		
		draw_set_colour(make_colour_rgb(51, 51, 51));
		draw_rectangle(1, 1, window_get_width() - 2, window_get_height() - 2, true);
		
		// CURSOR
		if(!(mouse_check_button(mb_right) && (mouse_x > 0 && mouse_x < room_width && mouse_y > 0 && mouse_y < room_height))) {
			draw_sprite_ext(s_Cursor, cursor, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 2, 2, 0, c_white, 1);
		}
		
	}
	
}