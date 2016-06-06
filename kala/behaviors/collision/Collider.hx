package kala.behaviors.collision;

import kala.behaviors.collision.CollisionShape;
import kala.math.Vec2;
import kala.objects.Object;
import kha.FastFloat;

class Collider extends BaseCollider<Object> {

	override public function addTo(object:Object):Collider {
		super.addTo(object);
		return this;
	}
	
	public function addCircle(x:FastFloat, y:FastFloat, radius:FastFloat):CollisionCircle {
		var circle = CollisionCircle.get();
		circle.collider = this;
		circle.position.set(x, y);
		circle.radius = radius;
		
		shapes.push(circle);
		
		return circle;
	}
	
	public function addRect(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):CollisionPolygon {
		var rect = CollisionPolygon.get();
		rect.collider = this;
		rect.position.set(x, y);
		rect.vertices = [
			new Vec2(0, 0),
			new Vec2(0, height), 
			new Vec2(width, height),
			new Vec2(width, 0)
		];
		
		shapes.push(rect);
		
		return rect;
	}
	
	// TODO: If concave set to true, break polygon into multiple triangles.
	public function addPolygon(x:FastFloat, y:FastFloat, vertices:Array<Vec2>, concave:Bool = false):Array<CollisionPolygon> {
		if (concave) {
			return null;
		}
		
		var polygon = CollisionPolygon.get();
		polygon.collider = this;
		polygon.position.set(x, y);
		polygon.vertices = vertices.copy();
		shapes.push(polygon);
		
		return [polygon];
	}
	
	public inline function addObjectRect():CollisionPolygon {
		var rect = addRect(0, 0, object.width, object.height);
		rect.position.setOrigin(object.position.ox, object.position.oy);
		return rect;
	}
	
	public inline function addShape(shape:CollisionShape):CollisionShape {
		shapes.push(shape);
		return shape;
	}
	
	/*
	 * Remove shape. This won't put the shape into its pool.
	 */
	public inline function removeShape(shape:CollisionShape):CollisionShape {
		if (shapes.remove(shape)) return shape;
		return null;
	}
	
}

