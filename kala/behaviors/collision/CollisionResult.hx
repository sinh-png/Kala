package kala.behaviors.collision;

import kala.math.Collision.CollisionData;
import kala.math.Vec2;
import kha.FastFloat;


class CollisionResult {

	public var shape1:CollisionShape;
	public var shape2:CollisionShape;
	public var data:CollisionData;

	public inline function new(shape1:CollisionShape, shape2:CollisionShape, data:CollisionData) {
		this.shape1 = shape1;
		this.shape2 = shape2;
		this.data = data;
	}
	
	@:extern
	public inline function flip():CollisionResult {
		var shape = shape1;
		shape1 = shape2;
		shape2 = shape;
		
		data.flip();
		
		return this;
	}
	
}