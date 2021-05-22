
function Ink(_x, _y, _size) constructor
{
	
	pos = new vec2(_x, _y);
	col = c_black;
	r = _size;
	
	Render = function() 
	{
		draw_set_colour(col);
		draw_circle(pos.x, pos.y, r, false);	
	}

}

function Erase(_x, _y, _size) constructor
{
	
	pos = new vec2(_x, _y);
	r = _size;
	
	Render = function() 
	{
		
		draw_circle(pos.x, pos.y, r, false);

	}

}
