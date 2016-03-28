package kala.components;

import kala.EventHandle;
import kala.objects.Object;

class Component<T:Object> extends EventHandle implements IComponent {

	public var object(default, null):T;
	
	//
	
	public var onDestroy:CallbackHandle<Component<T>->Void>;
	public var onReset:CallbackHandle<Component<T>->Void>;
	public var onAdd:CallbackHandle<Component<T>->Void>;
	public var onRemove:CallbackHandle<Component<T>->Void>;
	
	public function new() {
		super();
		
		onDestroy = addCBHandle(new CallbackHandle<Component<T>->Void>());
		onReset = addCBHandle(new CallbackHandle<Component<T>->Void>());
		onAdd = addCBHandle(new CallbackHandle<Component<T>->Void>());
		onRemove = addCBHandle(new CallbackHandle<Component<T>->Void>());
		
		reset();
	}
	
	public function reset():Void {
		for (callback in onReset) callback.cbFunction(this);
	}
	
	public function destroy():Void {
		remove();
		
		onDestroy = null;
		onReset = null;
		onAdd = null;
		onRemove = null;
	}
	
	public function deepReset():Void {
		reset();
		remove();
		clearCBHandles();
	}
	
	public function addTo(object:T):Component<T> {
		this.object = object;
		object._components.push(this);
		for (callback in onAdd) callback.cbFunction(this);
		
		return this;
	}
	
	public function remove():Bool {
		if (object != null) {
			for (callback in onRemove) callback.cbFunction(this);
			object._components.remove(this);
			object = null;
			
			return true;
		}
		
		return false;
	}
	
}

interface IComponent {
 
	public function destroy():Void;
	public function reset():Void;
	public function deepReset():Void;
	public function remove():Bool;
	
}