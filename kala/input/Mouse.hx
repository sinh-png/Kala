package kala.input;
import kala.math.Vec2;
import kala.objects.group.View;

#if (debug || kala_debug || kala_mouse)

import kala.EventHandle.CallbackHandle;
import kala.input.ButtonInputHandle;
import kala.math.Rect;
import kha.FastFloat;

@:allow(kala.Kala)
@:access(kala.CallbackHandle)
@:access(kala.input.ButtonInput)
class Mouse {
	
	public static var onStartPressing(default, never):CallbackHandle<MouseButton->Void> = new CallbackHandle<MouseButton->Void>();
	public static var onRelease(default, never):CallbackHandle<MouseButton->Void> = new CallbackHandle<MouseButton->Void>();

	//
	
	public static var x(default, null):Int = 0;
	public static var y(default, null):Int = 0;
	
	public static var wheel(get, null):Int;
	
	//
	
	public static var ANY(default, null):ButtonInput<MouseButton>;
	public static var LEFT(default, null):ButtonInput<MouseButton>;
	public static var RIGHT(default, null):ButtonInput<MouseButton>;
	public static var MIDDLE(default, null):ButtonInput<MouseButton>;
	
	//
	
	private static var _wheel:Int;
	private static var _wheelRegistered:Bool = false;
	
	private static var _handle:ButtonInputHandle<MouseButton>;
	
	//
	
	public static inline function checkAnyPressed(buttons:Array<MouseButton>):Bool {
		return _handle.checkAnyPressed(buttons);
	}
	
	public static inline function checkAnyJustPressed(buttons:Array<MouseButton>):Bool {
		return _handle.checkAnyJustPressed(buttons);
	}
	
	public static inline function checkAnyJustReleased(buttons:Array<MouseButton>):Bool {
		return _handle.checkAnyJustReleased(buttons);
	}
	
	public static inline function checkAllPressed(buttons:Array<MouseButton>):Bool {
		return _handle.checkAllPressed(buttons);
	}
	
	public static inline function checkAllJustPressed(buttons:Array<MouseButton>):Bool {
		return _handle.checkAllJustPressed(buttons);
	}
	
	public static inline function checkAllJustReleased(buttons:Array<MouseButton>):Bool {
		return _handle.checkAllJustReleased(buttons);
	}
	
	//
	
	public static inline function isHovering(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):Bool {
		return (
			Mouse.x >= x && Mouse.x <= x + width &&
			Mouse.y >= y && Mouse.y <= y + height
		);
	}
	
	public static inline function isHoveringRect(rect:Rect):Bool {
		return (
			Mouse.x >= rect.x && Mouse.x <= rect.x + rect.width &&
			Mouse.y >= rect.y && Mouse.y <= rect.y + rect.height
		);
	}
	
	public static inline function didLeftClickOn(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):Bool {
		return LEFT.justPressed && isHovering(x, y, width, height);
	}

	public static inline function didLeftClickRect(rect:Rect):Bool {
		return LEFT.justPressed && isHoveringRect(rect);
	}
	
	public static inline function didRightClickOn(x:FastFloat, y:FastFloat, width:FastFloat, height:FastFloat):Bool {
		return RIGHT.justPressed && isHovering(x, y, width, height);
	}

	public static inline function didRightClickRect(rect:Rect):Bool {
		return RIGHT.justPressed && isHoveringRect(rect);
	}
	
	/**
	 * Project the cursor position from the input view to its viewport.
	 * Only works when the view is visible.
	 */
	public static inline function project(view:View):Vec2 {
		return view.project(x, y);
	}
	
	//
	
	/*
	static inline function buttonIndexToButton(index:Int):MouseButton {
		return MouseButton.createByIndex(index + 1);
	}
	*/
	
	static function init():Void {
		kha.input.Mouse.get().notify(mouseDownListener, mouseUpListener, mouseMoveListener, onWheel);
		
		_handle = new ButtonInputHandle<MouseButton>(onStartPressing, onRelease);
		
		ANY 		= _handle.addButton(null);
		
		LEFT 		= _handle.addButton(MouseButton.LEFT);
		RIGHT 		= _handle.addButton(MouseButton.RIGHT);
		MIDDLE 		= _handle.addButton(MouseButton.MIDDLE);
	}
	
	static inline function update(delta:Int):Void {
		_handle.update(delta);
		
		if (_wheel != 0) {
			if (_wheelRegistered) _wheel = 0;
			else _wheelRegistered = true;
		}
	}
	
	static function mouseDownListener(button:Int, x:Int, y:Int):Void {
		_handle.inputs[button].waitForRegistration();
	}
	
	static function mouseUpListener(button:Int, x:Int, y:Int):Void {
		_handle.inputs[button].waitForReleasing();
	}
	
	static function mouseMoveListener(x:Int, y:Int, _:Int, _:Int):Void {
		Mouse.x = x;
		Mouse.y = y;
	}
	
	static function onWheel(amount:Int):Void {
		_wheel = amount;
		_wheelRegistered = false;
	}
	
	static function get_wheel():Int {
		return _wheelRegistered ? _wheel : 0;
	}
	
}

enum MouseButton {
	
	LEFT;
	RIGHT;
	MIDDLE;
	
}

#end