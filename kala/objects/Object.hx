package kala.objects;

import kala.behaviors.Behavior;
import kala.DrawingData;
import kala.EventHandle;
import kala.behaviors.Behavior.IBehavior;
import kala.graphics.Shader;
import kala.math.Collision;
import kala.math.Angle;
import kala.math.color.Color;
import kala.math.Matrix;
import kala.math.Position;
import kala.math.Rect;
import kala.math.Rotation;
import kala.math.Vec2T;
import kala.math.Vec2;
import kala.objects.group.Group;
import kha.Canvas;
import kha.FastFloat;
import kha.graphics2.ImageScaleQuality;
import kha.Image;

interface IObject {
	
	public var alive:Bool;
	public var active:Bool;
	public var visible:Bool;
	
	//
	
	public var x(get, set):FastFloat;
	public var y(get, set):FastFloat;
	
	public var angle(get, set):FastFloat;
	
	public var position:Position;
	
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
	
	public var group(default, null):IGroup;
	public var groups(get, never):Array<IGroup>;
	private var _groups:Array<IGroup>;
	
	//
	
	public var data:Dynamic;
	
	public var timeScale:FastFloat;
	
	//
	
	public var onDestroy(default, null):CallbackHandle<Object->Bool->Void>;
	public var onReset(default, null):CallbackHandle<Object->Bool->Void>;
	
	public var onPreUpdate(default, null):CallbackHandle<Object->FastFloat->Bool>;
	public var onPostUpdate(default, null):CallbackHandle<Object->FastFloat->Void>;
	
	public var onPreDraw(default, null):CallbackHandle<Object->DrawingData->Canvas->Bool>;
	public var onPostDraw(default, null):CallbackHandle<Object->DrawingData->Canvas->Void>;
	
	public var onFirstFrame(default, null):CallbackHandle<Object->Void>;
		
	public var firstFrameExecuted:Bool;
	
	//
	
	private var _behaviors:Array<IBehavior>;
	
	//
	
	private var _texture:Image;
	private var _shaderSize:UInt;

	private var _shaders:Array<Shader>;
	
	//
	
	private var _cachedDrawingMatrix:Matrix;
	
	//
	
	public function reset(resetBehaviors:Bool = false):Void;
	public function destroy(destroyBehaviors:Bool = true):Void;
	public function deepReset(deepResetBehaviors:Bool = true):Void;
	public function update(elapsed:FastFloat):Void;
	public function draw(data:DrawingData, canvas:Canvas):Void;
	public function drawBuffer(data:DrawingData, canvas:Canvas):Void;
	public function isVisible():Bool;
	public function addShader(shader:Shader):Void;
	public function removeShader(shader:Shader):Shader;
	public function getDrawingMatrix():Matrix;
	
}


@:allow(kala.Kala)
@:allow(kala.behaviors.Behavior)
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
	/**
	 * Shortcut to rotation.angle
	 */
	public var angle(get, set):FastFloat;
	
	public var position:Position = new Position();
	
	/**
	 * Horizontal flip this object at its center.
	 */
	public var flipX:Bool;
	/**
	 * Vertically flip this object at its center.
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
	
	/**
	 * The current group updating or rendering this object.
	 */
	public var group(default, null):IGroup;
	public var groups(get, never):Array<IGroup>;
	var _groups:Array<IGroup> = new Array<IGroup>();
	
	//
	
	public var data:Dynamic;
	
	/**
	 * Scale factor to calculate elapsed time. This affects all built-in timing processes of objects and behaviors. 
	 */
	public var timeScale:FastFloat;
	
	//
	
	public var onDestroy(default, null):CallbackHandle<Object->Bool->Void>;
	public var onReset(default, null):CallbackHandle<Object->Bool->Void>;
	
	public var onPreUpdate(default, null):CallbackHandle<Object->FastFloat->Bool>;
	public var onPostUpdate(default, null):CallbackHandle<Object->FastFloat->Void>;
	
	public var onPreDraw(default, null):CallbackHandle<Object->DrawingData->Canvas->Bool>;
	public var onPostDraw(default, null):CallbackHandle<Object->DrawingData->Canvas->Void>;
	
	public var onFirstFrame(default, null):CallbackHandle<Object->Void>;
		
	public var firstFrameExecuted:Bool;
	
	//
	
	private var _behaviors:Array<IBehavior> = new Array<IBehavior>();
	
	//
	
	private var _texture:Image;
	private var _shaderSize:UInt;

	private var _shaders:Array<Shader> = new Array<Shader>();
	
	//
	
	private var _cachedDrawingMatrix:Matrix;

	public function new() {
		super();
		
		onDestroy = addCBHandle(new CallbackHandle<Object->Bool->Void>());
		onReset = addCBHandle(new CallbackHandle<Object->Bool->Void>());
		
		onPreUpdate = addCBHandle(new CallbackHandle<Object->FastFloat->Bool>());
		onPostUpdate = addCBHandle(new CallbackHandle<Object->FastFloat->Void>());
		
		onPreDraw = addCBHandle(new CallbackHandle<Object->DrawingData->Canvas->Bool>());
		onPostDraw = addCBHandle(new CallbackHandle<Object->DrawingData->Canvas->Void>());
		
		onFirstFrame = addCBHandle(new CallbackHandle<Object->Void>());
		
		reset();
	}
	
	override public function clearCBHandles():Void {
		removeBehaviors();
		super.clearCBHandles();
	}
	
	/**
	 * Reset properties to their values when this object was created. 
	 * This won't remove the object from its groups.
	 * This won't remove added callbacks and behaviors.
	 * 
	 * @param	resetBehaviors		If true will also reset behaviors. 
	 */
	public function reset(resetBehaviors:Bool = false):Void {
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
		
		data = null;
		
		timeScale = 1;
		
		for (callback in onReset) callback.cbFunction(this, resetBehaviors);

		if (resetBehaviors) this.resetBehaviors();
	}
	
	public function destroy(destroyBehaviors:Bool = true):Void {
		for (callback in onDestroy) callback.cbFunction(this, destroyBehaviors);
		
		//
		
		position = null;
		scale = null;
		skew = null;
		rotation = null;
		
		//
		
		unloadGraphics();
		_shaders = null;

		//
		
		if (destroyBehaviors) this.destroyBehaviors();
		_behaviors = null;
		
		//
		
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
		group = null;
		_groups = null;
		
		//
		
		data = null;
		
		_cachedDrawingMatrix = null;
	}
	
	public function deepReset(deepResetBehaviors:Bool = true):Void {
		reset(false);
		if (deepResetBehaviors) this.deepResetBehaviors();
		clearCBHandles();
		removefromGroups();
	}
	
	public function update(elapsed:FastFloat):Void {

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

	public inline function getMatrix():Matrix {
		var matrix = Matrix.getTransformation(position, scale, skew, rotation);
		
		if (flipX || flipY) {
			return Matrix.flip(
				matrix, flipX, flipY,
				position.x - position.ox + width / 2, position.y - position.oy + height / 2
			);
		}
		
		return matrix;
	}
	
	public function getDrawingMatrix():Matrix {
		var group = this.group;
		
		while (true) {
			if (group == null) {
				return getMatrix();
			} else if (!group.transformationEnable) {
				return group.getDrawingMatrix().multmat(getMatrix());
			}
			
			group = cast group.group;
		}
	}
	
	public function kill():Void {
		alive = false;
	}
	
	public function revive():Void {
		alive = true;
	}
	
	public inline function removefromGroups(splice:Bool = false):Void {
		for (group in _groups) group._remove(this, splice);
	}
	
	public inline function getBehaviors():Array<IBehavior> {
		return _behaviors.copy();
	}
	
	public inline function removeBehaviors():Void {
		for (behavior in _behaviors) behavior.remove();
	}
	
	public inline function destroyBehaviors():Void {
		while (_behaviors.length > 0) {
			_behaviors.pop().destroy();
		}
	}
	
	public inline function resetBehaviors():Void {
		for (behavior in _behaviors) behavior.reset();
	}
	
	public inline function deepResetBehaviors():Void {
		for (behavior in _behaviors) behavior.deepReset();
	}
	
	inline function execFirstFrame():Void {
		if (!firstFrameExecuted) {
			for (callback in onFirstFrame) callback.cbFunction(this);
			firstFrameExecuted = true;
		}
	}
	
	inline function callUpdate(?group:IGroup, elapsed:FastFloat):Void {
		elapsed *= timeScale;
		
		this.group = group;
		
		execFirstFrame();
		
		var updatePrevented = false;
		for (callback in onPreUpdate) if (callback.cbFunction(this, elapsed)) updatePrevented = true;
		
		if (!updatePrevented) update(elapsed);
		
		for (callback in onPostUpdate) callback.cbFunction(this, elapsed);
	}
	
	function callDraw(?group:IGroup, data:DrawingData, canvas:Canvas):Void {
		this.group = group;
		
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
	
	inline function get_tWidth():FastFloat {
		return Math.abs(width * scale.x) + Math.abs(height * scale.y * Math.tan(skew.x * Angle.CONST_RAD));
	}
	
	inline function get_tHeight():FastFloat {
		return Math.abs(height * scale.y) + Math.abs(width  * scale.x  * Math.tan(skew.y * Angle.CONST_RAD));
	}
	
	inline function get_x():FastFloat {
		return position.x;
	}
	
	inline function set_x(value:FastFloat):FastFloat {
		return position.x = value;
	}
	
	inline function get_y():FastFloat {
		return position.y;
	}
	
	inline function set_y(value:FastFloat):FastFloat {
		return position.y = value;
	}

	inline function get_angle():FastFloat {
		return rotation.angle;
	}
	
	inline function set_angle(value:FastFloat):FastFloat {
		return rotation.angle = value;
	}
	
	inline function get_groups():Array<IGroup> {
		return _groups.copy();
	}
	
}