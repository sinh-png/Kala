package kala.behaviors;
import kala.behaviors.tween.Ease;

import kala.behaviors.tween.Ease.EaseFunction;
import kala.behaviors.tween.Tween;
import kala.behaviors.Behavior;
import kala.objects.Object;
import kala.util.types.Pair;
import kha.FastFloat;

class Timer extends Behavior<Object> {
	
	private var _coolingDownIDs:Array<Pair<Int, Int>> = new Array<Pair<Int, Int>>();
	private var _coolingDownFunctions:Array<Pair<Void->Void, Int>> = new Array<Pair<Void->Void, Int>>();
	
	private var _loopTasks:Array<LoopTask> = new Array<LoopTask>();
	
	override public function reset():Void {
		super.reset();
		
		_coolingDownIDs.splice(0, _coolingDownIDs.length);
		_coolingDownFunctions.splice(0, _coolingDownFunctions.length);
		_loopTasks.splice(0, _loopTasks.length);
	}
	
	override public function destroy():Void {
		super.destroy();
		
		_coolingDownIDs = null;
		_coolingDownFunctions = null;
		
		while (_loopTasks.length > 0) _loopTasks.pop().destroy();
		_loopTasks = null;
	}
	
	override public function addTo(object:Object):Timer {
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
	
	public function cooldown(?id:Int, coolingTime:Int, func:Void->Void):Bool {
		if (id == null) {
			for (cdFunc in _coolingDownFunctions) {
				if (cdFunc.a == func) return false;
			}
			
			_coolingDownFunctions.push(new Pair<Void->Void, Int>(func, coolingTime));
			func();
			
			return true;
		}
		
		for (cdID in _coolingDownIDs) {
			if (cdID.a == id) return false;
		}
		
		_coolingDownIDs.push(new Pair<Int, Int>(id, coolingTime));
		func();
		
		return true;
	}
	
	public function delay(delayTime:Int, func:LoopTask->Void):LoopTask {
		var task = new LoopTask(this, delayTime, 1, func, null);
		_loopTasks.push(task);
		return task;
	}
	
	public function loop(duration:Int, execTimes:Int, ?execFirst:Bool = false, onExecute:LoopTask->Void, ?onComplete:LoopTask->Void):LoopTask {
		var task = new LoopTask(this, duration, execTimes, onExecute, onComplete);
		_loopTasks.push(task);
		
		if (execFirst) {
			task.elapsedExecutions++;
			onExecute(task);
		}
		
		return task;
	}
	
	function update(obj:Object, elapsed:FastFloat):Void {
		for (cdID in _coolingDownIDs.copy()) {
			cdID.b -= elapsed ;
			if (cdID.b <= 0) _coolingDownIDs.remove(cdID);
		}
		
		for (cdFunc in _coolingDownFunctions.copy()) {
			cdFunc.b -= elapsed;
			if (cdFunc.b <= 0) _coolingDownFunctions.remove(cdFunc);
		}
		
		for (task in _loopTasks.copy()) {
			task.elapsedTime += elapsed;
			
			if (task.elapsedTime >= task.duration) {
				task.elapsedTime = 0;
				
				task.elapsedExecutions++;
				task.onExecCB(task);
				
				if (task.totalExecutions > 0 && (task.elapsedExecutions == task.totalExecutions)) {
					if (task.onCompleteCB != null) task.onCompleteCB(task);
					task.cancel();
				}
			}
		}
	}
	
}

@:allow(kala.behaviors.Timer)
@:access(kala.behaviors.Timer)
class LoopTask {

	public var duration:FastFloat;
	public var elapsedTime(default, null):FastFloat;
	
	public var totalExecutions:UInt;
	public var elapsedExecutions(default, null):UInt;
	
	public var onExecCB(default, null):LoopTask->Void;
	public var onCompleteCB(default, null):LoopTask->Void;
	
	private var _manager:Timer;
	
	private inline function new(manager:Timer, duration:Int, totalExecutions:UInt, onExecCB:LoopTask->Void, onCompleteCB:LoopTask->Void) {
		this._manager = manager;
		
		this.duration = duration;
		this.totalExecutions = totalExecutions;
		this.onExecCB = onExecCB;
		this.onCompleteCB = onCompleteCB;
		
		elapsedTime = 0;
		elapsedExecutions = 0;
	}

	@:extern
	public inline function cancel():Void {
		_manager._loopTasks.remove(this);
		_manager = null;
	}

	@:extern
	inline function destroy():Void {
		onExecCB = null;
		onCompleteCB = null;
		_manager = null;
	}
	
}

//

@:access(kala.behaviors.tween.Tween)
class TimerEx extends Timer {

	public var _tween:Tween;
	
	public function new() {
		super();
		
		_tween = new Tween();
	}
	
	override public function destroy():Void {
		super.destroy();
		_tween = null;
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
	
	override function update(obj:Object, elapsed:FastFloat):Void {
		super.update(obj, elapsed);
		_tween.update(obj, elapsed);
	}
	
	public function timeline(
		?target:Dynamic, ?ease:EaseFunction, ?onTweenUpdateCB:TweenTask->Void
	):TweenTimeline {
		return _tween.get(target, ease, onTweenUpdateCB);
	}
	
}