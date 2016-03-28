package kala.components;

import kala.Kala.TimeUnit;
import kala.components.Component;
import kala.components.Timer.TimerTask;
import kala.objects.Object;
import kala.util.types.Pair;
import kha.FastFloat;

// There is something in this file that breaks code-completion.

class Timer extends Component<Object> {

	private var _coolingDownIDs:Array<Pair<Int, Int>> = new Array<Pair<Int, Int>>();
	private var _coolingDownFunctions:Array<Pair<Void->Void, Int>> = new Array<Pair<Void->Void, Int>>();
	
	// This line breaks code-completion and function name coloring in FlashDevelop.
	// The problem with functions declared without access modifiers still stay when this line get removed.
	private var _tasks:Array<TimerTask> = new Array<TimerTask>(); // *[1]
	
	override public function reset():Void {
		super.reset();
		
		while (_coolingDownIDs.length > 0)_coolingDownIDs.pop();
		while (_coolingDownFunctions.length > 0)_coolingDownFunctions.pop();
		while (_tasks.length > 0)_tasks.pop();
	}
	
	override public function addTo(object:Object):Timer {
		super.addTo(object);
		object.onPostUpdate.addComponentCB(this, update);
		return this;
	}

	override public function remove():Bool {
		if (object != null) {
			object.onPostUpdate.removeComponentCB(this, update);
		}
		
		return super.remove();
	}
	
	public function cooldown(?id:Int, func:Void->Void, coolingTime:Int):Bool {
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
		
		return true;
	}
	
	public function delay(delayTime:Int, func:Void->Void):TimerTask {
		var task = new TimerTask(delayTime, 1, func, null);
		_tasks.push(task);
		return task;
	}
	
	public function loop(duration:Int, execTimes:Int, ?execFirst:Bool = false, onExecute:Void->Void, onComplete:Void->Void):TimerTask {
		var task = new TimerTask(duration, execTimes, onExecute, onComplete);
		_tasks.push(task);
		
		if (execFirst) onExecute();
		
		return task;
	}
	
	// Without "private" code-completion will work incorrectly even after *[1] get removed.
	private function update(obj:Object, delta:FastFloat):Void {
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
		for (task in _tasks) {
			task.elapsedTime += elapsed;
			
			if (task.elapsedTime >= task.duration) {
				task.elapsedTime = 0;
				task.elapsedExecutions++;
				
				task.onExecCB();
				
				if (task.elapsedExecutions == task.totalExecutions) {
					_tasks.splice(i, 1);
					if (task.onCompleteCB != null) task.onCompleteCB();
				}
			}
			
			i++;
		}
	}
	
}

@:allow(kala.components.Timer)
class TimerTask {

	public var onExecCB(default, null):Void->Void;
	public var onCompleteCB(default, null):Void->Void;
	
	public var duration:Int;
	public var elapsedTime(default, null):Int;
	
	public var totalExecutions:UInt;
	public var elapsedExecutions(default, null):UInt;
	
	public inline function new(duration:Int, totalExecutions:UInt, onExecCB:Void->Void, onCompleteCB:Void->Void) {
		this.duration = duration;
		this.totalExecutions = totalExecutions;
		this.onExecCB = onExecCB;
		this.onCompleteCB = onCompleteCB;
		
		elapsedTime = 0;
		elapsedExecutions = 0;
	}

}