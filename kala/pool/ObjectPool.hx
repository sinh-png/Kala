package kala.pool;

import kala.objects.Object;

class ObjectPool extends Pool<Object> {

	public function new(?factoryFunction:Void->Object, ?initFunction:Object->Void) {
		super(factoryFunction, initFunction);
	}
	
	override public function put(obj:Object):Object {
		obj.pool = this;
		return super.put(obj);
	}
	
}