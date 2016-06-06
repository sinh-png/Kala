package kala.behaviors.motion;

import kala.behaviors.Behavior;
import kala.math.Vec2;
import kala.math.Velocity;
import kala.objects.Object;
import kha.FastFloat;

using kala.math.Angle;

class VelocityMotion extends Behavior<Object> {

	public var velocity:Velocity = new Velocity();
	public var accel:Velocity = new Velocity();
	public var turnSpeed:FastFloat;
	public var turnAccel:FastFloat;
	
	override public function reset():Void {
		super.reset();
		velocity.set();
		accel.set();
		turnSpeed = 0;
		turnAccel = 0;
	}
	
	override public function destroy():Void {
		super.destroy();
		velocity = null;
		accel = null;
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
		
		if (accel.x != 0) velocity.x += accel.x * factor;
		if (accel.y != 0) velocity.y += accel.y * factor;
		
		turnSpeed += turnAccel * factor;
		if (turnSpeed != 0) velocity.angle += turnSpeed * factor;
		
		obj.x += velocity.x * factor;
		obj.y += velocity.y * factor;
	}
	
}