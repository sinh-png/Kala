package kala.behaviors.input;

#if (kala_mouse || kala_touch)
import kala.behaviors.collision.transformable.shapes.CollisionCircle;
import kala.behaviors.collision.transformable.shapes.CollisionPolygon;
import kala.behaviors.collision.transformable.shapes.CollisionShape;
import kala.behaviors.collision.transformable.Collider;
import kala.math.Vec2;
import kala.objects.Object;
import kha.FastFloat;

class ButtonInteraction extends BaseButtonInteraction {

	public var collider:Collider;
	
	public function new(?object:Object, ?collider:Collider, objectRectScale:FastFloat = 0) {
		super(null, objectRectScale);
		
		this.collider = collider;
		
		if (object != null) {
			addTo(object);
			if (objectRectScale > 0) addObjectRectMask();
		}
	}
	
	override public function reset():Void {
		super.reset();
		if (collider != null) collider.reset();
	}
	
	override public function destroy():Void {
		super.destroy();
		collider = null;
	}
	
	override public function addTo(object:Object):ButtonInteraction {
		super.addTo(object);
		if (collider == null) collider = new Collider(object);
		else collider.addTo(object);
		return this;
	}
	
	override public function remove():Void {
		if (object != null) {
			collider.remove();
		}
		
		super.remove();
	}
	
	public inline function addCircleMask(x:FastFloat, y:FastFloat, radius:FastFloat):CollisionCircle {
		return collider.addCircle(x, y, radius);
	}
	
	public inline function addRectMask(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):CollisionPolygon {
		return collider.addRect(x, y, width, height);
	}
	
	public inline function addPolygonMask(x:FastFloat, y:FastFloat, vertices:Array<Vec2>, concave:Bool = false):Array<CollisionPolygon> {
		return collider.addPolygon(x, y, vertices, concave);
	}
	
	public inline function addObjectRectMask():CollisionPolygon {
		return collider.addObjectRect();
	}
	
	public inline function addShapeMask(shape:CollisionShape):CollisionShape {
		return collider.addShape(shape);
	}
	
	override function test(x:FastFloat, y:FastFloat):Bool {
		return collider.testPoint(x, y);
	}
	
}

#end