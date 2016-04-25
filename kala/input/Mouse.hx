package kala.input;

@:access(kala.input.MouseStateHandle)
class Mouse {
	
	public static var x(default, null):Int = 0;
	public static var y(default, null):Int = 0;
	
	public static var pressed:MouseStateHandle = new MouseStateHandle();
	public static var justPressed:MouseStateHandle = new MouseStateHandle();
	public static var justReleased:MouseStateHandle = new MouseStateHandle();
	
	public static var wheel(get, null):Int;
	
	private static var _wheel:Int;
	private static var _wheelRegistered:Bool = false;
	
	static function init():Void {
		kha.input.Mouse.get().notify(onDown, onUp, onMove, onWheel);
	}

	static function onDown(button:Int, x:Int, y:Int):Void {
		var btn = codeToEnum(button);
		pressed.register(btn);
		justPressed.capture(btn);
	}
	
	static function onUp(button:Int, x:Int, y:Int):Void {
		var btn = codeToEnum(button);
		pressed.releaseRegistered(btn);
		justReleased.capture(btn);
	}
	
	static function onMove(x:Int, y:Int, _:Int, _:Int):Void {
		Mouse.x = x;
		Mouse.y = y;
	}
	
	static function onWheel(amount:Int):Void {
		_wheel = amount;
		_wheelRegistered = false;
	}
	
	static inline function register():Void {
		justPressed.registerAllCaptured();
		justReleased.registerAllCaptured();
		
		_wheelRegistered = true;
	}
	
	static inline function release():Void {
		justPressed.releaseAllRegistered();
		justReleased.releaseAllRegistered();
		
		if (_wheelRegistered) _wheel = 0;
	}
	
	static inline function codeToEnum(buttonCode:Int):MouseButton {
		return MouseButton.createByIndex(buttonCode);
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

class MouseStateHandle extends InputStateHandle<MouseButton> {

	public var ANY				(get, never):Bool; inline function get_ANY()			return checkAny();
	
	public var LEFT				(get, never):Bool; inline function get_LEFT()			return check(MouseButton.LEFT);
	public var RIGHT			(get, never):Bool; inline function get_RIGHT()			return check(MouseButton.RIGHT);
	public var MIDDLE			(get, never):Bool; inline function get_MIDDLE()			return check(MouseButton.MIDDLE);
	
}