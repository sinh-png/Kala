package kala.util.types;

class Pair<T1, T2> {
	
	public var a:T1;
	public var b:T2;

	public inline function new(a:T1, b:T2) {
		this.a = a;
		this.b = b;
	}
	
}