package kala.behaviors;

import kala.EventHandle;
import kala.objects.Object;

interface IBehavior {
 
	public function destroy():Void;
	public function reset():Void;
	public function deepReset():Void;
	public function remove():Void;
	
}

class Behavior<T:Object> extends EventHandle implements IBehavior {

	public var object(default, null):T;
	
	//
	
	public var onDestroy(default, null):CallbackHandle<Behavior<T>->Void>;
	public var onReset(default, null):CallbackHandle<Behavior<T>->Void>;
	public var onAdd(default, null):CallbackHandle<Behavior<T>->Void>;
	public var onRemove(default, null):CallbackHandle<Behavior<T>->Void>;
	
	public function new(?object:T) {
		super();
		
		onDestroy = addCBHandle(new CallbackHandle<Behavior<T>->Void>());
		onReset = addCBHandle(new CallbackHandle<Behavior<T>->Void>());
		onAdd = addCBHandle(new CallbackHandle<Behavior<T>->Void>());
		onRemove = addCBHandle(new CallbackHandle<Behavior<T>->Void>());
		
		reset();
		
		if (object != null) addTo(object);
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
	
	public function addTo(object:T):Behavior<T> {
		if (this.object != null) remove();
		
		this.object = object;
		object._behaviors.push(this);
		for (callback in onAdd) callback.cbFunction(this);
		
		return this;
	}
	
	public function remove():Void {
		if (object != null) {
			for (callback in onRemove) callback.cbFunction(this);
			object._behaviors.remove(this);
			object = null;
		}
	}
	
}