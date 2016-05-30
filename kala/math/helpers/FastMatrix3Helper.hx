package kala.math.helpers;

import kala.math.Rotation;
import kala.math.Vec2T;
import kha.FastFloat;
import kha.math.FastMatrix3;

class FastMatrix3Helper {

	@:extern
	public static inline function clone(matrix:FastMatrix3):FastMatrix3 {
		return new FastMatrix3(
			matrix._00, matrix._10, matrix._20,
			matrix._01, matrix._11, matrix._21,
			matrix._02, matrix._12, matrix._22
		);
	}
	
	@:extern
	public static inline function compare(a:FastMatrix3, b:FastMatrix3):Bool {
		return !(
			a._00 != b._00 || a._10 != b._10 || a._20 != b._20 ||
			a._01 != b._01 || a._11 != b._11 || a._21 != b._21 ||
			a._02 != b._02 || a._12 != b._12 || a._22 != b._22
		);
	}
	
	//
	
	@:extern
	public static inline function getTransformation(
		position:Vec2T, scale:Vec2T, skew:Vec2T, rotation:Rotation
	):FastMatrix3 {
			var x = position.x - position.ox;
			var y = position.y - position.oy;
			
			// Positing
			var matrix = FastMatrix3.translation(x, y);
			
			// Scaling
			var ox = x + scale.ox;
			var oy = y + scale.oy;
			
			matrix = FastMatrix3.translation(ox, oy)
					.multmat(FastMatrix3.scale(scale.x, scale.y))
					.multmat(FastMatrix3.translation( -ox, -oy))
					.multmat(matrix);
					
			// Skewing
			ox = x + skew.ox;
			oy = y + skew.oy;
			
			matrix = FastMatrix3.translation(ox, oy)
					.multmat(new FastMatrix3(1, Math.tan(skew.x * Angle.CONST_RAD), 0, Math.tan(skew.y * Angle.CONST_RAD), 1, 0, 0, 0, 1))
					.multmat(FastMatrix3.translation( -ox, -oy))
					.multmat(matrix);
			
			// Rotating
			ox = x + rotation.px;
			oy = y + rotation.py;
			
			matrix = FastMatrix3.translation(ox, oy)
					.multmat(FastMatrix3.rotation(rotation.rad))
					.multmat(FastMatrix3.translation( -ox, -oy))
					.multmat(matrix);
				
			return matrix;
	}
	
	public static inline function flip(
		matrix:FastMatrix3, flipX:Bool, flipY:Bool, ox:FastFloat, oy:FastFloat
	):FastMatrix3 {
		return FastMatrix3.translation(ox, oy)
				.multmat(FastMatrix3.scale(flipX ? -1 : 1, flipY ? -1 : 1))
				.multmat(FastMatrix3.translation( -ox, -oy))
				.multmat(matrix);
	}

}