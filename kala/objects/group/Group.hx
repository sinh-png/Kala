package kala.objects.group;

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
	
	public var colorBlendMode:ColorBlendMode = ColorBlendMode.NORMAL;
	
	public var transformEnable:Bool;
	
	public var views(default, null):Array<View> = new Array<View>();
	
	private var _children(default, null):Array<T> = new Array<T>();
	
	public inline function iterator():Iterator<T> {
		return _children.iterator();
	}
	
	public function new(transformEnable:Bool = false) {
		super();
		this.transformEnable = transformEnable;
		color.set(0);
	}
	
	override public function destroy(componentsDestroy:Bool = true):Void {
		super.destroy(componentsDestroy);
		
		while (_children.length > 0 ) _children.pop();
		_children = null;
		
		while (views.length > 0) views.pop();
		views = null;
	}
	
	override public function reset(componentsReset:Bool = true):Void {
		super.reset(componentsReset);
		color.set(0);
		colorBlendMode = ColorBlendMode.NORMAL;
	}
	
	override public function update(delta:FastFloat):Void {
		var removedIndices = new Array<Int>();
		var child:T;
		var index = 0;
		
		for (index in 0..._children.length) {
			child = _children[index];
			
			if (child == null) {
				removedIndices.push(index);
				continue;
			}
			
			child.callUpdate(this, delta);
		}
		
		for (index in removedIndices) {
			_children.splice(index, 1);
		}
	}
	
	override public function draw(
		?antialiasing:Bool = false,
		?transformation:FastMatrix3, ?color:Color, 
		?colorBlendMode:ColorBlendMode, 
		?opacity:FastFloat = 1, 
		canvas:Canvas
	):Void {
		var g2 = canvas.g2;
		
		if (transformEnable) {
			antialiasing = this.antialiasing || antialiasing;
			
			if (transformation == null) transformation = getMatrix();
			else transformation = transformation.multmat(getMatrix());
		
			if (color == null) {
				color = this.color;
			} else {
				color = Color.blendColors(this.color, color, colorBlendMode);
			}
			
			g2.opacity = this.opacity * opacity;
		}
		
		if (views.length == 0) {
			for (child in _children) {
				if (child.isVisible()) {
					child.callDraw(this, antialiasing, transformation, color, this.colorBlendMode, opacity, canvas);
				}
			}
		} else {
			
			g2.end();
			
			var buffer:Image;
			var matrix:FastMatrix3;

			for (view in views) {
				buffer = view.buffer;
				matrix = transformation.multmat(
					FastMatrix3.translation( -view.viewPos.x, -view.viewPos.y)
				);
				
				buffer.g2.begin(true, view.transparent ? 0 : (255 << 24 | view.bgColor));
				for (child in _children) {
					child.callDraw(this, antialiasing, matrix, color, this.colorBlendMode, opacity, buffer);
				}
				buffer.g2.end();
			}
			
			g2.begin(false);
			
			for (view in views) {
				view.callDraw(this, antialiasing, transformation, color, this.colorBlendMode, opacity, canvas);
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
	
	public inline function addView(view:View):Void {
		if (views.indexOf(view) == -1) {
			views.push(view);
			view._groups.push(this);
		}
	}
	
	public inline function removeView(view:View):Void {
		views.remove(view);
		view._groups.remove(this);
	}
	
}