package kala.objects.group;

import kala.DrawingData;
import kala.math.color.BlendMode;
import kala.objects.group.View;
import kala.objects.Object;
import kala.math.color.Color;
import kha.Canvas;
import kha.FastFloat;
import kha.Image;
import kha.graphics2.ImageScaleQuality;
import kha.math.FastMatrix3;

typedef GenericGroup = Group<Object>;

interface IGroup extends IObject {
	
	public var transformEnable:Bool;
	
	public var colorBlendMode:BlendMode;
	public var colorAlphaBlendMode:BlendMode;
	
	public var timeScale:FastFloat;
	
	private var _views:Array<View>;
	
	public function addView(view:View, pos:Int = -1):Void;
	public function removeView(view:View, splice:Bool = false):View;
	
	private function _add(obj:Object, pos:Int = -1):Void;
	private function _remove(obj:Object, spilce:Bool = false):Void;
}

@:access(kala.math.color.Color)
class Group<T:Object> extends Object implements IGroup {
	
	public var transformEnable:Bool;
	
	public var colorBlendMode:BlendMode;
	public var colorAlphaBlendMode:BlendMode;
	
	private var _children:Array<T> = new Array<T>();
	private var _views:Array<View> = new Array<View>();
	
	public function new(transformEnable:Bool = false) {
		super();
		this.transformEnable = transformEnable;
	}
	
	override public function reset(componentsReset:Bool = false):Void {
		super.reset(componentsReset);
		color = Color.WHITE;
		colorBlendMode = BlendMode.MULTI_2X;
		colorAlphaBlendMode = null;
	}
	
	override public function destroy(destroyComponents:Bool = true):Void {
		super.destroy(destroyComponents);
		
		while (_children.length > 0) _children.pop().destroy(destroyComponents);
		while (_views.length > 0) _views.pop().destroy(destroyComponents);
		
		_children = null;
		_views = null;
	}
	
	override public function update(elapsed:FastFloat):Void {
		var i = 0;
		var child:T;
		while (i < _children.length) {
			child = _children[i];

			if (child == null) {
				_children.splice(i, 1);
				continue;
			}
			
			if (child.alive && child.active) child.callUpdate(this, elapsed);
			
			i++;
		}
		
		i = 0;
		var view:View;
		while (i < _views.length) {
			view = _views[i];
			
			if (view == null) {
				_views.splice(i, 1);
				continue;
			}

			if (view.alive && view.active) view.callUpdate(this, elapsed);

			i++;
		}
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		var g2 = canvas.g2;
		
		if (transformEnable) {
			if (data.transformation == null) data.transformation = _cachedDrawingMatrix = getMatrix();
			else data.transformation = _cachedDrawingMatrix = data.transformation.multmat(getMatrix());
		
			if (data.color == null) {
				data.color = color;
			} else {
				data.color = Color.getBlendColor(color, data.color, data.colorBlendMode, data.colorAlphaBlendMode);
			}
			
			g2.opacity = this.opacity * data.opacity;
		}
		
		if (antialiasing) data.antialiasing = true;
		
		var drawingData = new DrawingData(
			data.antialiasing,
			data.transformation,
			data.color, colorBlendMode, colorAlphaBlendMode,
			data.opacity
		);
		
		if (_views.length == 0) {
			for (child in _children) {
				if (child == null) continue;
				
				if (child.alive && child.isVisible()) {
					child.callDraw(this, drawingData, canvas);
				}
			}
		} else {
			g2.end();
			
			var viewBuffer:Image;
			var matrix:FastMatrix3;
			
			for (view in _views) {
				if (view == null) continue;
				
				viewBuffer = view.viewBuffer;
				
				if (data.transformation == null) {
					drawingData.transformation = FastMatrix3.translation(
						-view.viewport.x,
						-view.viewport.y
					);
				} else {
					drawingData.transformation = data.transformation.multmat(
						FastMatrix3.translation( -view.viewport.x, -view.viewport.y)
					);
				}

				viewBuffer.g2.begin(true, view.transparent ? 0 : (255 << 24 | view.bgColor));
				for (child in _children) {
					if (child == null) continue;
					
					if (child.alive && child.isVisible()) {
						child.callDraw(this, drawingData, viewBuffer);
					}
				}
				viewBuffer.g2.end();
			}
			
			g2.begin(false);
			
			drawingData.transformation = data.transformation;
			
			for (view in _views) {
				if (view == null) continue;
				
				if (view.alive && view.isVisible()) {
					view.callDraw(this, drawingData, canvas);
				}
			}
		}
	}
	
	public inline function getChildren():Array<T> {
		return _children.copy();
	}
	
	public function add(obj:T, pos:Int = -1):Void {
		if (_children.indexOf(obj) != -1) return null;
		
		if (pos == -1) _children.push(obj);
		else _children.insert(pos, obj);
		
		obj._groups.push(this);
	}
	
	public function swap(swappedObj:T, obj:T):Bool {
		var index = _children.indexOf(swappedObj);
		
		if (index == -1) return false;
		
		_children[index] = obj;
		obj._groups.push(this);
		
		swappedObj._groups.remove(this);
		if (swappedObj.group == this) swappedObj.group = null;
		
		swappedObj.firstFrameExecuted = false;
		
		return true;
	}
	
	public function remove(obj:T, splice:Bool = false):T {
		var index = _children.indexOf(obj);
		
		if (index == -1) return null;
		
		if (splice) _children.splice(index, 1);
		else _children[index] = null;

		obj._groups.remove(this);
		if (obj.group == this) obj.group = null;
		
		obj.firstFrameExecuted = false;
		
		return obj;
	}
	
	public function addView(view:View, pos:Int = -1):Void {
		if (_views.indexOf(view) != -1) return null;
		
		if (pos == -1) _views.push(view);
		else _views.insert(pos, view);
		
		view._groups.push(this);
	}
	
	public function removeView(view:View, splice:Bool = false):View {
		var index = _views.indexOf(view);
		
		if (index == -1) return null;
		
		if (splice) _views.splice(index, 1);
		else _views[index] = null;
		
		view._groups.remove(this);
		if (view.group == this) view.group = null;
		
		view.firstFrameExecuted = false;
		
		return view;
	}
	
	function _add(obj:Object, pos:Int = -1):Void {
		add(cast obj, pos);
	}
	
	function _remove(obj:Object, spilce:Bool = false):Void {
		remove(cast obj, spilce);
	}
	
	public inline function iterator():Iterator<T> {
		return _children.iterator();
	}
	
}