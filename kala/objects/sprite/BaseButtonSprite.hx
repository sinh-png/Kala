package kala.objects.sprite;

#if (kala_mouse || kala_touch)
import kala.EventHandle.CallbackHandle;
import kala.math.Vec2;
import kala.objects.group.View;
import kha.FastFloat;
import kha.Image;

class BaseButtonSprite extends Sprite {

	public var hovered(default, null):Bool;
	public var pushed(get, never):Bool;
	
	/**
	 * The second arg is id of touch or mouse button (1 - left, 2 - middle, 3 - right).
	 */
	public var onPush(default, null):CallbackHandle<BaseButtonSprite->Int->Void>;
	/**
	 * The second arg is id of touch or mouse button (1 - left, 2 - middle, 3 - right).
	 */
	public var onRelease(default, null):CallbackHandle<BaseButtonSprite->Int->Void>;
	public var onOver(default, null):CallbackHandle<BaseButtonSprite->Void>;
	public var onOut(default, null):CallbackHandle<BaseButtonSprite->Void>;
	
	public var onPushRequestFullscreen:Bool;
	public var onReleaseRequestFullscreen:Bool;
	public var onPushOpenURL:String;
	public var onReleaseOpenURL:String;
	
	public var view:View;
	
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
		
		onPush = addCBHandle(new CallbackHandle<BaseButtonSprite->Int->Void>());
		onRelease = addCBHandle(new CallbackHandle<BaseButtonSprite->Int->Void>());
		onOver = addCBHandle(new CallbackHandle<BaseButtonSprite->Void>());
		onOut = addCBHandle(new CallbackHandle<BaseButtonSprite->Void>());
	}
	
	override public function reset(resetBehaviors:Bool = false):Void {
		super.reset(resetBehaviors);
		hovered = _mouseHovered = _touched = false;
		#if js
		disableMouseOnMobile = true;
		#end
		view = null;
		onPushRequestFullscreen = onReleaseRequestFullscreen = false;
		onPushOpenURL = onReleaseOpenURL = null;
	}
	
	override public function destroy(destroyBehaviors:Bool = true):Void {
		super.destroy(destroyBehaviors);
		view = null;
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
			callOnOut();
		}
	}
	
	function test(x:FastFloat, y:FastFloat):Bool {
		return false;
	}
	
	#if kala_mouse
	function updateMouse():Void {
		var p:Vec2;
		if (view == null) p = new Vec2(kala.input.Mouse.x, kala.input.Mouse.y);
		else p = view.project(kala.input.Mouse.x, kala.input.Mouse.y);
		
		if (test(p.x, p.y)) {
			if (!hovered) {
				callOnOver();
			}
			
			if (kala.input.Mouse.LEFT.justPressed) {
				callOnPush(1);
			} else if (kala.input.Mouse.LEFT.justReleased) {
				callOnRelease(1);
			}
			
			if (kala.input.Mouse.MIDDLE.justPressed) {
				callOnPush(2);
			} else if (kala.input.Mouse.MIDDLE.justReleased) {
				callOnRelease(2);
			}
			
			if (kala.input.Mouse.RIGHT.justPressed) {
				callOnPush(3);
			} else if (kala.input.Mouse.RIGHT.justReleased) {
				callOnRelease(3);
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
			
			if (test(p.x, p.y)) {
				if (!hovered) {
					callOnOver();
				}
				
				if (touch.justStarted) {
					callOnPush(touch.id);
				} else if (touch.justEnded) {
					callOnRelease(touch.id);
				}
				
				_touched = true;
			}
		}
	}
	#end
	
	inline function callOnOver():Void {
		#if (flash || js)
		if (onPushOpenURL != null) {
			#if js
			Kala.html5.canvas.addEventListener('click', openURLOnPush);
			#elseif flash
			#end
		}
		
		if (onReleaseOpenURL != null) {
			#if js
			Kala.html5.canvas.addEventListener('mouseup', openURLOnRelease);
			#elseif flash
			#end
		}
		
		if (onPushRequestFullscreen) {
			#if js
			Kala.html5.canvas.addEventListener('click', requestFullscreen);
			#elseif flash
			#end
		}
		
		if (onReleaseRequestFullscreen) {
			#if js
			Kala.html5.canvas.addEventListener('mouseup', requestFullscreen);
			#elseif flash
			#end
		}
		#end
		
		hovered = true;
		for (callback in onOver) callback.cbFunction(this);
	}
	
	inline function callOnOut():Void {
		#if js
		Kala.html5.canvas.removeEventListener('click', openURLOnPush);
		Kala.html5.canvas.removeEventListener('mouseup', openURLOnRelease);
		Kala.html5.canvas.removeEventListener('click', requestFullscreen);
		Kala.html5.canvas.removeEventListener('mouseup', requestFullscreen);
		#elseif flash
		#end
		
		hovered = false;
		for (callback in onOut) callback.cbFunction(this);
	}
	
	inline function callOnPush(id:Int):Void {
		#if (!flash && !js)
		if (onPushOpenURL != null) Kala.openURL(onPushOpenURL);
		if (onPushRequestFullscreen) Kala.requestFullscreen();
		#end
		
		for (callback in onPush) callback.cbFunction(this, id);
	}
	
	inline function callOnRelease(id:Int):Void {
		#if (!flash && !js)
		if (onReleaseOpenURL != null) Kala.openURL(onReleaseOpenURL);
		if (onReleaseRequestFullscreen) Kala.requestFullscreen();
		#end
		
		for (callback in onRelease) callback.cbFunction(this, id);
	}
	
	#if (flash || js)
	function requestFullscreen():Void {
		Kala.requestFullscreen();
	}
	
	function openURLOnPush():Void {
		Kala.openURL(onPushOpenURL);
	}
	
	function openURLOnRelease():Void {
		Kala.openURL(onReleaseOpenURL);
	}
	#end
	
	function get_pushed():Bool {
		return _touched || _mouseHovered;
	}
	
}

#end