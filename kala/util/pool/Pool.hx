package kala.util.pool;

class Pool<T> {

	public var factoryFunction:Void->T;

	private var _objects:Array<T> = new Array<T>();
	
	public function new(?factoryFunction:Void->T) {
		this.factoryFunction = factoryFunction;
	}
	
	public function destroy():Void {
		factoryFunction = null;
		_objects = null;
	}
	
	public function get():T {
		if (_objects.length > 0) return _objects.pop();
		if (factoryFunction != null) return factoryFunction();
		return null;
	}
	
	/**
	 * Put an object into the pool regardless if the object is already in the pool or not.
	 */
	public inline function putUnsafe(obj:T):Void {
		if (obj != null) _objects.push(obj);
	}
	
	public inline function put(obj:T):Void {
		if (obj != null && _objects.indexOf(obj) == -1) {
			_objects.push(obj);
		}
	}
	
}