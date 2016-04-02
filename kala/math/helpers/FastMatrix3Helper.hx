package kala.math.helpers;

import kala.math.Rotation;
import kala.math.Vec2T;
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
	public static inline function getTransformMatrix(
		position:Vec2T, 
		scale:Vec2T, skew:Vec2T, rotation:Rotation,
		flipX:Bool, flipY:Bool
	):FastMatrix3 {
			var x = position.x - position.ox;
			var y = position.y - position.oy;
			
			// Positing
			var matrix = FastMatrix3.translation(x, y);
			
			// Scaling
			var centerX = x + scale.ox;
			var centerY = y + scale.oy;
			
			matrix = FastMatrix3.translation(centerX, centerY)
					.multmat(FastMatrix3.scale(scale.x * (flipX ? -1 : 1), scale.y * (flipY ? -1 : 1)))
					.multmat(FastMatrix3.translation( -centerX, -centerY))
					.multmat(matrix);
					
			// Skewing
			centerX = x + skew.ox;
			centerY = y + skew.oy;
			
			matrix = FastMatrix3.translation(centerX, centerY)
					.multmat(new FastMatrix3(1, Math.tan(skew.x * Angle.CONST_RAD), 0, Math.tan(skew.y * Angle.CONST_RAD), 1, 0, 0, 0, 1))
					.multmat(FastMatrix3.translation( -centerX, -centerY))
					.multmat(matrix);
			
			// Rotating
			centerX = x + rotation.px;
			centerY = y + rotation.py;
			
			matrix = FastMatrix3.translation(centerX, centerY)
					.multmat(FastMatrix3.rotation(rotation.rad()))
					.multmat(FastMatrix3.translation( -centerX, -centerY))
					.multmat(matrix);
			
			return matrix;
	}

}