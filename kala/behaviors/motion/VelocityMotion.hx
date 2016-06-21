package kala.behaviors.motion;

import kala.behaviors.Behavior;
import kala.math.Vec2;
import kala.math.Velocity;
import kala.objects.Object;
import kha.FastFloat;

class VelocityMotion extends Behavior<Object> {

	public var velocity:Velocity = new Velocity();
	public var accelXY:Velocity = new Velocity();
	public var accel:FastFloat;
	public var turnSpeed:FastFloat;
	public var turnAccel:FastFloat;
	
	override public function reset():Void {
		super.reset();
		velocity.set();
		accelXY.set();
		accel = 0;
		turnSpeed = 0;
		turnAccel = 0;
	}
	
	override public function destroy():Void {
		super.destroy();
		velocity = null;
		accelXY = null;
	}
	
	override public function addTo(object:Object):VelocityMotion {
		super.addTo(object);
		
		object.onPostUpdate.notifyPrivateCB(this, update);
		
		return this;
	}
	
	override public function remove():Void {
		if (object != null) {
			object.onPostUpdate.removePrivateCB(this, update);
		}
		
		super.remove();
	}
	
	function update(obj:Object, elapsed:FastFloat):Void {
		var factor = elapsed;
		if (Kala.deltaTiming) factor /= Kala.perfectDelta;
		
		if (accelXY.x != 0) velocity.x += accelXY.x * factor;
		if (accelXY.y != 0) velocity.y += accelXY.y * factor;
		if (accel != 0) velocity.speed += accel * factor;
		
		turnSpeed += turnAccel * factor;
		if (turnSpeed != 0) velocity.angle += turnSpeed * factor;
		
		obj.x += velocity.x * factor;
		obj.y += velocity.y * factor;
	}
	
}