
function GUI_Welcome() 
{
	
	var _cCen = new vec2((view.camSize.x - 128) / 2, (view.camSize.y + 32) / 2);
	var _size = new vec2(256, 384);
	var _col = [make_colour_rgb(33, 33, 33), make_colour_rgb(51, 51, 51)]
	var _logoScale = 4;
		
	draw_rectangle_colour(_cCen.x - _size.x / 2, _cCen.y - _size.y / 2, _cCen.x + _size.x / 2, _cCen.y + _size.y / 2, _col[1], _col[0], _col[1], _col[0], false);
		
	draw_set_colour(_col[1]);
	draw_rectangle(_cCen.x - _size.x / 2, _cCen.y - _size.y / 2, _cCen.x + _size.x / 2, _cCen.y + _size.y / 2, true);
		
	draw_set_colour(_col[0]);
	draw_rectangle(_cCen.x - (_size.x / 2) + 8, _cCen.y + 16, _cCen.x + _size.x / 2 - 8, _cCen.y + _size.y / 2 - 32, false);
	draw_set_colour(_col[1]);
	draw_rectangle(_cCen.x - (_size.x / 2) + 8, _cCen.y + 16, _cCen.x + _size.x / 2 - 8, _cCen.y + _size.y / 2 - 32, true);
		
	draw_sprite_ext(s_Icon, 0, _cCen.x - ((sprite_get_width(s_Icon) / 2) * _logoScale), _cCen.y - 184, _logoScale, _logoScale, 0, c_white, 1);
		
	draw_set_colour(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_font(fnt_GUI_Title);
		
	draw_text(_cCen.x, _cCen.y - 48, "SHARKDOTNET Alpha v1.2.0");
		
	draw_set_font(fnt_GUI);
	draw_text(_cCen.x, _cCen.y - 32, "(Release 24/05/2021)");
		
	draw_set_halign(fa_left);
		
	draw_text(_cCen.x - (_size.x / 2) + 8, _cCen.y, "Changelog:");
		
	draw_set_valign(fa_top);
		
	draw_text_ext(_cCen.x - (_size.x / 2) + 16, _cCen.y + 24, "- Fixed cursor scaling inconsistencies in Multiplayer\n- Added Welcome Screen\n- Improved Tool Performance", 16, _size.x - 32);
		
	draw_text(_cCen.x - _size.x / 2 + 8, _cCen.y + _size.y / 2 - 22, "Click Anywhere to Dismiss");
	
}