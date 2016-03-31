package kala.pool;

class Pool<T> {

	public var objects:Array<T> = new Array<T>();
	
	public var factoryFunction:Void->T;
	public var initFunction:T->Void;
	
	public function new(?factoryFunction:Void->T, ?initFunction:T->Void) {
		this.factoryFunction = factoryFunction;
		this.initFunction = initFunction;
	}
	
	public function destroy():Void {
		objects = null;
		
		factoryFunction = null;
		initFunction = null;
	}
	
	public function get():T {
		var obj:T = null;
		
		if (objects.length > 0) {
			obj = objects.pop();
			if (initFunction != null) initFunction(obj);
		} else {
			if (factoryFunction != null) {
				obj = factoryFunction();
				if (initFunction != null) initFunction(obj);
			}
		}
		
		return obj;
	}
	
	public function put(obj:T):T {
		objects.push(obj);
		return obj;
	}
	
}