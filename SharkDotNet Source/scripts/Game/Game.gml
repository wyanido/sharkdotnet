/// CANVAS BOUNDS
#macro CANVASWID 1280
#macro CANVASHI 720
#macro MAXINK 400

// REFERENCES
#macro PLAYER obj_Network.player

room_set_width(rm_Game, CANVASWID);
room_set_height(rm_Game, CANVASHI);

#region CURSOR SETUP	
	window_set_cursor(cr_none);

	enum cr 
	{
		point,
		cross,
		drag,
		scale_h,
		scale_v
	}
	
	enum act 
	{
		none,
		draw,
		erase,
		panView,
		scaleWindow,
		dragWindow
	}
	
#endregion

randomize();

function Game() constructor {
	
	#region INITIALISE GAME SESSION
	
		// SESSION
		view = new Camera();
		resized = false;
		connected = false;
		showWelcome = true;
		inkCounter = 0;
	
		// CURSOR
		showGameCursor = true;
		cursor = cr.point;
		action = act.none;
		cursorSize = 6;
	
		preMouse = new vec2(-32, -32); 
		newStroke = true;
	
		panning = false;
		
		edgeDistance = 0;
	
		// CANVAS
		preCanvas = noone;
		lastActionPos = new vec3(0, 0, 0);
	
		canvasInk = [new Ink(-32, -32, 5)];
		canvasErase = [];
	
		// PROFILE & NETWORKING
		username = get_string("Please enter your username.", "Shark" + string(irandom_range(100, 999)));
	
		preMouse_global = new vec2(display_mouse_get_x(), display_mouse_get_y());
		pulledCanvas = -1;
	
		// WINDOW
		drag = false;
		scale = false;
		
		winDrag = new vec2(0, 0);

		scaleSide = [];
		winSize = new vec2(0, 0);
		scaleCursor = new vec2(0, 0);
		
		// BUTTONS
		
	
	#endregion
	
	CursorAction = function(_x, _y, _size, _type) {
		// EXIT IF OUT OF BOUNDS OR IF THE CANVAS IS LOADING
		if(_x < 0 || _x > room_width || _y < 0 || _y > room_height) { exit; }
		if(connected && pulledCanvas != 1) { exit; }
		
		if(_type == 1) { // DRAW
			
			var _blot = new Ink(_x, _y, cursorSize);
			canvasInk[array_length(canvasInk)] = _blot;
			
			if(!mouse_check_button(mb_right)) {
				inkCounter ++;
			}
			
		} else { // ERASE
			
			var _blot = new Erase(_x, _y, cursorSize);
			canvasErase[array_length(canvasErase)] = _blot;
			
		}

		lastActionPos = new vec3(_x, _y, _size);
				
		// SEND ACTION
		if(instance_exists(obj_Network) && obj_Network.playerExists) {
			PLAYER.SendAction(_x, _y, cursorSize, _type);
		}
	}
	
	ScaleWindow = function() 
	{
		
		if(!mouse_check_button(mb_left)) { scale = 0; scaleSide = -1; }
			
		if(mouse_check_button_pressed(mb_left) && !scale) {
			scaleSide = [];
				
			#region 4 DIRECTIONAL
				// LEFT
				if(device_mouse_x_to_gui(0) < 4) {
					scale = true;
					scaleSide = [0];
				}
				
				// TOP
				if(device_mouse_y_to_gui(0) < 4) {
					scale = true;
					scaleSide = [1];
				}
				
				// RIGHT
				if(device_mouse_x_to_gui(0) > window_get_width() - 6) {
					scale = true;
					scaleSide = [2];
				}
				
				// BOTTOM
				if(device_mouse_y_to_gui(0) > window_get_height() - 6) {
					scale = true;
					scaleSide = [3];
				}
			#endregion
				
			#region 4 DIAGONAL
				// TOP LEFT
				if(device_mouse_x_to_gui(0) < 8 && device_mouse_y_to_gui(0) < 8) {
					scale = true;
					scaleSide = [0, 1];
				}
				
				// TOP RIGHT
				if(device_mouse_y_to_gui(0) < 8 && device_mouse_x_to_gui(0) > window_get_width() - 10) {
					scale = true;
					scaleSide = [2, 1];
				}
				
				// BOTTOM LEFT
				if(device_mouse_y_to_gui(0) > window_get_height() - 10 && device_mouse_x_to_gui(0) < 8) {
					scale = true;
					scaleSide = [3, 0];
				}
				
				// BOTTOM RIGHT
				if(device_mouse_y_to_gui(0) > window_get_height() - 10 && device_mouse_x_to_gui(0) > window_get_width() - 10) {
					scale = true;
					scaleSide = [3, 2];
				}
			#endregion
				
			if(scale) {
				winSize = new vec2(window_get_width(), window_get_height());
				winDrag = new vec2(window_get_x(), window_get_y());
				scaleCursor = new vec2(display_mouse_get_x(), display_mouse_get_y())
					
				for(var i = 0; i < array_length(scaleSide); i ++) {
					if(scaleSide[i] == 0 || scaleSide[i] == 2) {
						edgeDistance = device_mouse_x_to_gui(0);
					} else {
						edgeDistance = device_mouse_y_to_gui(0);
					}
				}
			}
		}
			
		if(scale) {	
			var _targetMouse = new vec2(display_mouse_get_x(), display_mouse_get_y())
			var _targetScale = new vec2(window_get_width(), window_get_height());
			var _targetPos = new vec2(window_get_x(), window_get_y())
				
			for(var i = 0; i < array_length(scaleSide); i ++) {
				switch(scaleSide[i]) {
					case(0):
						var _ww = winSize.x - (_targetMouse.x - scaleCursor.x);
						
						if(_ww < 640) {
							_targetMouse.x = scaleCursor.x + winSize.x - 640;
						} else {
							_targetPos.x = _targetMouse.x - edgeDistance;
							_targetScale.x = _ww;
						}	
					break;
					case(1):
						var _hh = winSize.y - (_targetMouse.y - scaleCursor.y);
						
						if(_hh < 512) { 
							_targetMouse.y = scaleCursor.y + winSize.y - 512; 
						} else {
							_targetPos.y = _targetMouse.y - edgeDistance;
							_targetScale.y = _hh;
						}
					break;
					case(2):
						var _ww = winSize.x + (_targetMouse.x - scaleCursor.x);
						
						if(_ww < 640) { 
							_targetMouse.x = scaleCursor.x - winSize.x + 640; 
						} else {
							_targetScale.x = _ww;
						}
					break;
					case(3):
						var _hh = winSize.y + (_targetMouse.y - scaleCursor.y);
						
						if(_hh < 512) { 
							_targetMouse.y = scaleCursor.y - winSize.y + 512; 
						} else {
							_targetScale.y = _hh;
						}
					break;
				}
			}
				
			window_set_size(_targetScale.x, _targetScale.y);
			window_set_position(_targetPos.x, _targetPos.y);
			display_mouse_set(_targetMouse.x, _targetMouse.y);
				
			if(preMouse_global.x == display_mouse_get_x() && preMouse_global.y == display_mouse_get_y()) && !resized {
				view.Resize()	
				resized = true;
			} else {
				resized = false;
			}	
		}
			
		preMouse_global = new vec2(display_mouse_get_x(), display_mouse_get_y());
		
	}
	
	GetCursorState = function() 
	{
		// STORE INFO LOCALLY
		var _mX = device_mouse_x_to_gui(0), _mY = device_mouse_y_to_gui(0);
		var _win = view.camSize;
		
		// GET HOVERING ELEMENTS
		cursorOnCanvas = (mouse_x > 0 && mouse_x < room_width && mouse_y > 0 && mouse_y < room_height);
		cursorOnGUI = (_mY < 64);
		cursorOnBorder = (_mX < 4 || _mY < 4 || _mX > _win.x - 6 || _mY > _win.y - 6);
		panning = cursorOnCanvas && !cursorOnGUI && ;
		
		// SET ICON
		if(cursorOnBorder || scale) 
		{
			window_set_cursor(cr_none)
			
			/// DIAGONAL SCALING
			// TOP LEFT / BOTTOM RIGHT
			if(_mX < 8 && _mY < 8) || (_mY > _win.y - 10 && _mX > _win.x - 10) { window_set_cursor(cr_size_nwse); }
			// TOP RIGHT / BOTTOM LEFT
			if(_mY < 8 && _mX > _win.x - 10) || (_mY > _win.y - 10 && _mX < 8) { window_set_cursor(cr_size_nesw); }
			
			var _scaling = window_get_cursor() != cr_none;
			
			// 4-DIRECTIONAL SCALING
			if(!_scaling) {
				// HORIZONTAL
				if((_mX < 4 || _mX > _win.x - 6)) { window_set_cursor(cr_size_we); }
			
				// VERTICAL
				if((_mY < 4 || _mY > _win.y - 6)) { window_set_cursor(cr_size_ns); }
			}
			
			showGameCursor = window_get_cursor() == cr_none;
			
		} else {
			window_set_cursor(cr_none);
			showGameCursor = true;
				
			cursor = cursorOnCanvas && !cursorOnGUI ? cr.cross : cr.point;
		}

	}
	
	GetKeyState = function()
	{
		
	}
	
	Update = function() {
		
		GetCursorState();
		GetKeyState();
		
		ScaleWindow();
		
		view.Update();
		
		if(!keyboard_check(vk_lcontrol)) {
			if(mouse_wheel_down()) { cursorSize += 2; }
			if(mouse_wheel_up()) { cursorSize -= 2; }
		}
		
		cursorSize = clamp(cursorSize, 2, 32);

		/// DRAW ON CANVAS
		if(!(keyboard_check(vk_space) || mouse_check_button(mb_middle)) && device_mouse_y_to_gui(0) > 64 && !drag && !scale) {

			// ACTION TYPE
			var _act = 0;
			if(mouse_check_button(mb_left)) { _act = 1; } 
			else if(mouse_check_button(mb_right)) { _act = 2; }
			
			
			
			if(_act > 0 && ((abs(mouse_x - lastActionPos.x) > 0 || abs(mouse_y - lastActionPos.y) > 0) || newStroke))
			{
				
				if(_act == 1) { newStroke = false; }
				
				CursorAction(mouse_x, mouse_y, cursorSize, _act);
				
				var _dist = point_distance(preMouse.x, preMouse.y, mouse_x, mouse_y) / min(cursorSize * 10, 2);
				
				for(var i = 0; i < _dist; i++) {
					var _dot = new vec2(
						lerp(preMouse.x, mouse_x, (1 / (_dist)) * i), 
						lerp(preMouse.y, mouse_y, (1 / (_dist)) * i)	
					)
					
					if!(_dot.x == lastActionPos.x && _dot.y == lastActionPos.y) 
					{
					
						CursorAction(_dot.x, _dot.y, cursorSize, _act);

					}
				}
			}
			
			if(!mouse_check_button(mb_left)) { newStroke = true; }
			
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
				
				if((array_length(canvasInk) > 1) || (array_length(canvasErase) > MAXINK) || !mouse_check_button(mb_right)) {
					delete canvasErase;
					canvasErase = [];
				}
				
				surface_reset_target();
				
				surface_set_target(_canvas);
				
				gpu_set_blendmode(bm_subtract);
				
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
		if(!(keyboard_check(vk_space) || mouse_check_button(mb_middle)) && (mouse_x > 0 && mouse_x < room_width && mouse_y > 0 && mouse_y < room_height)) && !showWelcome {
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
		var _sideBar = 160;
		var _header = 32;
		
		draw_set_colour(make_colour_rgb(33, 33, 33));
		draw_rectangle(0, 0, _border,view.camSize.y, false);
		draw_rectangle(0, view.camSize.y, view.camSize.x, view.camSize.y - _border - 2, false);
		draw_rectangle(view.camSize.x, 0, view.camSize.x - _sideBar - _border - 2, view.camSize.y, false);
		
		draw_set_colour(make_colour_rgb(51, 51, 51));
		draw_rectangle(_border + 1, 32, view.camSize.x - _border - 2, 64, false);
		
		/// HEADER BAR
		draw_set_colour(make_colour_rgb(33, 33, 33));
		draw_rectangle(0, 0, obj_Game.game.view.camSize.x, _header, false);
		
		draw_set_colour(c_white);
		draw_set_valign(fa_middle);
		
		draw_sprite(s_Icon, 0, 5, 2);
		draw_text(40, 18, "SHARKDOTNET | Early Testing Alpha");
		draw_text(16, 50, "Draw: LMB   |   Pen Size: Scroll   |   Erase: RMB        Pan: Space + LMB / MMB   |   Zoom: CTRL + Scroll / CTRL + UP/DOWN");
		
		draw_set_colour(c_white);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		var _dx = device_mouse_x_to_gui(0), _dy = device_mouse_y_to_gui(0);
		var _a = ((_dx > view.camSize.x - 32 && _dx < view.camSize.x - 10) && (_dy < 32 && _dy > 4)) ? 0.5 : 1;
		
		draw_sprite_ext(s_Button, 0, view.camSize.x - 32, 2, 2, 2, 0, c_white, _a);
		
		if(_a == 0.5 && mouse_check_button_pressed(mb_left)) { game_end(); }
		
		// NETWORK BAR
		draw_set_colour(make_colour_rgb(51, 51, 51));
		
		#region Session Info
			draw_rectangle(view.camSize.x - _sideBar, 72, view.camSize.x - 10, 96, false);
			draw_rectangle(view.camSize.x - _sideBar, 100, view.camSize.x - 10, 162, false);
			
			draw_set_colour(c_white);
			draw_text_ext(view.camSize.x - _sideBar + 8, 116 - 8, "Net Status: ", 20, _sideBar - 16);
			draw_text_ext(view.camSize.x - _sideBar + 8, 116 - 8 + 16, "Ink Placed: " + string(inkCounter), 20, _sideBar - 16);
			draw_text_ext(view.camSize.x - _sideBar + 8, 116 - 8 + 32, "Session Time: " + string(floor(get_timer() / 1000000)) + "s", 20, _sideBar - 16);
		#endregion
		
		#region Profile Section
			draw_set_colour(make_colour_rgb(51, 51, 51));
			draw_rectangle(view.camSize.x - _sideBar, 166, view.camSize.x - 10, 190, false);
			draw_rectangle(view.camSize.x - _sideBar, 194, view.camSize.x - 10, 194 + 132, false);
			
			draw_set_colour(c_white);
			draw_text_ext(view.camSize.x - _sideBar + 8, 172, "My Profile", 20, _sideBar - 16);
			
			draw_set_colour(make_colour_rgb(33, 33, 33));
			draw_sprite_ext(s_DefaultIcon, 0, view.camSize.x - _sideBar + 8, 204, 3, 3, 0, c_white, 1);
			draw_rectangle(view.camSize.x - _sideBar + 8, 204, view.camSize.x - _sideBar + 7 + 48, 250, true);
			
			draw_set_color(c_white);
			draw_text(view.camSize.x - _sideBar + 64, 208, username);
			draw_text(view.camSize.x - _sideBar + 64, 232, "New User");
			
			// BUTTONS
			draw_set_colour(make_colour_rgb(96, 96, 96));
			draw_rectangle(view.camSize.x - _sideBar + 8, 258, view.camSize.x - _sideBar + 140, 282, true);
			
			draw_set_color(c_white);
			draw_set_halign(fa_middle);
			draw_text(view.camSize.x - _sideBar + 72, 264, "Change Username");
			draw_set_halign(fa_top);
			
			draw_set_colour(make_colour_rgb(80, 80, 80));
			draw_rectangle(view.camSize.x - _sideBar + 8, 258 + 32, view.camSize.x - _sideBar + 140, 282 + 32, true);
			
			draw_set_color(c_white);
			draw_set_halign(fa_middle);
			draw_text(view.camSize.x - _sideBar + 72, 264 + 32, "Change Icon");
			draw_set_halign(fa_top);

		#endregion
		
		// HEADER
		draw_set_colour(make_colour_rgb(51, 51, 51));
		draw_rectangle(view.camSize.x - _sideBar, 166 + 184, view.camSize.x - 10, 190 + 184, false);
		draw_rectangle(view.camSize.x - _sideBar, 194 + 184, view.camSize.x - 10, 194 + 132 + 184, false);
			
		draw_set_colour(c_white);
		
		var _users = instance_exists(obj_Network) ? string(ds_map_size(obj_Network.client.cln_SocketIDs)) : "0";
		
		draw_text_ext(view.camSize.x - _sideBar + 8, 172 + 184, "Online Users (" + _users +")", 20, _sideBar - 16);
		
		draw_set_colour(make_colour_rgb(96, 96, 96));
		draw_line(view.camSize.x - _sideBar + 2, 338, view.camSize.x - 12, 338);
		
		draw_set_colour(c_white);
		draw_text(view.camSize.x - _sideBar + 8, 84 - 6, "Session Info");
		
		if(!instance_exists(obj_Network)) {
			
			draw_set_colour(c_red);
			draw_text_ext(view.camSize.x - _sideBar + 8 + string_width("Net Status: "), 116 - 8, "Offline", 20, _sideBar - 16);
			
			draw_set_colour(c_white);
			draw_text_ext(view.camSize.x - _sideBar + 8, 172 + 184 + 30, "You're Offline! Connect to a server to see who you're doodling with.", 20, _sideBar - 16);
			
		} else {
			if(!connected) {
				
				draw_set_colour(c_yellow);
				draw_text_ext(view.camSize.x - _sideBar + 8 + string_width("Net Status: "), 116 - 8, "Connecting...", 20, _sideBar - 16);

			} else {
				draw_set_colour(c_lime);
				draw_text_ext(view.camSize.x - _sideBar + 8 + string_width("Net Status: "), 116 - 8, "Connected!", 20, _sideBar - 16);
				
				draw_set_colour(c_white);
				var _name = ds_map_find_first(obj_Network.client.cln_SocketIDs);
				
				for(var i = 0; i < ds_map_size(obj_Network.client.cln_SocketIDs); i ++) {
					
					draw_text_ext(view.camSize.x - _sideBar + 9, 388 + (16 * i), ds_map_find_value(obj_Network.client.cln_SocketIDs, _name).user, 20, 100);
					
					var _name = ds_map_find_next(obj_Network.client.cln_SocketIDs, _name);
				}
				
				if(pulledCanvas != 1) {
					draw_set_colour(c_black);
					draw_set_alpha(0.75);
					draw_rectangle(4, 64, view.camSize.x - _sideBar - 4, view.camSize.y - 6, false);
					draw_set_alpha(1);
					
					draw_set_colour(c_white);
					draw_set_halign(fa_center);
					draw_set_valign(fa_middle);
					draw_text((view.camSize.x - _sideBar - 4) / 2, (view.camSize.y + 64) / 2, "Downloading Canvas from Host...\nPlease wait a moment before drawing.");
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
				}
			}
		}
		
		
		// FOOTER
		draw_set_colour(make_colour_rgb(51, 51, 51));
		draw_rectangle(5, view.camSize.y - 6 - 20, view.camSize.x - 6, view.camSize.y - 6, false);
		
		draw_set_colour(c_white);
		draw_set_valign(fa_middle);
		draw_text(8,  view.camSize.y - 15, "Zoom Scale: " + string(view.zoom * 100) + "%  |  Pen Size: " + string(cursorSize) + "  |  " + string(array_length(canvasInk)) + " Active Ink Instance(s)");
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
		draw_rectangle(1, 1,  view.camSize.x - 2,  view.camSize.y - 2, true);
		
		if(showWelcome) {
			if((mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right) || mouse_check_button_pressed(mb_middle)) && !scale && !drag) {
				showWelcome = false;
			}
			
			GUI_Welcome();
		}
		
		// CURSOR
		if(showGameCursor && (!(mouse_check_button(mb_right) && (mouse_x > 0 && mouse_x < room_width && mouse_y > 0 && mouse_y < room_height)))) {
			draw_sprite_ext(s_Cursor, cursor, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 2, 2, 0, c_white, 1);
		}

	}
}