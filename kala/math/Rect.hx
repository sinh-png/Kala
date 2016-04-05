package kala.math;

import kha.FastFloat;

class Rect {
	
	public var x:FastFloat;
	public var y:FastFloat;
	public var width:FastFloat;
	public var height:FastFloat;
	
	public inline function new(x:FastFloat = 0, y:FastFloat = 0, width:FastFloat = 0, height:FastFloat = 0) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	@:extern
	public inline function set(x:FastFloat = 0, y:FastFloat = 0, width:FastFloat = 0, height:FastFloat = 0):Rect {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		
		return this;
	}
	
	@:extern
	public inline function copy(rect:Rect):Rect {
		x = rect.x;
		y = rect.y;
		width = rect.width;
		height = rect.height;
		
		return this;
	}
	
	@:extern
	public inline function clone():Rect {
		return new Rect(x, y, width, height);
	}
	
	public inline function toString():String {
		return "Rect(x: " + x + ", y: " + y + ", w: " + width + ", h: " + height + ")";
	}
	
}

class RectI {
	
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	
	public inline function new(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	@:extern
	public inline function set(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0):RectI {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		
		return this;
	}
	
	@:extern
	public inline function copy(rect:RectI):RectI {
		x = rect.x;
		y = rect.y;
		width = rect.width;
		height = rect.height;
		
		return this;
	}
	
	@:extern
	public inline function clone():RectI {
		return new RectI(x, y, width, height);
	}
	
	public inline function toString():String {
		return "RectI(x: " + x + ", y: " + y + ", w: " + width + ", h: " + height + ")";
	}
	
}