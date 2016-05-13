package kala.components.tween;

import kala.Kala;
import kala.components.Component;
import kala.components.tween.Ease.EaseFunction;
import kala.components.tween.Tween.TweenTask;
import kala.components.tween.Tween.TweenTimeline;
import kala.objects.Object;
import kala.pool.Pool;
import kala.util.types.Trio;
import kha.FastFloat;

@:allow(kala.components.tween.TweenTimeline)
class Tween extends Component<Object> {
	
	private var _tweens:Array<TweenTimeline> = new Array<TweenTimeline>();
	
	public function new(?object:Object) {
		super();
		if (object != null) addTo(object);
	}
	
	override public function reset():Void {
		super.reset();
		while (_tweens.length > 0) _tweens.pop().put();
	}
	
	override public function destroy():Void {
		super.destroy();
		while (_tweens.length > 0) _tweens.pop().put();
		_tweens = null;
	}

	override public function addTo(object:Object):Tween {
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
	
	public function get(?target:Dynamic, ?ease:EaseFunction, ?onTweenUpdateCB:TweenTask->Void):TweenTimeline {
		if (target == null) target = object;
		if (ease == null) ease = Ease.none;
		
		return TweenTimeline.get().init(this, target, ease, onTweenUpdateCB);
	}
	
	function update(obj:Object, delta:Int):Void {
		for (tween in _tweens) {
			tween.update(delta);
		}
	}
	
}

@:allow(kala.components.tween.Tween)
class TweenTimeline {
	
	public static var pool(default, never) = new Pool<TweenTimeline>(create);
	
	public static inline function get():TweenTimeline {
		return pool.get();
	}
	
	static function create():TweenTimeline {
		return new TweenTimeline();
	}
	
	//
	
	public var nodes:Array<TweenNode> = new Array<TweenNode>();
	
	public var pos(default, null):Int;
	public var node(default, null):TweenNode;
	
	public var loopsLeft(default, null):Array<UInt> = new Array<UInt>();
	public var loopStartPos(default, null):Array<UInt> = new Array<UInt>();
	
	public var waitTimeLeft(default, null):Int;
	
	public var target(default, null):Dynamic;
	public var ease(default, null):EaseFunction;
	public var tweenUpdateCB(default, null):TweenTask->Void;
	
	private var _prvTweenTask:TweenTask;
	private var _crTweenTask:TweenTask;

	private var _orgnTarget:Dynamic;
	private var _orgnEase:EaseFunction;
	private var _orgnTweenUpdateCB:TweenTask->Void;
	
	private var _manager:Tween;
	
	public function new() {
		reset();
	}
	
	public function init(
		manager:Tween, 
		target:Dynamic, ease:EaseFunction, tweenUpdateCB:TweenTask->Void
	):TweenTimeline {
		_manager = manager;
		
		_orgnTarget = target;
		_orgnEase = ease;
		_orgnTweenUpdateCB = tweenUpdateCB;
		
		reset();
		
		return this;
	}
	
	public function reset():Void {
		nodes.splice(0, nodes.length);
		loopsLeft.splice(0, loopsLeft.length);
		loopStartPos.splice(0, loopStartPos.length);
		
		pos = -1;
		node = null;
		
		target = _orgnTarget;
		ease = _orgnEase;
		tweenUpdateCB = _orgnTweenUpdateCB;
	}
	
	public function destroy():Void {
		cancel();
		
		_orgnTarget = null;
		_orgnEase = null;
		_orgnTweenUpdateCB = null;
		
		target = null;
		ease = null;
		tweenUpdateCB = null;
		
		node = null;
		
		nodes = null;
		loopsLeft = null;
		loopStartPos = null;
	}
	
	public function put():Void {
		cancel();
		
		_orgnTarget = null;
		_orgnEase = null;
		_orgnTweenUpdateCB = null;
		
		target = null;
		ease = null;
		tweenUpdateCB = null;
		
		node = null;
		
		nodes.splice(0, nodes.length);
		loopsLeft.splice(0, loopsLeft.length);
		loopStartPos.splice(0, loopStartPos.length);
		
		pool.put(this);
	}
	
	public function cancel():Void {
		if (_manager != null) {
			_manager._tweens.remove(this);
			_manager = null;
		}
	}
	
	public function start(?manager:Tween):Void {
		if (manager != null) _manager = manager;
		
		if (_manager == null) throw "Needs a manager to start.";
		
		_manager._tweens.push(this);
		
		nextNode();
	}
	
	public function tween(
		vars:Dynamic, duration:UInt, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void, ?target:Dynamic
	):TweenTimeline {
		var task = TweenTask.get();
		task.init(target, vars, duration, ease, onUpdateCB);
		nodes.push(TWEEN(task));
		return this;
	}
	
	public function tweenBack(?duration:UInt = 0, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void):TweenTimeline {
		var task = TweenTask.get();
		task.init(null, null, duration, ease, onUpdateCB);
		nodes.push(BACKWARD_TWEEN(task));
		return this;
	}
	
	public function tweenPos(
		?x:FastFloat, ?y:FastFloat, duration:UInt, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void, ?target:Dynamic
	):TweenTimeline {
		var task = TweenTask.get();
		
		var vars:Dynamic = { };
		if (x != null) vars.x = x;
		if (y != null) vars.y = y;
		
		task.init(target, vars, duration, ease, onUpdateCB);
		nodes.push(TWEEN(task));
		
		return this;
	}
	
	public function wait(duration:UInt):TweenTimeline {
		nodes.push(WAIT(duration));
		return this;
	}
	
	public function waitEx(f:TweenTimeline->Int):TweenTimeline {
		nodes.push(WAIT_EX(f));
		return this;
	}
	
	public function call(callback:TweenTimeline->Void):TweenTimeline {
		nodes.push(CALL(callback));
		return this;
	}
	
	public function startLoop(times:UInt = 0):TweenTimeline {
		nodes.push(START_LOOP(times));
		return this;
	}
	
	public function endLoop():TweenTimeline {
		nodes.push(END_LOOP);
		return this;
	}
	
	public function jump(f:TweenTimeline->Int):TweenTimeline {
		nodes.push(JUMP(f));
		return this;
	}
	
	public function set(target:Dynamic, ease:EaseFunction):TweenTimeline {
		nodes.push(SET(target, ease));
		return this;
	}
	
	function update(delta:Int):Void {
		if (waitTimeLeft > 0) {
			if (Kala.deltaTiming) {
				waitTimeLeft -= delta;
			} else {
				waitTimeLeft--;
			}
			
			if (waitTimeLeft <= 0) nextNode();
			
		} else {
			if (_crTweenTask != null) {
				if (_crTweenTask.update(delta)) {
					_prvTweenTask = _crTweenTask;
					_crTweenTask = null;
					nextNode();
				}
			}
		}
	}
	
	function nextNode():Void {
		if (pos == nodes.length - 1) {
			cancel();
			return;
		}
		
		setPos(pos + 1);
	}

	function setPos(index:Int):Void {
		if (index > nodes.length - 1) {
			throw 'Jump index ($index) is out of range (0 - $(node.lenght - 1)).';
		}
		
		pos = index;
		node = nodes[pos];
		
		switch(node) {
			
			case TWEEN(task):
				task.target = task._orgnTarget == null ? target : task._orgnTarget;
				task.ease = task._orgnEase == null ? ease : task._orgnEase;
				task.onUpdateCB = task._orgnUpdateCB == null ? tweenUpdateCB : task._orgnUpdateCB;
		
				task.initVars(false);
				_crTweenTask = task;
					
			case BACKWARD_TWEEN(task):
				if (_prvTweenTask == null) {
					nextNode();
					return;
				}
				
				task.copyBackward(_prvTweenTask);
				_crTweenTask = task;
				
			case WAIT(duration):
				waitTimeLeft = duration;
				
			case WAIT_EX(f):
				waitTimeLeft = f(this);	
				
			case CALL(callback):
				callback(this);
				nextNode();
			
			case START_LOOP(times):
				loopsLeft.push(times);
				loopStartPos.push(pos + 1);
				nextNode();
				
			case END_LOOP:
				if (loopsLeft.length == 0) {
					throw 'End loop declared without a start at ($pos).';
				}
				
				var i = loopsLeft.length - 1;
				if (loopsLeft[i] > 0) {
					if (loopsLeft[i] == 1) {
						loopsLeft.pop();
						loopStartPos.pop();
						nextNode();
						return;
					}
					
					loopsLeft[i]--;
				}
	
				setPos(loopStartPos[i]);
				
			case JUMP(f):
				var index = f(this);
				
				if (index < 0 || index >= nodes.length) {
					nextNode();
					return;
				}
				
				setPos(index);
				
			case SET(target, ease):
				if (target != null) this.target = target;
				if (ease != null) this.ease = ease;
				
				nextNode();
				
		}
	}
	
}

enum TweenNode {
	
	TWEEN(task:TweenTask);
	BACKWARD_TWEEN(task:TweenTask);
	WAIT(duration:Int);
	WAIT_EX(f:TweenTimeline->Int);
	CALL(callback:TweenTimeline->Void);
	START_LOOP(times:UInt);
	END_LOOP();
	JUMP(f:TweenTimeline-> Int);
	SET(target:Dynamic, ease:EaseFunction);
	
}

@:allow(kala.components.tween.TweenTimeline)
class TweenTask {
	
	public static var pool(default, never) = new Pool<TweenTask>(create);
	
	public static inline function get():TweenTask {
		return pool.get();
	}
	
	static function create():TweenTask {
		return new TweenTask();
	}
	
	//
	
	public var target(default, null):Dynamic;
	public var vars(default, null):Dynamic;
	
	public var duration(default, null):UInt;
	public var elapsed(default, null):UInt;
	public var percent(default, null):FastFloat;
	
	public var ease(default, null):EaseFunction;
	
	public var onUpdateCB:TweenTask->Void;
	
	private var _varNames:Array<String>;
	private var _varStartValues:Array<FastFloat>;
	private var _varRanges:Array<FastFloat>;
	
	private var _orgnTarget:Dynamic;
	private var _orgnEase:EaseFunction;
	private var _orgnUpdateCB:TweenTask->Void;
	
	public function new() {
		
	}
	
	function init(
		target:Dynamic, vars:Dynamic, duration:UInt, ease:EaseFunction, onUpdateCB:TweenTask->Void
	):Void {
		this.vars = vars;
		this.duration = duration;
		
		_orgnTarget = target;
		_orgnEase = ease;
		_orgnUpdateCB = onUpdateCB;
	}
	
	function initVars(backward:Bool):Void {
		percent = 0;
		
		if (!Reflect.isObject(vars)) {
			throw "Tweening destination values are not contained in a valid object.";
		}
		
		_varNames = new Array<String>();
		_varStartValues = new Array<FastFloat>();
		_varRanges = new Array<FastFloat>();
		
		var startValue:Dynamic;
		var destValue:Dynamic;
		
		for (name in Reflect.fields(vars)) {
			startValue = Reflect.getProperty(target, name);
			
			if (startValue == null) {
				throw 'Property / member varible "$name" does not exist in target "$target" or exists but its value is currently set to null.';
			}
			
			if (Math.isNaN(startValue)) {
				throw 'Start value of "$name" is not a valid number.';
			}
			
			destValue = Reflect.getProperty(vars, name);
			
			if (Math.isNaN(destValue)) {
				throw 'Destination value of "$name" is not a valid number.';
			}
			
			_varNames.push(name);
			
			if (backward) {
				_varStartValues.push(destValue);
				_varRanges.push(startValue - destValue);
			} else {
				_varStartValues.push(startValue);
				_varRanges.push(destValue - startValue);
			}
		}
		
		elapsed = 0;
	}
	
	function update(delta:Int):Bool {
		if (Kala.deltaTiming) {
			elapsed += delta;
		} else {
			elapsed++;
		}
		
		percent = elapsed /  duration;
		
		for (i in 0..._varNames.length) {
			Reflect.setProperty(
				target, _varNames[i], 
				_varStartValues[i] + _varRanges[i] * (ease == null ? percent : ease(percent))
			);
		}
		
		if (onUpdateCB != null) onUpdateCB(this);

		if (elapsed >= duration) return true;
		
		return false;
	}
	
	function copyBackward(task:TweenTask):Void {
		target = task.target;
		vars = task.vars;
		
		if (duration == 0) duration = task.duration;
		
		ease = _orgnEase == null ? task.ease : _orgnEase;
		onUpdateCB = _orgnUpdateCB == null ? task.onUpdateCB : _orgnUpdateCB;
		
		_varNames = new Array<String>();
		_varStartValues = new Array<FastFloat>();
		_varRanges = new Array<FastFloat>();
		
		for (i in 0...task._varNames.length) {
			_varNames.push(task._varNames[i]);
			_varStartValues.push(task._varStartValues[i] + task._varRanges[i]);
			_varRanges.push(-task._varRanges[i]);
		}

		elapsed = 0;
	}
	
}