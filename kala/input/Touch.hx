package kala.input;
import kala.math.Vec2;
import kala.objects.group.View;

#if kala_touch

import kala.EventHandle.CallbackHandle;
import kha.input.Surface;

@:allow(kala.Kala)
@:allow(kala.input.TouchHandle)
@:access(kala.input.TouchHandle)
class Touch {
	
	public static var onStart(default, never):CallbackHandle<Touch->Void> = new CallbackHandle<Touch->Void>();
	public static var onEnd(default, never):CallbackHandle<Touch->Void> = new CallbackHandle<Touch->Void>();
	public static var onMove(default, never):CallbackHandle<Touch->Void> = new CallbackHandle<Touch->Void>();
	
	public static var touches(default, never):TouchHandle = new TouchHandle();
	
	static function init():Void {
		var surface = Surface.get();
		if (surface != null) surface.notify(touchStartListener, touchEndListener, touchMoveListener);
	}
	
	static function touchStartListener(id:Int, x:Int, y:Int):Void {
		touches._capturedTouches.push(new Touch(id, x, y));
	}
	
	static function touchEndListener(id:Int, x:Int, y:Int):Void {
		touches.findTouch(id)._ending = true;
	}
	
	static function touchMoveListener(id:Int, x:Int, y:Int):Void {
		var touch = touches.findTouch(id);
		for (callback in onMove) callback.cbFunction(touch);
		touch.setPos(x, y);
	}
	
	static inline function update(delta:Int):Void {
		touches.update(delta);
	}
	
	//
	
	public var id(default, null):Int;
	
	public var x(default, null):Int;
	public var y(default, null):Int;
	
	public var duration(default, null):Int;
	
	public var justStarted(get, never):Bool;
	
	private var _ending:Bool;
	
	public inline function new(id:Int, x:Int, y:Int) {
		this.id = id;
		this.x = x;
		this.y = y;
		duration = 0;
		_ending = false;
	}
	
	/**
	 * Project the touch position from the input view to its viewport.
	 * Only works when the view is visible.
	 */
	public inline function project(view:View):Vec2 {
		return view.project(x, y);
	}
	
	@:extern
	inline function setPos(x:Int, y:Int):Void {
		this.x = x;
		this.y = y;
	}
	
	inline function get_justStarted():Bool {
		return duration == 0;
	}
	
}

class TouchHandle {
	
	public var lenght(get, never):Int;
	
	private var _registeredTouches:Array<Touch> = new Array<Touch>();
	private var _capturedTouches:Array<Touch> = new Array<Touch>();
	
	public function new() {
		
	}
	
	public inline function get(index:Int):Touch {
		return _registeredTouches[index];
	}
	
	public function findTouch(id:Int):Touch {
		for (touch in _registeredTouches) {
			if (touch.id == id) return touch;
		}
		
		return null;
	}
	
	function update(delta:Int):Void {
		var e = 1;
		if (Kala.deltaTiming) e = delta;
		
		var i = 0;
		var touch:Touch;
		while (_capturedTouches.length > 0) {
			touch = _capturedTouches.pop();
			_registeredTouches.push(touch);
			for (callback in Touch.onStart) callback.cbFunction(touch);
			i++;
		}
		
		var i = _registeredTouches.length;
		var touch:Touch;
		while (i-- > 0) {
			touch = _registeredTouches[i];
			touch.duration += e;
			
			if (touch._ending) {
				_registeredTouches.splice(i, 1);
				for (callback in Touch.onEnd) callback.cbFunction(touch);
			}
		}
	}
	
	public function iterator():Iterator<Touch> {
		return _registeredTouches.iterator();
	}
	
	inline function get_lenght():Int {
		return _registeredTouches.length;
	}
	
}

#end