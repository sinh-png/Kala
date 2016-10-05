package kala.behaviors.input;

#if (kala_mouse || kala_touch)
import kala.behaviors.collision.basic.shapes.CollisionCircle;
import kala.behaviors.collision.basic.shapes.CollisionRectangle;
import kala.behaviors.collision.basic.Collider;
import kala.objects.Object;
import kha.FastFloat;

class BasicButtonInteraction extends BaseButtonInteraction {

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
	
	override public function addTo(object:Object):BasicButtonInteraction {
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
	
	public inline function addRectMask(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):CollisionRectangle {
		return collider.addRect(x, y, width, height);
	}
	
	public inline function addObjectRectMask():CollisionRectangle {
		return collider.addObjectRect();
	}
	
	override function test(x:FastFloat, y:FastFloat):Bool {
		return collider.testPoint(x, y);
	}
	
}

#end