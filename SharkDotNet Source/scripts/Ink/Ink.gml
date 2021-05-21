
function Ink(_x, _y) constructor
{
	
	pos = new vec2(_x, _y);
	col = c_black;
	r = 5;
	
	Render = function() 
	{
		draw_set_colour(col);
		draw_circle(pos.x, pos.y, r, false);	
	}

}