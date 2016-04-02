package kala.objects;

import kala.DrawingData;
import kala.EventHandle;
import kala.components.Component.IComponent;
import kala.math.helpers.AngleHelper;
import kala.math.helpers.FastMatrix3Helper;
import kala.objects.group.Group;
import kala.math.Color;
import kala.math.Rect;
import kala.math.Rotation;
import kala.math.Vec2T;
import kala.math.Vec2;
import kala.pool.ObjectPool;
import kha.Canvas;
import kha.FastFloat;
import kha.graphics2.ImageScaleQuality;
import kha.math.FastMatrix3;

@:allow(kala.components.Component)
class Object extends EventHandle {
	
	public var alive:Bool;
	public var active:Bool;
	public var visible:Bool;
	
	//
	
	/**
	 * Shortcut to access position.x
	 */
	public var x(get, set):FastFloat;
	
	/**
	 * Shortcut to access position.y
	 */
	public var y(get, set):FastFloat;
	
	public var position:Vec2T = new Vec2T();
	
	public var flipX:Bool;
	public var flipY:Bool;
	
	public var scale:Vec2T = new Vec2T();
	public var skew:Vec2T = new Vec2T();
	public var rotation:Rotation = new Rotation();
	
	public var color:Color = new Color();
	public var opacity:FastFloat;
	
	public var antialiasing:Bool;
	
	//
	var _width:FastFloat;
	public var width(get, set):FastFloat;
	var _height:FastFloat;
	public var height(get, set):FastFloat;
	
	public var tWidth(get, never):FastFloat;
	public var tHeight(get, never):FastFloat;
	
	//
	
	public var dirty:Bool;
	
	//
	
	public var group(get, never):BasicGroup;
	public var pool:ObjectPool<Object>;
	
	//
	
	public var onDestroy:CallbackHandle<Object->Bool->Void>;
	public var onReset:CallbackHandle<Object->Bool->Void>;
	
	public var onPreUpdate:CallbackHandle<Object->FastFloat->Void>;
	public var onPostUpdate:CallbackHandle<Object->FastFloat->Void>;
	
	public var onPreDraw:CallbackHandle<Object->DrawingData->Canvas->Void>;
	public var onPostDraw:CallbackHandle<Object->DrawingData->Canvas->Void>;
	
	public var onFirstFrame:CallbackHandle<Object->Void>;
					
	private var _firstFrameExecuted:Bool;
	
	//
	
	private var _crGroup:Object;
	private var _groups:Array<Object> = [];
	
	private var _components:Array<IComponent> = new Array<IComponent>();
	
	//
	
	private var _cachedDrawingMatrix:FastMatrix3;
	
	public function new() {
		super();
		
		onDestroy = addCBHandle(new CallbackHandle<Object->Bool->Void>());
		onReset = addCBHandle(new CallbackHandle<Object->Bool->Void>());
		
		onPreUpdate = addCBHandle(new CallbackHandle<Object->FastFloat->Void>());
		onPostUpdate = addCBHandle(new CallbackHandle<Object->FastFloat->Void>());
		
		onPreDraw = addCBHandle(new CallbackHandle<Object->DrawingData->Canvas->Void>());
		onPostDraw = addCBHandle(new CallbackHandle<Object->DrawingData->Canvas->Void>());
		
		onFirstFrame = addCBHandle(new CallbackHandle<Object->Void>());
		
		reset();
	}
	
	override public function clearCBHandles():Void {
		removeComponents();
		super.clearCBHandles();
	}
	
	/**
	 * Reset properties to their values when this object was created. 
	 * This won't remove the object from its groups.
	 * This won't remove the object components.
	 * 
	 * @param	componentsReset		If true will also reset components. 
	 */
	public function reset(componentsReset:Bool = false):Void {
		alive = true;
		active = true;
		visible = true;

		position.set(0, 0, 0, 0);

		scale.set(1, 1, 0, 0);
		skew.set(0, 0, 0, 0);
		rotation.set(0, 0, 0);
		
		color.set(1, 0xffffff);
		opacity = 1;
		
		antialiasing = false;
		
		dirty = false;

		_firstFrameExecuted = false;
		
		for (callback in onReset) callback.cbFunction(this, componentsReset);

		if (componentsReset) resetComponents();
	}
	
	public function destroy(componentsDestroy:Bool = true):Void {
		position = null;

		scale = null;
		skew = null;
		rotation = null;
		
		color = null;
		
		//
		
		for (callback in onDestroy) callback.cbFunction(this, componentsDestroy);

		//
		
		if (componentsDestroy) destroyComponents();
		_components = null;
		
		destroyCBHandles();
		
		onDestroy = null;
		onReset = null;
		onPreUpdate = onPostUpdate = null;
		onPreDraw = onPostDraw = null;
		onFirstFrame = null;
		
		//
		
		removefromGroups();
		_groups = null;
	}
	
	public function deepReset(componentsDeepReset:Bool = true):Void {
		reset(false);
		if (componentsDeepReset) deepResetComponents();
		clearCBHandles();
		removefromGroups();
	}
	
	public function update(delta:FastFloat):Void {

	}
	
	public function draw(data:DrawingData, canvas:Canvas):Void {

	}
	
	public function refresh():Void {
		
	}
	
	public function isVisible():Bool {
		//alive && visible && tWidth != 0 && tHeight != 0 && opacity > 0
		return visible && scale.x != 0 && scale.y != 0 && opacity > 0;
	}
	
	public inline function setOrigin(x:FastFloat, y:FastFloat):Object {
		position.setOrigin(x, y);
		scale.setOrigin(x, y);
		skew.setOrigin(x, y);
		rotation.setPivot(x, y);
		
		return this;
	}
	
	public inline function setTransformationOrigin(x:FastFloat, y:FastFloat):Object {
		scale.setOrigin(x, y);
		skew.setOrigin(x, y);
		rotation.setPivot(x, y);
		
		return this;
	}
	
	public inline function centerOrigin(centerX:Bool = true, centerY:Bool = true):Object {
		if (centerX) {
			position.ox = scale.ox = skew.ox = rotation.px = width / 2;
		}
		
		if (centerY) {
			position.oy = scale.oy = skew.oy = rotation.py = height / 2;
		}
		
		return this;
	}
	
	public inline function centerTransformation(centerX:Bool = true, centerY:Bool = true):Object {
		if (centerX) {
			scale.ox = skew.ox = rotation.px = width / 2;
		}
		
		if (centerY) {
			scale.oy = skew.oy = rotation.py = height / 2;
		}
		
		return this;
	}

	public inline function getMatrix():FastMatrix3 {
		return FastMatrix3Helper.getTransformMatrix(position, scale, skew, rotation, flipX, flipY);
	}
	
	public inline function getDrawingMatrix():FastMatrix3 {
		if (_crGroup == null) return getMatrix();
		return _crGroup.getDrawingMatrix().multmat(getMatrix());
	}
	
	public inline function put():Object {	
		pool.put(this);
		return this;
	}
	
	public inline function getGroups():Array<Group<Object>> {
		var array = new Array<Group<Object>>();
		for (group in _groups) array.push(cast group);
		return array;
	}
	
	public inline function removefromGroups(splice:Bool = false):Void {
		for (group in getGroups()) group.remove(this, splice);
	}
	
	public inline function getComponents():Array<IComponent> {
		return _components.copy();
	}
	
	public inline function removeComponents():Void {
		for (component in _components) component.remove();
	}
	
	public inline function destroyComponents():Void {
		while (_components.length > 0) {
			_components.pop().destroy();
		}
	}
	
	public inline function resetComponents():Void {
		for (component in _components) component.reset();
	}
	
	public inline function deepResetComponents():Void {
		for (component in _components) component.deepReset();
	}
	
	inline function execFirstFrame():Void {
		if (!_firstFrameExecuted) {
			for (callback in onFirstFrame) callback.cbFunction(this);
			_firstFrameExecuted = true;
		}
	}
	
	inline function callUpdate(?caller:Object, delta:FastFloat):Void {
		_crGroup = caller;
		
		execFirstFrame();
		for (callback in onPreUpdate) callback.cbFunction(this, delta);
		update(delta);
		for (callback in onPostUpdate) callback.cbFunction(this, delta);
	}
	
	inline function callDraw(?caller:Object, data:DrawingData, canvas:Canvas):Void {
		_crGroup = caller;
		
		execFirstFrame();
		for (callback in onPreDraw) callback.cbFunction(this, data, canvas);
		draw(data, canvas);
		for (callback in onPostDraw) callback.cbFunction(this, data, canvas);
	}
	
	function applyDrawingData(data:DrawingData, canvas:Canvas):Void {
		var g2 = canvas.g2;
		
		if (this.antialiasing || data.antialiasing) {
			if (g2.imageScaleQuality != ImageScaleQuality.High) {
				g2.imageScaleQuality = ImageScaleQuality.High;
			}
		} else if (g2.imageScaleQuality != ImageScaleQuality.Low) {
			g2.imageScaleQuality = ImageScaleQuality.Low;
		}
	
		if (data.transformation == null) g2.transformation = _cachedDrawingMatrix = getMatrix();
		else g2.transformation = _cachedDrawingMatrix = data.transformation.multmat(getMatrix());
		
		if (data.color == null) {
			g2.color = this.color.argb();
		} else {
			g2.color = new Color().setOverlay(Color.blendColors(this.color, data.color, data.colorBlendMode)).argb();
		}
		
		g2.opacity = this.opacity * data.opacity;
	}
		
	function get_width():FastFloat {
		return _width;
	}
	
	function set_width(value:FastFloat):FastFloat {
		return _width = value;
	}
	
	function get_height():FastFloat {
		return _height;
	}
	
	function set_height(value:FastFloat):FastFloat {
		return _height = value;
	}
	
	function get_tWidth():FastFloat {
		return Math.abs(width * scale.x) + Math.abs(height * scale.y * Math.tan(skew.x * AngleHelper.CONST_RAD));
	}
	
	function get_tHeight():FastFloat {
		return Math.abs(height * scale.y) + Math.abs(width  * scale.x  * Math.tan(skew.y * AngleHelper.CONST_RAD));
	}
	
	function get_group():BasicGroup {
		return cast _crGroup;
	}
	
	function get_x():FastFloat {
		return position.x;
	}
	
	function set_x(value:FastFloat):FastFloat {
		return position.x = value;
	}
	
	function get_y():FastFloat {
		return position.y;
	}
	
	function set_y(value:FastFloat):FastFloat {
		return position.y = value;
	}

}