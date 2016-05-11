package kala.input;

import kala.EventHandle.CallbackHandle;
import kha.FastFloat;

class ButtonInputHandle<T:EnumValue> {
	
	public var inputs:Array<ButtonInput<T>> = new Array<ButtonInput<T>>();
	public var activeInputs:Array<ButtonInput<T>> = new Array<ButtonInput<T>>();
	
	public var  onStartPressing:CallbackHandle<T->Void>;
	public var  onRelease:CallbackHandle<T->Void>;
	
	public function new(onStartPressing:CallbackHandle<T->Void>, onRelease:CallbackHandle<T->Void>):Void {
		this.onStartPressing = onStartPressing;
		this.onRelease = onRelease;
	}
	
	public function addButton(button:T):ButtonInput<T> {
		var buttonInput = new ButtonInput<T>(button, this);
		inputs.push(buttonInput);
		return buttonInput;
	}
	
	public function update(delta:Int):Void {
		var e = 1;
		if (Kala.deltaTiming) e = delta;
		
		var i = activeInputs.length;
		var input:ButtonInput<T>;
		while (i-- > 0) {
			input = activeInputs[i];
			
			if (input.duration == -1) {
				if (input._state == 1) {
					input.duration = 0;
					for (callback in onStartPressing) callback.cbFunction(input.button);
				}
				
				input._state = 0;
			} else {
				if (input._state == 2) {
					activeInputs.splice(i, 1);
					input.duration = -1;
					for (callback in onRelease) callback.cbFunction(input.button);
					continue;
				}
				
				input.duration += e;
			}
		}
	}
	
	public function checkAnyPressed(buttons:Array<T>):Bool {
		var btns = buttons.copy();
		var i:Int;
		for (input in inputs) {
			i = 0;
			for (button in btns) {
				if (input.button.equals(button)) {
					if (input.pressed) return true;
					if (btns.length == 1) return false;
					btns.splice(i, 1);
					break;
				}
				
				i++;
			}
		}
		
		return false;
	}
	
	public function checkAnyJustPressed(buttons:Array<T>):Bool {
		var btns = buttons.copy();
		var i:Int;
		for (input in inputs) {
			i = 0;
			for (button in btns) {
				if (input.button.equals(button)) {
					if (input.justPressed) return true;
					if (btns.length == 1) return false;
					btns.splice(i, 1);
					break;
				}
				
				i++;
			}
		}
		
		return false;
	}
	
	public function checkAnyJustReleased(buttons:Array<T>):Bool {
		var btns = buttons.copy();
		var i:Int;
		for (input in inputs) {
			i = 0;
			for (button in btns) {
				if (input.button.equals(button)) {
					if (input.justReleased) return true;
					if (btns.length == 1) return false;
					btns.splice(i, 1);
					break;
				}
				
				i++;
			}
		}
		
		return false;
	}
	
	public function checkAllPressed(buttons:Array<T>):Bool {
		var btns = buttons.copy();
		var i:Int;
		for (input in inputs) {
			i = 0;
			for (button in btns) {
				if (input.button.equals(button)) {
					if (!input.pressed) return false;
					if (btns.length == 1) return true;
					btns.splice(i, 1);
					break;
				}
				
				i++;
			}
		}
		
		return false;
	}
	
	public function checkAllJustPressed(buttons:Array<T>):Bool {
		var btns = buttons.copy();
		var i:Int;
		for (input in inputs) {
			i = 0;
			for (button in btns) {
				if (input.button.equals(button)) {
					if (!input.justPressed) return false;
					if (btns.length == 1) return true;
					btns.splice(i, 1);
					break;
				}
				
				i++;
			}
		}
		
		return false;
	}
	
	public function checkAllJustReleased(buttons:Array<T>):Bool {
		var btns = buttons.copy();
		var i:Int;
		for (input in inputs) {
			i = 0;
			for (button in btns) {
				if (input.button.equals(button)) {
					if (!input.justReleased) return false;
					if (btns.length == 1) return true;
					btns.splice(i, 1);
					break;
				}
				
				i++;
			}
		}
		
		return false;
	}
	
}

@:allow(kala.input.ButtonInputHandle)
class ButtonInput<T:EnumValue> {

	public var button(default, null):T;
	
	/**
	 * The time this button has been pressed.
	 * In milliseconds if Kala.deltaTiming is set to true otherwise use frames.
	 * 0 means the button was just pressed.
	 * -1 means the button is not pressed.
	 */
	public var duration(default, null):Int = -1;
	
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;
	public var justReleased(get, never):Bool;
	
	private var _state:Int = 0; // 1 - waiting to be registered, 2 - waiting to be released
	
	private var _handle:ButtonInputHandle<T>;

	public function new(button:T, handle:ButtonInputHandle<T>) {
		this.button = button;
		_handle = handle;
	}
	
	inline function waitForRegistration():Void {
		_handle.activeInputs.push(this);
		_state = 1;
	}
	
	inline function waitForReleasing():Void {
		_state = 2;
	}
	
	inline function get_pressed():Bool {
		return duration > -1;
	}
	
	inline function get_justPressed():Bool {
		return duration == 0;
	}
	
	inline function get_justReleased():Bool {
		return duration == -1 && _state == 2;
	}
	
}