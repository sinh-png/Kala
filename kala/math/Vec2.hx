package kala.math;

import kha.FastFloat;
import kha.math.Vector2;

class Vec2 extends Vector2 {
	
	@:extern
	public inline function set(x:FastFloat = 0, y:FastFloat = 0):Vec2 {
		this.x = x;
		this.y = y;
		
		return this;
	}
	
}