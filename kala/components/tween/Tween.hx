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
	
	public inline function tween(
		target:Dynamic, vars:Dynamic, duration:UInt, ?ease:EaseFunction, ?onFinishCB:TweenTimeline->Void, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		var timeline = TweenTimeline.get().init(this, null, null, null).tween(target, vars, duration, ease, onUpdateCB);
		if (onFinishCB != null) timeline.call(onFinishCB);
		timeline.start();
		return timeline;
	}
	
	function update(obj:Object, delta:Int):Void {
		for (tween in _tweens) {
			tween.update(delta);
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
	
	public var nodes:Array<TweenNode> = new Array<TweenNode>();
	
	public var pos(default, null):Int;
	public var node(default, null):TweenNode;
	
	public var parent(default, null):TweenTimeline;
	public var children(default, null):Array<TweenTimeline> = new Array<TweenTimeline>();
	
	public var loopsLeft(default, null):Int;
	
	public var waitTimeLeft(default, null):Int;
	
	public var target(get, set):Dynamic;
	public var ease(get, set):EaseFunction;
	public var tweenUpdateCB(get, set):TweenTask->Void;
	var _target:Dynamic;
	var _ease:EaseFunction;
	var _tweenUpdateCB:TweenTask->Void;
	
	private var _paralleling(default, null):Bool;
	
	private var _prvTweenTasks:Array<TweenTask> = new Array<TweenTask>();
	private var _crTweenTasks:Array<TweenTask> = new Array<TweenTask>();

	private var _orgnTarget:Dynamic;
	private var _orgnEase:EaseFunction;
	private var _orgnTweenUpdateCB:TweenTask->Void;
	
	private var _manager:Tween;
	
	public function new() {
		reset();
	}
	
	public function start(?manager:Tween):Void {
		if (manager != null) _manager = manager;
		
		if (_manager == null) throw "Needs a manager to start.";
		
		_manager._tweens.push(this);
		
		nextNode();
	}
	
	public function tween(
		target:Dynamic, vars:Dynamic, duration:UInt, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		var task = TweenTask.get();
		task.init(target, vars, duration, ease, onUpdateCB);
		nodes.push(TWEEN(task));
		
		return this;
	}
	
	public function tweenPos(
		target:Dynamic, x:FastFloat, y:FastFloat, duration:UInt, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		var task = TweenTask.get();
		task.init(target, { x: x, y: y }, duration, ease, onUpdateCB);
		nodes.push(TWEEN(task));
		
		return this;
	}
	
	public function tweenX(
		target:Dynamic, x:FastFloat, duration:UInt, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		var task = TweenTask.get();
		task.init(target, { x: x }, duration, ease, onUpdateCB);
		nodes.push(TWEEN(task));
		
		return this;
	}
	
	public function tweenY(
		target:Dynamic, y:FastFloat, duration:UInt, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		var task = TweenTask.get();
		task.init(target, { y: y }, duration, ease, onUpdateCB);
		nodes.push(TWEEN(task));
		
		return this;
	}
	
	public function tweenAngle(
		target:Object, ?fromAngle:FastFloat, toAngle:FastFloat, duration:UInt, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		if (target == null) target = this.target;
		if (fromAngle != null) target.rotation.angle = fromAngle;
		
		var task = TweenTask.get();
		task.init(target.rotation, { angle: toAngle }, duration, ease, onUpdateCB);
		nodes.push(TWEEN(task));
		
		return this;
	}
	
	public function tweenOpacity(
		target:Object, opacity:FastFloat, duration:UInt, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void
	):TweenTimeline {
		if (target == null) target = this.target;

		var task = TweenTask.get();
		task.init(target, { opacity: opacity }, duration, ease, onUpdateCB);
		nodes.push(TWEEN(task));
		
		return this;
	}
	
	public function tweenBack(?duration:UInt = 0, ?ease:EaseFunction, ?onUpdateCB:TweenTask->Void):TweenTimeline {
		nodes.push(BACKWARD_TWEEN(duration, ease, onUpdateCB));
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
	
	public function startParallel(times:UInt = 0):TweenTimeline {
		nodes.push(START_PARALLEL);
		return this;
	}
	
	public function endParallel():TweenTimeline {
		nodes.push(END_PARALLEL);
		return this;
	}
	
	public function startLoop(times:UInt = 0):TweenTimeline {
		var timeline = TweenTimeline.get();
		timeline._manager = _manager;
		timeline.parent = this;
		timeline.loopsLeft = times - 1;
		timeline.reset();
		nodes.push(CHILD_TIMELINE(timeline));
		return timeline;
	}
	
	public function endLoop():TweenTimeline {
		return parent;
	}
	
	public function jump(f:TweenTimeline->Int):TweenTimeline {
		nodes.push(JUMP(f));
		return this;
	}
	
	public function set(target:Dynamic, ease:EaseFunction):TweenTimeline {
		nodes.push(SET(target, ease));
		return this;
	}
	
	function init(
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
	
	function reset():Void {
		while (children.length > 0) children.pop().put();
		
		nodes.splice(0, nodes.length);
		
		_paralleling = false;
		
		pos = -1;
		node = null;
		
		_target = parent == null ? _orgnTarget : parent._orgnTarget;
		_ease = parent == null ? _orgnEase : parent._orgnEase;
		_tweenUpdateCB = parent == null ? _orgnTweenUpdateCB : parent._orgnTweenUpdateCB;
	}
	
	function destroy():Void {
		while (children.length > 0) children.pop().destroy();
		
		cancel();
		
		parent = null;
		
		node = null;
		nodes = null;
		
		_manager = null;
		
		_orgnTarget = null;
		_orgnEase = null;
		_orgnTweenUpdateCB = null;
		
		_target = null;
		_ease = null;
		_tweenUpdateCB = null;
		
		_prvTweenTasks = null;
		_crTweenTasks = null;
	}
	
	function put():Void {
		while (children.length > 0) children.pop().put();
		
		cancel();
		
		parent = null;
		
		node = null;
		nodes.splice(0, nodes.length);
		
		_manager = null;
		
		_orgnTarget = null;
		_orgnEase = null;
		_orgnTweenUpdateCB = null;
		
		_target = null;
		_ease = null;
		_tweenUpdateCB = null;
		
		_prvTweenTasks.splice(0, _prvTweenTasks.length);
		_crTweenTasks.splice(0, _crTweenTasks.length);
		
		pool.put(this);
	}
	
	function cancel():Void {
		if (_manager != null) {
			_manager._tweens.remove(this);
			_manager = null;
		}
		
		if (parent != null) {
			parent.children.remove(this);
			parent = null;
		}
	}
	
	function update(delta:Int):Void {
		for (child in children) child.update(delta);

		if (waitTimeLeft > 0) {
			if (Kala.deltaTiming) {
				waitTimeLeft -= delta;
			} else {
				waitTimeLeft--;
			}
			
			if (waitTimeLeft <= 0) nextNode();
			
		} else {
			var i = 0;
			var task:TweenTask;
			while (i < _crTweenTasks.length) {
				task = _crTweenTasks[i];
				if (task.update(delta)) {
					if (!task.paralleling) _prvTweenTasks.splice(0, _prvTweenTasks.length);
					_prvTweenTasks.push(task);
					_crTweenTasks.splice(i, 1);
				} else i++;
			}
			
			nextNode();
		}
	}
	
	function nextNode():Void {
		if (!_paralleling && (_crTweenTasks.length > 0 || children.length > 0)) return;
		
		if (pos == nodes.length - 1) {
			if (loopsLeft == 0) put();
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
				task.target = task._orgnTarget == null ? target : task._orgnTarget;
				task.ease = task._orgnEase == null ? ease : task._orgnEase;
				task.onUpdateCB = task._orgnUpdateCB == null ? tweenUpdateCB : task._orgnUpdateCB;
				task.paralleling = _paralleling;
				task.initVars(false);
				_crTweenTasks.push(task);
					
			case BACKWARD_TWEEN(duration, ease, onUpdateCB):
				if (_prvTweenTasks.length == 0) {
					nextNode();
					return;
				}
				
				var appendedIndex = _crTweenTasks.length;
				var task:TweenTask;
				while (_prvTweenTasks.length > 0) {
					task = TweenTask.get();
					task.init(null, null, duration, ease, onUpdateCB);
					task.paralleling = _paralleling;
					task.copyBackward(_prvTweenTasks.pop());
					_crTweenTasks.insert(appendedIndex, task);
				}
				
			case WAIT(duration):
				waitTimeLeft = duration;
				
			case WAIT_EX(f):
				waitTimeLeft = f(this);	
				
			case CALL(callback):
				callback(this);
				nextNode();
			
			case START_PARALLEL:
				_paralleling = true;
				while (_paralleling) nextNode();
				
			case END_PARALLEL:
				_paralleling = false;
				
			case CHILD_TIMELINE(child):
				children.push(child);
				nextNode();
			
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
	START_PARALLEL;
	END_PARALLEL;
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
	
	public var duration(default, null):UInt;
	public var elapsed(default, null):UInt;
	public var percent(default, null):FastFloat;
	
	public var ease(default, null):EaseFunction;
	
	public var paralleling(default, null):Bool;
	
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
		
		paralleling = false;
		
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
	
	function put():Void {
		_varNames.splice(0, _varNames.length);
		_varStartValues.splice(0, _varStartValues.length);
		_varRanges.splice(0, _varRanges.length);
	
		pool.put(this);
	}
	
}