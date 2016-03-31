package kala.pool;

import kala.objects.Object;

class ObjectPool<T:Object> extends Pool<T> {

	public function new(?factoryFunction:Void->T, ?initFunction:T->Void) {
		super(factoryFunction, initFunction);
	}
	
	override public function put(obj:T):T {
		obj.pool = cast this;
		return super.put(obj);
	}
	
}