package kala.math;

import kha.FastFloat;

class Vec2 {
	
	public var x:FastFloat;
	public var y:FastFloat;
	
	public function new(x:FastFloat = 0, y:FastFloat = 0) {
		this.x = x;
		this.y = y;
	}
	
	@:extern
	public inline function set(x:FastFloat = 0, y:FastFloat = 0):Vec2 {
		this.x = x;
		this.y = y;
		
		return this;
	}
	
}