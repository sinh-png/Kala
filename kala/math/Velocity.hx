package kala.math;

import kha.FastFloat;

using kala.math.Angle;

class Velocity {

	var _x:FastFloat;
	var _y:FastFloat;
	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;
	
	var _angle:FastFloat;
	var _speed:FastFloat;
	public var angle(get, set):FastFloat;
	public var speed(get, set):FastFloat;
	
	private var _angleUpdated:Bool;
	private var _speedUpdated:Bool;
	
	public inline function new(x:FastFloat = 0, y:FastFloat = 0) {
		_x = x;
		_y = y;
		
		_angleUpdated = false;
		_speedUpdated = false;
	}
	
	@:extern
	public inline function set(x:FastFloat = 0, y:FastFloat = 0):Velocity {
		this.x = x;
		this.y = y;
		
		return this;
	}
	
	@:extern
	public inline function clone():Velocity {
		return new Velocity(x, y);
	}
	
	inline function get_x():FastFloat {
		return _x;
	}
	
	inline function set_x(value:FastFloat):FastFloat {
		_angleUpdated = _speedUpdated = false;
		return _x = value;
	}
	
	inline function get_y():FastFloat {
		return _y;
	}
	
	inline function set_y(value:FastFloat):FastFloat {
		_angleUpdated = _speedUpdated = false;
		return _y = value;
	}
	
	inline function get_angle():FastFloat {
		if (_angleUpdated) return _angle;
		_angleUpdated = true;
		return _angle = Math.atan2(y, x).toDeg();
	}
	
	inline function set_angle(value:FastFloat):FastFloat {
		var rad = value.toRad();
		_x = speed * Math.cos(rad);
		_y = speed * Math.sin(rad);
		_angleUpdated = true;
		return _angle = value;
	}
	
	inline function get_speed():FastFloat {
		if (_speedUpdated) return _speed;
		_speedUpdated = true;
		return _speed = x / Math.cos(angle.toRad());
	}
	
	inline function set_speed(value:FastFloat):FastFloat {
		var rad = angle.toRad();
		_x = value * Math.cos(rad);
		_y = value * Math.sin(rad);
		_speedUpdated = true;
		return _speed = value;
	}

}