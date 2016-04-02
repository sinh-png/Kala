package kala.components.motion;

import kala.components.Component;
import kala.math.Vec2;
import kala.math.Vec2V;
import kala.objects.Object;
import kha.FastFloat;

using kala.math.helpers.AngleHelper;

class VelocityMotion extends Component<Object> {

	public var velocity:Vec2V = new Vec2V();
	public var accel:Vec2V = new Vec2V();
	public var turnSpeed:FastFloat;
	
	override public function reset():Void {
		super.reset();
		velocity.set();
		accel.set();
		turnSpeed = 0;
	}
	
	override public function destroy():Void {
		super.destroy();
		velocity = null;
		accel = null;
	}
	
	override public function addTo(object:Object):VelocityMotion {
		super.addTo(object);
		
		object.onPostUpdate.addComponentCB(this, update);
		
		return this;
	}
	
	override public function remove():Void {
		if (object != null) {
			object.onPostUpdate.removeComponentCB(this, update);
		}
		
		super.remove();
	}
	
	function update(obj:Object, delta:FastFloat):Void {
		if (accel.x != 0) velocity.x += accel.x;
		if (accel.y != 0) velocity.y += accel.y;
		
		if (turnSpeed != 0) velocity.angle += turnSpeed;
		
		obj.x += velocity.x;
		obj.y += velocity.y;
	}
	
}