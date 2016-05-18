package kala.objects;

import kala.DrawingData;
import kala.EventHandle;
import kala.components.Component.IComponent;
import kala.graphics.Shader;
import kala.math.helpers.FastMatrix3Helper;
import kala.math.Angle;
import kala.math.color.Color;
import kala.math.Rect;
import kala.math.Rotation;
import kala.math.Vec2T;
import kala.math.Vec2;
import kala.pool.ObjectPool;
import kala.objects.group.Group;
import kha.Canvas;
import kha.FastFloat;
import kha.graphics2.ImageScaleQuality;
import kha.Image;
import kha.math.FastMatrix3;

interface IObject {
	
	public var alive:Bool;
	public var active:Bool;
	public var visible:Bool;
	
	//
	
	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;
	
	public var position:Vec2T;
	
	public var flipX:Bool;
	public var flipY:Bool;
	
	public var scale:Vec2T;
	public var skew:Vec2T;
	public var rotation:Rotation;
	
	public var color:Color;
	public var opacity:FastFloat;
	
	public var antialiasing:Bool;
	
	//
	
	private var _width:FastFloat;
	public var width(get, set):FastFloat;
	private var _height:FastFloat;
	public var height(get, set):FastFloat;
	
	public var tWidth(get, never):FastFloat;
	public var tHeight(get, never):FastFloat;
	
	//
	
	public var buffer(default, null):Image;
	public var bufferOriginX(default, null):FastFloat;
	public var bufferOriginY(default, null):FastFloat;
	
	//
	
	public var group(get, never):GenericGroup;
	public var pool:ObjectPool;
	
	//
	
	public var onDestroy:CallbackHandle<Object->Bool->Void>;
	public var onReset:CallbackHandle<Object->Bool->Void>;
	
	public var onPreUpdate:CallbackHandle<Object->Int->Bool>;
	public var onPostUpdate:CallbackHandle<Object->Int->Void>;
	
	public var onPreDraw:CallbackHandle<Object->DrawingData->Canvas->Bool>;
	public var onPostDraw:CallbackHandle<Object->DrawingData->Canvas->Void>;
	
	public var onFirstFrame:CallbackHandle<Object->Void>;
		
	//

	private var _firstFrameExecuted:Bool;
	
	private var _crGroup:Object;
	private var _groups:Array<Object>;
	
	private var _components:Array<IComponent>;
	
	//
	
	private var _texture:Image;
	private var _shaderSize:UInt;

	private var _shaders:Array<Shader>;
	
	//
	
	private var _cachedDrawingMatrix:FastMatrix3;
	
	//
	
	public function reset(componentsReset:Bool = false):Void;
	public function destroy(componentsDestroy:Bool = true):Void;
	public function deepReset(componentsDeepReset:Bool = true):Void;
	public function update(delta:Int):Void;
	public function draw(data:DrawingData, canvas:Canvas):Void;
	public function drawBuffer(data:DrawingData, canvas:Canvas):Void;
	public function isVisible():Bool;
	public function addShader(shader:Shader):Void;
	public function removeShader(shader:Shader):Shader;
	public function getDrawingMatrix():FastMatrix3;
	
}


@:allow(kala.Kala)
@:allow(kala.components.Component)
@:access(kala.objects.group.IGroup)
@:access(kala.math.color.Color)
class Object extends EventHandle implements IObject {
	
	public var alive:Bool;
	public var active:Bool;
	public var visible:Bool;
	
	//
	
	/**
	 * Shortcut to position.x
	 */
	public var x(get, set):FastFloat;
	/**
	 * Shortcut to position.y
	 */
	public var y(get, set):FastFloat;
	
	public var position:Vec2T = new Vec2T();
	
	/**
	 * Flip scale.x
	 */
	public var flipX:Bool;
	/**
	 * Flip scale.y
	 */
	public var flipY:Bool;
	
	public var scale:Vec2T = new Vec2T();
	public var skew:Vec2T = new Vec2T();
	public var rotation:Rotation = new Rotation();
	
	public var color:Color;
	public var opacity:FastFloat;
	
	public var antialiasing:Bool;
	
	//
	
	/**
	 * The original width of this object.
	 */
	public var width(get, set):FastFloat;
	var _width:FastFloat;
	/**
	 * The original height of this object.
	 */
	public var height(get, set):FastFloat;
	var _height:FastFloat;
	
	/**
	 * The width of this object taking scaling and skewing into account.
	 */
	public var tWidth(get, never):FastFloat;
	/**
	 * The height of this object taking scaling and skewing into account.
	 */
	public var tHeight(get, never):FastFloat;
	
	//
	
	public var buffer(default, null):Image;
	public var bufferOriginX(default, null):FastFloat;
	public var bufferOriginY(default, null):FastFloat;
	
	//
	
	public var group(get, never):GenericGroup;
	public var pool:ObjectPool;
	
	//
	
	public var onDestroy:CallbackHandle<Object->Bool->Void>;
	public var onReset:CallbackHandle<Object->Bool->Void>;
	
	public var onPreUpdate:CallbackHandle<Object->Int->Bool>;
	public var onPostUpdate:CallbackHandle<Object->Int->Void>;
	
	public var onPreDraw:CallbackHandle<Object->DrawingData->Canvas->Bool>;
	public var onPostDraw:CallbackHandle<Object->DrawingData->Canvas->Void>;
	
	public var onFirstFrame:CallbackHandle<Object->Void>;
		
	//

	private var firstFrameExecuted:Bool;
	
	private var _crGroup:Object;
	private var _groups:Array<Object> = [];
	
	private var _components:Array<IComponent> = new Array<IComponent>();
	
	//
	
	private var _texture:Image;
	private var _shaderSize:UInt;

	private var _shaders:Array<Shader> = new Array<Shader>();
	
	//
	
	private var _cachedDrawingMatrix:FastMatrix3;

	public function new() {
		super();
		
		onDestroy = addCBHandle(new CallbackHandle<Object->Bool->Void>());
		onReset = addCBHandle(new CallbackHandle<Object->Bool->Void>());
		
		onPreUpdate = addCBHandle(new CallbackHandle<Object->Int->Bool>());
		onPostUpdate = addCBHandle(new CallbackHandle<Object->Int->Void>());
		
		onPreDraw = addCBHandle(new CallbackHandle<Object->DrawingData->Canvas->Bool>());
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
	 * This won't remove added callbacks and components.
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
		
		color = Color.WHITE;
		
		opacity = 1;
		
		antialiasing = false;
	
		firstFrameExecuted = false;
		
		unloadGraphics();
		bufferOriginX = bufferOriginY = 0;
		_shaders.splice(0, _shaders.length);
		
		for (callback in onReset) callback.cbFunction(this, componentsReset);

		if (componentsReset) resetComponents();
	}
	
	public function destroy(destroyComponents:Bool = true):Void {
		position = null;

		scale = null;
		skew = null;
		rotation = null;
		
		//
		
		unloadGraphics();
		_shaders = null;
		
		//
		
		for (callback in onDestroy) callback.cbFunction(this, destroyComponents);

		//
		
		if (destroyComponents) this.destroyComponents();
		_components = null;
		
		destroyCBHandles();
		
		onDestroy = null;
		onReset = null;
		onPreUpdate = null;
		onPostUpdate = null;
		onPreDraw = null;
		onPostDraw = null;
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
	
	public function update(delta:Int):Void {

	}
	
	public function draw(data:DrawingData, canvas:Canvas):Void {

	}
	
	public function drawBuffer(data:DrawingData, canvas:Canvas):Void {
		var offsetX = (buffer.width - width) / 2;
		var offsetY = (buffer.height - height) / 2;
		
		position.moveOrigin(offsetX, offsetY);
		scale.moveOrigin(offsetX, offsetY);
		skew.moveOrigin(offsetX, offsetY);
		rotation.movePivot(offsetX, offsetY);
	
		applyDrawingData(data, canvas);
		canvas.g2.drawImage(buffer, -bufferOriginX, -bufferOriginY);

		offsetX = -offsetX;
		offsetY = -offsetY;
		
		position.moveOrigin(offsetX, offsetY);
		scale.moveOrigin(offsetX, offsetY);
		skew.moveOrigin(offsetX, offsetY);
		rotation.movePivot(offsetX, offsetY);
	}
	
	public function isVisible():Bool {
		return visible && scale.x != 0 && scale.y != 0 && opacity > 0;
	}
	
	public function addShader(shader:Shader):Void {
		_shaders.push(shader);
		if (shader.size > _shaderSize) _shaderSize = shader.size;
	}
	
	public inline function addShaders(shaders:Array<Shader>):Void {
		for (shader in shaders) addShader(shader);
	}
	
	public function removeShader(shader:Shader):Shader {
		var index = _shaders.indexOf(shader);
		if (index < 0) return null;
		
		_shaders.splice(index, 1);
		
		if (shader.size == _shaderSize) {
			var maxSize:UInt = 0;
			
			for (s in _shaders) {
				if (s.size == shader.size) return shader;
				if (s.size > maxSize) maxSize = s.size;
			}
			
			_shaderSize = maxSize;
		}
		
		return shader;
	}
	
	public inline function setPos(x:FastFloat, y:FastFloat, ?originX:FastFloat, ?originY:FastFloat):Object {
		position.set(x, y, originX == null ? width / 2 : originX, originY == null ? height / 2 : originY);
		return this;
	}
	
	public inline function setXY(x:FastFloat, y:FastFloat):Object {
		position.setXY(x, y);
		return this;
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
	
	public function getDrawingMatrix():FastMatrix3 {
		var group:IGroup = cast _crGroup;
		
		while (true) {
			if (group == null) {
				return getMatrix();
			} else if (!group.transformEnable) {
				return group.getDrawingMatrix().multmat(getMatrix());
			}
			
			group = cast group._crGroup;
		}
	}
	
	public inline function kill():Void {
		alive = false;
	}
	
	public inline function revive():Void {
		alive = true;
	}
	
	public inline function put():Void {
		pool.put(this);
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
		if (!firstFrameExecuted) {
			for (callback in onFirstFrame) callback.cbFunction(this);
			firstFrameExecuted = true;
		}
	}
	
	inline function callUpdate(?caller:Object, delta:Int):Void {
		_crGroup = caller;
		
		execFirstFrame();
		
		var updatePrevented = false;
		for (callback in onPreUpdate) if (callback.cbFunction(this, delta)) updatePrevented = true;
		
		if (!updatePrevented) update(delta);
		
		for (callback in onPostUpdate) callback.cbFunction(this, delta);
	}
	
	function callDraw(?caller:Object, data:DrawingData, canvas:Canvas):Void {
		_crGroup = caller;
		
		execFirstFrame();
		
		if (_shaders.length > 0) {
			canvas.g2.end();
			
			refreshTexture();
			
			var temp:Image;
			
			for (shader in _shaders) {
				buffer.g2.begin();
				buffer.g2.pipeline = shader.pipeline;
				shader.update(_texture, buffer);
				buffer.g2.drawImage(_texture, 0, 0);
				buffer.g2.end();
				
				temp = _texture;
				_texture = buffer;
				buffer = temp;
			}
			
			canvas.g2.begin(false);
		}

		var drawPrevented = false;
		for (callback in onPreDraw) if (callback.cbFunction(this, data, canvas)) drawPrevented = true;
		
		if (!drawPrevented) {
			if (_shaders.length > 0) drawBuffer(data, canvas);
			else draw(data, canvas);
		}
		
		for (callback in onPostDraw) callback.cbFunction(this, data, canvas);
	}
	
	function applyDrawingData(data:DrawingData, canvas:Canvas):Void {
		var g2 = canvas.g2;
		
		if (antialiasing || data.antialiasing) {
			if (g2.imageScaleQuality != ImageScaleQuality.High) {
				g2.imageScaleQuality = ImageScaleQuality.High;
			}
		} else if (g2.imageScaleQuality != ImageScaleQuality.Low) {
			g2.imageScaleQuality = ImageScaleQuality.Low;
		}
	
		if (data.transformation == null) g2.transformation = _cachedDrawingMatrix = getMatrix();
		else g2.transformation = _cachedDrawingMatrix = data.transformation.multmat(getMatrix());
		
		if (data.color == null) {
			g2.color = color;
		} else {
			g2.color = Color.getBlendColor(color, data.color, data.colorBlendMode, data.colorAlphaBlendMode);
		}
		
		g2.opacity = opacity * data.opacity;
	}
	
	function unloadGraphics():Void {
		if (_texture != null) {
			_texture.unload();
			buffer.unload();
			_texture = null;
			buffer = null;
		}
	}

	function refreshTexture():Void {
		var w = Std.int(width + _shaderSize);
		var h = Std.int(height + _shaderSize);
		
		if (_texture == null) {
			_texture = Image.createRenderTarget(w, h);
			buffer = Image.createRenderTarget(w, h);
		} else {
			if (_texture.width != _texture.width || _texture.height != _texture.height) {
				_texture.unload();
				buffer.unload();
				
				_texture = Image.createRenderTarget(w, h);
				buffer = Image.createRenderTarget(w, h);
			}
		}
		
		var tempPos = position.clone();
		var tempScale = scale.clone();
		var tempSkew = skew.clone();
		var tempRot = rotation.clone();
		var tempColor = color;
		var tempOpacity = opacity;
		
		position.set(bufferOriginX, bufferOriginY);
		scale.setXY(1, 1);
		skew.setXY();
		rotation.angle = 0;
		color = Color.WHITE;
		opacity = 1;
	
		_texture.g2.begin();
		draw(new DrawingData(), _texture);
		_texture.g2.end();
		
		position = tempPos;
		scale = tempScale;
		skew = tempSkew;
		rotation = tempRot;
		color = tempColor;
		opacity = tempOpacity;
	}
		
	function get_width():FastFloat {
		return _width;
	}
	
	function set_width(value:FastFloat):FastFloat {
		return _width;
	}
	
	function get_height():FastFloat {
		return _height;
	}
	
	function set_height(value:FastFloat):FastFloat {
		return _height;
	}
	
	function get_tWidth():FastFloat {
		return Math.abs(width * scale.x) + Math.abs(height * scale.y * Math.tan(skew.x * Angle.CONST_RAD));
	}
	
	function get_tHeight():FastFloat {
		return Math.abs(height * scale.y) + Math.abs(width  * scale.x  * Math.tan(skew.y * Angle.CONST_RAD));
	}
	
	function get_group():GenericGroup {
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