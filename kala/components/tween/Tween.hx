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
		cancel();
	}
	
	override public function destroy():Void {
		super.destroy();
		while (_tweens.length > 0) _tweens.pop().cancel();
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
	
	public inline function cancel():Void {
		while (_tweens.length > 0) _tweens.pop().cancel();
	}
	
	public inline function get(?target:Dynamic, ?ease:EaseFunction, ?onTweenUpdateCB:TweenTask->Void):TweenTimeline {
		if (target == null) target = object;
		if (ease == null) ease = Ease.linear;
		
		return TweenTimeline.get().init(this, null, target, ease, onTweenUpdateCB);
	}
	
	public inline function tween(
		target:Dynamic, vars:Dynamic, duration:UInt, ?ease:EaseFunction,
		?onFinishCB:TweenTimeline->Void, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		var timeline = TweenTimeline.get().init(this, null, null, null, null).tween(target, vars, duration, ease, onUpdateCB);
		if (onFinishCB != null) timeline.call(onFinishCB);
		timeline.start();
		
		return timeline;
	}
	
	public inline function tweenPos(
		target:Dynamic, x:FastFloat, y:FastFloat, duration:UInt, ?ease:EaseFunction,
		?onFinishCB:TweenTimeline->Void, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		var timeline = TweenTimeline.get().init(this, null, null, null, null).tween(target, { x: x, y: y }, duration, ease, onUpdateCB);
		if (onFinishCB != null) timeline.call(onFinishCB);
		timeline.start();
		
		return timeline;
	}
	
	public inline function tweenX(
		target:Dynamic, x:FastFloat, duration:UInt, ?ease:EaseFunction,
		?onFinishCB:TweenTimeline->Void, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		var timeline = TweenTimeline.get().init(this, null, null, null, null).tween(target, { x: x }, duration, ease, onUpdateCB);
		if (onFinishCB != null) timeline.call(onFinishCB);
		timeline.start();
		
		return timeline;
	}
	
	public inline function tweenY(
		target:Dynamic, y:FastFloat, duration:UInt, ?ease:EaseFunction,
		?onFinishCB:TweenTimeline->Void, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		var timeline = TweenTimeline.get().init(this, null, null, null, null).tween(target, { y: y }, duration, ease, onUpdateCB);
		if (onFinishCB != null) timeline.call(onFinishCB);
		timeline.start();
		
		return timeline;
	}
	
	function update(obj:Object, elapsed:FastFloat):Void {
		for (tween in _tweens) {
			if (!tween.paused) tween.update(elapsed);
		}
	}
	
}

@:allow(kala.components.tween.Tween)
class TweenTimeline {
	
	public static var pool(default, never):Pool<TweenTimeline> = new Pool<TweenTimeline>(create);
	
	public static inline function get():TweenTimeline {
		return pool.get();
	}
	
	static function create():TweenTimeline {
		return new TweenTimeline();
	}
	
	//
	
	public var manager(default, null):Tween;
	
	public var parent(default, null):TweenTimeline;
	public var children(default, null):Array<TweenTimeline> = new Array<TweenTimeline>();
	
	public var nodes:Array<TweenNode> = new Array<TweenNode>();
	
	public var pos(default, null):Int;
	public var node(default, null):TweenNode;
	
	public var loopsLeft(default, null):Int;
	
	public var waitTimeLeft(default, null):FastFloat;
	
	public var target(get, set):Dynamic;
	public var ease(get, set):EaseFunction;
	public var tweenUpdateCB(get, set):TweenTask->Void;
	var _target:Dynamic;
	var _ease:EaseFunction;
	var _tweenUpdateCB:TweenTask->Void;
	
	public var paused(default, null):Bool;
	
	public var batching(default, null):Bool;
	
	private var _batchCalling:Bool;
	
	private var _prvTweenTasks:Array<TweenTask> = new Array<TweenTask>();
	private var _crTweenTasks:Array<TweenTask> = new Array<TweenTask>();

	
	public function new() {
	
	}
	
	public inline function start():Void {
		manager._tweens.push(this);
		nextNode();
	}
	
	public inline function tween(
		target:Dynamic, vars:Dynamic, duration:UInt,
		?ease:EaseFunction, ?backwardEase:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		var task = TweenTask.get();
		task.init(target, vars, duration, ease, onUpdateCB);
		task.backwardEase = backwardEase;
		nodes.push(TWEEN(task));
		return this;
	}
	
	public inline function tweenPos(
		target:Object, x:FastFloat, y:FastFloat, duration:UInt,
		?ease:EaseFunction, ?backwardEase:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		tween(target, { x: x, y: y }, duration, ease, backwardEase, onUpdateCB);
		return this;
	}
	
	public inline function tweenX(
		target:Dynamic, x:FastFloat, duration:UInt,
		?ease:EaseFunction, ?backwardEase:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		tween(target, { x: x }, duration, ease, backwardEase, onUpdateCB);
		return this;
	}
	
	public inline function tweenY(
		target:Object, y:FastFloat, duration:UInt,
		?ease:EaseFunction, ?backwardEase:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		tween(target, { y: y }, duration, ease, backwardEase, onUpdateCB);
		return this;
	}
	
	public inline function tweenAngle(
		target:Object, ?fromAngle:FastFloat, toAngle:FastFloat, duration:UInt,
		?ease:EaseFunction, ?backwardEase:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		if (target == null) target = this.target;
		if (fromAngle != null) target.rotation.angle = fromAngle;
		tween(target.rotation, { angle: toAngle }, duration, ease, backwardEase, onUpdateCB);
		return this;
	}
	
	public inline function tweenOpacity(
		target:Object, opacity:FastFloat, duration:UInt,
		?ease:EaseFunction, ?backwardEase:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		tween(target, { opacity: opacity }, duration, ease, backwardEase, onUpdateCB);
		return this;
	}
	
	public inline function tweenBack(?duration:UInt = 0, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void):TweenTimeline {
		nodes.push(BACKWARD_TWEEN(duration, ease, onUpdateCB));
		return this;
	}
	
	/**
	 * If duration is lesser or equal to 0, this timeline will be paused on this node until resume() is called.
	 */
	public inline function wait(duration:Int):TweenTimeline {
		nodes.push(WAIT(duration));
		return this;
	}
	
	public inline function waitEx(f:TweenTimeline->Int):TweenTimeline {
		nodes.push(WAIT_EX(f));
		return this;
	}
	
	public inline function call(callback:TweenTimeline->Void):TweenTimeline {
		nodes.push(CALL(callback));
		return this;
	}
	
	public inline function startBatch(times:UInt = 0):TweenTimeline {
		nodes.push(START_BATCH);
		return this;
	}
	
	public inline function endBatch():TweenTimeline {
		nodes.push(END_BATCH);
		return this;
	}
	
	public inline function startLoop(times:UInt = 0):TweenTimeline {
		var timeline = TweenTimeline.get();
		timeline.init(manager, this, null, null, null);
		timeline.loopsLeft = times - 1;
		nodes.push(CHILD_TIMELINE(timeline));
		return timeline;
	}
	
	public inline function endLoop():TweenTimeline {
		return parent;
	}
	
	public inline function jump(f:TweenTimeline->Int):TweenTimeline {
		nodes.push(JUMP(f));
		return this;
	}
	
	public inline function set(target:Dynamic, ?ease:EaseFunction):TweenTimeline {
		nodes.push(SET(target, ease));
		return this;
	}
	
	public inline function pause():Void {
		paused = true;
	}
	
	public inline function resume():Void {
		paused = false;
	}
	
	/**
	 * Cancel this timeline and put it into the recycling pool.
	 * Do NOT do anything on this timeline after calling this method.
	 */
	public function cancel():Void {
		if (manager != null) {
			manager._tweens.remove(this);
			manager = null;
		}
		
		if (parent != null) {
			parent.children.remove(this);
			parent = null;
		}
		
		while (children.length > 0) children.pop().cancel();
		
		node = null;
		nodes.splice(0, nodes.length);
		
		_target = null;
		_ease = null;
		_tweenUpdateCB = null;
		
		_prvTweenTasks.splice(0, _prvTweenTasks.length);
		_crTweenTasks.splice(0, _crTweenTasks.length);
		
		pool.put(this);
	}
	
	function init(
		manager:Tween, parent:TweenTimeline,
		target:Dynamic, ease:EaseFunction, tweenUpdateCB:TweenTask->Void
	):TweenTimeline {
		this.parent = parent;
		this.manager = manager;
		
		_target = target;
		_ease = ease;
		_tweenUpdateCB = tweenUpdateCB;
		
		pos = -1;
		_batchCalling = false;
		
		paused = false;
		
		return this;
	}
	
	/*function destroy():Void {
		if (manager != null) {
			manager._tweens.remove(this);
			manager = null;
		}
		
		if (parent != null) {
			parent.children.remove(this);
			parent = null;
		}
		
		while (children.length > 0) children.pop().destroy();
		children = null;
		
		node = null;
		nodes = null;
		
		manager = null;
		
		_target = null;
		_ease = null;
		_tweenUpdateCB = null;
		
		_prvTweenTasks = null;
		_crTweenTasks = null;
	}*/
	
	function update(elapsed:FastFloat):Void {
		if (waitTimeLeft > 0) waitTimeLeft -= elapsed;
		
		if (waitTimeLeft <= 0 || batching) {
			for (child in children) child.update(elapsed);
			
			var i = 0;
			var task:TweenTask;
			while (i < _crTweenTasks.length) {
				task = _crTweenTasks[i];
				if (task.update(elapsed)) {
					if (!batching) _prvTweenTasks.splice(0, _prvTweenTasks.length);
					_prvTweenTasks.push(task);
					_crTweenTasks.splice(i, 1);
				} else i++;
			}
		}
		
		if (waitTimeLeft <= 0 && _crTweenTasks.length == 0 && children.length == 0) {
			batching = false;
			nextNode();
		}
	}
	
	function nextNode():Void {
		if (pos == nodes.length - 1) {
			if (loopsLeft == 0) cancel();
			else {
				loopsLeft--;
				setPos(0);
			}
			
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
				if (task.target == null) task.target = target;
				if (task.ease == null) task.ease = ease;
				if (task.onUpdateCB == null) task.onUpdateCB = tweenUpdateCB;
				task.initVars();
				_crTweenTasks.push(task);
					
			case BACKWARD_TWEEN(duration, ease, onUpdateCB):
				if (_prvTweenTasks.length == 0) {
					if (_batchCalling || children.length == 0) nextNode();
					return;
				}
				
				if (_prvTweenTasks.length > 1) batching = true;
				
				var appendedIndex = _crTweenTasks.length;
				var task:TweenTask = null;
				while (_prvTweenTasks.length > 0) {
					task = TweenTask.get();
					task.init(null, null, duration, ease, onUpdateCB);
					task.copyBackward(_prvTweenTasks.pop());
					_crTweenTasks.insert(appendedIndex, task);
				}
				
			case WAIT(duration):
				if (duration <= 0) paused = true;
				else waitTimeLeft = duration;
				
				
			case WAIT_EX(f):
				var duration = f(this);
				if (duration <= 0) paused = true;
				else waitTimeLeft = duration;
				
			case CALL(callback):
				callback(this);
				nextNode();
			
			case START_BATCH:
				batching = _batchCalling = true;
				while (_batchCalling) nextNode();
				
			case END_BATCH:
				_batchCalling = false;
				
			case CHILD_TIMELINE(child):
				children.push(child);
				if (_batchCalling) nextNode();
			
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
	
	function get_target():Dynamic {
		if (parent == null) return _target;
		return parent.target;
	}
	
	function set_target(value:Dynamic):Dynamic {
		if (parent == null) return _target = value;
		return parent.target = value;
	}
	
	function get_ease():EaseFunction {
		if (parent == null) return _ease;
		return parent.ease;
	}
	
	function set_ease(value:EaseFunction):EaseFunction {
		if (parent == null) return _ease = value;
		return parent.ease = value;
	}
	
	function get_tweenUpdateCB():TweenTask->Void {
		if (parent == null) return _tweenUpdateCB;
		return parent.tweenUpdateCB;
	}
	
	function set_tweenUpdateCB(value:TweenTask->Void):TweenTask->Void {
		if (parent == null) return _tweenUpdateCB = value;
		return parent.tweenUpdateCB = value;
	}
	
}

enum TweenNode {
	
	TWEEN(task:TweenTask);
	BACKWARD_TWEEN(duration:UInt, ease:EaseFunction, onUpdateCB:TweenTask->Void);
	WAIT(duration:Int);
	WAIT_EX(f:TweenTimeline->Int);
	CALL(callback:TweenTimeline-> Void);
	START_BATCH;
	END_BATCH;
	CHILD_TIMELINE(child:TweenTimeline);
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
	
	public var percent(default, null):FastFloat;
	public var duration(default, null):UInt;
	public var elapsed:FastFloat;
	
	public var backward(default, null):Bool;
	
	public var ease:EaseFunction;
	public var backwardEase:EaseFunction;
	
	public var onUpdateCB:TweenTask->Void;
	
	private var _varNames:Array<String>;
	private var _varStartValues:Array<FastFloat>;
	private var _varRanges:Array<FastFloat>;
	
	public function new() {
		
	}
	
	function init(
		target:Dynamic, vars:Dynamic, duration:UInt, ease:EaseFunction, onUpdateCB:TweenTask->Void
	):Void {
		this.target = target;
		this.vars = vars;
		this.duration = duration;
		this.ease = ease;
		this.onUpdateCB = onUpdateCB;
		
		backward = false;
	}
	
	function initVars():Void {
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
			

			_varStartValues.push(startValue);
			_varRanges.push(destValue - startValue);
		}
		
		elapsed = 0;
	}
	
	function copyBackward(task:TweenTask):Void {
		target = task.target;
		vars = task.vars;
		
		if (duration == 0) duration = task.duration;
		
		if (ease == null) {
			ease = task.backwardEase == null ? task.ease : task.backwardEase;
		}
		
		backwardEase = task.ease;
		
		if (onUpdateCB == null) onUpdateCB = task.onUpdateCB;
		
		_varNames = new Array<String>();
		_varStartValues = new Array<FastFloat>();
		_varRanges = new Array<FastFloat>();
		
		for (i in 0...task._varNames.length) {
			_varNames.push(task._varNames[i]);
			_varStartValues.push(task._varStartValues[i] + task._varRanges[i]);
			_varRanges.push(-task._varRanges[i]);
		}

		elapsed = 0;
		backward = true;
	}
	
	function put():Void {
		_varNames.splice(0, _varNames.length);
		_varStartValues.splice(0, _varStartValues.length);
		_varRanges.splice(0, _varRanges.length);
	
		pool.put(this);
	}
	
	function update(elapsed:FastFloat):Bool {
		this.elapsed += elapsed;
		
		percent = this.elapsed /  duration;
		
		for (i in 0..._varNames.length) {
			Reflect.setProperty(
				target, _varNames[i], 
				_varStartValues[i] + _varRanges[i] * (ease == null ? percent : ease(percent))
			);
		}
		
		if (onUpdateCB != null) onUpdateCB(this);

		if (this.elapsed >= duration) return true;
		
		return false;
	}
	
}