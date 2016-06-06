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

	public var lineStrenght:UInt;
	public var lineColor:Color;
	public var lineOpacity:FastFloat;

	public var fillColor:Color;
	public var fillOpacity:FastFloat;
	
	/**
	 * DEFAULT: MULTI_2X
	 */
	public var colorBlendMode:BlendMode;
	public var colorAlphaBlendMode:BlendMode;
	
	//
	
	private var _color:Color;
	private var _opacity:FastFloat;
	private var _canvas:Canvas;
	
	public function new(fill:Bool = true, outline:Bool = false) {
		super();
		
		if (fill) fillOpacity = 1; else fillOpacity = 0;
		if (outline) lineOpacity = 1; else lineOpacity = 0;
	}
	
	override public function reset(resetBehaviors:Bool = false):Void {
		super.reset(resetBehaviors);
	
		color = Color.WHITE;
		
		lineStrenght = 1;
		lineColor = Color.WHITE;
		fillColor = Color.WHITE;
		
		colorBlendMode = BlendMode.MULTI_2X;
		colorAlphaBlendMode = null;
	}
	
	override public function destroy(destroyBehaviors:Bool = true):Void {
		super.destroy(destroyBehaviors);
		_canvas = null;
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