package kala.math;

import kha.FastFloat;

class Rotation {
	
	public var px:FastFloat;
	public var py:FastFloat;
	public var angle:FastFloat;
	
	public var asDeg:Bool;
	
	public var deg(get, set):FastFloat;
	public var rad(get, set):FastFloat;
	
	public inline function new(angle:FastFloat = 0, pivotX:FastFloat = 0, pivotY:FastFloat = 0, asDeg:Bool = true) {
		this.angle = angle;
		this.px = pivotX;
		this.py = pivotY;
		this.asDeg = asDeg;
	}
	
	@:extern
	public inline function set(angle:FastFloat = 0, pivotX:FastFloat = 0, pivotY:FastFloat = 0, asDeg:Bool = true):Rotation {
		this.angle = angle;
		this.px = pivotX;
		this.py = pivotY;
		this.asDeg = asDeg;
		
		return this;
	}
	
	@:extern
	public inline function copy(rotation:Rotation):Void {
		px = rotation.px;
		py = rotation.py;
		angle = rotation.angle;
		asDeg = rotation.asDeg;
	}
	
	@:extern
	public inline function clone():Rotation {
		return new Rotation(angle, px, py, asDeg);
	}
	
	@:extern
	public inline function setPivot(pivotX:FastFloat = 0, pivotY:FastFloat = 0):Rotation {
		this.px = pivotX;
		this.py = pivotY;
		
		return this;
	}
	
	/**
	 * If asDeg is true, convert the angle value from radians to degrees 
	 * otherwise convert it from degrees to radians.
	 */
	@:extern
	public inline function convert():Rotation {
		if (asDeg) angle = Mathf.rad(angle);
		else angle = Mathf.deg(angle);
		
		asDeg = !asDeg;
		
		return this;
	}

	@:extern
	public inline function movePivot(px:FastFloat, py:FastFloat):Rotation {
		this.px += px;
		this.py += py;
		
		return this;
	}
	
	function get_deg():FastFloat {
		if (asDeg) return angle;
		return Mathf.deg(angle);
	}
	
	function set_deg(value:FastFloat):FastFloat {
		asDeg = true;
		return angle = value;
	}
	
	function get_rad():FastFloat {
		if (asDeg) return Mathf.rad(angle);
		return angle;
	}
	
	function set_rad(value:FastFloat):FastFloat {
		asDeg = false;
		return angle = value;
	}
	
}
