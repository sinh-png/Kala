package kala.math;

import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.math.Matrix3;

@:forward
abstract Matrix(FastMatrix3) from FastMatrix3 to FastMatrix3 {
	
	@:extern @:from
	public static inline function fromMatrix3(matrix:Matrix3):Matrix {
		return new FastMatrix3(
			matrix._00, matrix._10, matrix._20,
			matrix._01, matrix._11, matrix._21,
			matrix._02, matrix._12, matrix._22
		);
	}
	
	@:extern
	public static inline function getTransformation(
		position:Vec2T, scale:Vec2T, skew:Vec2T, rotation:Rotation
	):Matrix {
			var x = position.x - position.ox;
			var y = position.y - position.oy;
			
			// Positing
			var matrix = Matrix.translation(x, y);
			
			// Scaling
			var ox = x + scale.ox;
			var oy = y + scale.oy;
			
			matrix = Matrix.translation(ox, oy)
					.multmat(Matrix.scale(scale.x, scale.y))
					.multmat(Matrix.translation( -ox, -oy))
					.multmat(matrix);
					
			// Skewing
			ox = x + skew.ox;
			oy = y + skew.oy;
			
			matrix = Matrix.translation(ox, oy)
					.multmat(new Matrix(1, Math.tan(skew.x * Angle.CONST_RAD), 0, Math.tan(skew.y * Angle.CONST_RAD), 1, 0))
					.multmat(Matrix.translation( -ox, -oy))
					.multmat(matrix);
			
			// Rotating
			ox = x + rotation.px;
			oy = y + rotation.py;
			
			matrix = Matrix.translation(ox, oy)
					.multmat(Matrix.rotation(rotation.rad))
					.multmat(Matrix.translation( -ox, -oy))
					.multmat(matrix);
				
			return matrix;
	}
	
	@:extern
	public static inline function flip(
		matrix:FastMatrix3, flipX:Bool, flipY:Bool, ox:FastFloat, oy:FastFloat
	):Matrix {
		return Matrix.translation(ox, oy)
				.multmat(Matrix.scale(flipX ? -1 : 1, flipY ? -1 : 1))
				.multmat(Matrix.translation( -ox, -oy))
				.multmat(matrix);
	}
	
	
	@:extern 
	public static inline function translation(x:FastFloat, y:FastFloat):Matrix {
		return new Matrix(
			1, 0, x,
			0, 1, y
		);
	}

	@:extern 
	public static inline function identity():Matrix {
		return new Matrix(
			1, 0, 0,
			0, 1, 0
		);
	}

	@:extern 
	public static inline function scale(x:FastFloat, y:FastFloat):Matrix {
		return new Matrix(
			x, 0, 0,
			0, y, 0
		);
	}

	@:extern 
	public static inline function rotation(alpha:FastFloat):Matrix {
		return new Matrix(
			Math.cos(alpha), -Math.sin(alpha), 0,
			Math.sin(alpha), Math.cos(alpha), 0
		);
	}
	
	//
	
	public var a(get, set):FastFloat;
    public var b(get, set):FastFloat;
    public var c(get, set):FastFloat;
    public var d(get, set):FastFloat;
    public var tx(get, set):FastFloat;
    public var ty(get, set):FastFloat;
	
	public inline function new(a:Float = 1, c:Float = 0, tx:Float = 0, b:Float = 0, d:Float = 1, ty:Float = 0) {
		this = new FastMatrix3(a, c, tx, b, d, ty, 0, 0, 1);
	}
	
	@:extern @:to
	public inline function toMatrix3():Matrix3 {
		return new Matrix3(
			this._00, this._10, this._20,
			this._01, this._11, this._21,
			this._02, this._12, this._22
		);
	}
	
	@:extern
	public inline function clone():Matrix {
		return new FastMatrix3(
			this._00, this._10, this._20,
			this._01, this._11, this._21,
			this._02, this._12, this._22
		);
	}
	
	@:extern
	public inline function compare(matrix:Matrix):Bool {
		return !(
			this._00 != matrix._00 || this._10 != matrix._10 || this._20 != matrix._20 ||
			this._01 != matrix._01 || this._11 != matrix._11 || this._21 != matrix._21 ||
			this._02 != matrix._02 || this._12 != matrix._12 || this._22 != matrix._22
		);
	}
	
	@:extern
	inline function get_a():FastFloat {
		return this._00;
	}
	
	@:extern
	inline function set_a(value:FastFloat):FastFloat {
		return this._00 = value;
	}
	
	@:extern
	inline function get_b():FastFloat {
		return this._01;
	}
	
	@:extern
	inline function set_b(value:FastFloat):FastFloat {
		return this._01 = value;
	}
	
	@:extern
	inline function get_c():FastFloat {
		return this._10;
	}
	
	@:extern
	inline function set_c(value:FastFloat):FastFloat {
		return this._10 = value;
	}
	
	@:extern
	inline function get_d():FastFloat {
		return this._11;
	}
	
	@:extern
	inline function set_d(value:FastFloat):FastFloat {
		return this._11 = value;
	}
	
	@:extern
	inline function get_tx():FastFloat {
		return this._20;
	}
	
	@:extern
	inline function set_tx(value:FastFloat):FastFloat {
		return this._20 = value;
	}
	
	@:extern
	inline function get_ty():FastFloat {
		return this._21;
	}
	
	@:extern
	inline function set_ty(value:FastFloat):FastFloat {
		return this._21 = value;
	}
	
}