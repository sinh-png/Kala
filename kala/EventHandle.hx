package kala;

import kala.components.Component.IComponent;

class EventHandle {

	private var _cbHandles:Array<ICallbackHandle> = new Array<ICallbackHandle>();
	
	public function new() {
		
	}
	
	public function clearCBHandles():Void {
		for (handle in _cbHandles) handle.removeAll();
	}
	
	inline function destroyCBHandles():Void {
		while (_cbHandles.length > 0) {
			_cbHandles.pop().destroy();
		}
		
		_cbHandles = null;
	}
	
	
	inline function addCBHandle<T:ICallbackHandle>(handle:T):T {
		_cbHandles.push(handle);
		return handle;
	}
	
}

@:allow(kala.EventHandle)
interface ICallbackHandle {
	private function removeAll():Void;
	private function destroy():Void;
}

@:allow(kala.components.Component)
class CallbackHandle<T> implements ICallbackHandle {
	
	private var _callbacks:Array<Callback<T>> = new Array<Callback<T>>();
	
	public function new() {
	
	}
	
	function removeAll():Void {
		while (_callbacks.length > 0) _callbacks.pop();
	}
	
	function destroy():Void {
		removeAll();
		_callbacks = null;
	}
	
	public function notify(callback:T):Void {
		_callbacks.push(new Callback(callback));
	}
	
	/**
	 * Remove callback from this handle if it wasn't added by a component.
	 * 
	 * @param	callback	The callback to be removed.
	 */
	public function remove(callback:T):Void {
		var i = 0;
		for (cb in _callbacks) {
			if (cb.cbFunction == callback && cb.owner == null) {
				_callbacks.splice(i, 1);
				return;
			}
			i++;
		}
	}
	
	function notifyPrivateCB(component:Dynamic, callback:T):Void {
		_callbacks.push(new Callback(callback, component));
	}
	
	function removePrivateCB(component:Dynamic, callback:T):Void {
		var i = 0;
		for (cb in _callbacks) {
			if (cb.cbFunction == callback && cb.owner == component) {
				_callbacks.splice(i, 1);
				return;
			}
			i++;
		}
		
		throw 'Incorrectly tried to remove a private callback of $component from object $this.';
	}
	
	public function iterator():Iterator<Callback<T>> {
		return _callbacks.iterator();
	}
	
}

class Callback<T> {
	
	public var cbFunction(default, null):T;
	public var owner(default, null):Dynamic;
	
	public inline function new(cbFunction:T, component:Dynamic = null) {
		this.cbFunction = cbFunction;
		this.owner = component;
	}
	
}