package kala.util.types;

class Trio<T1, T2, T3> {
	
	public var a:T1;
	public var b:T2;
	public var c:T3;

	public function new(a:T1, b:T2, c:T3) {
		this.a = a;
		this.b = b;
		this.c = c;
	}
	
}