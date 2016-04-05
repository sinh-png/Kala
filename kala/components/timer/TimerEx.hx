package kala.components.timer;
import kala.components.timer.Timer;
import kala.components.tween.Ease.EaseFunction;
import kha.FastFloat;

import kala.components.tween.Tween;
import kala.objects.Object;

@:access(kala.components.tween.Tween)
class TimerEx extends Timer {

	public var _tween:Tween;
	
	public function new() {
		super();
		
		_tween = new Tween();
	}
	
	override public function addTo(object:Object):TimerEx {
		super.addTo(object);
		_tween.object = object;
		return this;
	}
	
	override public function remove():Void {
		super.remove();
		_tween.object = null;
	}
	
	override function update(obj:Object, delta:FastFloat):Void {
		super.update(obj, delta);
		_tween.update(obj, delta);
	}
	
	public function timeline(
		?target:Dynamic, ?ease:EaseFunction, ?onTweenUpdateCB:TweenTask->Void
	):TweenTimeline {
		return _tween.get(target, ease, onTweenUpdateCB);
	}
	
}