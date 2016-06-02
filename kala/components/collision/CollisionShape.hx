package kala.components.collision;

import kala.components.collision.BaseCollider.ICollider;
import kala.components.collision.CollisionResult;
import kala.components.collision.CollisionShape.CollisionCircle;
import kala.components.collision.CollisionShape.CollisionPolygon;
import kala.math.Collision;
import kala.math.Rotation;
import kala.math.Vec2;
import kala.math.Vec2T;
import kala.math.helpers.FastMatrix3Helper;
import kala.util.pool.Pool;
import kala.util.types.Trio;
import kha.FastFloat;
import kha.math.FastMatrix3;

@:allow(kala.components.Component)
class CollisionShape {
	
	// To avoid using Std.is
	public var isCircle(default, null):Bool;
	
	public var collider(default, null):Collider;

	public var position:Vec2T = new Vec2T();
	
	public var scale:Vec2T = new Vec2T();
	public var skew:Vec2T = new Vec2T();
	public var rotation:Rotation = new Rotation();
	
	public var flipX:Bool;
	public var flipY:Bool;

	public var matrix(default, null):FastMatrix3;
	
	public var width(get, never):FastFloat;
	public var height(get, never):FastFloat;
	
	private var _vertices:Array<Vec2> = new Array<Vec2>();

	public function new() {
		reset();
	}
	
	public function reset():Void {
		position.set();
		
		scale.set(1, 1, 0, 0);
		skew.set(0, 0, 0, 0);
		rotation.set(0, 0, 0);
		
		flipX = flipY = false;
	}
	
	public function destroy():Void {
		position = null;
		
		scale = null;
		skew = null;
		rotation = null;
		
		_vertices = null;
		
		matrix = null;
	}
	
	public function put():Void {
		
	}
	
	public inline function getMatrix():FastMatrix3 {
		var matrix = FastMatrix3Helper.getTransformation(position, scale, skew, rotation);
		
		if (flipX || flipY) {
			return FastMatrix3Helper.flip(
				matrix, flipX, flipY,
				position.x - position.ox + width / 2, position.y - position.oy + height / 2
			);
		}
		
		return matrix;
	}
	
	public function updateMatrix():CollisionShape {
		matrix = collider._matrix.multmat(getMatrix());
		return this;
	}
	
	public function getVertices():Array<Vec2> {
		return _vertices.copy();
	}
	
	public function getTransformedVertices():Array<Vec2> {
		var transformedVertices = new Array<Vec2>();
		
		for (vert in _vertices) {
			transformedVertices.push(vert.transform(matrix));
		}

		return transformedVertices;
	}
	
	public function test(shape:CollisionShape):CollisionResult {
		if (shape.isCircle) return testCircle(cast shape);
		return testPolygon(cast shape);
	}
	
	public function testCircle(circle:CollisionCircle):CollisionResult {
		return null;
	}
	
	public function testPolygon(polygon:CollisionPolygon):CollisionResult {
		return null;
	}
	
	public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		return false;
	}
	
	function get_width():FastFloat {
		return 0;
	}
	
	function get_height():FastFloat {
		return 0;
	}
	
}

class CollisionCircle extends CollisionShape {
	
	public static var pool(default, never) = new Pool<CollisionCircle>(create);
	
	public static inline function get():CollisionCircle {
		var circle = pool.get();
		circle.reset();
		return circle;
	}
	
	static function create():CollisionCircle {
		return new CollisionCircle();
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
		updateMatrix();
		circle.updateMatrix();
		
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
		updateMatrix();
		var polyVertices = polygon.updateMatrix().getTransformedVertices();
		
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
		updateMatrix();
		
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
	 * Test this circle with another cirlce using only position & radius data,
	 * ignore other transformations and collision data.
	 */
	public function testCircleNoTransform(circle:CollisionCircle):Bool {
		updateMatrix();
		circle.updateMatrix();
		return Collision.fastCircleVsCircle(
			matrix._20, matrix._21, radius,
			circle.matrix._20, circle.matrix._21, circle.radius
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

class CollisionPolygon extends CollisionShape {
	
	public static var pool(default, never) = new Pool<CollisionPolygon>(create);
	
	var _width:FastFloat;
	var _height:FastFloat;
	
	public static inline function get():CollisionPolygon {
		var polygon = pool.get();
		polygon.reset();
		return polygon;
	}
	
	static function create():CollisionPolygon {
		return new CollisionPolygon()	;
	}
	
	//
	
	public var vertices(get, set):Array<Vec2>;
	
	public function new() {
		super();
		isCircle = false;
	}
	
	override public function put():Void {
		pool.putUnsafe(this);
	}

	override public function testCircle(circle:CollisionCircle):CollisionResult {
		var result = circle.testPolygon(this);
		if (result == null) return null;
		return result.flip();
	}
	
	override public function testPolygon(polygon:CollisionPolygon):CollisionResult {
		var result = Collision.polygonVsPolygon(
			updateMatrix().getTransformedVertices(), polygon.updateMatrix().getTransformedVertices()
		);
		
		if (result == null) return null;
		
		if (result.b) {
			return new CollisionResult(polygon, this, result.a);
		}
		
		return new CollisionResult(this, polygon, result.a);
	}
	
	override public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		return Collision.pointVsPolygon(pointX, pointY, updateMatrix().getTransformedVertices());
	}
	
	function get_vertices():Array<Vec2> {
		return _vertices;
	}
	
	function set_vertices(value:Array<Vec2>):Array<Vec2> {
		_vertices = value;
		
		var minX:FastFloat = 0;
		var maxX:FastFloat = 0;
		var minY:FastFloat = 0;
		var maxY:FastFloat = 0;
		
		for (v in _vertices) {
			if (v.x < minX) minX = v.x;
			else if (v.x > maxX) maxX = v.x;
			
			if (v.y < minY) minY = v.y;
			else if (v.y > maxY) maxY = v.y;
		}
		
		_width = Math.abs(maxX - minX);
		_height = Math.abs(maxY - minY);
		
		return _vertices;
	}
	
	override function get_width():FastFloat {
		return _width;
	}
	
	override function get_height():FastFloat {
		return _height;
	}
	
}