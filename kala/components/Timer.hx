package kala.components;

import kala.components.tween.Tween.Timeline;
import kala.Kala.TimeUnit;
import kala.components.Component;
import kala.objects.Object;
import kala.util.types.Pair;
import kha.FastFloat;

// TODO: Timeline

class Timer extends Component<Object> {
	
	private var _coolingDownIDs:Array<Pair<Int, Int>> = new Array<Pair<Int, Int>>();
	private var _coolingDownFunctions:Array<Pair<Void->Void, Int>> = new Array<Pair<Void->Void, Int>>();
	
	private var _loopTasks:Array<LoopTask> = new Array<LoopTask>();
	
	private var _timelines:Array<Timeline> = new Array<Timeline>();
	
	override public function reset():Void {
		super.reset();
		
		while (_coolingDownIDs.length > 0) _coolingDownIDs.pop();
		while (_coolingDownFunctions.length > 0) _coolingDownFunctions.pop();
		while (_loopTasks.length > 0 )_loopTasks.pop();
	}
	
	override public function addTo(object:Object):Timer {
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
		var task = new LoopTask(delayTime, 1, func, null);
		_loopTasks.push(task);
		return task;
	}
	
	public function loop(duration:Int, execTimes:Int, ?execFirst:Bool = false, onExecute:LoopTask->Void, ?onComplete:LoopTask->Void):LoopTask {
		var task = new LoopTask(duration, execTimes, onExecute, onComplete);
		_loopTasks.push(task);
		
		if (execFirst) {
			task.elapsedExecutions++;
			onExecute(task);
		}
		
		return task;
	}
	
	public function cancelLoop(task:LoopTask):Timer {
		_loopTasks.remove(task);
		return this;
	}
	
	function update(obj:Object, delta:FastFloat):Void {
		var elapsed  = 1;
		if (Kala.timingUnit == TimeUnit.MILLISECOND) {
			elapsed  = Std.int(delta * 1000);
		}
		
		var i = 0;
		for (cdID in _coolingDownIDs) {
			cdID.b -= elapsed ;
			if (cdID.b <= 0) _coolingDownIDs.splice(i, 1);
			i++;
		}
		
		i = 0;
		for (cdFunc in _coolingDownFunctions) {
			cdFunc.b -= elapsed;
			if (cdFunc.b <= 0) _coolingDownFunctions.splice(i, 1);
			i++;
		}
		
		i = 0;	
		for (task in _loopTasks.copy()) {
			task.elapsedTime += elapsed;
			
			if (task.elapsedTime >= task.duration) {
				task.elapsedTime = 0;
				
				task.elapsedExecutions++;
				task.onExecCB(task);
				
				if (task.totalExecutions > 0 && (task.elapsedExecutions == task.totalExecutions)) {
					_loopTasks.splice(i, 1);
					if (task.onCompleteCB != null) task.onCompleteCB(task);
				}
			}
			
			i++;
		}
	}
	
}

@:allow(kala.components.Timer)
class LoopTask {

	public var onExecCB(default, null):LoopTask->Void;
	public var onCompleteCB(default, null):LoopTask->Void;
	
	public var duration:Int;
	public var elapsedTime(default, null):Int;
	
	public var totalExecutions:UInt;
	public var elapsedExecutions(default, null):UInt;
	
	public inline function new(duration:Int, totalExecutions:UInt, onExecCB:LoopTask->Void, onCompleteCB:LoopTask->Void) {
		this.duration = duration;
		this.totalExecutions = totalExecutions;
		this.onExecCB = onExecCB;
		this.onCompleteCB = onCompleteCB;
		
		elapsedTime = 0;
		elapsedExecutions = 0;
	}

}