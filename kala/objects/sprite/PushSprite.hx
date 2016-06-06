package kala.objects.sprite;

#if (kala_mouse || kala_touch)

import kala.behaviors.collision.Collider;
import kala.behaviors.collision.CollisionShape;
import kala.EventHandle.CallbackHandle;
import kala.math.Vec2;
import kha.FastFloat;
import kha.Image;

/**
 * Sprite with basic touch and / or mouse interaction using Collider behavior. 
 * Good for making basic button.
 */
class PushSprite extends Sprite {

	public var collider(default, null):Collider;
	
	public var hovered(default, null):Bool;

	/**
	 * The second arg is id of touch or mouse button (1 - left, 2 - middle, 3 - right).
	 */
	public var onPush(default, null):CallbackHandle<PushSprite->Int->Void>;
	/**
	 * The second arg is id of touch or mouse button (1 - left, 2 - middle, 3 - right).
	 */
	public var onRelease(default, null):CallbackHandle<PushSprite->Int->Void>;
	public var onOver(default, null):CallbackHandle<PushSprite->Void>;
	public var onOut(default, null):CallbackHandle<PushSprite->Void>;
	
	#if js
	public var disableMouseOnMobile:Bool;
	#end
	
	private var _mouseHovered:Bool;
	private var _touched:Bool;
	
	public function new(
		?image:Image, 
		?frameX:Int, ?frameY:Int, 
		?frameWidth:Int, ?frameHeight:Int,
		animated:Bool = false
	) {
		super(image, frameX, frameY, frameWidth, frameHeight, animated);
		
		this.collider = new Collider(this);
		
		onPush = addCBHandle(new CallbackHandle<PushSprite->Int->Void>());
		onRelease = addCBHandle(new CallbackHandle<PushSprite->Int->Void>());
		onOver = addCBHandle(new CallbackHandle<PushSprite->Void>());
		onOut = addCBHandle(new CallbackHandle<PushSprite->Void>());
	}
	
	override public function reset(resetBehaviors:Bool = false):Void {
		super.reset(resetBehaviors);
		
		hovered = _mouseHovered = _touched = false;
		
		#if js
		disableMouseOnMobile = true;
		#end
	}
	
	override public function destroy(destroyBehaviors:Bool = true):Void {
		super.destroy(destroyBehaviors);
		
		collider = null;
		
		onPush = null;
		onRelease = null;
		onOver = null;
		onOut = null;
	}
	
	override public function update(elapsed:FastFloat):Void {
		#if kala_mouse
			#if js
			if (!disableMouseOnMobile || !Kala.html5.mobile) updateMouse();
			#else
			updateMouse();
			#end
		#end
		
		#if kala_touch
		updateTouch();
		#end
		
		if (hovered && !_touched && !_mouseHovered) {
			hovered = false;
			for (callback in onOut) callback.cbFunction(this);
		}
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
	
	#if kala_mouse
	function updateMouse():Void {
		if (collider.testPoint(kala.input.Mouse.x, kala.input.Mouse.y)) {
			if (!hovered) {
				hovered = true;
				for (callback in onOver) callback.cbFunction(this);
			}
			
			if (kala.input.Mouse.LEFT.justPressed) {
				for (callback in onPush) callback.cbFunction(this, 1);
			} else if (kala.input.Mouse.LEFT.justReleased) {
				for (callback in onRelease) callback.cbFunction(this, 1);
			}
			
			if (kala.input.Mouse.MIDDLE.justPressed) {
				for (callback in onPush) callback.cbFunction(this, 2);
			} else if (kala.input.Mouse.MIDDLE.justReleased) {
				for (callback in onRelease) callback.cbFunction(this, 2);
			}
			
			if (kala.input.Mouse.RIGHT.justPressed) {
				for (callback in onPush) callback.cbFunction(this, 3);
			} else if (kala.input.Mouse.RIGHT.justReleased) {
				for (callback in onRelease) callback.cbFunction(this, 3);
			}
			
			_mouseHovered = true;
		} else {
			_mouseHovered = false;
		}
	}
	#end
	
	#if kala_touch
	function updateTouch():Void {
		_touched = false;
		
		for (touch in kala.input.Touch.touches) {
			if (collider.testPoint(touch.x, touch.y)) {
				if (!hovered) {
					hovered = true;
					for (callback in onOver) callback.cbFunction(this);
				}
				
				if (touch.justStarted) {
					for (callback in onPush) callback.cbFunction(this, touch.id);
				} else if (touch.justEnded) {
					for (callback in onRelease) callback.cbFunction(this, touch.id);
				}
				
				_touched = true;
			}
		}
	}
	#end
	
}

#end