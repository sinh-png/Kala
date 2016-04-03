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
		
		object.onPreUpdate.addComponentCB(this, update);
		
		return this;
	}
	
	override public function remove():Void {
		if (object != null) {
			object.onPreUpdate.removeComponentCB(this, update);
		}
		
		super.remove();
	}
	
	public function get(?target:Dynamic, duration:UInt, ?ease:EaseFunction, ?onTweenUpdateCB:TweenTask->Void):TweenTimeline {
		if (target == null) target = object;
		if (ease == null) ease = Ease.none;
		if (duration == 0) throw 'Tweening duration has to be greater than 0.';
		
		return TweenTimeline.get().init(this, target, duration, ease, onTweenUpdateCB);
	}
	
	function update(obj:Object, delta:FastFloat):Void {
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
	
	public var loopsLeft(default, null):UInt;
	public var loopStartPos(default, null):UInt;
	
	public var target(default, null):Dynamic;
	public var duration(default, null):UInt;
	public var ease(default, null):EaseFunction;
	public var tweenUpdateCB(default, null):TweenTask->Void;
	
	private var _originTarget:Dynamic;
	private var _originDuration:UInt;
	private var _originEase:EaseFunction;
	private var _originTweenUpdateCB:TweenTask->Void;
	
	private var _manager:Tween;
	
	public function new() {
		reset();
	}
	
	public function init(
		manager:Tween, 
		target:Dynamic, duration:UInt, ease:EaseFunction, tweenUpdateCB:TweenTask->Void
	):TweenTimeline {
		_manager = manager;
		
		_originTarget = target;
		_originDuration = duration;
		_originEase = ease;
		_originTweenUpdateCB = tweenUpdateCB;
		
		reset();
		
		return this;
	}
	
	public function reset():Void {
		while (nodes.length > 0) nodes.pop();
		
		pos = -1;
		node = null;
		
		loopsLeft = 0;
		loopStartPos = 0;
		
		target = _originTarget;
		duration = _originDuration;
		ease = _originEase;
		tweenUpdateCB = _originTweenUpdateCB;
	}
	
	public function put():Void {
		_manager = null;
		pool.put(this);
	}
	
	public function start(?manager:Tween):Void {
		if (manager != null) _manager = manager;
		_manager._tweens.push(this);
		nextNode();
	}
	
	public function stop():Void {
		_manager._tweens.remove(this);
	}

	public function tween(
		vars:Dynamic, ?duration:UInt = 0, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void, ?target:Dynamic
	):TweenTimeline {
		var task = TweenTask.get();
		task.init(target, vars, duration, ease, onUpdateCB, false);
		nodes.push(TWEEN(task));
		return this;
	}
	
	public function wait(duration:UInt):TweenTimeline {
		nodes.push(WAIT(duration));
		return this;
	}
	
	function update(delta:FastFloat):Void {
		switch(node) {
			
			case TWEEN(task):
				if (task.update(delta)) {
					nextNode();
					return;
				}
				
			default:
		}
	}
	
	function nextNode():Void {
		if (pos == nodes.length - 1) {
			stop();
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
				task.elapsed = 0;
				
				if (task.target == null) task.target = target;
				if (task.duration == 0) task.duration = duration;
				if (task.ease == null) task.ease = ease;
				if (task.onUpdateCB == null) task.onUpdateCB = tweenUpdateCB;
				
				task.initVars();
				
			default: 
				
		}
	}
	
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
	
	public var backward(default, null):Bool;
	
	private var _varNames:Array<String>;
	private var _varStartValues:Array<FastFloat>;
	private var _varRanges:Array<FastFloat>;
	
	public function new() {
		
	}
	
	// Putting parameters to this function breaks code completion of below functions if they don't have acess modifier.
	function init(
		target:Dynamic, vars:Dynamic, duration:UInt, ease:EaseFunction, onUpdateCB:TweenTask->Void, backward:Bool
	):Void {
		this.target = target;
		this.vars = vars;
		this.duration = duration;
		this.ease = ease;
		this.onUpdateCB = onUpdateCB;
		this.backward = backward;
	}
	
	function initVars() {
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
		
		return this;
	}
	
	// Without "private", code completion will break.
	private function update(delta:FastFloat):Bool {
		if (Kala.timingUnit == TimeUnit.FRAME) {
			elapsed++;
		} else {
			elapsed += Std.int(delta * 1000);
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
	
}

enum TweenNode {
	
	TWEEN(task:TweenTask);
	WAIT(duration:UInt);
	CALL(callback:Void->Void);
	START_LOOP(times:UInt);
	END_LOOP();
	
}