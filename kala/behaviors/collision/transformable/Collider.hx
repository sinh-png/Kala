package kala.behaviors.collision.transformable;

import kala.behaviors.collision.transformable.shapes.CollisionCircle;
import kala.behaviors.collision.transformable.shapes.CollisionPolygon;
import kala.behaviors.collision.transformable.shapes.CollisionShape;
import kala.math.Vec2;
import kala.objects.Object;
import kha.Canvas;
import kha.FastFloat;

using kha.graphics2.GraphicsExtension;

/**
 * Used for SAT supported collision detection.
 */
class Collider extends BaseCollider<Object> {

	private var _shapes:Array<CollisionShape>;
	
	public function new(object:Object) {
		super(object);
		_shapes = cast shapes;
	}
	
	override public function destroy():Void {
		super.destroy();
		_shapes = null;
	}
	
	override public function drawDebug(color:UInt, ?fill:Bool = false, ?lineStrenght:FastFloat = 1, canvas:Canvas):Bool {
		if (!super.drawDebug(color, fill, lineStrenght, canvas)) return false;
		
		for (shape in _shapes) {
			if (!shape.active) continue;
			
			canvas.g2.transformation = shape.matrix;
			
			if (fill) {
				canvas.g2.fillPolygon(
					0, 0,
					Vec2.toVector2Array(shape.getVertices())
				);
			} else {
				canvas.g2.drawPolygon(
					0, 0,
					Vec2.toVector2Array(shape.getVertices()), 
					lineStrenght
				);
			}
		}
		
		return true;
	}
	
	public function addCircle(x:FastFloat, y:FastFloat, radius:FastFloat):CollisionCircle {
		var circle = CollisionCircle.get();
		circle.position.setXY(x, y);
		circle.radius = radius;
		_shapes.push(circle);
		
		return circle;
	}
	
	public function addRect(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):CollisionPolygon {
		var rect = CollisionPolygon.get();
		rect.position.setXY(x, y);
		rect.vertices = [
			new Vec2(0, 0),
			new Vec2(0, height), 
			new Vec2(width, height),
			new Vec2(width, 0)
		];
		_shapes.push(rect);
		
		return rect;
	}
	
	// TODO: If concave set to true, break polygon into multiple triangles.
	public function addPolygon(x:FastFloat, y:FastFloat, vertices:Array<Vec2>, concave:Bool = false):Array<CollisionPolygon> {
		if (concave) return null;

		var polygon = CollisionPolygon.get();
		polygon.position.setXY(x, y);
		polygon.vertices = vertices.copy();
		_shapes.push(polygon);
		
		return [polygon];
	}
	
	public inline function addObjectRect():CollisionPolygon {
		return addRect(0, 0, object.width, object.height);
	}
	
	public inline function addShape(shape:CollisionShape):CollisionShape {
		_shapes.push(shape);
		return shape;
	}
	
	public inline function removeShape(shape:CollisionShape):Bool {
		return _shapes.remove(shape);
	}
	
	public function test(collider:Collider):CollisionResult {
		if (!available) return null;
		
		var result:CollisionResult;
		
		for (shapeA in _shapes) {
			if (!shapeA.active) continue;
			for (shapeB in collider._shapes) {
				if (!shapeB.active) continue;
				result = shapeA.test(shapeB);
				if (result != null) return result;
			}
		}
		
		return null;
	}
	
}

