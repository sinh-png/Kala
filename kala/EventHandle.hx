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
	
	public function iterator():Iterator<Callback<T>> {
		return _callbacks.iterator();
	}
	
	public function add(callback:T):Void {
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
			if (cb.cbFunction == callback && cb.component == null) {
				_callbacks.splice(i, 1);
				break;
			}
			i++;
		}
	}
	
	function addComponentCB(component:IComponent, callback:T):Void {
		_callbacks.push(new Callback(callback, component));
	}
	
	function removeComponentCB(component:IComponent, callback:T):Void {
		var i = 0;
		for (cb in _callbacks) {
			if (cb.cbFunction == callback && cb.component == component) {
				_callbacks.splice(i, 1);
				return;
			}
			i++;
		}
		
		Log.error('Incorrectly tried to remove a callback of component $component from object $this');
	}
	
}

class Callback<T> {
	
	public var cbFunction(default, null):T;
	public var component(default, null):IComponent;
	
	public inline function new(cbFunction:T, component:IComponent = null) {
		this.cbFunction = cbFunction;
		this.component = component;
	}
	
}