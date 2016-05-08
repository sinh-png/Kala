package kala.components.input;

import kha.FastFloat;

class ButtonInput<T> {

	public var button<default, null>:T;
	
	/**
	 * The time this button has been pressed. In frames if Kala.frameTiming is set to true otherwise uses milliseconds.
	 * -2 means the button is not pressed.
	 * -1 means the button is waiting for the next update to be registered.
	 * 0 means the button was just pressed.
	 */
	public var time:FastFloat;
	
	public function new(button:T) {
		this.button = button;
	}
	
}

class ButtonInputHandle<T> {
	
	var _buttons:Array<ButtonInput<T>> = new Array<ButtonInput<T>>();
	
	function new():Void {
		
	}
	
	function update(delta:Int):Void {
		if (Kala.frameTiming) {
			for (btn in _buttons) btn.time++;
		} else {
			for (btn in _buttons) btn.time+= delta;
		}
	}
	
}