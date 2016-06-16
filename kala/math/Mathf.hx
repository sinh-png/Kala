package kala.math;

import kha.FastFloat;

class Mathf {

	/**
	 * 	Degrees to radians conversion constant.
	 */
	public static var CONST_RAD(default, never):FastFloat = Math.PI / 180;
	/**
	 * 	Radians to degrees conversion constant.
	 */
	public static var CONST_DEG(default, never):FastFloat = 180 / Math.PI;
	
	//
	
	/**
	 * Converts radians to degrees.
	 */
	@:extern
	public static inline function rad(deg:FastFloat):FastFloat {
		return deg * CONST_RAD;
	}
	
	/**
	 * Converts degrees to radians.
	 */
	@:extern
	public static inline function deg(rad:FastFloat):FastFloat {
		return rad * CONST_DEG;
	}
	
	/**
	 * Wraps a value between -180 and 180 if the 'positive' parameter set to false
	 * otherwise wrap between 0 and 360.
	 */
	@:extern
	public static inline function wrapDeg(angle:FastFloat, positive:Bool = false):FastFloat {
		angle %= 360;
		if (positive) return (angle + 360) % 360;
		return angle;
	}
		
	/**
	 * Gets angle between two points.
	 */
	@:extern
	public static inline function angle(
		x1:FastFloat, y1:FastFloat,
		x2:FastFloat, y2:FastFloat,
		asDeg:Bool = true
	):FastFloat {
		return Math.atan2(y2 - y1, x2 - x1) * (asDeg ? Mathf.CONST_DEG : 1);
	}
	
	/**
	 * Gets distance between two points.
	 */
	@:extern
	public static inline function distance(
		x1:FastFloat, y1:FastFloat,
		x2:FastFloat, y2:FastFloat
	):FastFloat {
		return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
	}
	
	/**
	 * Clamps a value between a minimum and a maximum value.
	 */
	@:extern
	public static inline function clamp(value:FastFloat, min:FastFloat, max:FastFloat):FastFloat {
		return Math.max(min, Math.min(max, value));
	}
	
}