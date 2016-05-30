package kala.math;

import kha.FastFloat;

abstract Random(kha.math.Random) from kha.math.Random to kha.math.Random {

	public static var instance(default, never):Random = new Random(6172039);
	
	public static inline function int(min:Int, max:Int):Int {
		return instance.getInt(min, max);
	}
	
	public static inline function float(min:Float, max:Float):Float {
		return instance.getFloat(min, max);
	}
	
	public static inline function fast(min:FastFloat, max:FastFloat):FastFloat {
		return instance.getFast(min, max);
	}
	
	public static inline function bool(chance:Float = 50):Bool {
		return float(0, 100) < 50;
	}
	
	//
	

	public inline function new(seed:Int) {
		this = new kha.math.Random(seed);
	}
	
	public inline function getInt(min:Int, max:Int):Int {
		return this.GetIn(min, max);
	}
	
	public inline function getFloat(min:Float, max:Float):Float {
		return this.GetFloatIn(min, max);
	}
	
	public inline function getFast(min:FastFloat, max:FastFloat):FastFloat {
		return this.GetFloatIn(min, max);
	}
	
}