package kala.behaviors.input;
import kala.objects.group.View;

#if (kala_mouse || kala_touch)
import kala.behaviors.collision.transformable.shapes.CollisionCircle;
import kala.behaviors.collision.transformable.shapes.CollisionPolygon;
import kala.behaviors.collision.transformable.shapes.CollisionShape;
import kala.behaviors.collision.transformable.Collider;
import kala.EventHandle.CallbackHandle;
import kala.math.Vec2;
import kala.objects.Object;
import kha.FastFloat;


class ButtonInteraction extends Behavior<Object> {

	public var collider:Collider;
	
	public var active:Bool;
	public var hovered(default, null):Bool;
	public var pushed(get, never):Bool;

	/**
	 * The second arg is id of touch or mouse button (1 - left, 2 - middle, 3 - right).
	 */
	public var onPush(default, null):CallbackHandle<ButtonInteraction->Int->Void>;
	/**
	 * The second arg is id of touch or mouse button (1 - left, 2 - middle, 3 - right).
	 */
	public var onRelease(default, null):CallbackHandle<ButtonInteraction->Int->Void>;
	public var onOver(default, null):CallbackHandle<ButtonInteraction->Void>;
	public var onOut(default, null):CallbackHandle<ButtonInteraction->Void>;
	
	public var view:View;
	
	#if js
	public var disableMouseOnMobile:Bool;
	#end
	
	private var _mouseHovered:Bool;
	private var _touched:Bool;
	
	public function new(?object:Object, ?collider:Collider, objectRectScale:FastFloat = 0) {
		super();
		
		this.collider = collider;
		
		onPush = addCBHandle(new CallbackHandle<ButtonInteraction->Int->Void>());
		onRelease = addCBHandle(new CallbackHandle<ButtonInteraction->Int->Void>());
		onOver = addCBHandle(new CallbackHandle<ButtonInteraction->Void>());
		onOut = addCBHandle(new CallbackHandle<ButtonInteraction->Void>());
		
		if (object != null) {
			addTo(object);
			if (objectRectScale > 0) addObjectRectMask();
		}
	}
	
	override public function reset():Void {
		super.reset();
		active = true;
		hovered = _mouseHovered = _touched = false;
		#if js
		disableMouseOnMobile = true;
		#end
		view = null;
		if (collider != null) collider.reset();
	}
	
	override public function destroy():Void {
		super.destroy();
		collider = null;
		view = null;
		onPush = null;
		onRelease = null;
		onOver = null;
		onOut = null;
	}
	
	override public function addTo(object:Object):ButtonInteraction {
		super.addTo(object);
		if (collider == null) collider = new Collider(object);
		else collider.addTo(object);
		object.onPostUpdate.notifyPrivateCB(this, update);
		return this;
	}
	
	override public function remove():Void {
		if (object != null) {
			collider.remove();
			object.onPostUpdate.removePrivateCB(this, update);
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
	
	function update(obj:Object, elapsed:FastFloat):Void {
		if (!active) return;
		
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
	
	#if kala_mouse
	function updateMouse():Void {
		var p:Vec2;
		if (view == null) p = new Vec2(kala.input.Mouse.x, kala.input.Mouse.y);
		else p = view.project(kala.input.Mouse.x, kala.input.Mouse.y);
		
		if (collider.testPoint(p.x, p.y)) {
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
		
		var p:Vec2;
	
		for (touch in kala.input.Touch.touches) {
			if (view == null) p = new Vec2(touch.x, touch.y);
			else p = view.project(touch.x, touch.y);
			
			if (collider.testPoint(p.x, p.y)) {
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
	
	function get_pushed():Bool {
		return _touched || _mouseHovered;
	}
	
}

#end