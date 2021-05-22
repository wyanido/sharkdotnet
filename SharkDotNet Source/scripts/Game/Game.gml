/// CANVAS BOUNDS
#macro CANVASWID 1280
#macro CANVASHI 720
#macro INTERP 3
#macro MAXINK 300

room_set_width(rm_Game, CANVASWID);
room_set_height(rm_Game, CANVASHI);

function Game() constructor {
	
	/// INIITALISE GAME
	view = new Camera();
	panning = false;
	canvasInk = [new Ink(-32, -32, 5)];
	canvasErase = [];
	preInk = new vec2(0, 0);
	preCanvas = noone;
	preErase = noone;
	username = "Shark" + string(irandom_range(100, 999));
	connected = false;
	
	cursorSize = 5;
	
	CursorPen = function(_x, _y) {
		var _ink = new Ink(_x, _y, cursorSize);
		
		canvasInk[array_length(canvasInk)] = _ink;
		preInk = new vec2(_x, _y);
				
		// SEND PEN STROKE
		if(instance_exists(obj_Network) && obj_Network.playerExists) {
			obj_Network.player.SendInk(_x, _y, cursorSize);
		}
	}
	
	CursorErase = function(_x, _y) {
		var _ink = new Erase(_x, _y, cursorSize);
		
		canvasErase[array_length(canvasErase)] = _ink;
		preInk = new vec2(_x, _y);
				
		// SEND PEN STROKE
		if(instance_exists(obj_Network) && obj_Network.playerExists) {
			obj_Network.player.SendErase(_x, _y, cursorSize);
		}
	}
	
	Update = function() {
		
		view.Update();
		
		if(mouse_wheel_down()) { cursorSize ++; }
		if(mouse_wheel_up()) { cursorSize --; }
		
		cursorSize = clamp(cursorSize, 2, 32);
		
		// SET CURSOR
		if(keyboard_check(vk_space)) 
		{
			window_set_cursor(cr_drag);	
		} else {
			var _mX = device_mouse_x_to_gui(0), _mY = device_mouse_y_to_gui(0);
			if(mouse_x > 0 && mouse_x < room_width && mouse_y > 0 && mouse_y < room_height) {
				window_set_cursor(cr_cross);	
			} else if(_mX > 0 && _mX < window_get_width() - 1 && _mY > 0 && _mY < window_get_height() - 1) {
				window_set_cursor(cr_default);	
			}
		}
		
		/// DRAW ON CANVAS
		if(!keyboard_check(vk_space)) {
			if(mouse_check_button(mb_right)) 
			{
			
				CursorErase(mouse_x, mouse_y);
			
				var _dist = point_distance(preMouse.x, preMouse.y, mouse_x, mouse_y) / INTERP;
			
				for(var i = 0; i < _dist; i++) {
					var _dot = new vec2(
						lerp(preMouse.x, mouse_x, (1 / (_dist)) * i), 
						lerp(preMouse.y, mouse_y, (1 / (_dist)) * i)	
					)
					
					if!(_dot.x == preInk.x && _dot.y == preInk.y) 
					{
					
						CursorErase(_dot.x, _dot.y);

					}
				}
			
			}
				else if(mouse_check_button(mb_left)) 
			{

				CursorPen(mouse_x, mouse_y);

				var _dist = point_distance(preMouse.x, preMouse.y, mouse_x, mouse_y) / INTERP;

				for(var i = 0; i < _dist; i++) {
					var _dot = new vec2(
						lerp(preMouse.x, mouse_x, (1 / (_dist)) * i), 
						lerp(preMouse.y, mouse_y, (1 / (_dist)) * i)	
					)
					
					if!(_dot.x == preInk.x && _dot.y == preInk.y) 
					{
					
						CursorPen(_dot.x, _dot.y);

					}
				}	
			}
		}
		
		preMouse = new vec2(mouse_x, mouse_y);
		
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
				
				if((array_length(canvasInk) > 1)) {
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
		var _ww = obj_Game.game.view.camSize.x / 2;
		var _hh = obj_Game.game.view.camSize.y / 2;
		
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
		draw_set_colour(c_black);
		draw_circle(mouse_x, mouse_y, cursorSize, true);

	}

	GUI = function() 
	{
		
		/// DRAW GAME INTERFACE
		draw_set_colour(make_colour_rgb(51, 51, 51));
		draw_rectangle(0, 0, obj_Game.game.view.camSize.x, 64, false);
		
		draw_set_colour(c_white);
		
		if(!instance_exists(obj_Network)) {
			draw_set_colour(c_red);
			
			draw_text(8, 8, "You are offline. F1 to Connect | F2 to Host (Currently Unsupported)");
			
			draw_set_colour(c_white);
		} else {
			if(!connected) {
				draw_set_colour(c_yellow);
				
				draw_text(8, 8, "We're trying to connect you to a server, sit tight!");
				
				draw_set_colour(c_white);
			} else {
				draw_set_colour(c_lime);
				
				draw_text(8, 8, "Connected! There are " + string(ds_map_size(obj_Network.client.cln_SocketIDs)) + " player(s) online.");
				
				draw_set_colour(c_white);
			}
		}
		
		draw_text(8, 24, string(array_length(canvasInk)) + " Ink Instance(s) on the Canvas");
		
	}
	
}