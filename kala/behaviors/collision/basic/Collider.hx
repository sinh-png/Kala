package kala.behaviors.collision.basic;

import kala.behaviors.collision.BaseCollider;
import kala.behaviors.collision.basic.shapes.CollisionCircle;
import kala.behaviors.collision.basic.shapes.CollisionRectangle;
import kala.behaviors.collision.basic.shapes.CollisionShape;
import kala.behaviors.collision.basic.shapes.ShapeType;
import kala.math.Matrix;
import kala.objects.Object;
import kha.Canvas;
import kha.FastFloat;

/**
 * Used for lightweight collision detection between shapes.
 * Does not support transformation & collision result data.
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
		for (shape in _shapes) if (shape.active) shape.drawDebug(fill, lineStrenght, canvas);
		return true;
	}
	
	public inline function removeShape(shape:CollisionShape):Bool {
		return _shapes.remove(shape);
	}
	
	public inline function addShape(shape:CollisionShape):CollisionShape {
		_shapes.push(shape);
		return shape;
	}
	
	public inline function addCircle(x:FastFloat, y:FastFloat, radius:FastFloat):CollisionCircle {
		var circle = CollisionCircle.get();
		circle.position.setXY(x, y);
		circle.radius = radius;
		_shapes.push(circle);
		return circle;
	}
	
	public inline function addRect(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):CollisionRectangle {
		var rect = CollisionRectangle.get();
		rect.position.setXY(x, y);
		rect.setSize(width, height);
		_shapes.push(rect);
		return rect;
	}
	
	public inline function addObjectRect(scaleX:FastFloat = 1, scaleY:FastFloat = 1):CollisionRectangle {
		var rect = addRect(0, 0, object.width * scaleX, object.height * scaleY);
		rect.position.setXY((object.width - rect.width) / 2, (object.height - rect.height) / 2);
		return rect;
	}
	
	public function test(collider:Collider):Bool {
		if (!available) return false;
		
		for (shapeA in _shapes) {
			if (!shapeA.active) continue;
			for (shapeB in collider._shapes) {
				if (shapeB.active && shapeA.test(shapeB)) return true;
			}
		}
		
		return false;
	}
	
}