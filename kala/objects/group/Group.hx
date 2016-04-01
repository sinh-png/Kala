package kala.objects.group;

import kala.DrawingData;
import kala.objects.Object;
import kala.math.Color;
import kala.math.Color.ColorBlendMode;
import kha.Canvas;
import kha.FastFloat;
import kha.Image;
import kha.graphics2.ImageScaleQuality;
import kha.math.FastMatrix3;

typedef BasicGroup = Group<Object>;

class Group<T:Object> extends Object {
	
	public var transformEnable:Bool;
	
	public var colorBlendMode:ColorBlendMode;

	private var _children:Array<T> = new Array<T>();
	private var _views:Array<View> = new Array<View>();
	
	public function new(transformEnable:Bool = false) {
		super();
		this.transformEnable = transformEnable;
	}
	
	override public function reset(componentsReset:Bool = false):Void {
		super.reset(componentsReset);
		color.set(0);
		colorBlendMode = ColorBlendMode.NORMAL;
	}
	
	override public function destroy(componentsDestroy:Bool = true):Void {
		super.destroy(componentsDestroy);
		
		while (_children.length > 0 ) _children.pop();
		_children = null;
		
		while (_views.length > 0) _views.pop();
		_views = null;
	}
	
	override public function update(delta:FastFloat):Void {
		var removedIndices = new Array<Int>();
		var child:T;

		for (index in 0..._children.length) {
			child = _children[index];

			if (child == null) {
				removedIndices.push(index);
				continue;
			}
			
			if (child.alive && child.active) child.callUpdate(this, delta);
		}
		
		for (index in removedIndices) {
			_children.splice(index, 1);
		}
		
		removedIndices = new Array<Int>();
		var view:View;
		
		for (index in 0..._views.length) {
			view = _views[index];
			
			if (view == null) {
				removedIndices.push(index);
				continue;
			}

			if (view.alive && view.active) view.callUpdate(this, delta);
		}
		
		for (index in removedIndices) {
			_views.splice(index, 1);
		}
	}
	
	override public function draw(data:DrawingData, canvas:Canvas):Void {
		var g2 = canvas.g2;
		
		if (transformEnable) {
			data.antialiasing = this.antialiasing || data.antialiasing;
			
			if (data.transformation == null) data.transformation = _drawingMatrixCache = getMatrix();
			else data.transformation = _drawingMatrixCache = data.transformation.multmat(getMatrix());
		
			if (data.color == null) {
				data.color = this.color;
			} else {
				data.color = Color.blendColors(this.color, data.color, data.colorBlendMode);
			}
			
			g2.opacity = this.opacity * data.opacity;
		}
		
		if (_views.length == 0) {
			for (child in _children) {
				if (child == null) continue;
				
				if (child.alive && child.isVisible()) {
					var drawingData = new DrawingData(
						data.antialiasing,
						data.transformation,
						data.color, this.colorBlendMode,
						data.opacity
					);
					child.callDraw(this, drawingData, canvas);
				}
			}
		} else {
			g2.end();
			
			var buffer:Image;
			var matrix:FastMatrix3;

			for (view in _views) {
				if (view == null) continue;
				
				buffer = view.buffer;
				matrix = data.transformation.multmat(
					FastMatrix3.translation( -view.viewPos.x + view.viewPos.ox, -view.viewPos.y + view.viewPos.oy)
				);
				
				buffer.g2.begin(true, view.transparent ? 0 : (255 << 24 | view.bgColor));
				for (child in _children) {
					if (child == null) continue;
					
					if (child.alive && child.isVisible()) {
						var drawingData = new DrawingData(
							data.antialiasing,
							matrix,
							data.color, this.colorBlendMode,
							data.opacity
						);
						child.callDraw(this, drawingData, buffer);
					}
				}
				buffer.g2.end();
			}
			
			g2.begin(false);
			
			for (view in _views) {
				if (view == null) continue;
				
				if (view.alive && view.isVisible()) {
					var drawingData = new DrawingData(
						data.antialiasing,
						data.transformation,
						data.color, this.colorBlendMode,
						data.opacity
					);
					view.callDraw(this, drawingData, canvas);
				}
			}
		}
	}
	
	public inline function getChildren():Array<T> {
		return _children.copy();
	}
	
	public function add(obj:T):T {
		if (_children.indexOf(obj) != -1) return null;
		_children.push(obj);
		obj._groups.push(this);
		return obj;
	}
	
	public function remove(obj:T, splice:Bool = false):T {
		var index = _children.indexOf(obj);
		
		if (index == -1) return null;
		
		if (splice) _children.splice(index, 1);
		else _children[index] = null;

		obj._groups.remove(this);
		
		return obj;
	}
	
	public inline function addView(view:View):View {
		if (_views.indexOf(view) != -1) return null;
		_views.push(view);
		view._groups.push(this);
		return view;
	}
	
	public inline function removeView(view:View, splice:Bool = false):View {
		var index = _views.indexOf(view);
		
		if (index == -1) return null;
		
		if (splice) _views.splice(index, 1);
		else _views[index] = null;
		
		view._groups.remove(this);
		
		return view;
	}
	
	public inline function iterator():Iterator<T> {
		return _children.iterator();
	}
	
}