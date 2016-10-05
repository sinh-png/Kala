package kala.objects.sprite;

#if (kala_mouse || kala_touch)
import kala.behaviors.collision.basic.shapes.CollisionCircle;
import kala.behaviors.collision.basic.shapes.CollisionRectangle;
import kala.behaviors.collision.basic.Collider;
import kha.FastFloat;
import kha.Image;

class BasicButtonSprite extends BaseButtonSprite {

	public var collider(default, null):Collider;
	
	public function new(
		?image:Image, 
		?frameX:Int, ?frameY:Int, 
		?frameWidth:Int, ?frameHeight:Int,
		animated:Bool = false
	) {
		super(image, frameX, frameY, frameWidth, frameHeight, animated);
		collider = new Collider(this);
	}
	
	override public function reset(resetBehaviors:Bool = false):Void {
		super.reset(resetBehaviors);
		if (collider != null) collider.reset();
	}
	
	override public function destroy(destroyBehaviors:Bool = true):Void {
		super.destroy(destroyBehaviors);
		collider = null;
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