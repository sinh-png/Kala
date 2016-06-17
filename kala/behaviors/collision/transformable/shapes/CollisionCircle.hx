package kala.behaviors.collision.transformable.shapes;

import kala.behaviors.collision.transformable.CollisionResult;
import kala.math.Collision;
import kala.math.Vec2;
import kala.util.pool.Pool;
import kha.FastFloat;

class CollisionCircle extends CollisionShape {
	
	public static var pool(default, never) = new Pool<CollisionCircle>(function() return new CollisionCircle());
	
	public static inline function get():CollisionCircle {
		var circle = pool.get();
		circle.reset();
		return circle;
	}
	
	//
	
	public var radius(default, set):FastFloat;
	public var segments(default, set):Int;
	
	private var _verticesUpdated:Bool;
	
	public function new() {
		super();
		isCircle = true;
	}
	
	override public function reset():Void {
		super.reset();
		segments = 0;
	}
	
	override public function put():Void {
		pool.putUnsafe(this);
	}
	
	override public function testCircle(circle:CollisionCircle):CollisionResult {
		var otherStillCircle = circle.hasSymmetricalTransformation();
		
		var otherX = circle.matrix._20;
		var otherY = circle.matrix._21;
		var otherRadius = circle.radius * circle.matrix._00;
		
		var data:CollisionData;
		
		if (hasSymmetricalTransformation()) {
			var x = matrix._20;
			var y = matrix._21;
			var radius = radius * matrix._00;
			
			if (otherStillCircle) {
				data = Collision.circleVsCircle(x, y, radius, otherX, otherY, otherRadius);
				if (data == null) return null;
				return new CollisionResult(this, circle, data);
			}
			
			data = Collision.circleVsPolygon(x, y, radius, circle.getTransformedVertices());
			if (data == null) return null;
			return new CollisionResult(this, circle, data);
		}
		
		if (otherStillCircle) {
			data = Collision.circleVsPolygon(otherX, otherY, otherRadius, getTransformedVertices());
			if (data == null) return null;
			return new CollisionResult(circle, this, data.flip());
		}
		
		var result = Collision.polygonVsPolygon(getTransformedVertices(), circle.getTransformedVertices());
		
		if (result == null) return null;
		
		if (result.b) {
			return new CollisionResult(circle, this, result.a);
		}
		
		return new CollisionResult(this, circle, result.a);
	}
	
	override public function testPolygon(polygon:CollisionPolygon):CollisionResult {
		var polyVertices = polygon.getTransformedVertices();
		
		var data:CollisionData;
		
		if (hasSymmetricalTransformation()) {
			data = Collision.circleVsPolygon(matrix._20, matrix._21, radius * matrix._00, polygon.getTransformedVertices());
			if (data == null) return null;
			return new CollisionResult(this, polygon, data);
		}
		
		var result = Collision.polygonVsPolygon(getTransformedVertices(), polygon.getTransformedVertices());
		
		if (result == null) return null;
		
		if (result.b) {
			return new CollisionResult(polygon, this, result.a);
		}
		
		return new CollisionResult(this, polygon, result.a);
	}
	
	override public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		if (hasSymmetricalTransformation()) {
			return Collision.pointVsCircle(pointX, pointY, matrix._20, matrix._21, radius * matrix._00);
		}
		
		return Collision.pointVsPolygon(pointX, pointY, getTransformedVertices());
	}

	override public function getVertices():Array<Vec2> {
		if (!_verticesUpdated) updateVertices();
		return _vertices;
	}
	
	override public function getTransformedVertices():Array<Vec2> {
		if (!_verticesUpdated) updateVertices();
		return super.getTransformedVertices();
	}
	
	/**
	 * Test this circle with another cirlce using only position & radius,
	 * ignore other transformation and collision data.
	 */
	public inline function testCircleNoTransform(circle:CollisionCircle):Bool {
		return Collision.fastCircleVsCircle(
			matrix.tx, matrix.ty, radius,
			circle.matrix.tx, circle.matrix.ty, circle.radius
		);
	}
	
	public function updateVertices():Void {
		var segments = this.segments;
		if (segments <= 0) {
			segments = Math.floor(10 * Math.sqrt(radius));
		}
		
		if (_vertices.length > segments) _vertices.splice(0, _vertices.length - segments);
		
		var theta = 2 * Math.PI / segments;
		var c = Math.cos(theta);
		var s = Math.sin(theta);
		
		var x = radius;
		var y:FastFloat = 0;
		var t:FastFloat;
		
		var point:Vec2;
		
		for (i in 0...segments) {
			if (i < _vertices.length) {
				point = _vertices[i];
			} else {
				point = new Vec2();
				_vertices.push(point);
			}
			
			point.set(x, y);

			t = x;
			x = c * x - s * y;
			y = c * y + s * t;
		}
			
		_verticesUpdated = true;
	}
	
	public inline function hasSymmetricalTransformation():Bool {
		return matrix._00 == matrix._11 && matrix._10 == 0 && matrix._01 == 0;
	}
	
	function set_radius(value:FastFloat):FastFloat {
		_verticesUpdated = false;
		return radius = value;
	}
	
	function set_segments(value:Null<Int>):Null<Int> {
		_verticesUpdated = false;
		return segments = value;
	}
	
	override function get_width():FastFloat {
		return radius * 2;
	}
	
	override function get_height():FastFloat {
		return radius * 2;
	}
	
}