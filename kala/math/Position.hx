package kala.math;

import kha.FastFloat;

@:forward
abstract Position(Vec2T) from Vec2T to Vec2T {

	public var realX(get, never):FastFloat;
	public var realY(get, never):FastFloat;
	
	public inline function new() {
		this = new Vec2T();
	}
	
	public inline function getDistance(pos:Position):FastFloat {
		return Math.sqrt((this.x - pos.x) * (this.x - pos.x) + (this.y - pos.y) * (this.y - pos.y));
	}
	
	public inline function getAngle(pos:Position, asDeg:Bool = true):FastFloat {
		return Math.atan2(pos.y - this.y, pos.x - this.x) * (asDeg ? Mathf.CONST_DEG : 1);
	}
	
	inline function get_realX():FastFloat {
		return this.x - this.ox;
	}
	
	function get_realY():FastFloat {
		return this.y - this.oy;
	}
	
}