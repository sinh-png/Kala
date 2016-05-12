package kala.objects.shapes;

import kala.DrawingData;
import kala.math.color.BlendMode;
import kala.math.color.Color;
import kala.objects.Object;
import kha.Canvas;
import kha.FastFloat;
import kha.math.FastMatrix3;

@:access(kala.math.color.Color)
class Shape extends Object {

	// To avoid using Std.is().
	public var type(default, null):ShapeType;
	
	public var lineStrenght:UInt;
	public var lineColor:Color = Color.WHITE;
	public var lineOpacity:FastFloat;

	public var fillColor:Color = Color.WHITE;
	public var fillOpacity:FastFloat;
	
	public var colorBlendMode:BlendMode = BlendMode.ADD;
	public var colorAlphaBlendMode:BlendMode = null;
	
	//
	
	private var _color:Color;
	private var _opacity:FastFloat;
	private var _canvas:Canvas;
	
	public function new(fill:Bool = true, outline:Bool = false) {
		super();
		
		if (fill) fillOpacity = 1; else fillOpacity = 0;
		if (outline) lineOpacity = 1; else lineOpacity = 0;
	}
	
	override public function reset(componentsReset:Bool = false):Void {
		super.reset(componentsReset);
	
		color = Color.TRANSPARENT;
		
		lineStrenght = 1;
		lineColor = Color.WHITE;
		
		fillColor = Color.WHITE;

		colorBlendMode = BlendMode.ADD;
	}
	
	override public function destroy(componentsDestroy:Bool = true):Void {
		super.destroy(componentsDestroy);
	}
	
	override public function isVisible():Bool {
		return super.isVisible() && (fillOpacity > 0 || lineOpacity > 0);
	}
	
	override function applyDrawingData(data:DrawingData, canvas:Canvas):Void {
		super.applyDrawingData(data, canvas);
		
		_color = canvas.g2.color;
		_opacity = canvas.g2.opacity;
	
		_canvas = canvas;
		
	}
	
	inline function applyFillDrawingData():Void {
		_canvas.g2.color = Color.getBlendColor(fillColor, _color, colorBlendMode, colorAlphaBlendMode);
		_canvas.g2.opacity = _opacity * fillOpacity;
	}
	
	inline function applyLineDrawingData():Void {
		_canvas.g2.color = Color.getBlendColor(lineColor, _color, colorBlendMode, colorAlphaBlendMode);
		_canvas.g2.opacity = _opacity * lineOpacity;
	}
	
}

enum ShapeType {
	CIRCLE;
	RECTANGLE;
	POLYGON;
}