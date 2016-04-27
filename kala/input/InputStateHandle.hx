package kala.input;

class InputStateHandle<T:EnumValue> {

	private var _captured:Array<T> = new Array<T>();
	private var _registered:Array<T> = new Array<T>();
	
	public function new() {
		
	}
	
	public inline function check(button:T):Bool {
		return findRegistered(button) > -1 ? true : false;
	}
	
	public function checkAnyOf(buttons:Array<T>):Bool {
		for (button in buttons) {
			if (findRegistered(button) > -1) return true;
		}
		
		return false;
	}
	
	inline function checkAny():Bool {
		return _registered.length > 0 ? true : false;
	}
	
	inline function capture(button:T):Void {
		_captured.push(button);
	}
	
	inline function register(button:T):Void {
		_registered.push(button);
	}
	
	function findRegistered(button:T):Int {
		for (i in 0..._registered.length) {
			if (_registered[i].equals(button)) return i;
		}
		
		return -1;
	}
	
	inline function releaseRegistered(button:T):Void {
		var i = findRegistered(button);
		if (i < 0) return;
		_registered.splice(i, 1);
	}
	
	inline function registerAllCaptured():Void {
		for (button in _captured.copy()) {
			_registered.push(button);
			_captured.remove(button);
		}
	}
	
	inline function releaseAllRegistered():Void {
		while (_registered.length > 0) {
			_registered.pop();
		}
	}
	
}