package kala.behaviors.display;

import kala.behaviors.Behavior;
import kala.objects.Object;
import kha.FastFloat;

class Flicker extends Behavior<Object> {
	
	public var delay:FastFloat;
	public var visibleDuration:FastFloat;
	public var flickersLeft:Int;

	var _delayTimeLeft:FastFloat;
	var _visibleTimeLeft:FastFloat;
	
	override public function reset():Void {
		super.reset();
		delay = 1;
	}
	
	override public function addTo(object:Object):Flicker {
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
	
	public inline function flicker(times:Int, delay:FastFloat = 0, visibleDuration:FastFloat = 0):Void {
		flickersLeft = times;
		if (delay > 0) this.delay = _delayTimeLeft = delay;
		if (visibleDuration > 0) this.visibleDuration = visibleDuration;
		_visibleTimeLeft = 0;
	}
	
	function update(obj:Object, elapsed:FastFloat):Void {
		if (flickersLeft > 0) {
			if (_visibleTimeLeft > 0) _visibleTimeLeft -= elapsed;
			else {
				obj.visible = false;
				
				if (_delayTimeLeft > 0) _delayTimeLeft -= elapsed;
				else {
					_delayTimeLeft = delay;
					_visibleTimeLeft = visibleDuration;
					obj.visible = true;
					flickersLeft--;
				}
			}
		}
	}
	
}