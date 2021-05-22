/// CAMERA BOUNDS

function Camera() constructor {
	
	/// INITIALISE WORLD VIEW
	cam = camera_create();
	pos = new vec2(0, 0);
	
	camSize = new vec2(1280, 720);
	
	mousePrevious = new vec2(mouse_x, mouse_y);
	
	var _vm = matrix_build_lookat(pos.x, pos.y, -10, pos.x, pos.y, 0, 0, 1, 0);
	var _pm = matrix_build_projection_ortho(camSize.x, camSize.y, 0, 32000);
	
	camera_set_view_mat(cam, _vm);
	camera_set_proj_mat(cam, _pm);
	
	view_camera[0] = cam;
	
	window_set_size(camSize.x, camSize.y);
	surface_resize(application_surface, camSize.x, camSize.y);
	display_reset(0, 0);
	
	Resize = function() 
	{
		
		show_debug_message("Window was resized!");
		
		camSize = new vec2(window_get_width(), window_get_height());
		
		var _vm = matrix_build_lookat(pos.x, pos.y, -10, pos.x, pos.y, 0, 0, 1, 0);
		var _pm = matrix_build_projection_ortho(camSize.x, camSize.y, 0, 32000);
		
		camera_set_view_mat(cam, _vm);
		camera_set_proj_mat(cam, _pm);
		
		surface_resize(application_surface, camSize.x, camSize.y);
		display_reset(0, 0);
		
	}
	
	Update = function() 
	{
		
		if(window_get_width() != camSize.x || window_get_height() != camSize.y) 
		{
			Resize();	
		}
		
		if(keyboard_check(vk_space) && mouse_check_button(mb_left)) {
			if(!panning) 
			{
				panning = true;
				mousePrevious = new vec2(mouse_x, mouse_y);
			}
			
			/// STORE DIFFERENCE IN MOUSE POSITION
			var _off = new vec2(mouse_x - mousePrevious.x, mouse_y - mousePrevious.y);
			var _view = new vec2(pos.x - _off.x, pos.y - _off.y);

			// RESTRICT VIEW
			_view.x = clamp(_view.x, 0, room_width);
			_view.y = clamp(_view.y, 0, room_height);
				
			// APPLY TO CAMERA
			var _vm = matrix_build_lookat(_view.x, _view.y, -10, _view.x, _view.y, 0, 0, 1, 0);
			camera_set_view_mat(cam, _vm);
			
			pos = _view;

		} else {
			panning = false;	
		}
		
	}
	
}