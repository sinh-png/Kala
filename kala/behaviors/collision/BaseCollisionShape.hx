package kala.behaviors.collision;

import kala.behaviors.collision.transformable.Collider;
import kala.math.Matrix;
import kala.math.Position;
import kha.FastFloat;

@:allow(kala.behaviors.collision.BaseCollider)
class BaseCollisionShape {

	public var position:Position = new Position();
	public var available(get, never):Bool;
	
	public function new() {
		
	}
	
	public function reset():Void {
		position.setOrigin();
	}
	
	public function destroy():Void {
		position = null;
	}
	
	public function update(objectMatrix:Matrix):Void {
	
	}
	
	public function put():Void {
		
	}
	
	public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		return false;
	}
	
	function get_available():Bool {
		return false;
	}
	
}