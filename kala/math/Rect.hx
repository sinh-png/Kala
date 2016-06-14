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
	public inline function set(x:FastFloat = 0, y:FastFloat = 0, width:FastFloat = 0, height:FastFloat = 0):Void {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	@:extern
	public inline function copy(rect:Rect):Void {
		x = rect.x;
		y = rect.y;
		width = rect.width;
		height = rect.height;
	}
	
	@:extern
	public inline function clone():Rect {
		return new Rect(x, y, width, height);
	}
	
	/**
	 * Get the intersection arena of this rectangle with the input rectangle.
	 */
	@:extern
	public inline function getIntersection(rect:Rect):Rect {
		var x2 = x + width;
		var x4 = rect.x + rect.width;
		var y1 = y - height;
		var y3 = rect.y - rect.height;

		var leftX = Math.max(x, rect.x);
		var rightX = Math.min(x2, x4);
		
		if (rightX <= leftX) return null;
		else {
			var topY = Math.max(y1, y3);
			var bottomY = Math.min(y, rect.y);
			
			if (bottomY <= topY) return null;
			else return new Rect(leftX, bottomY, rightX - leftX, bottomY - topY);
		}
	}
	
	@:extern
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
	public inline function set(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0):Void {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	@:extern
	public inline function copy(rect:RectI):Void {
		x = rect.x;
		y = rect.y;
		width = rect.width;
		height = rect.height;
	}
	
	@:extern
	public inline function clone():RectI {
		return new RectI(x, y, width, height);
	}
	
	/**
	 * Get the intersection arena of this rectangle with the input rectangle.
	 */
	@:extern
	public inline function getIntersection(rect:Rect):RectI {
		var x2 = x + width;
		var x4 = rect.x + rect.width;
		var y1 = y - height;
		var y3 = rect.y - rect.height;

		var leftX = Std.int(Math.max(x, rect.x));
		var rightX = Std.int(Math.min(x2, x4));
		
		if (rightX <= leftX) return null;
		else {
			var topY = Std.int(Math.max(y1, y3));
			var bottomY = Std.int(Math.min(y, rect.y));
			
			if (bottomY <= topY) return null;
			else return new RectI(leftX, bottomY, rightX - leftX, bottomY - topY);
		}
	}
	
	@:extern
	public inline function toString():String {
		return "RectI(x: " + x + ", y: " + y + ", w: " + width + ", h: " + height + ")";
	}
	
}