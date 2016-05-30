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
		return int(0, 100) < 50;
	}
	
	/**
	 *	Randomly return 1 or -1 based on the input chance.
	 */
	public static inline function roll(chance:Float = 50):Int {
		if (int(0, 1) == 0) return -1;
		return 1;
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