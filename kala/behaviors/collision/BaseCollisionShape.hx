package kala.behaviors.collision;

import kala.behaviors.collision.transformable.Collider;
import kala.math.Matrix;
import kala.math.Position;
import kha.FastFloat;

@:allow(kala.behaviors.collision.BaseCollider)
class BaseCollisionShape {

	public var position:Position = new Position();
	public var available(get, never):Bool;
	public var active:Bool;
	
	public function new() {
		
	}
	
	public function reset():Void {
		position.setOrigin();
		active = true;
	}
	
	public function destroy():Void {
		position = null;
	}
	
	public function put():Void {
		
	}
	
	public function testPoint(pointX:FastFloat, pointY:FastFloat):Bool {
		return false;
	}
	
	function update(objectMatrix:Matrix):Void {
	
	}
	
	function get_available():Bool {
		return false;
	}
	
}