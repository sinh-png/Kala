package kala.objects.shapes;

import kala.DrawingData;
import kala.math.Color;
import kala.objects.Object;
import kha.Canvas;
import kha.FastFloat;
import kha.math.FastMatrix3;

class Shape extends Object {

	// To avoid using Std.is().
	public var type(default, null):ShapeType;
	
	public var lineStrenght:UInt;
	public var lineColor:Color = new Color();
	public var lineOpacity:FastFloat;

	public var fillColor:Color = new Color();
	public var fillOpacity:FastFloat;
	
	public var colorBlendMode:ColorBlendMode;
	
	//
	
	private var _color:Color;
	private var _opacity:FastFloat;
	private var _canvas:Canvas;
	
	override public function reset(componentsReset:Bool = false):Void {
		super.reset(componentsReset);
	
		color.set(0);
		
		lineStrenght = 1;
		lineColor.set();
		lineOpacity = 0;
		
		fillColor.set();
		fillOpacity = 1;
		
		colorBlendMode = ColorBlendMode.NORMAL;
	}
	
	override public function destroy(componentsDestroy:Bool = true):Void {
		super.destroy(componentsDestroy);
		lineColor = fillColor = null;
	}
	
	override function applyDrawingData(data:DrawingData, canvas:Canvas):Void {
		super.applyDrawingData(data, canvas);
		
		if (color == null) {
			_color = this.color;
		} else {
			_color = Color.blendColors(this.color, color, colorBlendMode);
		}
				
		_opacity = canvas.g2.opacity;
	
		_canvas = canvas;
		
	}
	
	inline function applyDrawingFillData():Void {
		_canvas.g2.color = new Color().setOverlay(Color.blendColors(fillColor, _color, this.colorBlendMode)).argb();
		_canvas.g2.opacity = _opacity * fillOpacity;
	}
	
	inline function applyDrawingLineData():Void {
		_canvas.g2.color = new Color().setOverlay(Color.blendColors(lineColor, _color, this.colorBlendMode)).argb();
		_canvas.g2.opacity = _opacity * lineOpacity;
	}
	
}

enum ShapeType {
	CIRCLE;
	RECTANGLE;
	POLYGON;
}