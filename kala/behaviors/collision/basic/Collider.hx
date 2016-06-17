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
	
	override public function drawDebug(color:UInt, ?fill:Bool = false, ?lineStrenght:FastFloat = 1, canvas:Canvas):Void {
		super.drawDebug(color, fill, lineStrenght, canvas);
		for (shape in _shapes) if (shape.active) shape.drawDebug(fill, lineStrenght, canvas);
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
	
	public inline function addObjectRect():CollisionRectangle {
		var rect = addRect(0, 0, object.width, object.height);
		rect.position.setOrigin(object.position.ox, object.position.oy);
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