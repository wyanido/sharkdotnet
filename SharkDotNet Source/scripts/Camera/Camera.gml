/// CAMERA BOUNDS
#macro CAMWID 1280
#macro CAMHI 720

function Camera() constructor {
	
	/// INITIALISE WORLD VIEW
	cam = camera_create();
	pos = new vec2(0, 0);
	mousePrevious = new vec2(mouse_x, mouse_y);
	
	var _vm = matrix_build_lookat(pos.x, pos.y, -10, pos.x, pos.y, 0, 0, 1, 0);
	var _pm = matrix_build_projection_ortho(CAMWID, CAMHI, 0, 32000);
	
	camera_set_view_mat(cam, _vm);
	camera_set_proj_mat(cam, _pm);
	
	view_camera[0] = cam;
	
	window_set_size(CAMWID, CAMHI);
	surface_resize(application_surface, CAMWID, CAMHI);
	display_reset(0, 0);
	
	Update = function() {
		
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