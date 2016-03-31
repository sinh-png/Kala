package kala.math.shapes;

import kala.math.Vec2;
import kha.math.FastMatrix3;

class Triangle {
	
	public var p1:Vec2;
	public var p2:Vec2;
	public var p3:Vec2;

	public inline function new(p1:Vec2, p2:Vec2, p3:Vec2) {
		this.p1 = p1;
		this.p2 = p2;
		this.p3 = p3;
	}
	
	@:extern
	public inline function transform(matrix:FastMatrix3):Triangle {
		return new Triangle(p1.transform(matrix), p2.transform(matrix), p3.transform(matrix));
	}
	
	@:extern
	public inline function transformBy(matrix:FastMatrix3):Triangle {
		p1.transformBy(matrix);
		p2.transformBy(matrix);
		p3.transformBy(matrix);
		
		return this;
	}
	
}