package kala.behaviors.collision.shapes;

import kala.math.Collision;
import kala.math.Vec2;
import kala.util.pool.Pool;
import kha.FastFloat;

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
			getTransformedVertices(), polygon.getTransformedVertices()
		);
		
		if (result == null) return null;
		
		if (result.b) {
			return new CollisionResult(polygon, this, result.a);
		}
		
		return new CollisionResult(this, polygon, result.a);
	}
	
	override public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		return Collision.pointVsPolygon(pointX, pointY, getTransformedVertices());
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