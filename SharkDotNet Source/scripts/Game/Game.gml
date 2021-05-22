/// CANVAS BOUNDS
#macro CANVASWID 960
#macro CANVASHI 1000
#macro INTERP 3
#macro MAXINK 1000

room_set_width(rm_Game, CANVASWID);
room_set_height(rm_Game, CANVASHI);

function Game() constructor {
	
	/// INIITALISE GAME
	view = new Camera();
	panning = false;
	canvasInk = [new Ink(-32, -32)];
	preInk = new vec2(0, 0);
	preCanvas = noone;
	username = "Shark" + string(irandom_range(100, 999));
	
	Update = function() {
		
		view.Update();
		
		// SET CURSOR
		if(keyboard_check(vk_space)) 
		{
			window_set_cursor(cr_drag);	
		} else {
			if(mouse_x > 0 && mouse_x < room_width && mouse_y > 0 && mouse_y < room_height) {
				window_set_cursor(cr_cross);	
			} else {
				window_set_cursor(cr_default);	
			}
		}
		
		/// DRAW ON CANVAS	
		if(mouse_check_button(mb_left) && !keyboard_check(vk_space)) {
			var _ink = new Ink(mouse_x, mouse_y);
			canvasInk[array_length(canvasInk)] = _ink;
				
			var _dist = point_distance(preMouse.x, preMouse.y, mouse_x, mouse_y) / INTERP;
				
			// CONNECT DOTS WITH LINE

			for(var i = 0; i < _dist; i++) {
				var _dot = new vec2(
					lerp(preMouse.x, mouse_x, (1 / (_dist)) * i), 
					lerp(preMouse.y, mouse_y, (1 / (_dist)) * i)	
				)
					
				if!(_dot.x == preInk.x && _dot.y == preInk.y) 
				{

					var _ink = new Ink(_dot.x, _dot.y);
					canvasInk[array_length(canvasInk)] = _ink;
						
					preInk = new vec2(_dot.x, _dot.y);
						
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
		
		if(_refresh) { var _canvas = surface_create(CANVASWID, CANVASHI); surface_set_target(_canvas); }
		
		if(preCanvas != noone) { draw_sprite(preCanvas, 0, 0, 0); }
		
		for(var i = 0; i < array_length(canvasInk); i ++) 
		{
			canvasInk[i].Render();
		}
		
		if(_refresh) {
			surface_reset_target();
			preCanvas = sprite_create_from_surface(_canvas, 0, 0, CANVASWID, CANVASHI, false, false, 0, 0);
			draw_sprite(preCanvas, 0, 0, 0);
			
			canvasInk = [new Ink(-32, -32)];
			
			surface_free(_canvas);
		}
		
		// OOB
		var _ww = CAMWID / 2;
		var _hh = CAMHI / 2;
		
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
		draw_circle(mouse_x, mouse_y, 5, true);

	}
	
	GUI = function() 
	{
		
		/// DRAW GAME INTERFACE
		draw_set_colour(make_colour_rgb(51, 51, 51));
		draw_rectangle(0, 0, CAMWID, 64, false);
		
		draw_set_colour(c_white);
		
		if(!instance_exists(obj_Network)) {
			draw_text(8, 8, "You are offline. Press F1 to Connect to a server, or F2 to Host (Currently Unsupported)");
		} else {
			if(obj_Network.client.socket == 0) {
				draw_text(8, 8, "We're trying to connect you to a server, sit tight!");
			} else {
				draw_text(8, 8, "Connected! There are " + string(ds_map_size(obj_Network.client.cln_SocketIDs)) + " player(s) online.");
			}
		}
		
		draw_text(8, 24, string(array_length(canvasInk)) + " Ink Instance(s) on the Canvas");
		
	}
	
}