package kala.components.collision;

import kala.components.collision.CollisionShape;
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
		
		_shapes.push(circle);
		
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
		
		_shapes.push(rect);
		
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
		_shapes.push(polygon);
		
		return [polygon];
	}
	
}

