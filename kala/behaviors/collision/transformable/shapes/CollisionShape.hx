package kala.behaviors.collision.transformable.shapes;

import kala.behaviors.collision.BaseCollisionShape;
import kala.math.Matrix;
import kala.math.Position;
import kala.math.Rotation;
import kala.math.Vec2;
import kala.math.Vec2T;
import kala.objects.Object;
import kha.FastFloat;

@:access(kala.objects.Object)
@:allow(kala.behaviors.Behavior)
class CollisionShape extends BaseCollisionShape {
	
	// To avoid using Std.is
	public var isCircle(default, null):Bool;
	
	public var scale:Vec2T = new Vec2T();
	public var rotation:Rotation = new Rotation();
	
	public var matrix(default, null):Matrix;
	
	public var width(get, never):FastFloat;
	public var height(get, never):FastFloat;
	
	private var _vertices:Array<Vec2> = new Array<Vec2>();

	public function new() {
		super();
		reset();
	}
	
	override public function reset():Void {
		super.reset();
		scale.set(1, 1, 0, 0);
		rotation.set(0, 0, 0);
		matrix = null;
	}
	
	override public function destroy():Void {
		super.destroy();
		
		scale = null;
		rotation = null;
		
		_vertices = null;
		
		matrix = null;
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
	
	override public function update(object:Object):Void {
		matrix = object._cachedDrawingMatrix.multmat(
			Matrix.getTransformation(
				new Position(
					position.x + object.position.ox, position.y + object.position.oy,
					position.ox, position.oy
				),
				scale, rotation
			)
		);
	}
	
	function get_width():FastFloat {
		return 0;
	}
	
	function get_height():FastFloat {
		return 0;
	}
	
	override function get_available():Bool {
		return matrix != null;
	}
	
}